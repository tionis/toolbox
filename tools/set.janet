(import tools/set/native :as _set)

(defn intersection [set1 set2]
  (def new-set (_set/new))
  (each element set1
    (if (set2 element)
      (_set/add new-set element)))
  new-set)

(import tools/set/native :prefix "" :export true)
