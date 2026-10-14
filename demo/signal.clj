(ns signal-lab.core)

(def samples [0.2 0.8 -0.5 1.0 0.4])

(defn average [values]
  (/ (reduce + values) (count values)))

(defn smooth [values window]
  (->> values
       (partition window 1)
       (map average)
       (into [])))

(let [result (smooth samples 3)]
  (println "Smoothed samples:" result)
  (println "Average:" (average result)))
