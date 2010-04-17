#lang typed-scheme
(require "../realtimedeque.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (deque 1)) #f)
(check-expect (head (deque 1)) 1)
(check-expect (last (deque 1)) 1)
(check-expect (head (deque 4 5 1 2 -1)) -1)
(check-expect (head (tail (deque 4 5 1 2 -1))) 2)
(check-expect (last (deque 4 5 1 2 -1)) 4)
(check-expect (last (init (deque 4 5 1 2 -1))) 5)
(check-expect (head (tail (init (deque 4 5 1 2 -1)))) 2)
(check-expect (last (tail (init (deque 4 5 1 2 -1)))) 5)

(check-error (head empty) "head: Given deque is empty")
(check-error (last empty) "last: Given deque is empty")
(check-error (tail empty) "tail: Given deque is empty")
(check-error (init empty) "init: Given deque is empty")

(check-expect (deque->list (tail (deque 1))) null)
(check-expect (deque->list (init (deque 1))) null)
(check-expect (deque->list (tail (deque 1 2 3 4))) (list 1 2 3))
(check-expect (deque->list (init (deque 1 2 3 4))) (list 2 3 4))

(check-expect (deque->list (enqueue 1 empty)) (list 1))
(check-expect (deque->list (enqueue-front 1 empty)) (list 1))
(check-expect (deque->list (enqueue 1 (deque 2))) (list 2 1))
(check-expect (deque->list (enqueue-front 1 (deque 2))) (list 1 2))
(check-expect (deque->list (enqueue 1 (deque 2 3))) (list 2 3 1))
(check-expect (deque->list (enqueue-front 1 (deque 2 3))) (list 1 2 3))

(define lst (build-list 100 (λ: ([x : Integer]) x)))

(check-expect (deque->list (apply deque lst)) lst)

(test)
