(import spork/sh)
(import spork/path)
(import ./util)

(defn exists?
  "checks if branch exists (locally)"
  [dir branch]
  (def stat (os/stat (path/join (util/git-dir dir) "refs" "heads" branch)))
  (and stat (= (stat :mode) :file)))

(defn recently-checked-out
  `Get list with timestamp and names of recently checked-out branches in reverse
  chronological order. Uses git-reflog and excludes branches that have since been deleted.`
  [&opt dir]
  (default dir (os/cwd))
  (def seen @{})
  (def full-reflog
    (->> (sh/exec-slurp "git" "-C" dir "reflog" "-n100" "--pretty=%cr|%gs" "--grep-reflog=checkout: moving" "HEAD")
         (string/split "\n")
         (map |(string/split "|" $0))
         (map |{:timestamp ($0 0)
                :branch (first
                          (peg/match
                            ~(* "checkout: moving from " (to " ") " to " (capture (to (+ "^" -1 "\n"))))
                            ($0 1)))})
         (filter |(exists? dir ($0 :branch)))))
  (def out @[])
  (each item full-reflog
    (unless (seen (item :branch))
      (array/push out item)
      (put seen (item :branch) true)))
  out)
