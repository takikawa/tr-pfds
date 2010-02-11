#lang typed-scheme

(require scheme/promise)

(provide empty empty? enqueue head tail queue->list pqueue list->pqueue)

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
(: empty? : (All (A) ((PQueue A) -> Boolean)))
(define (empty? que)
  (= (PQueue-lenf que) 0))


;; Maintains "preF" invariant (preF in not not null when front is not null)
(: check-preF-inv : (All (A) ((PQueue A) -> (PQueue A))))
(define (check-preF-inv que)
  (if (null? (PQueue-preF que))
      (make-PQueue (force (PQueue-front que))
                   (PQueue-front que)
                   (PQueue-lenf que)
                   (PQueue-rear que)
                   (PQueue-lenr que))
      que))


;; Maintains lenr <= lenf invariant
(: check-len-inv : (All (A) ((PQueue A) -> (PQueue A))))
(define (check-len-inv que)
  (let ([lenf (PQueue-lenf que)]
        [lenr (PQueue-lenr que)])
    (if (>= lenf lenr)
        que
        (let* ([front (PQueue-front que)]
               [newpref (force front)]
               [rear (PQueue-rear que)]
               [newf (delay (append newpref (reverse rear)))])
          (make-PQueue newpref newf (+ lenf lenr) null 0)))))

;; Maintains queue invariants
(: internal-queue : (All (A) ((PQueue A) -> (PQueue A))))
(define (internal-queue que)
  (check-preF-inv (check-len-inv que)))


;; Enqueues an item into the list
(: enqueue : (All (A) (A (PQueue A) -> (PQueue A))))
(define (enqueue item que)
  (internal-queue (make-PQueue (PQueue-preF que)
                               (PQueue-front que)
                               (PQueue-lenf que)
                               (cons item (PQueue-rear que))
                               (add1 (PQueue-lenr que)))))


;; Returns the first element in the queue if non empty. Else raises an error
(: head : (All (A) ((PQueue A) -> A)))
(define (head que)
  (if (empty? que)
      (error "Queue is empty :" 'head)
      (car (PQueue-preF que))))


;; Removes the first element in the queue and returns the rest
(: tail : (All (A) ((PQueue A) -> (PQueue A))))
(define (tail que)
  (if (empty? que)
      (error "Queue is empty :" 'tail)
      (internal-queue (make-PQueue (cdr (PQueue-preF que))
                                   (delay (cdr (force (PQueue-front que))))
                                   (sub1 (PQueue-lenf que))
                                   (PQueue-rear que)
                                   (PQueue-lenr que)))))

(: queue->list : (All (A) ((PQueue A) -> (Listof A))))
(define (queue->list que)
  (if (empty? que)
      null
      (cons (head que) (queue->list (tail que)))))

(: list->pqueue : (All (A) ((Listof A) -> (PQueue A))))
(define (list->pqueue items)
  (foldl (inst enqueue A) empty items))

(: pqueue : (All (A) (A A * -> (PQueue A))))
(define (pqueue item . items)
  (let ([first (enqueue item empty)])
    (if (null? items)
        first
        (foldl (inst enqueue A) first items))))