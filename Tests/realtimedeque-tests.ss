#lang typed-scheme
(require "../realtimedeque.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (rtdeque 1)) #f)
(check-expect (head (rtdeque 1)) 1)
(check-expect (last (rtdeque 1)) 1)
(check-expect (head (rtdeque 4 5 1 2 -1)) -1)
(check-expect (head (tail (rtdeque 4 5 1 2 -1))) 2)
(check-expect (last (rtdeque 4 5 1 2 -1)) 4)
(check-expect (last (init (rtdeque 4 5 1 2 -1))) 5)
(check-expect (head (tail (init (rtdeque 4 5 1 2 -1)))) 2)
(check-expect (last (tail (init (rtdeque 4 5 1 2 -1)))) 5)

(check-error (head empty) "Deque is empty : head")
(check-error (last empty) "Deque is empty : last")
(check-error (tail empty) "Deque is empty : tail")
(check-error (init empty) "Deque is empty : init")

(check-expect (rtdeque->list (tail (rtdeque 1))) null)
(check-expect (rtdeque->list (init (rtdeque 1))) null)
(check-expect (rtdeque->list (tail (rtdeque 1 2 3 4))) (list 1 2 3))
(check-expect (rtdeque->list (init (rtdeque 1 2 3 4))) (list 2 3 4))

(check-expect (rtdeque->list (enqueue 1 empty)) (list 1))
(check-expect (rtdeque->list (snoc 1 empty)) (list 1))
(check-expect (rtdeque->list (enqueue 1 (rtdeque 2))) (list 2 1))
(check-expect (rtdeque->list (snoc 1 (rtdeque 2))) (list 1 2))
(check-expect (rtdeque->list (enqueue 1 (rtdeque 2 3))) (list 2 3 1))
(check-expect (rtdeque->list (snoc 1 (rtdeque 2 3))) (list 1 2 3))

(test)