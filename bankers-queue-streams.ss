#lang typed-scheme

(require "stream.ss")

(provide Queue empty empty? enqueue head tail queue queue->list)
         
;; A Banker's Queue (Maintains length of front >= length of rear)

(define-struct: (A) Queue
  ([front : (Stream A)]
   [lenf  : Integer]
   [rear  : (Stream A)]
   [lenr  : Integer]))


;; Constants
(define ZERO 0)
(define empty (make-Queue (stream null) ZERO (stream null) ZERO))

;; Checks if the given queue is empty
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define empty?
  (lambda (que)
    (= (Queue-lenf que) 0)))


;; A Pseudo-constructor. Maintains the invariant lenf >= lenr
(: internal-queue : (All (A) ((Queue A) -> (Queue A))))
(define internal-queue
  (lambda (que)
    (if (>= (Queue-lenf que) (Queue-lenr que))
        que
        (make-Queue (stream-append (Queue-front que)
                                   (stream-reverse (Queue-rear que)))
                    (+ (Queue-lenf que) (Queue-lenr que))
                    null-stream ZERO))))

;; Pushes an element into the queue
(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define enqueue
  (lambda (elem que)
    (internal-queue (make-Queue (Queue-front que) 
                                (Queue-lenf que) 
                                (stream-cons elem (Queue-rear que))
                                (add1 (Queue-lenr que))))))

;; Retrieves the head element of the queue
(: head : (All (A) ((Queue A) -> A)))
(define head
  (lambda (que)
    (if (empty? que)
        (error "Queue is empty :" 'head)
        (stream-car (Queue-front que)))))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define tail
  (lambda (que)
    (if (empty? que)
        (error "Queue is empty :" 'head)
        (internal-queue (make-Queue (stream-cdr (Queue-front que))
                                    (sub1 (Queue-lenf que))
                                    (Queue-rear que)
                                    (Queue-lenr que))))))

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (: helper : (All (A) ((Queue A) (Listof A) -> (Listof A))))
  (define (helper intque accu)
    (if (empty? intque)
        (reverse accu)
        (helper (tail intque) (cons (head intque) accu))))
  (helper que null))

;; A Queue constructor with the given element
(: queue : (All (A) ((Listof A) -> (Queue A))))
(define (queue lst)
  (foldl (inst enqueue A) empty lst))