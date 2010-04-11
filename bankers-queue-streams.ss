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
(define empty (make-Queue null-stream ZERO null-stream ZERO))

;; Checks if the given queue is empty
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? que)
  (zero? (Queue-lenf que)))


;; A Pseudo-constructor. Maintains the invariant lenf >= lenr
(: internal-queue : 
   (All (A) ((Stream A) Integer (Stream A) Integer -> (Queue A))))
(define (internal-queue front lenf rear lenr)
  (if (>= lenf lenr)
      (make-Queue front lenf rear lenr)
      (make-Queue (stream-append front (stream-reverse rear))
                  (+ lenf lenr)
                  null-stream ZERO)))

;; Pushes an element into the queue
(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue elem que)
  (internal-queue (Queue-front que) 
                  (Queue-lenf que) 
                  (stream-cons elem (Queue-rear que))
                  (add1 (Queue-lenr que))))

;; Retrieves the head element of the queue
(: head : (All (A) ((Queue A) -> A)))
(define (head que)
  (if (empty? que)
      (error "Queue is empty :" 'head)
      (stream-car (Queue-front que))))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (if (empty? que)
      (error "Queue is empty :" 'tail)
      (internal-queue (stream-cdr (Queue-front que))
                      (sub1 (Queue-lenf que))
                      (Queue-rear que)
                      (Queue-lenr que))))

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (zero? (Queue-lenf que))
      null
      (cons (head que) (queue->list (tail que)))))

;; A Queue constructor with the given element
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))