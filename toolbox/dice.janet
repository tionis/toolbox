(defmacro s+ "Appends string to var x" [x & strings] ~(set ,x (string ,x ,;strings)))
(defn roll-one-y-sided-die [y]
  (if (not (dyn :rng)) (setdyn :rng (math/rng (os/cryptorand 8))))
  (+ 1 (math/rng-int (dyn :rng) y)))

(defn roll-x-y-sided-dice [x y]
  (var ret (array/new x))
  (loop [i :range [0 x]]
    (array/push ret (roll-one-y-sided-die y)))
  ret)

# (defn roll-x-y-sided-dice [x y]
#   (if (= x 0)
#       @[]
#       (array/concat @[(roll-one-y-sided-die y)] (roll-x-y-sided-dice (- x 1) y))))

(defn parse-modifiers [sides modifiers]
  (var ret @{})
  (put ret :again sides)
  (put ret :success (- sides (math/ceil (/ sides 3.5))))
  (put ret :fail (math/floor (/ sides 6)))
  (put ret :rote false)
  (each item modifiers
    (case (type item)
      :string (do (def number (scan-number item))
                  (if number
                      (if (< number (ret :again))
                          (do (put ret :again number)
                              (if (< number (ret :success)) (put ret :success number))))
                      (case item
                        "r" (put ret :rote true)
                        "n" (do (put ret :again (+ sides 1))
                                (put ret :rote false)))))
      :keyword (case item
                  :rote (put ret :rote true)
                  :no-reroll (put ret :again (+ sides 1))
                  :r (put ret :rote true)
                  :n (put ret :again (+ sides 1)))
      :number (if (< item (ret :again))
                  (do (put ret :again item)
                      (if (< item (ret :success)) (put ret :success item))))
      (error "Could not parse!")))
  (if (< (ret :again) 2)
      (error "Again modifier too low!"))
  (table/to-struct ret))

(defn format-result [result]
  (var ret "")
  (loop [i :range [0 (length result)]]
  (def max-i (- (length result) 1))
    (s+ ret "[")
    (def max-j (- (length (result i))))
    (loop [j :range [0 (length (result i))]]
      (if (> j 0)
          (s+ ret (string " -> " ((result i) j)))
          (s+ ret ((result i) j))))
    (if (= i max-i) (s+ ret "]") (s+ ret "] ")))
  ret)

(defn count-successes [result modifiers]
  (var successes 0)
  (each line result
    (each item line
      (if (>= item (modifiers :success)) (++ successes))))
  successes)

(defn- count-fails [result modifiers]
  (var fails 0)
  (each line result
    (if (<= (line 0) (modifiers :fail)) (++ fails)))
  fails)

(defn get-result-message [amount modifiers result]
  (var ret "")
  (def successes (count-successes result modifiers))
  (def fails (count-fails result modifiers))
  (if (> fails (math/floor (/ amount 2)))
      (if (= successes 0)
          (s+ ret "Crit Fail")
          (s+ ret "Fail with " successes " successes"))
      (if (>= successes 5)
          (s+ ret "Crit Success with " successes " successes")
          (if (= successes 0)
            (s+ ret "Fail with 0 successes")
            (s+ ret "Success with " successes " successes"))))
  ret)

(defn get-status [amount modifiers result]
  (def successes (count-successes result modifiers))
  (def fails (count-fails result modifiers))
  (if (> fails (math/floor (/ amount 2)))
      (if (= successes 0)
          :crit-fail
          :fail)
      (if (>= successes 5)
          :crit-success
          (if (= successes 0)
              :fail
              :success))))

(defn mass-init [init-table]
  (def result @[])
  (def init-mods @{})
  (each char init-table
    (put init-mods (char 0) (char 1))
    (def die-result (roll-one-y-sided-die 10))
    (var init-result (+ die-result (char 1)))
    (each modifier (slice char 2 -1)
      (case modifier
        :advantage (do (def die-result-2 (roll-one-y-sided-die 10))
                       (def init-result-2 (+ die-result-2 (char 1)))
                       (if (> init-result-2 init-result)
                           (set init-result init-result-2)))
        (error (string "modifier not implemented: " modifier))))
    (array/push result @[(char 0) init-result]))
  (sort result (fn [x y] (if (= (x 1) (y 1))
                               (> (init-mods (x 0)) (init-mods (y 0)))
                               (> (x 1) (y 1))))))

(defn cod-roll-raw [sides amount modifiers]
  (def result @[])
  (loop [i :range [0 amount]]
    (array/push result @[])
    (var continue true)
    (var recursion 0)
    (while continue
      (++ recursion)
      (def die-result (roll-one-y-sided-die sides))
      (if (and (< die-result (modifiers :again))
               (or (not (modifiers :rote)) (and (modifiers :rote)
                                                (> recursion 1))))
          (set continue false))
      (array/push (get result i) die-result)))
  result)

(defn cod-roll [sides amount & raw-modifiers]
  (if (= amount nil) (error "Not a number!"))
  (def parsed-modifiers(parse-modifiers sides raw-modifiers))
  (def result (cod-roll-raw sides amount parsed-modifiers))
  (print (format-result result))
  (print (get-result-message amount parsed-modifiers result))
  {:result result
   :status (get-status amount parsed-modifiers result)
   :successes (count-successes result parsed-modifiers)})

(defn roll-chance [& modifiers]
  (def result (roll-one-y-sided-die 10))
  (print "[" result "]")
  (cond
    (= result 1)  (print "Crit Fail!")
    (= result 10) (print "Success!")
    (print "Fail!")))

(defn- roll-init [& args]
  (def result (roll-one-y-sided-die 10))
  (if (= (length args) 0)
      (print "Your result: [" result "]")
      (do (def number (scan-number (args 0)))
          (if number
              (print "Your result: " result " + " number " = [" (+ result number) "]")
              (error "Could not parse init mod")))))

(defn roll [dice & args]
  (case (type dice)
    :string (if (peg/match ~(* (some :d) "d" (some :d)) dice)
                (do (def dice-arr (string/split "d" dice))
                    (def result (roll-x-y-sided-dice (scan-number (dice-arr 0)) (scan-number (dice-arr 1))))
                    (prin "Result: ") (pp result)
                    (print "Sum: " (sum result)))
                (let [number (scan-number dice)]
                  (if number
                    (cod-roll 10 number ;args)
                    (case dice
                      "chance" (roll-chance ;args)
                      "init" (roll-init ;args)
                      (error "Unknown command!")))))
    :number (cod-roll 10 dice ;args)
    :keyword (case dice
               :chance (roll-chance ;args)
               :init (roll-init ;args))))

(defn multi [amount init &opt name]
  (default name "npc")
  (def ret @[])
  (loop [i :range [1 (+ amount 1)]]
    (array/push ret [(string name "-" i) init]))
  ret)

(defn main [_ & args]
  (def args-count (length args))
  (cond
    (= args-count 0) (do (print "Please supply the dice to roll!") (os/exit 1))
    (> args-count 0) (roll ;args)
    (print "unsupported amount of arguments")))
