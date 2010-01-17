#lang typed-scheme
(require "../implicitqueue.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (implicit-queue (list 1))) #f)
(check-expect (head (implicit-queue (list 1))) 1)
(check-error (head (implicit-queue (list))) "Queue is empty : head")
(check-expect (head (implicit-queue (list 1 2))) 1)
(check-expect (head (implicit-queue (list 10 2 34 55))) 10)

(check-expect (queue->list (tail (implicit-queue (list 1)))) null)
(check-error (tail (implicit-queue (list))) "Queue is empty : tail")
(check-expect (queue->list (tail (implicit-queue (list 10 12)))) (list 12))
(check-expect (queue->list (tail (implicit-queue (list 23 45 -6)))) (list 45 -6))
(check-expect (queue->list (tail (implicit-queue (list 23 45 -6 15)))) 
              (list 45 -6 15))

(check-expect (queue->list (enqueue 10 (implicit-queue (list 23 45 -6 15)))) 
              (list 23 45 -6 15 10))
(check-expect (queue->list (enqueue 10 (implicit-queue (list)))) (list 10))

(check-expect (queue->list (enqueue 10 (implicit-queue (list 20)))) 
              (list 20 10))

(test)