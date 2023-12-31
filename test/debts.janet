(use spork/test)
(import ../toolbox/debts)

(defn arr-sort [x] (sorted x (fn [x y] (< (hash x) (hash y)))))

(assert
  (deep=
    {:crediters @[["karl" 10] ["john" 100]] :debiters @[["peter" -50] ["valentina" -60]]}
    (let [res (debts/split_balance @{"karl" 10 "peter" -50 "john" 100 "valentina" -60})]
      {:crediters (arr-sort (res :crediters)) :debiters (arr-sort (res :debiters))}))
  "split_balance")

(assert
  (debts/check_balance_solvable @[["karl" 10] ["john" 100]] @[["valentina" -60] ["peter" -50]])
  "check_balance_solvable")

(assert-error # "check_balance_solvable_error"
    "Unsolvable balance"
    (debts/check_balance_solvable @[["karl" 10] ["john" 150]] @[["valentina" -60] ["peter" -50]]))

(assert
  (deep=
    (arr-sort @[["valentina" 60 "john"] ["peter" 40 "john"] ["peter" 10 "karl"]])
    (arr-sort (debts/solve_balance @[["valentina" -60] ["peter" -50]] @[["karl" 10] ["john" 100]])))
  "solve_balance")

(assert
  (deep=
    @[["peter" 40 "john"] ["peter" 10 "karl"] ["valentina" 60 "john"]]
    (arr-sort (debts/settle @{"karl" 10 "peter" -50 "john" 100 "valentina" -60})))
  "settle1")

(assert
  (deep=
    @[["svetlana" 10 "peter"] ["svetlana" 10 "brian"]]
    (arr-sort (debts/settle @{"peter" 10 "brian" 10 "svetlana" -20})))
  "settle2")

(assert-no-error
  (let [balance @{"simon" 778.06
                  "laura" -28.78
                  "pauline" 126.60
                  "valentin" -445.9
                  "colin" -134.28
                  "remy" 163.41
                  "elsa" 339.45
                  "alexis" 611.77
                  "ter-ter" -298.33
                  "chez-francine" -176.82
                  "la-lanterne" -240.75
                  "cece-manu" -184.85
                  "thorigne" -28.67
                  "amour-de-coloc" -151.26
                  "fleurs-bleues" -37.78
                  "treguinguette" -291.87}]
  # (def expected_result
  #   (arr-sort @[["thorigne" 28.67 "pauline"]
  #               ["laura" 28.78 "pauline"]
  #               ["fleurs-bleues" 37.78 "pauline"]
  #               ["colin" 31.37 "pauline"]
  #               ["colin" 102.91 "remy"]
  #               ["amour-de-coloc" 60.50 "remy"]
  #               ["amour-de-coloc" 90.76 "elsa"]
  #               ["chez-francine" 176.82 "elsa"]
  #               ["cece-manu" 71.87 "elsa"]
  #               ["cece-manu" 112.98 "alexis"]
  #               ["la-lanterne" 240.75 "alexis"]
  #               ["treguinguette" 258.04 "alexis"]
  #               ["treguinguette" 33.83 "simon"]
  #               ["ter-ter" 298.33 "simon"]
  #               ["valentin" 445.90 "simon"]]))
    (def bank (table/clone balance))
    (def solution (debts/settle balance))
    (each step solution
      (+= (bank (step 0)) (step 1))
      (-= (bank (step 2)) (step 1)))
    (each account bank
      (if (>= (math/abs account) 0.01)
          (do (pp bank)
              (error "balance does not check out")))))
  "test-big-debts-are-solved-properly")

(assert
  (deep=
    @[["fred" 200 "remy"] ["alexis" 300 "remy"]]
    (arr-sort (debts/settle @{"fred" -200 "alexis" -300 "remy" 500})))
  "test_person_in_both_sides")
