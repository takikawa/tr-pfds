#lang typed/racket #:optimize

(require "../../stream/stream.rkt")

(provide filter remove Deque build-deque
         empty? empty enqueue-front head tail deque enqueue last init
         deque->list foldr head+tail last+init
         (rename-out [deque-map map] [dqfoldl foldl]
                     [deque-andmap andmap] [deque-ormap ormap]))

;; A Banker's Deque (Maintains length of front >= length of rear)

(struct: (A) Deque ([front : (Stream A)]
                    [lenf  : Integer]
                    [rear  : (Stream A)]
                    [lenr  : Integer]))

(define inv-c 2)

(define-syntax-rule (empty A)
  ((inst Deque A) empty-stream 0 empty-stream 0))

;; Checks if the given deque is empty
(: empty? : (All (A) ((Deque A) -> Boolean)))
(define (empty? que)
  (zero? (+ (Deque-lenf que) (Deque-lenr que))))


;; A Pseudo-constructor. Maintains the invariants 
;; 1. lenf <= inv-c * lenr
;; 2. lenr <= inv-c * lenf
(: internal-deque : 
   (All (A) ((Stream A) Integer (Stream A) Integer -> (Deque A))))
(define (internal-deque front lenf rear lenr)
  (cond 
    [(> lenf (add1 (* lenr inv-c))) (maintainF front lenf rear lenr)]
    [(> lenr (add1 (* lenf inv-c))) (maintainR front lenf rear lenr)]
    [else (Deque front lenf rear lenr)]))


;; Maintains invariant lenf <= inv-c * lenr
(: maintainF : (All (A) ((Stream A) Integer (Stream A) Integer -> (Deque A))))
(define (maintainF front lenf rear lenr)
  (let* ([new-lenf (arithmetic-shift (+ lenf lenr) -1)]
         [new-lenr (- (+ lenf lenr) new-lenf)]
         [newF (take new-lenf front)]
         [newR (stream-append rear (stream-reverse (drop new-lenf front)))])
    (Deque newF new-lenf newR new-lenr)))


;; Maintains invariant lenr <= inv-c * lenf
(: maintainR : (All (A) ((Stream A) Integer (Stream A) Integer -> (Deque A))))
(define (maintainR front lenf rear lenr)
  (let* ([new-lenf (arithmetic-shift (+ lenf lenr) -1)]
         [new-lenr (- (+ lenf lenr) new-lenf)]
         [newR (take (ann new-lenr Integer) rear)]
         [newF (stream-append front (stream-reverse (drop new-lenr rear)))])
    (Deque newF new-lenf newR new-lenr)))


;; Pushes an element into the Deque at the front end
(: enqueue-front : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue-front elem deq)
  ((inst internal-deque A) (stream-cons elem (Deque-front deq))
                           (add1 (Deque-lenf deq))
                           (Deque-rear deq)
                           (Deque-lenr deq)))


;; Pushes an element into the Deque at the rear end
(: enqueue : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue elem deq)
  ((inst internal-deque A) (Deque-front deq)
                           (Deque-lenf deq)
                           (stream-cons elem (Deque-rear deq))
                           (add1 (Deque-lenr deq))))

;; Retrieves the head element of the queue
(: head : (All (A) ((Deque A) -> A)))
(define (head deq)
  (let ([lenf (Deque-lenf deq)]
        [lenr (Deque-lenr deq)])
    (if (zero? (+ lenf lenr))
        (error 'head "given deque is empty")
        (let ([front (Deque-front deq)])
          (if (empty-stream? front) 
              (stream-car (Deque-rear deq))
              (stream-car front))))))


;; Retrieves the last element of the queue
(: last : (All (A) ((Deque A) -> A)))
(define (last deq)
  (if (zero? (+ (Deque-lenf deq) (Deque-lenr deq)))
      (error 'last "given deque is empty")
      (let ([rear (Deque-rear deq)])
        (if (empty-stream? rear) 
            (stream-car (Deque-front deq))
            (stream-car rear)))))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((Deque A) -> (Deque A))))
(define (tail deq)
  (let ([lenf (Deque-lenf deq)]
        [lenr (Deque-lenr deq)])
    (if (zero? (+ lenf lenr))
        (error 'tail "given deque is empty")
        (let ([front (Deque-front deq)])
          (if (empty-stream? front) 
              (empty A)
              (internal-deque (stream-cdr front) 
                              (sub1 lenf)
                              (Deque-rear deq)
                              lenr))))))
  
;; Removes the last and returns the deque without the last
(: init : (All (A) ((Deque A) -> (Deque A))))
(define (init deq)
  (let ([lenf (Deque-lenf deq)]
        [lenr (Deque-lenr deq)])
    (if (zero? (+ lenf lenr))
        (error 'init "given deque is empty")
        (let ([rear (Deque-rear deq)])
          (if (empty-stream? rear)
              (empty A)
              (internal-deque (Deque-front deq) 
                              lenf
                              (stream-cdr rear)
                              (sub1 lenr)))))))

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
                  (map-single (empty C) func deq)]
                 [([func : (A B ... B -> C)]
                   [deq  : (Deque A)] . [deqs : (Deque B) ... B])
                  (apply map-multiple (empty C) func deq deqs)]))


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
(define (deque->list deq)
  (if (empty? deq)
      null
      (cons (head deq) (deque->list (tail deq)))))

;; A Deque constructor with the given element
(: deque : (All (A) (A * -> (Deque A))))
(define (deque . lst)
  (foldl (inst enqueue A) (empty A) lst))

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
  (inner func que (empty A)))

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
  (inner func que (empty A)))


;; Similar to build-list function
(: build-deque : (All (A) (Natural (Natural -> A) -> (Deque A))))
(define (build-deque size func)
  (let: loop : (Deque A) ([n : Natural size])
        (if (zero? n)
            (empty A)
            (let ([nsub1 (sub1 n)])
              (enqueue (func nsub1) (loop nsub1))))))

;; Returns the pair head and tail of the given queue
(: head+tail : (All (A) (Deque A) -> (Pair A (Deque A))))
(define (head+tail deq)
  (let ([lenf (Deque-lenf deq)]
        [lenr (Deque-lenr deq)])
    (if (zero? (+ lenf lenr))
        (error 'head+tail "given deque is empty")
        (let ([front (Deque-front deq)])
          (if (empty-stream? front) 
              (cons (stream-car (Deque-rear deq)) (empty A))
              (cons (stream-car front)
                    (internal-deque (stream-cdr front) 
                                    (sub1 lenf)
                                    (Deque-rear deq)
                                    lenr)))))))

;; Returns the pair last and init of the given queue
(: last+init : (All (A) (Deque A) -> (Pair A (Deque A))))
(define (last+init deq)
  (let ([lenf (Deque-lenf deq)]
        [lenr (Deque-lenr deq)])
    (if (zero? (+ lenf lenr))
        (error 'last+init "given deque is empty")
        (let ([rear (Deque-rear deq)])
          (if (empty-stream? rear)
              (cons (stream-car (Deque-front deq)) (empty A))
              (cons (stream-car rear)
                    (internal-deque (Deque-front deq) 
                                    lenf
                                    (stream-cdr rear)
                                    (sub1 lenr))))))))

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
