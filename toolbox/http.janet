(import spork/json)
(import spork/sh)

(defn get/json
  [url]
  (json/decode (sh/exec-slurp "curl" "-s" url) true))
