#lang typed-scheme

(require scheme/promise)

(provide pq-enqueue 
         pq-empty? 
         pq-head 
         pq-tail pqueue)

;; Physicists Queue
;; Maintains invariant lenr <= lenf
;; pref is empty only if lenf = 0
(define-struct: (A) PQueue 
  ([preF  : (Listof A)]
   [front : (Promise (Listof A))]
   [lenf  : Integer]
   [rear  : (Listof A)]
   [lenr  : Integer]))

;; Empty PQueue
(define empty (make-PQueue '() (delay '()) 0 '() 0))

;; Checks if the given PQueue is empty
(: pq-empty? : (All (A) ((PQueue A) -> Boolean)))
(define (pq-empty? que)
  (eq? (PQueue-lenf que) 0))


;; Maintains "preF" invariant (preF in not not null when front is not null)
(: check-preF-inv (All (A) ((PQueue A) -> (PQueue A))))
(define (check-preF-inv que)
  (if (null? (PQueue-preF que))
      (make-PQueue (force (PQueue-front que))
                   (PQueue-front que)
                   (PQueue-lenf que)
                   (PQueue-rear que)
                   (PQueue-lenr que))
      que))


;; Maintains lenr <= lenf invariant
(: check-len-inv (All (A) ((PQueue A) -> (PQueue A))))
(define (check-len-inv que)
  (if (>= (PQueue-lenf que) (PQueue-lenr que))
      que
      (let ([newpref (force (PQueue-front que))])
        (make-PQueue (force (PQueue-front que))
                     (delay (append (force (PQueue-front que)) (reverse (PQueue-rear que))))
                     (+ (PQueue-lenf que) (PQueue-lenr que))
                     null
                     0))))

;; Maintains queue invariants
(: internal-queue (All (A) ((PQueue A) -> (PQueue A))))
(define (internal-queue que)
  (check-preF-inv (check-len-inv que)))


;; Enqueues an item into the list
(: pq-enqueue (All (A) (A (PQueue A) -> (PQueue A))))
(define (pq-enqueue item que)
  (internal-queue (make-PQueue (PQueue-preF que)
                               (PQueue-front que)
                               (PQueue-lenf que)
                               (cons item (PQueue-rear que))
                               (add1 (PQueue-lenr que)))))


;; Returns the first element in the queue if non empty. Else raises an error
(: pq-head (All (A) ((PQueue A) -> A)))
(define (pq-head que)
  (if (pq-empty? que)
      (error "PQueue is empty" 'head)
      (car (PQueue-preF que))))


;; Removes the first element in the queue and returns the rest
(: pq-tail (All (A) ((PQueue A) -> (PQueue A))))
(define (pq-tail que)
  (if (pq-empty? que)
      (error "PQueue is empty" 'head)
      (internal-queue (make-PQueue (cdr (PQueue-preF que))
                                   (delay (cdr (force (PQueue-front que))))
                                   (sub1 (PQueue-lenf que))
                                   (PQueue-rear que)
                                   (PQueue-lenr que)))))

;; A PQueue constructor with the given elements
;(: pqueue (All (A) ((Listof A) -> (PQueue A))))
;(define (pqueue lst)
;  (if (null? lst)
;      empty
;      (foldl pq-enqueue empty lst)))

;(: pqueue (All (A) (A A * -> (PQueue A))))
;(define (pqueue fst . lst)
;  (if (null? fst)
;      empty
;      (foldl pq-enqueue (pq-enqueue fst empty) lst)))


;(: pqueue (All (A) (A * -> (PQueue A))))
;(define (pqueue . lst)
;  (if (null? lst)
;      empty
;      (foldl pq-enqueue (pq-enqueue (car lst) empty) (cdr lst))))


(: pqueue (All (A) ((Listof A) -> (PQueue A))))
(define (pqueue items)
  (foldl (inst pq-enqueue A) empty items))