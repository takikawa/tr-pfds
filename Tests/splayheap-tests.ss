#lang typed-scheme
(require "../splayheap.ss")
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

(check-expect (find-min/max (splayheap less-than? 1 2 3 4)) 1)
(check-expect (find-min/max (splayheap less-than? 1 2 3 0)) 0)
(check-expect (find-min/max (splayheap less-than? 1 2 -3 4)) -3)
(check-error (find-min/max (delete-min/max (splayheap less-than? 1))) 
             "Heap is empty : find-min")

(check-expect (sorted-list (delete-min/max (splayheap less-than? 1 2 3 4)))
              (list 2 3 4))
(check-expect (sorted-list (delete-min/max (splayheap less-than? 1 2 3 0)))
              (list 1 2 3))
(check-expect (sorted-list (delete-min/max (splayheap less-than? 1 2 -3 4)))
              (list 1 2 4))
(check-error (delete-min/max (delete-min/max (splayheap less-than? 1))) 
             "Heap is empty : delete-min")

(check-expect (sorted-list (delete-min/max (splayheap less-than? 1))) (list))
(check-expect (sorted-list (delete-min/max (splayheap less-than? 1 -2 -3 -4))) 
              (list -3 -2 1))

(check-expect (sorted-list (insert 10 (splayheap less-than? 1 -2 -3 -4)))
              (list -4 -3 -2 1 10))

(check-expect (sorted-list (insert -10 (splayheap less-than? 1 20 -3 -4)))
              (list -10 -4 -3 1 20))

(check-expect (sorted-list (insert 0 (splayheap less-than? 1 2 -3 -4)))
              (list -4 -3 0 1 2))

(check-expect (sorted-list (merge (splayheap less-than? 2 3 0 -10)
                                  (splayheap less-than? 1 -2 -3 -4)))
              (list -10 -4 -3 -2 0 1 2 3))

(check-expect (sorted-list (merge (delete-min/max (splayheap less-than? -1))
                                  (splayheap less-than? 1 -2 -3 -4)))
              (list -4 -3 -2 1))

(check-expect (sorted-list (merge (splayheap less-than? 1 -2 -3 -4)
                                  (delete-min/max (splayheap less-than? -1))))
              (list -4 -3 -2 1))

(define int-list (build-list 100 (λ: ([x : Integer]) x)))

(define int-list1 (build-list 100 (λ: ([x : Integer]) (+ 100 x))))

(check-expect (sorted-list (merge (apply splayheap less-than? int-list)
                                  (apply splayheap less-than? int-list1)))
              (append int-list int-list1))

(check-expect (sorted-list (apply splayheap less-than? int-list)) 
              int-list)

(check-expect (sorted-list (apply splayheap gt int-list))
              (reverse int-list))
(check-expect (empty? (splayheap gt 1 2 3 4)) #f)

(check-expect (empty? (splayheap gt)) #t)
(test)