(defn editor
  "get default editor to use"
  []
  (or (os/getenv "EDITOR")
      "vi"))
