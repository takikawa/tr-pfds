#lang typed-scheme
(require "../pairingheap.ss")
(require typed/test-engine/scheme-tests)


(check-expect 
 (sorted-list (apply heap 
                     (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                     (build-list 100 (λ: ([x : Integer]) x))))
 (build-list 100 (λ(x) x)))

(check-expect 
 (sorted-list (merge (apply heap 
                            (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                            (build-list 100 (λ: ([x : Integer]) x)))
                     (apply heap 
                            (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                            (build-list 100 (λ: ([x : Integer]) (+ 100 x))))))
 (append (build-list 100 (λ(x) x)) 
         (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))

(check-expect 
 (sorted-list 
  (delete-min/max
   (merge (apply heap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) x)))
          (apply heap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))))
 (append (cdr (build-list 100 (λ(x) x)))
         (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))


(check-expect 
 (sorted-list 
  (delete-min/max
   (delete-min/max
   (merge (apply heap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) x)))
          (apply heap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) (- x 100))))))))
 (append (build-list 98 (λ: ([x : Integer]) (- x 98)))
         (build-list 100 (λ(x) x))))

(check-expect 
 (sorted-list 
  (insert 
   500
   (delete-min/max
    (delete-min/max
     (merge (apply heap 
                   (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                   (build-list 100 (λ: ([x : Integer]) x)))
            (apply heap 
                   (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                   (build-list 100 (λ: ([x : Integer]) (- x 100)))))))))
  (append (build-list 98 (λ: ([x : Integer]) (- x 98)))
          (build-list 100 (λ(x) x))
          (cons 500 null)))

(check-error 
 (delete-min/max (heap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "delete-min/max: given heap is empty")

(check-error 
 (find-min/max (heap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "find-min/max: given heap is empty")
 
(test)
