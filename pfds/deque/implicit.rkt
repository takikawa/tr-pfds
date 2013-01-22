#lang typed/racket

(provide filter remove Deque head+tail last+init build-deque
         empty empty? head tail last init deque->rev-list
         enqueue-front enqueue deque->list deque
         foldr (rename-out [deque-map map] [dqfoldl foldl]
                           [deque-andmap andmap] [deque-ormap ormap]))

(require scheme/match)

(struct: Zero ())
(struct: (A) One ([elem : A]))

(struct: (A) Two ([first  : A] 
                  [second : A]))

(struct: (A) Three ([first  : A] 
                    [second : A]
                    [third  : A]))

(define-type (D A)  (U Zero (One A) (Two A) (Three A)))

(define-type (D1 A) (U Zero (One A) (Two A)))

(struct: (A) Shallow ([elem : (D A)]))

(struct: (A) Deep ([F : (D A)]
                   [M : (Promise (Pair (Deque A) (Deque A)))]
                   [R : (D A)]))

(define-type (Deque A) (U (Shallow A) (Deep A)))

;; An empty deque
(define empty (Shallow (Zero)))

;; Check for empty deque
(: empty? : (All (A) ((Deque A) -> Boolean)))
(define (empty? que)
  (and (Shallow? que) (Zero? (Shallow-elem que))))

;; Inserts an element into the front of deque
(: enqueue-front : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue-front elem que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (Shallow (One elem))]
    [(struct Shallow ((struct One (a)))) (Shallow (Two elem a))]
    [(struct Shallow ((struct Two (a b)))) 
     (Shallow (Three elem a b))]
    [(struct Shallow ((struct Three (f s t))))
     (Deep (Two elem f) (delay (cons empty empty)) (Two s t))]
    [(struct Deep ((struct Zero ()) m r)) (Deep (One elem) m r)]
    [(struct Deep ((struct One (a)) m r)) (Deep (Two elem a) m r)]
    [(struct Deep ((struct Two (a b)) m r)) 
     (Deep (Three elem a b) m r)]
    [(struct Deep ((struct Three (f s t)) m r)) 
     (Deep (Two elem f) 
           (delay 
             (let* ([forced-mid (force m)]
                    [first (car forced-mid)]
                    [second (cdr forced-mid)])
               (cons (enqueue-front s first) (enqueue-front t second))))
           r)]))

;; Inserts into the rear of the queue
(: enqueue : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue elem que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (Shallow (One elem))]
    [(struct Shallow ((struct One (a)))) (Shallow (Two a elem))]
    [(struct Shallow ((struct Two (a b)))) 
     (Shallow (Three a b elem))]
    [(struct Shallow ((struct Three (f s t))))
     (Deep (Two f s) (delay (cons empty empty)) (Two t elem))]
    [(struct Deep (f m (struct Zero ()))) (Deep f m (One elem))]
    [(struct Deep (f m (struct One (a)))) (Deep f m (Two a elem))]
    [(struct Deep (f m (struct Two (a b)))) 
     (Deep f m (Three a b elem))]
    [(struct Deep (fi m (struct Three (f s t)))) 
     (Deep fi 
           (delay (let* ([forced-mid (force m)]
                         [first (car forced-mid)]
                         [second (cdr forced-mid)])
                    (cons (enqueue f first) (enqueue s second))))
           (Two t elem))]))

