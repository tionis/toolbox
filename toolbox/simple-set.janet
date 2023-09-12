(defn new
  "create new set"
  [list]
  (def x @{})
  (each element list
    (put x element true))
  x)

(defn intersection
  "get the intersetion of two sets"
  [set1 set2]
  (def x (table/clone set1))
  (eachk element set2
    (put x element nil))
  x)
