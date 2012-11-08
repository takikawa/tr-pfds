#lang typed/racket

(provide filter remove last+init build-deque head+tail
         empty empty? enqueue enqueue-front init 
         last head tail deque deque->list Deque
         foldr (rename-out [deque-map map] [dqfoldl foldl]
                           [deque-andmap andmap] [deque-ormap ormap]))

(require "../stream.rkt")

(struct: (A) Deque
         ([front  : (Stream A)]
          [lenf   : Integer]
          [scdulF : (Stream A)]
          [rear   : (Stream A)]
          [lenr   : Integer]
          [scdulR : (Stream A)]))

;; Invariant
(define inv-c 2)

(define-syntax-rule (empty A) 
  ((inst Deque A) empty-stream 0 empty-stream
                  empty-stream 0 empty-stream))

;; Check for empty dequeue
(: empty? : (All (A) ((Deque A) -> Boolean)))
(define (empty? rtdq)
  (zero? (+ (Deque-lenf rtdq) (Deque-lenr rtdq))))


(: exec-one : (All (A) ((Stream A) -> (Stream A))))
(define (exec-one strem)
  (if (empty-stream? strem)
      empty-stream
      (stream-cdr strem)))


(: exec-two : (All (A) ((Stream A) -> (Stream A))))
(define (exec-two strem)
  (exec-one (exec-one strem)))


(: rotate-rev : (All (A) ((Stream A) (Stream A) (Stream A) -> (Stream A))))
(define (rotate-rev frnt rer accum)
  (if (empty-stream? frnt)
      (rev-append rer accum)
      (stream-cons (stream-car frnt)
                   (rotate-rev (stream-cdr frnt)
                               (drop inv-c rer)
                               (rev-append (take inv-c rer) accum)))))

(: rev-append : (All (A) ((Stream A) (Stream A) -> (Stream A))))
(define (rev-append strm accum)
  (if (empty-stream? strm)
      accum
      (rev-append (stream-cdr strm) 
                  (ann (stream-cons (stream-car strm) accum) (Stream A)))))

(: rotate-drop : (All (A) ((Stream A) Integer (Stream A) -> (Stream A))))
(define (rotate-drop frnt num rer)
  (if (< num inv-c)
      (rotate-rev frnt (drop num rer) empty-stream)
      (stream-cons (stream-car frnt) 
                   (rotate-drop (stream-cdr frnt) 
                                (- num inv-c) 
                                (drop inv-c rer)))))

(define-type-alias (S A) (Stream A))
;; A Pseudo-constructor. Maintains the invariants 
;; 1. lenf <= inv-c * lenr
;; 2. lenr <= inv-c * lenf

(: internal-deque : 
   (All (A) ((S A) Integer (S A) (S A) Integer (S A) -> (Deque A))))
(define (internal-deque fr lenf sf r lenr sr)
  (cond 
    [(> lenf (add1 (* lenr inv-c))) (maintainR fr lenf sf r lenr sr)]
    [(> lenr (add1 (* lenf inv-c))) (maintainF fr lenf sf r lenr sr)]
    [else (Deque fr lenf sf r lenr sr)]))


;; Maintains invariant lenf <= inv-c * lenr
(: maintainR : 
   (All (A) ((S A) Integer (S A) (S A) Integer (S A) -> (Deque A))))
(define (maintainR front lenf sf rear lenr sr)
  (let* ([size (+ lenf lenr)]
         [new-lenf (arithmetic-shift size -1)]
         [new-lenr (- size new-lenf)]
         [newF (take new-lenf front)]
         [newR (rotate-drop rear new-lenf front)])
    (Deque newF new-lenf newF newR new-lenr newR)))


;; Maintains invariant lenr <= inv-c * lenf
(: maintainF : 
   (All (A) ((S A) Integer (S A) (S A) Integer (S A) -> (Deque A))))
(define (maintainF front lenf sf rear lenr sr)
  (let* ([size (+ lenf lenr)]
         [new-lenr (arithmetic-shift size -1)]
         [new-lenf (- size new-lenr)]
         [newF (rotate-drop front new-lenr rear)]
         [newR (take new-lenr rear)])
    (Deque newF new-lenf newF newR new-lenr newR)))


;; Pushes an element into the Deque at the front end
(: enqueue : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue elem rtdq)
  ((inst internal-deque A) (stream-cons elem (Deque-front rtdq))
                           (add1 (Deque-lenf rtdq))
                           (exec-one (Deque-scdulF rtdq))
                           (Deque-rear rtdq)
                           (Deque-lenr rtdq)
                           (exec-one (Deque-scdulR rtdq))))


