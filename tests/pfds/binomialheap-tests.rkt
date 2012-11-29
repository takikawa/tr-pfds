#lang typed-scheme
(require data/heap/binomial)
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

(check-expect (find-min/max (heap less-than? 1 2 3 4)) 1)
(check-expect (find-min/max (heap less-than? 1 2 3 0)) 0)
(check-expect (find-min/max (heap less-than? 1 2 -3 4)) -3)
(check-error (find-min/max (delete-min/max (heap less-than? 1))) 
             "find-min/max: given heap is empty")

(check-expect (sorted-list (delete-min/max 
                            (heap less-than? 1 2 3 4)))
              (list 2 3 4))
(check-expect (sorted-list (delete-min/max 
                            (heap less-than? 1 2 3 0)))
              (list 1 2 3))
(check-expect (sorted-list (delete-min/max 
                            (heap less-than? 1 2 -3 4)))
              (list 1 2 4))
(check-error (delete-min/max (delete-min/max (heap less-than? 1))) 
             "delete-min/max: given heap is empty")

(check-expect (sorted-list (delete-min/max 
                            (heap less-than? 1))) (list))
(check-expect (sorted-list (delete-min/max 
                            (heap less-than? 1 -2 -3 -4))) 
              (list -3 -2 1))

(check-expect (sorted-list (insert 10 (ann (heap less-than? 1 -2 -3 -4)
                                           (Heap Integer))))
              (list -4 -3 -2 1 10))

(check-expect (sorted-list (insert -10 (heap less-than? 1 20 -3 -4)))
              (list -10 -4 -3 1 20))

(check-expect (sorted-list (insert 5 (heap less-than? 1 2 -3 -4)))
              (list -4 -3 1 2 5))

(check-expect (sorted-list (merge (ann (heap less-than? 2 3 -10) 
                                       (Heap Integer))
                                  (ann (heap less-than? 1 -2 -3 -4)
                                       (Heap Integer))))
              (list -10 -4 -3 -2 1 2 3))

(check-expect (sorted-list (merge (delete-min/max 
                                    (ann (heap less-than? -1 5)
                                         (Heap Integer)))
                                  (ann (heap less-than? 1 -2 -3 -4)
                                       (Heap Integer))))
              (list -4 -3 -2 1 5))

(check-expect (sorted-list (merge (heap less-than? 1 -2 -3 -4)
                                  (delete-min/max 
                                   (heap less-than? -1 1))))
              (list -4 -3 -2 1 1))

(define int-list (build-list 100 (λ: ([x : Integer]) x)))

(check-expect (sorted-list (apply heap < int-list)) 
              int-list)

(check-expect (sorted-list (apply heap > int-list))
              (reverse int-list))

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
