#!/bin/env janet
(import ./jeff)
(use ./shell/cli)
(import spork/path)
(import spork/sh)
(description "collection of git utils")

(defc lock
  "lock a file to ignore changes done to it"
  [filename]
  (os/execute ["git" "update-index" "--skip-worktree" filename] :px))

(defc unlock
  "unlock a file, considering it's changes again"
  [filename]
  (os/execute ["git" "update-index" "--no-skip-worktree" filename] :px))

(defc locked
  :cli/print
  "list locked files"
  []
  (->> (sh/exec-slurp "git" "ls-files" "-v")
       (string/split "\n")
       (filter |(= (first $0) (chr "S")))
       (map |(slice $0 2))))

(defc select-dir
  "select a directory in the repo"
  {:cli/func |(print (($0 :func)))}
  []
  (jeff/choose (distinct (map |(path/dirname $0) (string/split "\n" (sh/exec-slurp "git" "ls-files"))))))

(defc graph
  "show commit graph using git log"
  []
  (os/execute ["git" "log" "--all" "--graph" "--decorate" "--oneline" "--simplify-by-decoration"] :px))
