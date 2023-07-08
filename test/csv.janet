(import ../toolbox/csv :as csv)
(use spork/test)

(start-suite "csv-clean")
(def sample
 ``"new ""doublyquoted word""","double ""doublequote"""``)

(let [results (csv/parse sample)]
  (each row results
    (each field row
      (assert (not (string/find "\"\"" field))
              "fields contains double doublequotes"))))

(end-suite)

(start-suite "csv-empy-field")
(def sample
``h1,h2,h3
,val2,
,,val3``)

(let [results (csv/parse
                sample
                true)]
  #(pp results)
  (assert (= 2 (length results))
          "results length not valid")
  (loop [row :in results]
    (assert (= 3 (length row))
            "resulting row is not valid")))
(end-suite)

(start-suite "csv-escaped")
(def sample
``"new
lines","single
row"``)

(let [results (csv/parse
                sample)]
  (assert (= 1 (length results))
          "results length not valid"))

(def sample2
``"embedded ""quotes""","embedded ""quotes""","embedded ""quotes"""
"embedded ""commas,""","embedded ""commas,""","embedded ""commas,"""``)

(let [results (csv/parse sample2)]
  (assert (= 3 (length (first results)))
          "error while parsing double quotes")
  (assert (= 3 (length (1 results)))
          "error while parsing embedded commas"))
(end-suite)

(start-suite "csv-headers")
(def sample
``h1,h2
val1,val2
val3,val4``)

(let [results (csv/parse
                sample
                true)]
  (assert (= 2 (length results))
          "results length not valid")
  (assert (= "val1" ((first results) :h1))
          "invalid header results"))
(end-suite)
