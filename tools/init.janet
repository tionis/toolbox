(defn clean
  `Walk datastructure and only collects elements that are encodable in JDN.
  Returns a new cleaned datastructure`
  [ds]
  (case (type ds)
    :number ds
    :array (walk clean ds)
    :tuple (walk clean ds)
    :table (walk clean ds)
    :struct (walk clean ds)
    :string ds
    :buffer ds
    :symbol ds
    :keyword ds))
