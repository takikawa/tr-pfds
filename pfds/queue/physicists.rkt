#lang typed/racket

(provide filter remove Queue head+tail build-queue
         empty empty? enqueue head tail queue->list queue list->queue
         (rename-out [qmap map]
                     [queue-andmap andmap] 
                     [queue-ormap ormap]) fold)


(define-type (Promiseof A) (Boxof (U (→ (Listof A)) (Listof A))))

;; Physicists Queue
;; Maintains invariant lenr <= lenf
;; pref is empty only if lenf = 0
(struct: (A) Queue ([preF  : (Listof A)]
                    [front : (Promiseof A)]
                    [lenf  : Integer]
                    [rear  : (Listof A)]
                    [lenr  : Integer]))

;; Empty Queue Because of some limitations in TR in typechecking the
;; boxed values, I had to make empty a macro so that users can
;; instantiate empty easily.
(define-syntax-rule (empty A)
  ((inst Queue A) '() (box (lambda: () '())) 0 '() 0))

;; Checks if the given Queue is empty
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? que)
  (zero? (Queue-lenf que)))

(define-syntax-rule (force promise)
  (let ([p (unbox promise)])
    (if (procedure? p)
        (let ([result (p)])
          (set-box! (ann promise (Promiseof A)) result)
          result)
        p)))

;; Maintains "preF" invariant (preF in not not null when front is not null)
;(: check-pref-inv : 
;   (All (A) ((Listof A) (Promiseof A) Integer (Listof A) Integer ->
;                        (Queue A))))
(define-syntax-rule (check-pref-inv pref front lenf rear lenr)
  (if (null? pref)
      ((inst Queue A) (force front) front lenf rear lenr)
      ((inst Queue A) pref front lenf rear lenr)))


;; Maintains lenr <= lenf invariant
;(: check-len-inv : 
;   (All (A) ((Listof A) (Promiseof A) Integer (Listof A) Integer -> (Queue A))))
(define-syntax-rule (check-len-inv pref front lenf rear lenr)
  (if (>= lenf lenr)
      (check-pref-inv pref front lenf rear lenr)
      (let*: ([newpref : (Listof A) (force front)]
              [newf    : (Promiseof A)
                       (box (lambda () (append newpref (reverse rear))))])
             (check-pref-inv newpref newf (+ lenf lenr) null 0))))

;; Maintains queue invariants
;(: internal-queue : 
;   (All (A) ((Listof A) (Promiseof A) Integer (Listof A) Integer -> (Queue A))))
(define-syntax-rule (internal-queue pref front lenf rear lenr)
  (check-len-inv pref front lenf rear lenr))

;; Enqueues an item into the list
(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue item que)
  (internal-queue (Queue-preF que)
                  (Queue-front que)
                  (Queue-lenf que)
                  (cons item (Queue-rear que))
                  (add1 (Queue-lenr que))))


;; Returns the first element in the queue if non empty. Else raises an error
(: head : (All (A) ((Queue A) -> A)))
(define (head que)
  (if (zero? (Queue-lenf que))
      (error 'head "given queue is empty")
      (car (Queue-preF que))))


;; Removes the first element in the queue and returns the rest
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (let ([lenf (Queue-lenf que)])
    (if (zero? lenf)
        (error 'tail "given queue is empty")
        (internal-queue (cdr (Queue-preF que))
                        (box (lambda () (cdr (force (Queue-front que)))))
                        (sub1 lenf)
                        (Queue-rear que)
                        (Queue-lenr que)))))

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
                  (map-single 
                   ((inst Queue C) '() (box (lambda () '())) 0 '() 0) func deq)]
                 [([func : (A B ... B -> C)]
                   [deq  : (Queue A)] . [deqs : (Queue B) ... B])
                  (apply map-multiple 
                         ((inst Queue C) '() (box (lambda () '())) 0 '() 0) 
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

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (empty? que)
      null
      (cons (head que) (queue->list (tail que)))))

(: list->queue : (All (A) ((Listof A) -> (Queue A))))
(define (list->queue items)
  (foldl (inst enqueue A) 
         ((inst Queue A) '() (box (lambda: () '())) 0 '() 0) items))

;; Queue constructor function
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . items)
  (foldl (inst enqueue A) 
         ((inst Queue A) '() (box (lambda: () '())) 0 '() 0) items))

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
  (inner func que 
         ((inst Queue A) '() (box (lambda: () '())) 0 '() 0)))

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
  (inner func que 
         ((inst Queue A) '() (box (lambda: () '())) 0 '() 0)))

(: head+tail : (All (A) ((Queue A) -> (Pair A (Queue A)))))
(define (head+tail que)
  (let ([lenf (Queue-lenf que)])
    (if (zero? lenf)
        (error 'head+tail "given queue is empty")
        (let ([pref (Queue-preF que)])
          (cons (car pref)
                (internal-queue
                 (cdr pref) 
                 (box (lambda () (cdr (force (Queue-front que)))))
                 (sub1 lenf) 
                 (Queue-rear que) 
                 (Queue-lenr que)))))))


;; Similar to build-list function
(: build-queue : (All (A) (Natural (Natural -> A) -> (Queue A))))
(define (build-queue size func)
  (let: loop : (Queue A) ([n : Natural size])
        (if (zero? n)
            ((inst Queue A) '() (box (lambda: () '())) 0 '() 0)
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
