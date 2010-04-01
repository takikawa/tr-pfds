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
  (delete-min
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
  (delete-min
   (delete-min
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
   (delete-min
    (delete-min
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
 (delete-min (leftistheap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "Heap is empty : delete-min")

(check-error 
 (find-min (leftistheap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "Heap is empty : find-min")
 
(test)