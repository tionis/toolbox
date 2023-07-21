#!/bin/env janet
(import spork/rawterm)
(import spork/randgen)
(import spork/sh)
(import spork/temple)
(import ./http)
(import ./jeff/init :as jeff)
(import ./shell/defaults)
(use ./shell/cli)
(description "collection of shell utils")

(defc net/ip/external/info
  :cli/print
  []
  (http/get/json "https://am.i.mullvad.net/json"))

(defn roll-one-y-sided-die [y]
  (if (not (dyn :rng)) (setdyn :rng (math/rng (os/cryptorand 8))))
  (+ 1 (math/rng-int (dyn :rng) y)))

(defc core/nproc
  "print the number of processing units available"
  []
  (print (os/cpu-count)))

(defc core/fold
  {:cli/func argparse-keyed
   :cli/argparse {"spaces" {:kind :option
                            :short "s"
                            :help "break at spaces"}
                  "width" {:kind :flag
                           :short "w"
                           :map |(scan-number $0)
                           :default 80
                           :help "use WIDTH columns"}
                  "bytes" {:kind :option
                           :short "b"
                           :help "count bytes rather than columns"}
                  :default {:kind :accumulate}}}
  `Wrap input lines in each $file, writing to standard output.
  With no file, or when file is -, read standard input.
  Width defaults to 80, if bytes thruthy count bytes instead of terminal columns
  If spaces truthy, split at spaces`
  [file &named width spaces bytes]
  (default width 80)
  (def text
    (if (and file (not= file "-"))
      (slurp file)
      (string/trimr (file/read stdin :all))))
  # find next cut point considering bytes and width
  # if spaces is given look at index if space, split at index+1 else walk backwards to find previous space and split there (handle special case of not finding one/walking back into already printed subarr)
  )

(defc more/chronic
  "runs a command quietly unless it fails"
  [& args]
  (def env (os/environ))
  (def streams (os/pipe))
  (put env :out (streams 1))
  (def exit_code (os/execute args :pe env))
  (ev/close (streams 1))
  (if (not (= exit_code 0)) (prin (ev/read (streams 0) :all))))

(def simple-html-template
  (temple/compile
    `<!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>{{ (or (args "title") "INSERT_TITLE_HERE") }}</title>
        <link rel="stylesheet" href="https://tionis.dev/water.css">
      </head>
      <body>
        <h1>{{ (or (args "title") "INSERT_TITLE_HERE") }}</h1>
      </body>
    </html>`))

(defc web/html/new
  `simple html template, file defaults to index.html`
  {:options @{"title" {:kind :option
                       :default "INSERT_TITLE_HERE"
                       :help "the title of the html template"}}}
  [args &opt file]
  (default file "index.html")
  (spit file (simple-html-template ;(mapcat identity (kvs args)))))

(defc fzf/edit
  "select file to edit via fzf"
  []
  (os/execute [(defaults/editor) (jeff/choose (sh/list-all-files ".") :use-fzf true)] :px))

(defc fzf/preview
  {:cli/alias ["fzf:preview"]}
  [& args]
  # (when (= (first args) "preview")
  #   (var file (get args 1 ""))
  #   (def w (get args 2 ""))
  #   (def h (get args 3 ""))
  #   (def x (get args 4 ""))
  #   (def y (get args 5 ""))
  #   (def id (get args 6 ""))
  #   (sh/exec "ctpv" "-c" id)
  #   (sh/exec "ctpv" file w h x y id)
  #   (os/exit 0))
  (def id (string (roll-one-y-sided-die 1000000000)))
  (def pv @[])
  (var [h w] (rawterm/size))
  (var [x y] [0 0])
  (var img? (or (> w 52) (> h 13)))

  (if img?
    (let [COLS w LINS h]
      (array/push pv "--preview-window")
      (if (or (> w (* h 3))
              (> w 169))
        (do
          (array/push pv "right:50%")
          (set x (math/floor (+ (/ COLS 2) 2)))
          (set y 1)
          (set w (math/floor (- (/ (- COLS 1) 2) 2)))
          (set h (- LINS 2)))
        (do
          (array/push pv "down:50%")
          (set x 1)
          (set y (math/floor (+ (/ LINS 2) 2)))
          (set w (- COLS 2))
          (set h (math/floor (- (/ (- LINS 1) 2) 2)))))
      (array/push pv "--preview")
      (array/push pv (string/join (map |(string $0)
                                       ["ctpv" "-c" id "&&" "ctpv" "{}" w h x y id])
                                       #["fzf:preview" "preview" "{}" w h x y id])
                                  " "))))

  (if img?
    (os/spawn ["ctpv" "-s" id] :p {:in (sh/devnull)}))

  (os/execute ["fzf" ;pv "--reverse" ;args] :p)

  (if img?
    (os/execute ["ctpvquit" id] :p)))

(init-main)
