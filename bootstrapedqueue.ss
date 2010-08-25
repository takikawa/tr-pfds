#lang typed/scheme #:optimize

(require (prefix-in pq: "physicists-queue.ss"))
(provide filter remove
         empty empty? enqueue head tail queue queue->list Queue
         (rename-out [qmap map]) fold)

(require scheme/promise)
(define-type-alias (Mid A) (pq:Queue (Promise (Listof A))))
(define-struct: (A) IntQue ([F : (Listof A)]
                            [M : (Mid A)]
                            [LenFM : Integer]
                            [R : (Listof A)]
                            [LenR : Integer]))

;; An empty queue
(define empty null)

(define-type-alias (Queue A) (U Null (IntQue A)))

;; Checks for empty
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? bsq)
  (null? bsq))

;; Maintains invarients
(: internal-queue : (All (A) ((Listof A) (Mid A) Integer (Listof A) Integer 
                                         -> (Queue A))))
(define (internal-queue f m lenfm r lenr)
  (if (<= lenr lenfm) 
      (checkF (make-IntQue f m lenfm r lenr))
      (checkF (make-IntQue f (pq:enqueue (delay (reverse r)) m) 
                           (+ lenfm lenr)
                           null 0))))

;; Inserts an element into the queue
(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue elem bsq)
  (if (null? bsq)
      (make-IntQue (cons elem null) pq:empty 1 null 0)
      (internal-queue (IntQue-F bsq)
                      (IntQue-M bsq)
                      (IntQue-LenFM bsq)
                      (cons elem (IntQue-R bsq))
                      (add1 (IntQue-LenR bsq)))))

;; Returns the first element of the queue
(: head : (All (A) ((Queue A) -> A)))
(define (head bsq)
  (if (null? bsq)
      (error 'head "given queue is empty")
      (car (IntQue-F bsq))))

;; Returns the rest of the queue
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail bsq)
  (if (null? bsq)
      (error 'tail "given queue is empty")
      (internal-queue (cdr (IntQue-F bsq)) 
                      (IntQue-M bsq) 
                      (sub1 (IntQue-LenFM bsq)) 
                      (IntQue-R bsq)
                      (IntQue-LenR bsq))))

;; Invarient check
(: checkF : (All (A) ((IntQue A) -> (Queue A))))
(define (checkF que)
  (let* ([front (IntQue-F que)]
         [mid (IntQue-M que)])
    (if (null? front) 
        (if (pq:empty? mid) 
            empty
            (make-IntQue (force (pq:head mid))
                         (pq:tail mid)
                         (IntQue-LenFM que)
                         (IntQue-R que)
                         (IntQue-LenR que)))
        que)))


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
(define (queue->list bsq)
  (if (null? bsq)
      null
      (cons (head bsq) (queue->list (tail bsq))))) 

;; Queue constructor
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))

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
