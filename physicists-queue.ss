#lang typed/scheme #:optimize

(provide filter remove Queue
         empty empty? enqueue head tail queue->list queue list->queue
         (rename-out [qmap map]) fold)

;; Physicists Queue
;; Maintains invariant lenr <= lenf
;; pref is empty only if lenf = 0
(struct: (A) Queue ([preF  : (Listof A)]
                    [front : (Promise (Listof A))]
                    [lenf  : Integer]
                    [rear  : (Listof A)]
                    [lenr  : Integer]))

;; Empty Queue
(define empty (Queue '() (delay '()) 0 '() 0))

;; Checks if the given Queue is empty
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? que)
  (zero? (Queue-lenf que)))


;; Maintains "preF" invariant (preF in not not null when front is not null)
(: check-preF-inv : 
   (All (A) ((Listof A) (Promise (Listof A)) Integer (Listof A) Integer ->
                        (Queue A))))
(define (check-preF-inv pref front lenf rear lenr)
  (if (null? pref)
      (Queue (force front) front lenf rear lenr)
      (Queue pref front lenf rear lenr)))


;; Maintains lenr <= lenf invariant
(: check-len-inv : 
   (All (A) ((Listof A) (Promise (Listof A)) Integer (Listof A) Integer -> (Queue A))))
(define (check-len-inv pref front lenf rear lenr)
  (if (>= lenf lenr)
      (check-preF-inv pref front lenf rear lenr)
      (let* ([newpref (force front)]
             [newf (delay (append newpref (reverse rear)))])
        (check-preF-inv newpref newf (+ lenf lenr) null 0))))

;; Maintains queue invariants
(: internal-queue : 
   (All (A) ((Listof A) (Promise (Listof A)) Integer (Listof A) Integer -> (Queue A))))
(define (internal-queue pref front lenf rear lenr)
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
  (if (empty? que)
      (error 'head "given queue is empty")
      (car (Queue-preF que))))


;; Removes the first element in the queue and returns the rest
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (if (empty? que)
      (error 'tail "given queue is empty")
      (internal-queue (cdr (Queue-preF que))
                      (delay (cdr (force (Queue-front que))))
                      (sub1 (Queue-lenf que))
                      (Queue-rear que)
                      (Queue-lenr que))))

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

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (empty? que)
      null
      (cons (head que) (queue->list (tail que)))))

(: list->queue : (All (A) ((Listof A) -> (Queue A))))
(define (list->queue items)
  (foldl (inst enqueue A) empty items))

;; Queue constructor function
(: queue : (All (A) (A * -> (Queue A))))
(define (queue . items)
  (foldl (inst enqueue A) empty items))

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
