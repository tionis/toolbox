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

(each f (if (os/stat "man") (os/dir "man") [])
  (declare-manpage # Install man pages # TODO auto generate from module if not existant?
    (string "man/" f)))

(declare-native
  :name "toolbox/set"
  :source ["src/set.c"])

(def fuzzy
  (declare-native
    :name "toolbox/fuzzy"
    :source @["cjanet/fuzzy.janet"]))

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
  :name "toolbox/ctrl-c/native"
  :source ["src/ctrl.c"])
(declare-source
  :prefix "toolbox"
  :source ["src/ctrl-c.janet"])

(def jermbox
  (declare-native
    :name "toolbox/jermbox"
    :cflags ["-std=c99"
             "-Wall"
             "-D_POSIX_C_SOURCE=200809L"
             "-D_XOPEN_SOURCE"]
    :source ["src/jermbox.c"
             "src/deps/termbox_next/src/termbox.c"
             "src/deps/termbox_next/src/utf8.c"
             "src/deps/termbox_next/src/term.c"
             "src/deps/termbox_next/src/ringbuffer.c"
             "src/deps/termbox_next/src/input.c"
             "src/deps/termbox_next/src/memstream.c"]))

(when (index-of (os/which) [:posix :linux :macos])
  # if creating executable use add :deps [(posix-spawn :static)] etc
  # to declare-executable to handle compile steps correctly
  (def posix-spawn
    (declare-native
      :name "toolbox/posix_spawn/native"
      :source ["src/posix-spawn.c"]))
  (declare-source
    :prefix "toolbox"
    :source ["src/posix-spawn.janet"])
  (def sh
    (declare-native
      :name "toolbox/sh/native"
      :source ["src/sh.c"]))
  (declare-source
    :prefix "toolbox"
    :source ["src/sh.janet"]))

(declare-executable
  :name "tb" # TODO install man pages for this or add better cli help
  :entry "toolbox/cli.janet"
  :deps [(fuzzy :static)
         (jermbox :static)]
  :install true)

(declare-executable
  :name "git-tb" # TODO install man pages for this or add better cli help
  :entry "toolbox/git-cli.janet"
  :deps [(fuzzy :static)]
  :install true)

(declare-executable
  :name "tb-fuzzy"
  :entry "toolbox/jeff/cli.janet"
  :deps [(fuzzy :static)]
  :install true)
