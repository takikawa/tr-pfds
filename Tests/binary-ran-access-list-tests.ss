#lang typed/scheme
(require (prefix-in rk: racket/base))
(require "../binaryrandomaccesslist.ss")
(require typed/test-engine/scheme-tests)

(check-expect (head (list 1 2 3 4 5 6 7)) 1)
(check-expect (head (list "" "")) "")
(check-expect (tail (list 1)) (list))
(check-expect (head (tail (list 1 2 3 4 5 6 7))) 2)

(check-expect (empty? (tail (list 1))) #t)
(check-expect (empty? (tail (list 2 1))) #f)

(check-expect (->list (tail (list 1 2 3 4 5 6 7)))
              (rk:list 2 3 4 5 6 7))

(check-expect (->list (tail (tail (list 1 2 3 4 5 6 7))))
              (rk:list 3 4 5 6 7))

(check-expect (drop 1 (list 1)) (list))
(check-expect (->list (drop 2 (list 1 2 3 4 5 6 7))) 
              (rk:list 3 4 5 6 7))

(check-expect (->list (drop 0 (list 1 2 3 4 5 6 7)))
              (rk:list 1 2 3 4 5 6 7))
(check-error (drop 8 (list 1 2 3 4 5 6 7)) 
             "drop: not enough elements to drop")
(check-error (drop -1 (list 1 2 3 4 5 6 7)) 
             "drop: not enough elements to drop")

(check-expect (->list (list-set (list 1 2 3 4 5 6 7) 2 1234))
              (rk:list 1 2 1234 4 5 6 7))

(check-expect (->list (list-set (list 1 2 3 4 5 6 7) 0 1234))
              (rk:list 1234 2 3 4 5 6 7))

(check-error (list-set (list 1 2 3 4 5 6 7) -2 1234)
             "list-set: given index out of bound")

(check-error (list-set (list 1 2 3 4 5 6 7) 20 1234)
             "list-set: given index out of bound")

(define lst (rk:build-list 100 (λ(x) x)))
(check-expect (->list (apply list lst)) lst)

(check-expect (length empty) 0)
(check-expect (length (list 1)) 1)
(check-expect (length (list 1 2 3 4 5 6 7)) 7)

(check-expect (length (list 1 2 3 4 5)) 5)

(check-expect (length (apply list lst)) 100)

(check-expect (->list (map + (list 1 2 3 4 5) (list 1 2 3 4 5)))
              (rk:list 2 4 6 8 10))

(check-expect (->list (map - (list 1 2 3 4 5) (list 1 2 3 4 5)))
              (rk:list 0 0 0 0 0))

(check-expect (foldl + 0 (list 1 2 3 4 5)) 15)

(check-expect (foldl - 2 (list 1 2 3 4 5)) -13)

(check-expect (foldr + 0 (list 1 2 3 4 5)) 15)

(check-expect (foldr + 0 (list 1 2 3 4 5) (list 1 2 3 4 5)) 30)

(check-expect (->list (filter positive? (list 1 2 -4 5 0 -6 12 3 -2)))
              (rk:list 1 2 5 12 3))

(check-expect (->list (filter negative? (list 1 2 -4 5 0 -6 12 3 -2)))
              (rk:list -4 -6 -2))

(check-expect (->list (remove positive? (list 1 2 -4 5 0 -6 12 3 -2)))
              (rk:list -4 0 -6 -2))

(check-expect (->list (remove negative? (list 1 2 -4 5 0 -6 12 3 -2)))
              (rk:list 1 2 5 0 12 3))
(test)
