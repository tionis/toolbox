# (defn test "dawdawd" {:args {:test {:required true}}} [one &named test] (def x one) (def two (+ x one)) two)
# (defn test2 "dawdadawdawd" [one])
# (defn test3 "dawdadawdawd" [one &opt two])
# (defn test4 "dawdwad" [&keys {:test test :dadw dawdd}])
#
# (def docstr ((dyn 'test) :doc))
# (def func ((dyn 'test) :value))
#
# (defn parse-docstring [docstr]
#   (def lines (string/split "\n" docstr))
#   {:definition (lines 0) :help (string/join (slice lines 2 -1) "\n")})
#
# (defn get-function-metadata [func]
#   (def meta (disasm func)) # {:arity 1 :bytecode @[(ldc 4 0) (in 3 1 4) (movn 4 3) (add 1 0 0) (movn 3 1) (ret 3)] :constants @[:test] :defs @[] :environments @[] :max-arity 2147483647 :min-arity 1 :name "test" :slotcount 5 :source "/home/tionis/dev/tionis/toolbox/toolbox/shell/cli2.janet" :sourcemap @[(1 1) (1 1) (1 1) (1 94) (1 85) (1 1)] :structarg true :symbolmap @[(0 6 0 one) (2 6 4 test) (2 6 0 x) (4 6 3 two)] :vararg true}
#   # (if (meta :structarg)) --> either :named or :keys
#   {:args {:positional {:required [{:name 'one :description "some message" :type :number}]
#                        :optional []}}
#           :named {:required []
#                   :optional []}
#           :variadic nil
#           :keys {:required []
#                  :optional []}
#           :ignoring-extra-args false}
#
# (parse-docstring ((dyn 'test) :doc))
