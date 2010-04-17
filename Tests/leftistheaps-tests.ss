#lang typed-scheme
(require "../LeftistHeaps.ss")
(require typed/test-engine/scheme-tests)

(define lst (build-list 100 (λ: ([x : Integer]) x)))
(check-expect 
 (sorted-list (apply leftistheap 
                     (λ: ([a : Integer] [b : Integer]) (<= a b)) lst)) lst)

(check-expect 
 (sorted-list (merge (apply leftistheap 
                            (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                            (build-list 100 (λ: ([x : Integer]) x)))
                     (apply leftistheap 
                            (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                            (build-list 100 (λ: ([x : Integer]) (+ 100 x))))))
 (append (build-list 100 (λ(x) x)) 
         (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))

(check-expect 
 (sorted-list 
  (delete-min/max
   (merge (apply leftistheap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) x)))
          (apply leftistheap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))))
 (append (cdr (build-list 100 (λ(x) x)))
         (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))


(check-expect 
 (sorted-list 
  (delete-min/max
   (delete-min/max
   (merge (apply leftistheap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) x)))
          (apply leftistheap 
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
     (merge (apply leftistheap 
                   (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                   (build-list 100 (λ: ([x : Integer]) x)))
            (apply leftistheap 
                   (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                   (build-list 100 (λ: ([x : Integer]) (- x 100)))))))))
  (append (build-list 98 (λ: ([x : Integer]) (- x 98)))
          (build-list 100 (λ(x) x))
          (cons 500 null)))

(check-error 
 (delete-min/max (leftistheap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "delete-min/max: Given heap is empty")

(check-error 
 (find-min/max (leftistheap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "find-min/max: Given heap is empty")
 
(test)
