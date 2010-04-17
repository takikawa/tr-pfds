#lang typed-scheme
(require "../implicitqueue.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (queue 1)) #f)
(check-expect (head (queue 1)) 1)
(check-error (head empty) "head: Given queue is empty")
(check-expect (head (queue 1 2)) 1)
(check-expect (head (queue 10 2 34 55)) 10)

(check-expect (queue->list (tail (queue 1))) null)
(check-error (tail empty) "tail: Given queue is empty")
(check-expect (queue->list (tail (queue 10 12))) (list 12))
(check-expect (queue->list (tail (queue 23 45 -6))) (list 45 -6))
(check-expect (queue->list (tail (queue 23 45 -6 15)))
              (list 45 -6 15))

(check-expect (queue->list (enqueue 10 (queue 23 45 -6 15)))
              (list 23 45 -6 15 10))
(check-expect (queue->list (enqueue 10 empty)) (list 10))

(check-expect (queue->list (enqueue 10 (queue 20)))
              (list 20 10))
(check-expect (queue->list (apply queue (build-list 100 (λ(x) x))))
              (build-list 100 (λ(x) x)))
(test)
