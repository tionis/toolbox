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
  :name "gp/data/fuzzy"
  :source @["cjanet/fuzzy.janet"])

(declare-native
  :name "gp/net/curi"
  :source @["cjanet/curi.janet"])

(declare-native
  :name "gp/codec"
  :source @["cjanet/codec.janet"])

(declare-binscript
  :main "bin/gpf"
  :is-janet true
  :auto-shebang true)
