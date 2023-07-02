# stolen from https://github.com/sogaiu/janet-xmlish
# https://www.w3.org/TR/xml
(def grammar
  ~{:main (sequence (opt (drop :xml-declaration))
                    (opt (drop :doctype))
                    (any :comment)
                    :element
                    (any :comment))
    #
    :xml-declaration (sequence
                      :s* "<?xml" :s*
                      (any :attribute) :s*
                      "?>" :s*)
    # XXX: only handles very simple case
    :doctype (sequence
               :s* "<!doctype" :s*
               :tag-name :s*
               ">" :s*)
    # XXX: not accurate
    :attribute (sequence
                (capture (to (set " /<=>\""))) :s*
                "=" :s*
                (choice (sequence `"` (capture (to `"`)) `"`)
                        (sequence "'" (capture (to "'")) "'"))
                :s*)
    # section 2.5 of xml spec
    :comment (sequence
              "<!--"
              (any (choice
                    (if-not (set "-") 1)
                    (sequence "-" (if-not (set "-") 1))))
              "-->" :s*)
    #
    :element (choice :empty-element :non-empty-element)
    #
    :empty-element (cmt (sequence
                         "<" (capture :tag-name) :s*
                         (any :attribute)
                         "/>")
                        ,|(let [args $&
                                elt-name (first args)
                                attrs (drop 1 args)
                                attrs (if (= (length attrs) 0)
                                        nil
                                        (table ;attrs))]
                            {:attrs attrs
                             :tag elt-name}))
    # XXX: not accurate
    :tag-name (to (set " /<>"))
    #
    :non-empty-element (cmt (sequence
                             :open-tag
                             (any
                              (choice :comment :element (capture :pcdata)))
                             :close-tag)
                            ,|(let [args $&
                                    open-name (first (first args))
                                    attrs (drop 1 (first args))
                                    close-name (last args)]
                                (when (= open-name close-name)
                                  (let [elt-name open-name
                                        content (filter (fn [c-item]
                                                          (not= "" c-item))
                                                        (tuple/slice args 1 -2))
                                        content (if (= (length content) 0)
                                                  nil
                                                  content)
                                        attrs (if (= (length attrs) 0)
                                                nil
                                                (table ;attrs))]
                                    {:attrs attrs
                                     :content content
                                     :tag elt-name}))))
    #
    :open-tag (group
               (sequence
                "<" (capture :tag-name) :s*
                (any :attribute)
                ">"))
    # XXX: not accurate
    :pcdata (to (set "<>"))
    #
    :close-tag (sequence
                "</" (capture :tag-name) :s* ">")})

(defn parse [str]
  (peg/match grammar str))
