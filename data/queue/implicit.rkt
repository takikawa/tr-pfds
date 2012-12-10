#lang typed/racket

(provide filter remove build-queue head+tail
         empty empty? enqueue head tail queue->list queue
         (rename-out [qmap map] [queue-andmap andmap] 
                     [queue-ormap ormap]) fold Queue)
(require scheme/match)

(struct: Zero ())

(struct: (A) One ([elem : A]))

(struct: (A) Two ([fst : A]
                  [snd : A]))

(define-type (ZeroOne A) (U Zero (One A)))

(define-type (OneTwo A) (U (One A) (Two A)))

(struct: (A) Shallow ([elem : (ZeroOne A)]))

(struct: (A) Deep ([F : (OneTwo A)]
                   [M : (Promise (Pair (Queue A) (Queue A)))]
                   [R : (ZeroOne A)]))

(define-type (Queue A) (U (Shallow A) (Deep A)))


;; An empty queue
(define empty (Shallow (Zero)))

;; Check for empty queue
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? que)
  (and (Shallow? que) (Zero? (Shallow-elem que))))

;; Inserts an element into the queue
(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue elem que)
  (match que
    [(struct Shallow ((struct Zero ()))) (Shallow (One elem))]
    [(struct Shallow ((struct One (one)))) (Deep (Two one elem)
                                                 (delay (cons empty empty))
                                                 (Zero))]
    [(struct Deep (f m (struct Zero ()))) (Deep f m (One elem))]
    [(struct Deep (f m (struct One (el))))
     (Deep f (delay 
               (let ([forced-mid (force m)])
                 (cons (enqueue el (car forced-mid))
                       (enqueue elem (cdr forced-mid)))))
           (Zero))]))

;; Returns the first element of the queue
(: head : (All (A) ((Queue A) -> A)))
(define (head que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error 'head "given queue is empty")]
    [(struct Shallow ((struct One (one)))) one]
    [(struct Deep ((struct One (one)) _ _)) one]
    [(struct Deep ((struct Two (one two)) _ _)) one]))

;; Returns the rest of the queue
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error 'tail "given queue is empty")]
    [(struct Shallow ((struct One (one)))) (Shallow (Zero))]
    [(struct Deep ((struct Two (one two)) m r)) (Deep (One two) m r)]
    [(struct Deep (_ m r)) 
     (let* ([forced-mid (force m)]
            [carm (car forced-mid)])
       (if (empty? carm) 
           (Shallow r)
           (let* ([cdrm (cdr forced-mid)]
                  [fst (head carm)]
                  [snd (head cdrm)]
                  [new-mid (delay (cons (tail carm) (tail cdrm)))])
             (Deep (Two fst snd) new-mid r))))]))


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
                   [que  : (Queue A)])
                  (map-single empty func que)]
                 [([func : (A B ... B -> C)]
                   [que  : (Queue A)] . [ques : (Queue B) ... B])
                  (apply map-multiple empty func que ques)]))


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
(define (queue->list que)
  (if (and (Shallow? que) (Zero? (Shallow-elem que)))
      null
      (cons (head que) (queue->list (tail que)))))

;; Queue constructor
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) (Shallow (Zero)) lst))

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

;; Returns the pair of first and the rest of the queue
(: head+tail : (All (A) ((Queue A) -> (Pair A (Queue A)))))
(define (head+tail que)
  (cons (head que) (tail que)))

;; Similar to build-list function
(: build-queue : (All (A) (Natural (Natural -> A) -> (Queue A))))
(define (build-queue size func)
  (let: loop : (Queue A) ([n : Natural size])
        (if (zero? n)
            empty
            (let ([nsub1 (sub1 n)])
              (enqueue (func nsub1) (loop nsub1))))))


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
