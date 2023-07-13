(declare-project
  :name "toolbox"
  :description "a collection of useful janet functions, libraries and more"
  :dependencies ["https://github.com/janet-lang/spork.git"
                 "https://tasadar.net/tionis/jeff"] # TODO inline this dep
  :author "tionis.dev"
  :license "MIT"
  :url "https://tasadar.net/tionis/tools"
  :repo "git+https://tasadar.net/tionis/tools")

(declare-source
  :source ["toolbox"])

(each f (if (os/stat "man") (os/dir "man") [])
  (declare-manpage # Install man pages # TODO auto generate from module if not existant?
    (string "man/" f)))

(declare-executable
  :name "tb" # TODO install man pages for this or add better cli help
  :entry "toolbox/cli.janet"
  :install true)

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

(declare-native
  :name "shell/ctrl-c/native"
  :source ["src/ctrl.c"])

(when (index-of (os/which) [:posix :linux :macos])
  # if creating executable use add :deps [(posix-spawn :static)] etc
  # to declare-executable to handle compile steps correctly
  (def posix-spawn
    (declare-native
      :name "shell/posix_spawn/native"
      :source ["src/posix-spawn.c"]))
  (declare-source
    :prefix "shell"
    :source ["src/posix-spawn.janet"])
  (def sh
    (declare-native
      :name "shell/sh/native"
      :source ["src/sh.c"]))
  (declare-source
    :prefix "shell"
    :source ["src/sh.janet"]))
