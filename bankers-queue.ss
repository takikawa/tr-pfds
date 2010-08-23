#lang typed/scheme ;#:optimize

(require "stream.ss")

(provide filter remove
         Queue empty empty? enqueue head tail queue queue->list
         (rename-out [qmap map]) fold)

;; A Banker's Queue (Maintains length of front >= length of rear)

(define-struct: (A) Queue
  ([front : (Stream A)]
   [lenf  : Integer]
   [rear  : (Stream A)]
   [lenr  : Integer]))


;; Constants
(define ZERO 0)
(define empty (make-Queue empty-stream ZERO empty-stream ZERO))

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
                  empty-stream ZERO)))

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
      (error 'head "given queue is empty")
      (stream-car (Queue-front que))))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (if (empty? que)
      (error 'tail "given queue is empty")
      (internal-queue (stream-cdr (Queue-front que))
                      (sub1 (Queue-lenf que))
                      (Queue-rear que)
                      (Queue-lenr que))))

;; similar to list map function 
(: qmap : (All (A C B ...) 
               ((A B ... B -> C) (Queue A) (Queue B) ... B -> (Queue C))))
(define (qmap func que . ques)
  (: in-map : (All (A C B ...) 
                   ((Queue C) (A B ... B -> C) (Queue A) (Queue B) ... B -> 
                              (Queue C))))
  (define (in-map accum func que . ques)
    (if (or (empty? que) (ormap empty? ques))
        accum
        (apply in-map 
               (enqueue (apply func (head que) (map head ques)) accum)
               func 
               (tail que)
               (map tail ques))))
  (apply in-map empty func que ques))

;; similar to list foldr or foldl
(: fold : (All (A C B ...)
               ((C A B ... B -> C) C (Queue A) (Queue B) ... B -> C)))
(define (fold func base que . ques)
  (if (or (empty? que) (ormap empty? ques))
        base
        (apply fold 
               func 
               (apply func base (head que) (map head ques))
               (tail que)
               (map tail ques))))

;; similar to list filter function
(: filter : (All (A) ((A -> Boolean) (Queue A) -> (Queue A))))
(define (filter func que)
  (: inner : (All (A) ((A -> Boolean) (Queue A) (Queue A) -> (Queue A))))
  (define (inner func que accum)
    (if (empty? que)
        accum
        (let ([head (head que)]
              [tail (tail que)])
          (if (func head)
              (inner func tail (enqueue head accum))
              (inner func tail accum)))))
  (inner func que empty))

;; similar to list remove function
(: remove : (All (A) ((A -> Boolean) (Queue A) -> (Queue A))))
(define (remove func que)
  (: inner : (All (A) ((A -> Boolean) (Queue A) (Queue A) -> (Queue A))))
  (define (inner func que accum)
    (if (empty? que)
        accum
        (let ([head (head que)]
              [tail (tail que)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (enqueue head accum))))))
  (inner func que empty))

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (zero? (Queue-lenf que))
      null
      (cons (head que) (queue->list (tail que)))))

;; A Queue constructor with the given element
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))
