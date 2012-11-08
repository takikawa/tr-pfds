#lang typed/scheme
(require data/heap/leftist)
(require typed/test-engine/scheme-tests)

(define lst (build-list 100 (λ: ([x : Integer]) x)))
(check-expect 
 (sorted-list (apply heap 
                     (λ: ([a : Integer] [b : Integer]) (<= a b)) lst)) lst)

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

(check-expect (fold + 0 (heap < 1 1 1 10 1 15)) 29)
(check-expect (sorted-list (map < add1 (heap < 10 4 5 14 29 15)))
              (list 5 6 11 15 16 30))
(check-expect (fold + 0 (heap > 1)) 1)
(check-expect (sorted-list (filter even? (heap < 10 4 5 14 29 15)))
              (list 4 10 14))
(check-expect (sorted-list (remove odd? (heap < 10 4 5 14 29 15)))
              (list 4 10 14))
(check-expect (sorted-list (remove even? (heap < 10 4 5 14 29 15)))
              (list 5 15 29))
(check-expect (sorted-list (filter odd? (heap < 10 4 5 14 29 15)))
              (list 5 15 29))

(check-expect (ormap odd? (heap < 10 4 5 14 29 15)) #t)
(check-expect (ormap even? (heap < 5 29 15)) #f)
(check-expect (andmap odd? (heap < 5 29 15)) #t)
(check-expect (andmap odd? (heap < 5 29 14)) #f)

(test)
