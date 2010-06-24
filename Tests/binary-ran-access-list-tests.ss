#lang typed/scheme
(require (prefix-in sh: scheme/base))
(require "../binaryrandomaccesslist.ss")
(require typed/test-engine/scheme-tests)

(check-expect (head (list 1 2 3 4 5 6 7)) 1)
(check-expect (head (list "" "")) "")
(check-expect (tail (list 1)) (list))
(check-expect (head (tail (list 1 2 3 4 5 6 7))) 2)

(check-expect (empty? (tail (list 1))) #t)
(check-expect (empty? (tail (list 2 1))) #f)

(check-expect (->list (tail (list 1 2 3 4 5 6 7)))
              (sh:list 2 3 4 5 6 7))

(check-expect (->list (tail (tail (list 1 2 3 4 5 6 7))))
              (sh:list 3 4 5 6 7))

(check-expect (drop 1 (list 1)) (list))
(check-expect (->list (drop 2 (list 1 2 3 4 5 6 7))) 
              (sh:list 3 4 5 6 7))

(check-expect (->list (drop 0 (list 1 2 3 4 5 6 7)))
              (sh:list 1 2 3 4 5 6 7))
(check-error (drop 8 (list 1 2 3 4 5 6 7)) 
             "drop: Not enough elements to drop")
(check-error (drop -1 (list 1 2 3 4 5 6 7)) 
             "drop: Not enough elements to drop")

(check-expect (->list (list-set (list 1 2 3 4 5 6 7) 2 1234))
              (sh:list 1 2 1234 4 5 6 7))

(check-expect (->list (list-set (list 1 2 3 4 5 6 7) 0 1234))
              (sh:list 1234 2 3 4 5 6 7))

(check-error (list-set (list 1 2 3 4 5 6 7) -2 1234)
             "list-set: given index out of bound")

(check-error (list-set (list 1 2 3 4 5 6 7) 20 1234)
             "list-set: given index out of bound")

(define lst (build-list 100 (λ(x) x)))
(check-expect (->list (apply list lst)) lst)

(check-expect (list-length empty) 0)
(check-expect (list-length (list 1)) 1)
(check-expect (list-length (list 1 2 3 4 5 6 7)) 7)

(check-expect (list-length (list 1 2 3 4 5)) 5)

(check-expect (list-length (apply list lst)) 100)
(test)
