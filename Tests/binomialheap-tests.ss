#lang typed-scheme
(require "../binomialheap.ss")
(require typed/test-engine/scheme-tests)


(: less-than? : (Integer Integer -> Boolean))
(define (less-than? a b)
  (<= a b))

(: str-less-than? : (String String -> Boolean))
(define (str-less-than? a b)
  (string<=? a b))

(check-expect (findMin (binomialheap less-than? (list 1 2 3 4))) 1)
(check-expect (findMin (binomialheap less-than? (list 1 2 3 0))) 0)
(check-expect (findMin (binomialheap less-than? (list 1 2 -3 4))) -3)

(check-expect (sorted-list (deleteMin (binomialheap less-than? (list 1 2 3 4)))) 
              (list 2 3 4))
(check-expect (sorted-list (deleteMin (binomialheap less-than? (list 1 2 3 0))))
              (list 1 2 3))
(check-expect (sorted-list (deleteMin (binomialheap less-than? (list 1 2 -3 4)))) 
              (list 1 2 4))

(check-expect (sorted-list (deleteMin (binomialheap less-than? (list 1)))) (list))
(check-expect (sorted-list (deleteMin (binomialheap less-than? (list 1 -2 -3 -4)))) 
              (list -3 -2 1))

(check-expect (sorted-list (insert 10 (binomialheap less-than? (list 1 -2 -3 -4)))) 
              (list -4 -3 -2 1 10))

(check-expect (sorted-list (insert -10 (binomialheap less-than? (list 1 20 -3 -4)))) 
              (list -10 -4 -3 1 20))

(check-expect (sorted-list (insert 0 (binomialheap less-than? (list 1 2 -3 -4)))) 
              (list -4 -3 0 1 2))

(check-expect (sorted-list (merge (binomialheap less-than? (list 2 3 0 -10)) 
                                  (binomialheap less-than? (list 1 -2 -3 -4))))
              (list -10 -4 -3 -2 0 1 2 3))

(check-expect (sorted-list (merge (deleteMin (binomialheap less-than? (list -1)))
                                  (binomialheap less-than? (list 1 -2 -3 -4))))
              (list -4 -3 -2 1))

(check-expect (sorted-list (merge (binomialheap less-than? (list 1 -2 -3 -4))
                                  (deleteMin (binomialheap less-than? (list -1)))))
              (list -4 -3 -2 1))

(test)