;; Pushes an element into the Deque at the rear end
(: enqueue-front : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue-front elem rtdq)
  ((inst internal-deque A) (Deque-front rtdq)
                           (Deque-lenf rtdq)
                           (exec-one (Deque-scdulF rtdq))
                           (stream-cons elem (Deque-rear rtdq))
                           (add1 (Deque-lenr rtdq))
                           (exec-one (Deque-scdulR rtdq))))

;; Retrieves the last element of the queue
(: last : (All (A) ((Deque A) -> A)))
(define (last rtdq)
  (if (zero? (+ (Deque-lenf rtdq) (Deque-lenr rtdq)))
      (error 'last "given deque is empty")
      (let ([front (Deque-front rtdq)])
        (if (empty-stream? front) 
            (stream-car (Deque-rear rtdq))
            (stream-car front)))))


;; Retrieves the head element of the queue
(: head : (All (A) ((Deque A) -> A)))
(define (head rtdq)
  (if (zero? (+ (Deque-lenf rtdq) (Deque-lenr rtdq)))
      (error 'head "given deque is empty")
      (let ([rear (Deque-rear rtdq)])
        (if (empty-stream? rear) 
            (stream-car (Deque-front rtdq))
            (stream-car rear)))))

;; Removes the head and returns the rest of the queue
(: init : (All (A) ((Deque A) -> (Deque A))))
(define (init rtdq)
  (let ([lenf (Deque-lenf rtdq)]
        [lenr (Deque-lenr rtdq)])
    (if (zero? (+ lenf lenr))
        (error 'init "given deque is empty")
        (let ([front (Deque-front rtdq)])
          (if (empty-stream? front) 
              (empty A)
              ((inst internal-deque A) (stream-cdr front) 
                                       (sub1 lenf)
                                       (exec-two (Deque-scdulF rtdq))
                                       (Deque-rear rtdq)
                                       lenr
                                       (exec-two (Deque-scdulR rtdq))))))))

;; Removes the last and returns the Deque without the last
(: tail : (All (A) ((Deque A) -> (Deque A))))
(define (tail rtdq)
  (let ([lenf (Deque-lenf rtdq)]
        [lenr (Deque-lenr rtdq)])
    (if (zero? (+ lenf lenr))
        (error 'tail "given deque is empty")
        (let ([rear (Deque-rear rtdq)])
          (if (empty-stream? rear)
              (empty A)
              ((inst internal-deque A) (Deque-front rtdq)
                                       lenf
                                       (exec-two (Deque-scdulF rtdq))
                                       (stream-cdr rear)
                                       (sub1 lenr)
                                       (exec-two (Deque-scdulR rtdq))))))))

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
(define (deque->list dque)
  (if (empty? dque)
      null
      (cons (head dque) (deque->list (tail dque)))))


(: list->deque : (All (A) ((Listof A) -> (Deque A))))
(define (list->deque lst)
  (foldl (inst enqueue A) (empty A) lst))

;; A Deque constructor
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

;; Similar to build-list
(: build-deque : (All (A) (Natural (Natural -> A) -> (Deque A))))
(define (build-deque size func)
  (let: loop : (Deque A) ([n : Natural size])
        (if (zero? n)
            (empty A)
            (let ([nsub1 (sub1 n)])
              (enqueue (func nsub1) (loop nsub1))))))


(: head+tail : (All (A) (Deque A) -> (Pair A (Deque A))))
(define (head+tail rtdq)
  (let ([lenf (Deque-lenf rtdq)]
        [lenr (Deque-lenr rtdq)])
    (if (zero? (+ lenf lenr))
        (error 'head+tail "given deque is empty")
        (let ([rear (Deque-rear rtdq)])
          (if (empty-stream? rear)
              (cons (stream-car (Deque-front rtdq)) (empty A))
              (cons (stream-car rear)
                    (internal-deque (Deque-front rtdq)
                                    lenf
                                    (exec-two (Deque-scdulF rtdq))
                                    (stream-cdr rear)
                                    (sub1 lenr)
                                    (exec-two (Deque-scdulR rtdq))))))))) 


(: last+init : (All (A) (Deque A) -> (Pair A (Deque A))))
(define (last+init rtdq)
  (let ([lenf (Deque-lenf rtdq)]
        [lenr (Deque-lenr rtdq)])
    (if (zero? (+ lenf lenr))
        (error 'last+init "given deque is empty")
        (let ([front (Deque-front rtdq)])
          (if (empty-stream? front)
              (cons (stream-car (Deque-rear rtdq)) (empty A))
              (cons (stream-car front)
                    (internal-deque (stream-cdr front) 
                                    (sub1 lenf)
                                    (exec-two (Deque-scdulF rtdq))
                                    (Deque-rear rtdq)
                                    lenr
                                    (exec-two (Deque-scdulR rtdq)))))))))


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
