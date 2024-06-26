(use spork/test spork/misc)
(import ../gp/net/server)
(use ../gp/net/ws)
(start-suite "Documentation")
(assert-docs "../gp/net/ws")
(end-suite)
(start-suite "Response")

(assert (= (string (response 0xA "Pong"))
           "\x8A\x04Pong")
        "response")

(assert (= (string (text "Hey")) "\x81\x03Hey")
        "text")

(assert (= (string (binary "Hey")) "\x82\x03Hey")
        "binary")

(end-suite)

(start-suite "supervisor on-connection")
(def c (ev/chan))
(def h @{:connect (fn [s c] (net/write (dyn :conn) (text "Connected")))
         :read (fn [s c m] (net/write (dyn :conn) (text (string "Received: " m))))
         :closed (fn [s])})
(ev/spawn
  (server/start c)
  (supervisor c (on-connection h)))

(ev/sleep 0.001)
(def w (net/connect "localhost" 8888))
(net/write w "Sec-WebSocket-Key: ABCDEF")
(ev/sleep 0.001)
(assert
  (deep= (net/read w 256)
         @"HTTP/1.1 101 Switching Protocols\r\nContent-Length: 0\r\nSec-WebSocket-Accept: Kfh9QIsMVZcl6xEPYxPHzW8SZ8w=\r\nConnection: Upgrade\r\nUpgrade: websocket\r\nContent-Type: text/plain\r\n\r\n\x81\tConnected")
  "handshake")
(end-suite)

(start-suite "server")
(server h "localhost" 8887)
(ev/sleep 0.001)
(def w (net/connect "localhost" 8887))
(net/write w "Sec-WebSocket-Key: HOHO")
(ev/sleep 0.001)
(assert
  (deep= (net/read w 256)
         @"HTTP/1.1 101 Switching Protocols\r\nContent-Length: 0\r\nSec-WebSocket-Accept: Kfh9QIsMVZcl6xEPYxPHzW8SZ8w=\r\nConnection: Upgrade\r\nUpgrade: websocket\r\nContent-Type: text/plain\r\n\r\n\x81\tConnected")
  "handshake")
(net/write w (string/from-bytes 9 129 256 256 256 256 38))
(assert (deep= (net/read w 256) @"\x8A\x01&") "ping")
(net/write w (string/from-bytes 129 129 256 256 256 256 38))
(assert (deep= (net/read w 256) @"\x81\fReceived: &&"))
(net/write w (string/from-bytes 8 129 256 256 256 256 38))
(:write h (text "Emitted"))
(assert (deep= (net/read w 256) @"\x81\x07Emitted") "emitted")
(assert (deep= (net/read w 256) @"\x88\x01&") "close")
(end-suite)
(os/exit 0)
