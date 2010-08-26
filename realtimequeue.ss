#lang typed/scheme #:optimize

(provide filter remove
         queue queue->list empty empty? (rename-out [qmap map]) fold
         head tail enqueue Queue list->queue)

(require "stream.ss")

(struct: (A) Queue ([front : (Stream A)]
                    [rear  : (Listof A)]
                    [scdul : (Stream A)]))


;; An empty queue
(define empty (Queue empty-stream null empty-stream))

;; Function to check for empty queue
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? rtq)
  (empty-stream? (Queue-front rtq)))


(: rotate : (All (A) ((Stream A) (Listof A) (Stream A) -> (Stream A))))
(define (rotate frnt rer accum)
  (let ([carrer (car rer)])
    (if (empty-stream? frnt)
        (stream-cons carrer accum)
        (stream-cons (stream-car frnt)
                     (rotate (stream-cdr frnt) 
                             (cdr rer) 
                             (stream-cons carrer accum))))))

(: internal-queue : (All (A) ((Stream A) (Listof A) (Stream A) -> (Queue A))))
(define (internal-queue front rear schdl)
  (if (empty-stream? schdl)
      (let ([newf (rotate front rear schdl)])
        (Queue newf null newf))
      (Queue front rear (stream-cdr schdl))))


(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue elem rtq)
  (internal-queue (Queue-front rtq)
                  (cons elem (Queue-rear rtq))
                  (Queue-scdul rtq)))


(: head : (All (A) ((Queue A) -> A)))
(define (head rtq)
  (if (empty? rtq)
      (error 'head "given queue is empty")
      (stream-car (Queue-front rtq))))


(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail rtq)
  (if (empty? rtq)
      (error 'tail "given queue is empty")
      (internal-queue (stream-cdr (Queue-front rtq)) 
                      (Queue-rear rtq) 
                      (Queue-scdul rtq))))


;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: qmap : 
   (All (A C B ...) 
        (case-lambda 
          ((A -> C) (Queue A) -> (Queue C))
          ((A B ... B -> C) (Queue A) (Queue B) ... B -> (Queue C)))))
(define qmap
  (pcase-lambda: (A C B ...)
                 [([func : (A -> C)]
                   [deq  : (Queue A)])
                  (map-single empty func deq)]
                 [([func : (A B ... B -> C)]
                   [deq  : (Queue A)] . [deqs : (Queue B) ... B])
                  (apply map-multiple empty func deq deqs)]))


(: map-single : (All (A C) ((Queue C) (A -> C) (Queue A) -> (Queue C))))
(define (map-single accum func que)
  (if (empty? que)
      accum
      (map-single (enqueue (func (head que)) accum) func (tail que))))

(: map-multiple : 
   (All (A C B ...) 
        ((Queue C) (A B ... B -> C) (Queue A) (Queue B) ... B -> (Queue C))))
(define (map-multiple accum func que . ques)
  (if (or (empty? que) (ormap empty? ques))
      accum
      (apply map-multiple
             (enqueue (apply func (head que) (map head ques)) accum)
             func 
             (tail que)
             (map tail ques))))


;; similar to list foldr or foldl
(: fold : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (Queue A) -> C)
                     ((C A B ... B -> C) C (Queue A) (Queue B) ... B -> C))))
(define fold
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [que  : (Queue A)])
                  (if (empty? que)
                      base
                      (fold func (func base (head que)) (tail que)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [que  : (Queue A)] . [ques : (Queue B) ... B])
                  (if (or (empty? que) (ormap empty? ques))
                      base
                      (apply fold 
                             func 
                             (apply func base (head que) (map head ques))
                             (tail que)
                             (map tail ques)))]))


(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list rtq)
  (if (empty? rtq)
      null
      (cons (head rtq) (queue->list (tail rtq)))))

(: list->queue : (All (A) ((Listof A) -> (Queue A))))
(define (list->queue lst)
  (foldl (inst enqueue A) empty lst))

(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))

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
