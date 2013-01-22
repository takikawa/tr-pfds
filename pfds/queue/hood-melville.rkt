#lang typed/racket

(provide filter remove head+tail build-queue
         Queue queue enqueue head tail empty empty? queue->list
         (rename-out [qmap map]
                     [queue-andmap andmap] 
                     [queue-ormap ormap]) fold)

(require scheme/match)

(struct: (A) Reversing ([count  : Integer]
                        [first  : (Listof A)]
                        [second : (Listof A)]
                        [third  : (Listof A)]
                        [fourth : (Listof A)]))

(struct: (A) Appending ([count  : Integer]
                        [first  : (Listof A)]
                        [second : (Listof A)]))

(struct: (A) Done ([first : (Listof A)]))

(define-type (RotationState A) (U Null (Reversing A) (Appending A) (Done A)))

(struct: (A) Queue ([lenf : Integer]
                    [front : (Listof A)]
                    [state : (RotationState A)]
                    [lenr : Integer]
                    [rear : (Listof A)]))

(: exec : (All (A) ((RotationState A) -> (RotationState A))))
(define (exec state)
  (match state
    [(struct Reversing (cnt (cons x first) second (cons y third) fourth)) 
     (Reversing (add1 cnt) first (cons x second) third (cons y fourth))]
    [(struct Reversing (cnt null second (list y) fourth)) 
     (Appending cnt second (cons y fourth))]
    [(struct Appending (0 first second)) (Done second)]
    [(struct Appending (cnt (cons x first) second)) 
     (Appending (sub1 cnt) first (cons x second))]
    [else state]))


(: invalidate : (All (A) ((RotationState A) -> (RotationState A))))
(define (invalidate state)
  (match state
    [(struct Reversing (cnt first second third fourth)) 
     (Reversing (sub1 cnt) first second third fourth)]
    [(struct Appending (0 first (cons x second))) (Done second)]
    [(struct Appending (cnt first second)) 
     (Appending (sub1 cnt) first second)]
    [else state]))

(: exec2 : 
   (All (A) (Integer (Listof A) (RotationState A) Integer (Listof A) -> 
                     (Queue A))))
(define (exec2 lenf front state lenr rear)
  (let ([newstate (exec (exec state))])
    (match newstate
      [(struct Done (newf)) (Queue lenf newf null lenr rear)]
      [else (Queue lenf front newstate lenr rear)])))


(: check : 
   (All (A) (Integer (Listof A) (RotationState A) Integer (Listof A) -> 
                     (Queue A))))
(define (check lenf front state lenr rear)
  (if (<= lenr lenf)
      (exec2 lenf front state lenr rear)
      (exec2 (+ lenf lenr) front 
             (Reversing 0 front null rear null) 0 null)))

;; Check for empty queue
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? que)
  (zero? (Queue-lenf que)))

;; An empty queue
(define empty (Queue 0 null null 0 null))

;; Inserts an element into the queue
(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue elem que)
  (check (Queue-lenf que)
         (Queue-front que)
         (Queue-state que)
         (add1 (Queue-lenr que))
         (cons elem (Queue-rear que))))

;; Returns the first element of the queue
(: head : (All (A) ((Queue A) -> A)))
(define (head que)
  (let ([fr (Queue-front que)])
    (if (null? fr)
        (error 'head "given queue is empty")
        (car fr))))

;; Returns the rest of the queue
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (let ([fr (Queue-front que)])
    (if (null? fr)
        (error 'tail "given queue is empty")
        (check (sub1 (Queue-lenf que))
               (cdr fr)
               (invalidate (Queue-state que))
               (Queue-lenr que)
               (Queue-rear que)))))

;; similar to list map function
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

;; Queue constructor function
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))


(: queue->list (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (empty? que)
      null
      (cons (head que) (queue->list (tail que)))))

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

(: head+tail : (All (A) ((Queue A) -> (Pair A (Queue A)))))
(define (head+tail que)
  (let ([fr (Queue-front que)])
    (if (null? fr)
        (error 'head+tail "given queue is empty")
        (cons (car fr)
              (check (sub1 (Queue-lenf que))
                     (cdr fr)
                     (invalidate (Queue-state que))
                     (Queue-lenr que)
                     (Queue-rear que))))))

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