#lang typed-scheme

(require "stream.ss")

(provide Queue empty empty? enqueue head tail)
         
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
    (eq? (Queue-lenf que) ZERO)))


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
                                    (Queue-lenf que))))))

;; A Queue constructor with the given element
(: queue : (All (A) ((Listof A) -> (Queue A))))
(define (queue lst)
  (foldl (inst enqueue A) empty lst))


;;------------------------------------------------------------------------
;; Checks if the given two Queues are equal. (Defined for tests)
(: check-eq? : (All (A) ((Queue A) (Queue A) -> Boolean)))
(define check-eq?
  (lambda (que1 que2)
    (and (andmap equal? 
                 (stream->list (Queue-front que1)) 
                 (stream->list (Queue-front que2)))
         (andmap equal? 
                 (stream->list (Queue-rear que1)) 
                 (stream->list (Queue-rear que2))))))

(and 
 (eq? (empty? empty) #t)
 (eq? (empty? (make-Queue (stream '(4 2)) 2 (stream '(4)) 0)) #f)
 
 (eq? (head (make-Queue (stream '(4 2)) 2 (stream '(4)) 1)) 4)
 (eq? (head (make-Queue (stream '(2)) 1 (stream '(4)) 1)) 2)  
 
 (check-eq? (tail (make-Queue (stream '(4)) 1 (stream '(2)) 1)) 
            (make-Queue (stream '(2)) 1 (stream '()) 0))
 (check-eq? (tail (make-Queue (stream '(4 2)) 2 (stream '(4)) 1)) 
            (make-Queue (stream '(2 4)) 2 (stream '()) 0))
 (check-eq? (tail (make-Queue (stream '(4 2)) 2 (stream '(4 5)) 2)) 
            (make-Queue (stream '(2 5 4)) 3 null-stream 0))
 
 (check-eq? (internal-queue empty) empty)
 (check-eq? (internal-queue (make-Queue (stream '(4 2)) 2 (stream '(4)) 1)) 
            (make-Queue (stream '(4 2)) 2 (stream '(4)) 1))
 (check-eq? (internal-queue (make-Queue (stream '(4 2)) 2 (stream '(4 5)) 2)) 
            (make-Queue (stream '(4 2)) 2 (stream '(4 5)) 2))
 (check-eq? (internal-queue (make-Queue (stream '(4 2)) 2 (stream '(4 5 6)) 3)) 
            (make-Queue (stream '(4 2 6 5 4)) 5 null-stream 0))
 
 (check-eq? (enqueue 1 empty) (make-Queue (stream '(1)) 1 null-stream 0))
 (check-eq? (enqueue 4 (make-Queue (stream '(4 2)) 2 null-stream 0)) 
            (make-Queue (stream '(4 2)) 2 (stream '(4)) 1))
 (check-eq? (enqueue 5 (make-Queue (stream '(4 2)) 2 (stream '(4)) 1)) 
            (make-Queue (stream '(4 2)) 2 (stream '(5 4)) 2))
 (check-eq? (enqueue "6" (make-Queue (stream '(4 2)) 2 (stream '(4 5)) 2)) 
            (make-Queue (stream '(4 2 5 4 "6")) 5 null-stream 0))
 
 (check-eq? (queue null) empty)
 (check-eq? (queue (list 1 2 3))
            (make-Queue (stream '(1 2 3)) 3 (stream '()) 0))
 (check-eq? (queue (list 1))
            (make-Queue (stream '(1)) 1 null-stream 0))
 (check-eq? (queue (list 1 2 3 4))
            (make-Queue (stream '(1 2 3)) 3 (stream '(4)) 1))
 (check-eq? (queue (list 1 2 3 4 5))
            (make-Queue (stream '(1 2 3)) 3 (stream '(5 4)) 2))
 (check-eq? (queue (list 1 2 3 4 5 6))
            (make-Queue (stream '(1 2 3)) 3 (stream '(6 5 4)) 3))
 (check-eq? (queue (list 1 2 3 4 5 6 7))
            (make-Queue (stream '(1 2 3 4 5 6 7)) 7 (stream '()) 0))
 
 ;; Problem in check-eq?
 (check-eq? (queue (list '(1) '(2 2) '(3 4) '(5 6 7) '(5))) 
            (make-Queue (stream (list '(1) '(2 2) '(3 4))) 3 (stream (list '(5) '(5 6 7))) 2)))