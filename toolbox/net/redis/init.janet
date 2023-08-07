(import ./parser)

(def- conn-proto
  @{:command (fn [x args &opt timeout]
               (:write (x :in) (parser/encode args) timeout)
               (parser/decode (x :out) timeout))
    :pipeline (fn [x commands &opt timeout]
                (each command commands (:write (x :in) (parser/encode command) timeout))
                (def result (array/new (length commands)))
                (repeat (length commands)
                  (array/push result (parser/decode (x :out) timeout)))
                result)
    :get-reply (fn [x &opt timeout] (parser/decode (x :out) timeout))})

(defn new-tcp
  "create a new connection over tcp"
  [&opt host port]
  (default host "127.0.0.1")
  (default port 6379)
  (def conn @{})
  (table/setproto conn conn-proto)
  (def net-conn (net/connect host port))
  (put conn :in net-conn)
  (put conn :out net-conn)
  (put conn :close
       (fn [x] (net/close (x :in))))
  conn)

(defn new-exec
  "create a new connection by executing the arguments and using stdin stdout as communication streams"
  [& args]
  (def conn @{})
  (table/setproto conn conn-proto)
  (def proc (os/spawn args :px {:in :pipe :out :pipe}))
  (put conn :in (proc :in))
  (put conn :out (proc :out))
  (put conn :proc proc)
  (put conn :close
       (fn [x]
         (ev/close (x :in))
         (ev/close (x :out))
         (os/proc-kill (x :proc))))
  conn)
