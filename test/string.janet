(import ../toolbox/string)
(use spork/test)

(start-suite)
(assert (= 10 (string/distance "this is a test" "test this is")))
(assert (= 1 (string/distance "hello" "hallo")))
(assert (= 1 (string/distance "123" "1234")))
(assert (= 2 (string/distance "123" "234")))
(end-suite)
