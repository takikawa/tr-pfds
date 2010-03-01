#lang typed-scheme
(require "../implicitqueue-try.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (implicit-queue 1)) #f)
(check-expect (head (implicit-queue 1)) 1)
(check-error (head empty) "Queue is empty : head")
(check-expect (head (implicit-queue 1 2)) 1)
(check-expect (head (implicit-queue 10 2 34 55)) 10)

(check-expect (queue->list (tail (implicit-queue 1))) null)
(check-error (tail empty) "Queue is empty : tail")
(check-expect (queue->list (tail (implicit-queue 10 12))) (list 12))
(check-expect (queue->list (tail (implicit-queue 23 45 -6))) (list 45 -6))
(check-expect (queue->list (tail (implicit-queue 23 45 -6 15))) 
              (list 45 -6 15))

(check-expect (queue->list (enqueue 10 (implicit-queue 23 45 -6 15)))
              (list 23 45 -6 15 10))
(check-expect (queue->list (enqueue 10 empty)) (list 10))

(check-expect (queue->list (enqueue 10 (implicit-queue 20))) 
              (list 20 10))
(check-expect (queue->list (apply implicit-queue (build-list 100 (λ(x) x))))
              (build-list 100 (λ(x) x)))
(test)