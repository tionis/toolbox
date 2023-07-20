(import spork/sh)

(defn git-dir
  "given working directory return path to git_dir"
  [dir]
  (sh/exec-slurp "git" "-C" dir "rev-parse" "--git-dir")) # TODO replace with git-exec util
