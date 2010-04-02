#lang typed-scheme
(require "../bankers-deque.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (deque 1 2 3)) #f)

(check-expect (head (deque 1 2 3)) 1)
(check-expect (head (deque 5 6 2 3)) 5)
(check-error (head empty) "Deque is empty : head")

(check-expect (last (deque 1 2 3)) 3)
(check-expect (last (deque 5 6 2 8)) 8)
(check-error (last empty) "Deque is empty : last")

(check-expect (deque->list (tail (deque 1 2 3))) (list 2 3))
(check-expect (deque->list (tail (deque 1 2 3 5 7 8))) 
              (list 2 3 5 7 8))
(check-error (tail empty) "Deque is empty : tail")

(check-expect (deque->list (init (deque 1 2 3))) (list 1 2))
(check-expect (deque->list (init (deque 1 2 3 5 7 8))) 
              (list 1 2 3 5 7))
(check-error (init empty) "Deque is empty : init")

(check-expect (deque->list (enqueue 1 empty)) (list 1))
(check-expect (deque->list (enqueue 4 (deque 1 2))) (list 1 2 4))

(check-expect (deque->list (enqueue-front 1 empty)) (list 1))
(check-expect (deque->list (enqueue-front 4 (deque 1 2))) (list 4 1 2))

(define lst (build-list 100 (λ: ([x : Integer]) x)))

(check-expect (deque->list 
               (enqueue-front 40 (enqueue-front 4 (apply deque lst)))) 
              (cons 40 (cons 4 lst)))

(check-expect (deque->list (apply deque lst)) lst)

(test)