(def is-valid-nick?
  [nick]
  (def forbidden-symbols [" " "," "*" "?" "!" "@"])
  (def forbidden-start-symbols ["$" ":" "#" "&"]) # Build this automatically as ["$" ":" ;CHANTYPES]?
  (def unwanted-symbols ["."])
  (error "not implemented")
  # TODO
  )

(def is-valid-channel?
  [name]
  (def forbidden-symbols [" " "\a" ","])
  (error "not implemented")
  # TODO
  )

(def grammar
  (peg/compile
    ~{:main (error "not implemented")
      }))

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
  `decode one IRC message on conn by calling :read on conn until a valid message was built`
  [conn]
  (error "not implemented")
  # TODO decode part by part
  )

(defn encode [ds]
  (error "not implemented")
  # TODO encode here
  out)
