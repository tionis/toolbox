(declare-project
  :name "tools"
  :description "a collection of useful janet functions, libraries and more"
  :dependencies ["https://github.com/janet-lang/spork.git"]
  :author "tionis.dev"
  :license "MIT"
  :url "https://tasadar.net/tionis/tools"
  :repo "git+https://tasadar.net/tionis/tools")

(declare-source
  :source ["tools"])

(declare-native
  :name "tools/set"
  :source ["src/set.c"])
