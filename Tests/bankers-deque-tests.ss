#lang typed-scheme
(require "../bankers-deque.ss")
(require typed/test-engine/scheme-tests)

(check-expect (dq-empty? empty) #t)
(check-expect (dq-empty? (deque (list 1 2 3))) #f)

(check-expect (dq-head (deque (list 1 2 3))) 1)
(check-expect (dq-head (deque (list 5 6 2 3))) 5)
(check-error (dq-head (deque (list))) "Deque is empty : dq-head")

(check-expect (dq-last (deque (list 1 2 3))) 3)
(check-expect (dq-last (deque (list 5 6 2 8))) 8)
(check-error (dq-last (deque (list))) "Deque is empty : dq-last")

(check-expect (deque->list (dq-tail (deque (list 1 2 3)))) (list 2 3))
(check-expect (deque->list (dq-tail (deque (list 1 2 3 5 7 8)))) (list 2 3 5 7 8))
(check-error (dq-tail (deque (list))) "Deque is empty : dq-tail")

(check-expect (deque->list (dq-init (deque (list 1 2 3)))) (list 1 2))
(check-expect (deque->list (dq-init (deque (list 1 2 3 5 7 8)))) (list 1 2 3 5 7))
(check-error (dq-init (deque (list))) "Deque is empty : dq-init")

(check-expect (deque->list (dq-snoc 1 empty)) (list 1))
(check-expect (deque->list (dq-snoc 4 (deque (list 1 2)))) (list 1 2 4))

(check-expect (deque->list (dq-cons 1 empty)) (list 1))
(check-expect (deque->list (dq-cons 4 (deque (list 1 2)))) (list 4 1 2))

(test)