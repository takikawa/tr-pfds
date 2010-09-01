#lang typed/scheme
(require (prefix-in sh: scheme/base))
(require (rename-in "../catenablelist1.ss"))
(require typed/test-engine/scheme-tests)

(check-expect (first (list 1 2 3 4 5 6 7)) 1)
(check-expect (first (list "" "")) "")
(check-expect (rest (list 1)) empty)
(check-expect (first (rest (list 1 2 3 4 5 6 7))) 2)

(check-expect (empty? (rest (list 1))) #t)
(check-expect (empty? (rest (list 2 1))) #f)
(check-expect (empty? empty) #t)
(check-error (first empty) "first: given list is empty")
(check-error (rest empty) "rest: given list is empty")
(check-expect (->list (rest (list 1 2 3 4 5 6 7)))
              (sh:list 2 3 4 5 6 7))

(check-expect (->list (rest (rest (list 1 2 3 4 5 6 7))))
              (sh:list 3 4 5 6 7))

(check-expect (->list (append (list 1) 
                                   (list 1 2 3 4 5 6 7))) 
              (sh:list 1 1 2 3 4 5 6 7))

(check-expect (->list (append empty 
                                   (list 1 2 3 4 5 6 7))) 
              (sh:list 1 2 3 4 5 6 7))

(check-expect (->list (append (list 1 2 3 4 5 6 7) empty)) 
              (sh:list 1 2 3 4 5 6 7))

(check-expect (->list (append empty empty)) null)

(check-expect (->list (cons-to-end 0 (list 1 2 3 4 5 6 7)))
              (sh:list 1 2 3 4 5 6 7 0))

(check-expect (->list (cons-to-end 0 (list 1 2 3)))
              (sh:list 1 2 3 0))

(check-expect (->list (cons 0 (list 1)))
              (sh:list 0 1))

(check-expect (->list (cons-to-end 0 empty)) (sh:list 0))

(check-expect (->list (cons 0 empty)) (sh:list 0))

(define lst (sh:build-list 100 (λ: ([x : Integer]) x)))
(define lst1 (sh:build-list 100 (λ: ([x : Integer]) (+ x 100))))
(check-expect (->list (apply list lst)) lst)

(check-expect (->list (append (apply list lst) (apply list lst1))) 
              (sh:append lst lst1))

(test)
