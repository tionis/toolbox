(def- [PATTERN CONTENT CHILDREN] [0 1 2])

(defmacro defp
  ``Create a multi-method. `defp` has the same signature
  as `defn`, but expects the types of the arguments to be specified
  in a table in the metadata under the :args key with the values
  being valid patterns for a spork/schema validator.``
  [name & body]
  (def expansion (apply defn name body))
  (def fbody (last expansion))
  (def modifiers (tuple/slice expansion 2 -2))
  (def metadata @{})
  (each m modifiers
    (cond
      (keyword? m) (put metadata m true)
      (string? m) (put metadata :doc m)
      (error (string "invalid metadata " m))))
  (unless (metadata :args) (error "missing arg table in metadata for multi-method pattern matching"))
  # TODO check if metadata is valid (args are defined and can be parsed into schema)
  # TODO check if ,name is already defined and has the 
  (unless (get (dyn ',name) :multimethod false)
    (defn ',name
      "Multi-method wrapper, child functions:\n" # TODO better docstring
      [& args]
      # TODO apply each func schema
      ))
  # TODO add function to wrapper functions func array
  # TODO extract function metadata
  # TODO update wrapper functions doc-string
  # note that doc-string shouldn's just be appended but regenerated from a table of func dosctrings, so that multimethods can be changed/overwritten later
  (fn ,f ,fbody)
  (get-in (dyn ',name) [:submethods ',name]))
