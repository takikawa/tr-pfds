#lang typed-scheme
(require "../pairingheap.ss")
(require typed/test-engine/scheme-tests)


(check-expect 
 (sorted-list (apply pairingheap 
                     (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                     (build-list 100 (λ: ([x : Integer]) x))))
 (build-list 100 (λ(x) x)))

(check-expect 
 (sorted-list (merge (apply pairingheap 
                            (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                            (build-list 100 (λ: ([x : Integer]) x)))
                     (apply pairingheap 
                            (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                            (build-list 100 (λ: ([x : Integer]) (+ 100 x))))))
 (append (build-list 100 (λ(x) x)) 
         (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))

(check-expect 
 (sorted-list 
  (delete-min/max
   (merge (apply pairingheap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) x)))
          (apply pairingheap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))))
 (append (cdr (build-list 100 (λ(x) x)))
         (build-list 100 (λ: ([x : Integer]) (+ 100 x)))))


(check-expect 
 (sorted-list 
  (delete-min/max
   (delete-min/max
   (merge (apply pairingheap 
                 (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                 (build-list 100 (λ: ([x : Integer]) x)))
          (apply pairingheap 
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
     (merge (apply pairingheap 
                   (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                   (build-list 100 (λ: ([x : Integer]) x)))
            (apply pairingheap 
                   (λ: ([a : Integer] [b : Integer]) (<= a b)) 
                   (build-list 100 (λ: ([x : Integer]) (- x 100)))))))))
  (append (build-list 98 (λ: ([x : Integer]) (- x 98)))
          (build-list 100 (λ(x) x))
          (cons 500 null)))

(check-error 
 (delete-min/max (pairingheap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "Heap is empty : delete-min/max")

(check-error 
 (find-min/max (pairingheap (λ: ([a : Integer] [b : Integer]) (<= a b))))
 "Heap is empty : find-min/max")
 
(test)