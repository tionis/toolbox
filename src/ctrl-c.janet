(import toolbox/ctrl-c/native :prefix "" :export true)

(defn await
  [stream]
  (truthy? (ev/read stream 128)))
