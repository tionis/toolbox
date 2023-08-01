(def grammar
  (peg/compile
    ~{:main (+ :string :error :number :array :bulk)
      :bulk (replace
              (* "$"
                 (number (to "\r\n") nil :length) "\r\n"
                 (capture (lenprefix (backref :length) 1)))
              ,(fn [num cap]
                 (if (= num -1)
                   nil
                   cap)))
      :string (* "+" (capture (to "\r\n")) "\r\n")
      :error (error (* "-" (capture (to "\r\n")) "\r\n"))
      :number (* "-" (number (to "\r\n")) "\r\n")
      :array (replace
               (* "*"
                  (number (to "\r\n") nil :length) "\r\n"
                  (capture (lenprefix (backref :length) (some :main))))
               ,(fn [num cap]
                  cap))}))

(defn peg-decode [str]
  # TODO fix :array parsing
  (first (peg/match grammar str)))

(defn- buf-ends-in
  [buf end]
  (var i (- (length buf) 1))
  (label res
    (if (< (length buf) (length end)) (return res false))
    (each char (reverse end)
      (if (not= (buf i) char)
        (return res false))
      (-= i 1))
    (return res true)))

(defn- read-to
  `read from conn until encountering end
  returns a buffer with captured content excluding end
  (end is read from conn though)`
  [conn end]
  (def out @"")
  (while (not (buf-ends-in out end))
    (:read conn 1 out))
  (buffer/popn out (length end)))

(defn decode
  `decode one RESP message on conn by calling :read on conn until a valid message is constructed
  RESP errors are thrown as is`
  [conn]
  (def typ (:read conn 1))
  (case (first typ)
    (chr "$") (let [len (scan-number (read-to conn "\r\n"))]
                (if (= len -1)
                  nil
                  (let [out (:read conn len)]
                    (:read conn 2)
                    out)))
    (chr "+") (read-to conn "\r\n")
    (chr ":") (scan-number (read-to conn "\r\n"))
    (chr "-") (error (read-to conn "\r\n"))
    (chr "*") (seq [i :range [0 (scan-number (read-to conn "\r\n"))]]
                (decode conn))
    (error (string/format "unknown type: %j" typ))))

(defn encode [ds]
  (def out @"")
  (case (type ds)
    :boolean (buffer/push out (encode (string ds)))
    :number (buffer/push out ":" (string ds) "\r\n")
    :array (do (buffer/push out "*" (string (length ds)) "\r\n")
               (each el ds
                 (buffer/push out (encode el))))
    :tuple (do (buffer/push out "*" (string (length ds)) "\r\n")
               (each el ds
                 (buffer/push out (encode el))))
    :table (buffer/push out (encode (pairs ds)))
    :struct (buffer/push out (encode (pairs ds)))
    :string (buffer/push out "$" (string (length ds)) "\r\n" ds "\r\n")
    :buffer (buffer/push out "$" (string (length ds)) "\r\n" ds "\r\n")
    :symbol (buffer/push out (encode (string ds)))
    :keyword (buffer/push out (encode (string ds)))
    (error (string/format "unsupported type: %j" (type ds))))
  out)
