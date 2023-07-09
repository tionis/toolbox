(use toolbox/crypto)
(use spork/test)

(start-suite "crypto-1")

(assert
  # ok, so this isn't strictly correct, but it is very unlikely.
  (all identity (seq [i :range [0 500]]
                  (not= (random/u32) (random/u32))))
  "u32")
(assert (= 1024 (length (random/buf 1024))) "buffer 1")
(assert (= 0 (length (random/buf 0))) "buffer 2")

(assert-error "buffer 3" (random/buf -1))

(assert-error "buffer 4" (random/buf @"abc" -10))

(end-suite)

(start-suite "crypto-2")

(assert (deep= (util/hex2bin "a3") @"\xA3") "util/hex2bin")
(assert (deep= (util/bin2hex "\xA3") @"a3") "util/bin2hex")

(end-suite)

(start-suite "crypto-3")

# n variant
(do
  (def {:public-key pk :secret-key sk} (kx/keygen))
  (def packet @"")
  (def psk (random/buf kx/psk-bytes))
  (def {:tx client-tx :rx client-rx} (kx/n1 packet psk pk))
  (def {:tx server-tx :rx server-rx} (kx/n2 packet psk pk sk))
  (assert (util/= client-tx server-rx) "client rx = server tx")
  (assert (util/= client-rx server-tx) "client tx = server rx"))

# kk variant
(do
  (def {:public-key pk1 :secret-key sk1} (kx/keygen))
  (def {:public-key pk2 :secret-key sk2} (kx/keygen))
  (def packet1 @"")
  (def packet2 @"")
  (def a-state (kx/kk1 packet1 pk2 pk1 sk1))
  (def {:tx b-tx :rx b-rx} (kx/kk2 packet2 packet1 pk1 pk2 sk2))
  (def {:tx a-tx :rx a-rx} (kx/kk3 a-state packet2 pk1 sk1))
  (assert (util/= a-tx b-rx) "a tx = b rx")
  (assert (util/= a-rx b-tx) "a rx = b tx"))

# xx variant
(do
  (def {:public-key pk1 :secret-key sk1} (kx/keygen))
  (def {:public-key pk2 :secret-key sk2} (kx/keygen))
  (def packet1 @"")
  (def packet2 @"")
  (def packet3 @"")
  (def psk (random/buf kx/psk-bytes))
  (def a-state (kx/xx1 packet1 psk))
  (def b-state (kx/xx2 packet2 packet1 psk pk2 sk2))
  (def {:tx b-tx :rx b-rx} (kx/xx3 a-state packet3 packet2 psk pk1 sk1))
  (def {:tx a-tx :rx a-rx} (kx/xx4 b-state packet3 psk))
  (assert (util/= a-tx b-rx) "a tx = b rx")
  (assert (util/= a-rx b-tx) "a rx = b tx"))

(end-suite)
