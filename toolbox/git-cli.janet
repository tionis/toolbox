#!/bin/env janet
(import ./jeff)
(use ./shell/cli)
(import spork/path)
(import spork/sh)
(description "collection of git utils")

(defc lfs/util/get-pattern-by-file-size
  `get a list of patterns that are match all the file extensions that have files over size
  size defaults to 1000000 (1MB)`
  {:cli/func |(each pattern (if (first ($1 :args))
                              (($0 :func) (scan-number (first ($1 :args))))
                              (($0 :func)))
                (print pattern))}
  [&opt size]
  (default size 1000000)
  (->>
    (do (def ret @[])
        (sh/scan-directory "." (fn [x]
                                 (if (not (peg/match ~(* ".git" (any 1) -1) x))
                                     (let [stat (os/stat x)]
                                          (if (> (stat :size) size)
                                              (array/push ret x))))))
        ret)
    (map (fn [x]
           (when x
             (if-let [rev (string/reverse x)
                      dot (string/find "." rev)]
               (string "*" (string/reverse (string/slice rev 0 (inc dot)))) x))))
    distinct))

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
