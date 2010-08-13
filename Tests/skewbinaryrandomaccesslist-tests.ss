#lang typed-scheme
(require (prefix-in sh: scheme/base))
(require "../skewbinaryrandomaccesslist.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (list 1 2 3)) #f)
(check-expect (head (list 1 2 3)) 1)
(check-expect (head (list 2 3)) 2)
(check-error (head null) "head: given list is empty")

(check-expect (->list (tail (list 1 2 3))) (sh:list 2 3))
(check-expect (->list (tail (list 2 3))) (sh:list 3))
(check-expect (->list (tail (list 3))) null)
(check-error (tail null) "tail: given list is empty")

(check-expect (->list (cons 5 (list 1 2 3))) 
              (sh:list 5 1 2 3))
(check-expect (->list (cons 10 (list 2 3))) 
              (sh:list 10 2 3))
(check-expect (->list (cons 12 (list 3))) 
              (sh:list 12 3))
(check-expect (->list (cons 12 null)) 
              (sh:list 12))

(check-expect (->list (list-set (list 1 2 3) 2 5)) 
              (sh:list 1 2 5))
(check-expect (->list (list-set (list 1 2 3 5 6) 4 10)) 
              (sh:list 1 2 3 5 10))
(check-error (list-set (list 1 2 3 5) 4 10) 
             "list-set: given index out of bounds")
(check-error (list-set null 0 10)
             "list-set: given index out of bounds")
(check-error (list-set null -1 10)
             "list-set: given index out of bounds")

(check-expect (list-ref (list 1 2 3) 2) 3)
(check-expect (list-ref (list 1 2 3) 0) 1)
(check-expect (list-ref (list 1 2 3) 1) 2)
(check-error (list-ref (list 1 2 3 5) 4) 
             "list-ref: given index out of bounds")
(check-error (list-ref null 0)
             "list-ref: given index out of bounds")
(check-error (list-ref null -1)
             "list-ref: given index out of bounds")

(check-expect (->list (drop 2 (list 1 2 3))) 
              (sh:list 3))
(check-expect (->list (drop 5 (list 1 2 3 5 6))) 
              (sh:list))
(check-expect (->list (drop 3 (list 1 2 3 5 6))) 
              (sh:list 5 6))
(check-expect (drop 0 null) null)
(check-error (drop 5 (list 1 2 3 5)) 
             "drop: not enough elements to drop")
(check-error (drop -1 null)
             "drop: not enough elements to drop")

(define lst (build-list 100 (λ(x) x)))
(check-expect (->list (apply list lst)) lst)

(check-expect (list-length (list 1 2 3)) 3)
(check-expect (list-length (list 1 2 3 10 12)) 5)
(check-expect (list-length null) 0)

(check-expect (->list (map + (list 1 2 3 4 5) (list 1 2 3 4 5)))
              (sh:list 2 4 6 8 10))

(check-expect (->list (map - (list 1 2 3 4 5) (list 1 2 3 4 5)))
              (sh:list 0 0 0 0 0))

(check-expect (foldl + 0 (list 1 2 3 4 5)) 15)

(check-expect (foldl - 2 (list 1 2 3 4 5)) -13)

(check-expect (foldr + 0 (list 1 2 3 4 5)) 15)

(check-expect (foldr + 0 (list 1 2 3 4 5) (list 1 2 3 4 5)) 30)

(check-expect (->list (filter positive? (list 1 2 -4 5 0 -6 12 3 -2)))
              (sh:list 1 2 5 12 3))

(check-expect (->list (filter negative? (list 1 2 -4 5 0 -6 12 3 -2)))
              (sh:list -4 -6 -2))

(check-expect (->list (remove positive? (list 1 2 -4 5 0 -6 12 3 -2)))
              (sh:list -4 0 -6 -2))

(check-expect (->list (remove negative? (list 1 2 -4 5 0 -6 12 3 -2)))
              (sh:list 1 2 5 0 12 3))

(test)
