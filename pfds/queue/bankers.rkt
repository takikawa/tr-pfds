#lang typed/racket

(require "../stream.rkt")

(provide filter remove head+tail build-queue
         Queue empty empty? enqueue head tail queue queue->list
         (rename-out [qmap map] 
                     [queue-andmap andmap] 
                     [queue-ormap ormap]) fold)

;; A Banker's Queue (Maintains length of front >= length of rear)

(struct: (A) Queue ([front : (Stream A)]
                    [lenf  : Integer]
                    [rear  : (Stream A)]
                    [lenr  : Integer]))


;; An empty queue
(define-syntax-rule (empty A)
  ((inst Queue A) empty-stream 0 empty-stream 0))

;; Checks if the given queue is empty
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? que)
  (zero? (Queue-lenf que)))


;; A Pseudo-constructor. Maintains the invariant lenf >= lenr
(: internal-queue : 
   (All (A) ((Stream A) Integer (Stream A) Integer -> (Queue A))))
(define (internal-queue front lenf rear lenr)
  (if (>= lenf lenr)
      ((inst Queue A) front lenf rear lenr)
      (Queue (stream-append front (stream-reverse rear))
             (+ lenf lenr)
             empty-stream 0)))

;; Pushes an element into the queue
(: enqueue : (All (A) A (Queue A) -> (Queue A)))
(define (enqueue elem que)
  (internal-queue (Queue-front que) 
                  (Queue-lenf que) 
                  (ann (stream-cons elem (Queue-rear que)) (Stream A))
                  (add1 (Queue-lenr que))))

;; Retrieves the head element of the queue
(: head : (All (A) ((Queue A) -> A)))
(define (head que)
  (if (zero? (Queue-lenf que))
      (error 'head "given queue is empty")
      (stream-car (Queue-front que))))

;; Queueue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (let ([lenf (Queue-lenf que)])
    (if (zero? lenf)
        (error 'tail "given queue is empty")
        (internal-queue (stream-cdr (Queue-front que))
                        (sub1 lenf)
                        (Queue-rear que)
                        (Queue-lenr que)))))

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
                  (map-single ((inst Queue C) empty-stream 0 empty-stream 0) 
                              func deq)]
                 [([func : (A B ... B -> C)]
                   [deq  : (Queue A)] . [deqs : (Queue B) ... B])
                  (apply map-multiple 
                         ((inst Queue C) empty-stream 0 empty-stream 0) 
                         func deq deqs)]))


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
  (inner func que ((inst Queue A) empty-stream 0 empty-stream 0) ))

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
  (inner func que ((inst Queue A) empty-stream 0 empty-stream 0) ))

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (zero? (Queue-lenf que))
      null
      (cons (head que) (queue->list (tail que)))))

;; A Queue constructor with the given element
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) 
         ((inst Queue A) empty-stream 0 empty-stream 0) 
         lst))

;; Similar to build-list function
(: build-queue : (All (A) (Natural (Natural -> A) -> (Queue A))))
(define (build-queue size func)
  (let: loop : (Queue A) ([n : Natural size])
        (if (zero? n)
            ((inst Queue A) empty-stream 0 empty-stream 0)
            (let ([nsub1 (sub1 n)])
              (enqueue (func nsub1) (loop nsub1))))))

;; Returns pair of the first element of the queue and the rest 
;; of the queue
(: head+tail : (All (A) ((Queue A) -> (Pair A (Queue A)))))
(define (head+tail que)
  (let ([lenf (Queue-lenf que)])
    (if (zero? lenf)
        (error 'head+tail "given queue is empty")
        (let ([front (Queue-front que)])
          (cons (stream-car front) 
                (internal-queue (stream-cdr front)
                                (sub1 lenf)
                                (Queue-rear que)
                                (Queue-lenr que)))))))

;; similar to list andmap function
(: queue-andmap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Queue A) -> Boolean)
                     ((A B ... B -> Boolean) (Queue A) (Queue B) ... B -> Boolean))))
(define queue-andmap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [queue : (Queue A)])
                  (or (empty? queue)
                      (and (func (head queue))
                           (queue-andmap func (tail queue))))]
                 [([func  : (A B ... B -> Boolean)]
                   [queue : (Queue A)] . [queues : (Queue B) ... B])
                  (or (empty? queue) (ormap empty? queues)
                      (and (apply func (head queue) (map head queues))
                           (apply queue-andmap func (tail queue) 
                                  (map tail queues))))]))

;; Similar to ormap
(: queue-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Queue A) -> Boolean)
                     ((A B ... B -> Boolean) (Queue A) (Queue B) ... B -> Boolean))))
(define queue-ormap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [queue : (Queue A)])
                  (and (not (empty? queue))
                       (or (func (head queue))
                           (queue-ormap func (tail queue))))]
                 [([func  : (A B ... B -> Boolean)]
                   [queue : (Queue A)] . [queues : (Queue B) ... B])
                  (and (not (or (empty? queue) (ormap empty? queues)))
                       (or (apply func (head queue) (map head queues))
                           (apply queue-ormap func (tail queue) 
                                  (map tail queues))))]))
