#lang typed-scheme
(require "../skewbinomialheap.ss")
(require typed/test-engine/scheme-tests)


(: less-than? : (Integer Integer -> Boolean))
(define (less-than? a b)
  (<= a b))

(: gt : (Integer Integer -> Boolean))
(define (gt a b)
  (> a b))

(: str-less-than? : (String String -> Boolean))
(define (str-less-than? a b)
  (string<=? a b))

(check-expect (find-min/max (binomialheap less-than? 1 2 3 4)) 1)
(check-expect (find-min/max (binomialheap less-than? 1 2 3 0)) 0)
(check-expect (find-min/max (binomialheap less-than? 1 2 -3 4)) -3)
(check-error (find-min/max (delete-min/max (binomialheap less-than? 1))) 
             "Heap is empty : find-min/max")

(check-expect (sorted-list (delete-min/max 
                            (binomialheap less-than? 1 2 3 4)))
              (list 2 3 4))
(check-expect (sorted-list (delete-min/max 
                            (binomialheap less-than? 1 2 3 0)))
              (list 1 2 3))
(check-expect (sorted-list (delete-min/max 
                            (binomialheap less-than? 1 2 -3 4)))
              (list 1 2 4))
(check-error (delete-min/max (delete-min/max 
                              (binomialheap less-than? 1))) 
             "Heap is empty : delete-min/max")

(check-expect (sorted-list (delete-min/max 
                            (binomialheap less-than? 1))) (list))
(check-expect (sorted-list (delete-min/max 
                            (binomialheap less-than? 1 -2 -3 -4))) 
              (list -3 -2 1))

(check-expect (sorted-list (insert 10 (binomialheap less-than? 1 -2 -3 -4)))
              (list -4 -3 -2 1 10))

(check-expect (sorted-list (insert -10 (binomialheap less-than? 1 20 -3 -4)))
              (list -10 -4 -3 1 20))

(check-expect (sorted-list (insert 0 (binomialheap less-than? 1 2 -3 -4)))
              (list -4 -3 0 1 2))

(check-expect (sorted-list (merge (binomialheap less-than? 2 3 0 -10)
                                  (binomialheap less-than? 1 -2 -3 -4)))
              (list -10 -4 -3 -2 0 1 2 3))

(check-expect (sorted-list (merge (delete-min/max (binomialheap less-than? -1))
                                  (binomialheap less-than? 1 -2 -3 -4)))
              (list -4 -3 -2 1))

(check-expect (sorted-list (merge (binomialheap less-than? 1 -2 -3 -4)
                                  (delete-min/max 
                                   (binomialheap less-than? -1))))
              (list -4 -3 -2 1))

(define int-list (build-list 100 (λ: ([x : Integer]) x)))

(check-expect (sorted-list (apply binomialheap less-than? int-list)) 
              int-list)

(check-expect (sorted-list (apply binomialheap gt int-list))
              (reverse int-list))

(define lst (build-list 100 (λ: ([x : Integer]) x)))
(check-expect (sorted-list (apply binomialheap less-than? lst)) lst)
(check-expect (sorted-list (apply binomialheap gt lst)) (reverse lst))

(test)