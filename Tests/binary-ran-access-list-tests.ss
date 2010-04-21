#lang typed-scheme
(require "../binaryrandomaccesslist.ss")
(require typed/test-engine/scheme-tests)

(check-expect (head (ralist 1 2 3 4 5 6 7)) 1)
(check-expect (head (ralist "" "")) "")
(check-expect (tail (ralist 1)) (ralist))
(check-expect (head (tail (ralist 1 2 3 4 5 6 7))) 2)

(check-expect (empty? (tail (ralist 1))) #t)
(check-expect (empty? (tail (ralist 2 1))) #f)

(check-expect (ralist->list (tail (ralist 1 2 3 4 5 6 7)))
              (list 2 3 4 5 6 7))

(check-expect (ralist->list (tail (tail (ralist 1 2 3 4 5 6 7))))
              (list 3 4 5 6 7))

(check-expect (drop 1 (ralist 1)) (ralist))
(check-expect (ralist->list (drop 2 (ralist 1 2 3 4 5 6 7))) 
              (list 3 4 5 6 7))

(check-expect (ralist->list (drop 0 (ralist 1 2 3 4 5 6 7)))
              (list 1 2 3 4 5 6 7))
(check-error (drop 8 (ralist 1 2 3 4 5 6 7)) 
             "drop: Not enough elements to drop")
(check-error (drop -1 (ralist 1 2 3 4 5 6 7)) 
             "drop: Not enough elements to drop")

(check-expect (ralist->list (update 2 (ralist 1 2 3 4 5 6 7) 1234))
              (list 1 2 1234 4 5 6 7))

(check-expect (ralist->list (update 0 (ralist 1 2 3 4 5 6 7) 1234))
              (list 1234 2 3 4 5 6 7))

(check-error (update -2 (ralist 1 2 3 4 5 6 7) 1234)
             "update: Given index out of bound")

(check-error (update 20 (ralist 1 2 3 4 5 6 7) 1234)
             "update: Given index out of bound")

(define lst (build-list 100 (λ(x) x)))
(check-expect (ralist->list (apply ralist lst)) lst)

(check-expect (list-length empty) 0)
(check-expect (list-length (ralist 1)) 1)
(check-expect (list-length (ralist 1 2 3 4 5 6 7)) 7)

(check-expect (list-length (ralist 1 2 3 4 5)) 5)

(check-expect (list-length (apply ralist lst)) 100)
(test)