;; Returns the first element of the deque
(: head : (All (A) ((Deque A) -> A)))
(define (head que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (error 'head "given deque is empty")]
    [(struct Shallow ((struct One (f)))) f]
    [(struct Shallow ((struct Two (f s)))) f]
    [(struct Shallow ((struct Three (f s t)))) f]
    [(struct Deep ((struct Zero ()) m r)) (error 'head "given deque is empty")]
    [(struct Deep ((struct One (f)) m r)) f]
    [(struct Deep ((struct Two (f s)) m r)) f]
    [(struct Deep ((struct Three (f s t)) m r)) f]))

;; Returns the last element of the deque 
(: last : (All (A) ((Deque A) -> A)))
(define (last que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (error 'last "given deque is empty")]
    [(struct Shallow ((struct One (f)))) f]
    [(struct Shallow ((struct Two (f s)))) s]
    [(struct Shallow ((struct Three (f s t)))) t]
    [(struct Deep (f m (struct Zero ()))) (error 'last "given deque is empty")]
    [(struct Deep (fi m (struct One (f)))) f]
    [(struct Deep (fi m (struct Two (f s)))) s]
    [(struct Deep (fi m (struct Three (f s t)))) t]))

;; Returns a deque without the first element
(: tail : (All (A) ((Deque A) -> (Deque A))))
(define (tail que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (error 'tail "given deque is empty")]
    [(struct Shallow ((struct One (_)))) (Shallow (Zero))]
    [(struct Shallow ((struct Two (_ s)))) (Shallow (One s))]
    [(struct Shallow ((struct Three (_ s t)))) (Shallow (Two s t))]
    [(struct Deep ((struct Zero ()) m r)) (error 'tail "given deque is empty")]
    [(struct Deep ((struct One (_)) mid r)) 
     (let ([m (force mid)])
       (if (empty? (car m))
           (Shallow r)
           (let* ([carm (car m)]
                  [cdrm (cdr m)]
                  [first (head carm)]
                  [second (head cdrm)])
             (Deep (Two first second) 
                   (delay (cons (tail carm) (tail cdrm))) r))))]
    [(struct Deep ((struct Two (_ s)) m r)) (Deep (One s) m r)]
    [(struct Deep ((struct Three (_ s t)) m r)) 
     (Deep (Two s t) m r)]))

;; Returns a deque without the last element
(: init : (All (A) ((Deque A) -> (Deque A))))
(define (init que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error 'init "given deque is empty")]
    [(struct Shallow ((struct One (f)))) (Shallow (Zero))]
    [(struct Shallow ((struct Two (f _)))) 
     (Shallow (One f))]
    [(struct Shallow ((struct Three (f s _)))) (Shallow (Two f s))]
    [(struct Deep (f m (struct Zero ()))) (error 'init "given deque is empty")]
    [(struct Deep (f mid (struct One (a))))
     (let* ([m (force mid)]
            [carm (car m)])
       (if (empty? carm)
           (Shallow f)
           (let* ([cdrm (cdr m)]
                  [first (last carm)]
                  [second (last cdrm)])
             (Deep f (delay (cons (init carm) (init cdrm))) 
                   (Two first second)))))]
    [(struct Deep (fi m (struct Two (f _)))) (Deep fi m (One f))]
    [(struct Deep (fi m (struct Three (f s t)))) 
     (Deep fi m (Two f s))]))

;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: deque-map : 
   (All (A C B ...) 
        (case-lambda 
          ((A -> C) (Deque A) -> (Deque C))
          ((A B ... B -> C) (Deque A) (Deque B) ... B -> (Deque C)))))
(define deque-map
  (pcase-lambda: (A C B ...)
                 [([func : (A -> C)]
                   [deq  : (Deque A)])
                  (map-single empty func deq)]
                 [([func : (A B ... B -> C)]
                   [deq  : (Deque A)] . [deqs : (Deque B) ... B])
                  (apply map-multiple empty func deq deqs)]))


(: map-single : (All (A C) ((Deque C) (A -> C) (Deque A) -> (Deque C))))
(define (map-single accum func que)
  (if (empty? que)
      accum
      (map-single (enqueue (func (head que)) accum) func (tail que))))

(: map-multiple : 
   (All (A C B ...) 
        ((Deque C) (A B ... B -> C) (Deque A) (Deque B) ... B -> (Deque C))))
(define (map-multiple accum func que . ques)
  (if (or (empty? que) (ormap empty? ques))
      accum
      (apply map-multiple
             (enqueue (apply func (head que) (map head ques)) accum)
             func 
             (tail que)
             (map tail ques))))

;; Similar to list foldr function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: foldr : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (Deque A) -> C)
                     ((C A B ... B -> C) C (Deque A) (Deque B) ... B -> C))))
(define foldr
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [que  : (Deque A)])
                  (if (empty? que)
                      base
                      (foldr func (func base (head que)) (tail que)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [que  : (Deque A)] . [ques : (Deque B) ... B])
                  (if (or (empty? que) (ormap empty? ques))
                      base
                      (apply foldr 
                             func 
                             (apply func base (head que) (map head ques))
                             (tail que)
                             (map tail ques)))]))

;; similar to list foldl function
(: dqfoldl : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (Deque A) -> C)
                     ((C A B ... B -> C) C (Deque A) (Deque B) ... B -> C))))
(define dqfoldl
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [que  : (Deque A)])
                  (if (empty? que)
                      base
                      (dqfoldl func (func base (last que)) (init que)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [que  : (Deque A)] . [ques : (Deque B) ... B])
                  (if (or (empty? que) (ormap empty? ques))
                      base
                      (apply dqfoldl 
                             func 
                             (apply func base (last que) (map last ques))
                             (init que)
                             (map init ques)))]))


