(declare-project
  :name "toolbox"
  :description "a collection of useful janet functions, libraries and more"
  :dependencies ["https://github.com/janet-lang/spork.git"]
  :author "tionis.dev"
  :license "MIT"
  :url "https://tasadar.net/tionis/tools"
  :repo "git+https://tasadar.net/tionis/tools")

(declare-source
  :source ["toolbox"])

(declare-native
  :name "toolbox/set"
  :source ["src/set.c"])

(declare-native
  :name "toolbox/fuzzy"
  :source @["cjanet/fuzzy.janet"])

(declare-native
  :name "toolbox/curi"
  :source @["cjanet/curi.janet"])

(declare-native
  :name "toolbox/codec"
  :source @["cjanet/codec.janet"])

(declare-native
  :name "toolbox/crypto"
  :cflags [;default-cflags "-I."]
  :source @["src/crypto.c"
            "src/deps/libhydrogen/hydrogen.c"])
