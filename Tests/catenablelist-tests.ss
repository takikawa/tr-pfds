#lang typed-scheme
(require (rename-in "../catenablelist.ss" [list catlist]))
(require typed/test-engine/scheme-tests)

(check-expect (first (clist 1 2 3 4 5 6 7)) 1)
(check-expect (first (clist "" "")) "")
(check-expect (rest (clist 1)) empty)
(check-expect (first (rest (clist 1 2 3 4 5 6 7))) 2)

(check-expect (empty? (rest (clist 1))) #t)
(check-expect (empty? (rest (clist 2 1))) #f)
(check-expect (empty? empty) #t)
(check-error (first empty) "first: given list is empty")
(check-error (rest empty) "rest: given list is empty")
(check-expect (clist->list (rest (clist 1 2 3 4 5 6 7)))
              (list 2 3 4 5 6 7))

(check-expect (clist->list (rest (rest (clist 1 2 3 4 5 6 7))))
              (list 3 4 5 6 7))

(check-expect (clist->list (append (clist 1) 
                                  (clist 1 2 3 4 5 6 7))) 
              (list 1 1 2 3 4 5 6 7))

(check-expect (clist->list (append empty 
                                  (clist 1 2 3 4 5 6 7))) 
              (list 1 2 3 4 5 6 7))

(check-expect (clist->list (append (clist 1 2 3 4 5 6 7) empty)) 
              (list 1 2 3 4 5 6 7))

(check-expect (clist->list (append empty empty)) null)

(check-expect (clist->list (kons-rear 0 (clist 1 2 3 4 5 6 7)))
              (list 1 2 3 4 5 6 7 0))

(check-expect (clist->list (kons-rear 0 (clist 1 2 3)))
              (list 1 2 3 0))

(check-expect (clist->list (kons 0 (clist 1)))
              (list 0 1))

(check-expect (clist->list (kons-rear 0 empty)) (list 0))

(check-expect (clist->list (kons 0 empty)) (list 0))

(define lst (build-list 100 (λ (x) x)))

(check-expect (clist->list (apply clist lst)) lst)

(test)