(: deque->list : (All (A) ((Deque A) -> (Listof A))))
(define (deque->list que)
  (if (empty? que)
      null
      (cons (head que) (deque->list (tail que)))))

(: deque->rev-list : (All (A) ((Deque A) -> (Listof A))))
(define (deque->rev-list que)
  (if (and (Shallow? que) (Zero? (Shallow-elem que)))
      null
      (cons (last que) (deque->rev-list (init que)))))

;; Deque constructor
(: deque : (All (A) (A * -> (Deque A))))
(define (deque . lst)
  (foldl (inst enqueue A) empty lst))

;; similar to list filter function
(: filter : (All (A) ((A -> Boolean) (Deque A) -> (Deque A))))
(define (filter func que)
  (: inner : (All (A) ((A -> Boolean) (Deque A) (Deque A) -> (Deque A))))
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
(: remove : (All (A) ((A -> Boolean) (Deque A) -> (Deque A))))
(define (remove func que)
  (: inner : (All (A) ((A -> Boolean) (Deque A) (Deque A) -> (Deque A))))
  (define (inner func que accum)
    (if (empty? que)
        accum
        (let ([head (head que)]
              [tail (tail que)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (enqueue head accum))))))
  (inner func que empty))


;; Similar to build-list
(: build-deque : (All (A) (Natural (Natural -> A) -> (Deque A))))
(define (build-deque size func)
  (let: loop : (Deque A) ([n : Natural size])
        (if (zero? n)
            empty
            (let ([nsub1 (sub1 n)])
              (enqueue (func nsub1) (loop nsub1))))))


(: head+tail : (All (A) (Deque A) -> (Pair A (Deque A))))
(define (head+tail deq)
  (if (empty? deq)
      (error 'head+tail "given deque is empty")
      (cons (head deq) (tail deq))))


(: last+init : (All (A) (Deque A) -> (Pair A (Deque A))))
(define (last+init deq)
  (if (empty? deq)
      (error 'last+init "given deque is empty")
      (cons (last deq) (init deq))))


;; similar to list andmap function
(: deque-andmap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Deque A) -> Boolean)
                     ((A B ... B -> Boolean) (Deque A) (Deque B) ... B -> Boolean))))
(define deque-andmap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [queue : (Deque A)])
                  (or (empty? queue)
                      (and (func (head queue))
                           (deque-andmap func (tail queue))))]
                 [([func  : (A B ... B -> Boolean)]
                   [queue : (Deque A)] . [queues : (Deque B) ... B])
                  (or (empty? queue) (ormap empty? queues)
                      (and (apply func (head queue) (map head queues))
                           (apply deque-andmap func (tail queue) 
                                  (map tail queues))))]))

;; Similar to ormap
(: deque-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Deque A) -> Boolean)
                     ((A B ... B -> Boolean) (Deque A) (Deque B) ... B -> Boolean))))
(define deque-ormap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [queue : (Deque A)])
                  (and (not (empty? queue))
                       (or (func (head queue))
                           (deque-ormap func (tail queue))))]
                 [([func  : (A B ... B -> Boolean)]
                   [queue : (Deque A)] . [queues : (Deque B) ... B])
                  (and (not (or (empty? queue) (ormap empty? queues)))
                       (or (apply func (head queue) (map head queues))
                           (apply deque-ormap func (tail queue) 
                                  (map tail queues))))]))
