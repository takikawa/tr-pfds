#lang typed-scheme

(require scheme/promise)

(provide empty empty? enqueue head tail queue->list queue list->queue)

;; Physicists Queue
;; Maintains invariant lenr <= lenf
;; pref is empty only if lenf = 0
(define-struct: (A) PQueue ([preF  : (Listof A)]
                            [front : (Promise (Listof A))]
                            [lenf  : Integer]
                            [rear  : (Listof A)]
                            [lenr  : Integer]))

(define-type-alias (Queue A) (PQueue A))

;; Empty PQueue
(define empty (make-PQueue '() (delay '()) 0 '() 0))

;; Checks if the given PQueue is empty
(: empty? : (All (A) ((PQueue A) -> Boolean)))
(define (empty? que)
  (zero? (PQueue-lenf que)))


;; Maintains "preF" invariant (preF in not not null when front is not null)
(: check-preF-inv : 
   (All (A) ((Listof A) (Promise (Listof A)) Integer (Listof A) Integer -> (PQueue A))))
(define (check-preF-inv pref front lenf rear lenr)
  (if (null? pref)
      (make-PQueue (force front) front lenf rear lenr)
      (make-PQueue pref front lenf rear lenr)))


;; Maintains lenr <= lenf invariant
(: check-len-inv : 
   (All (A) ((Listof A) (Promise (Listof A)) Integer (Listof A) Integer -> (PQueue A))))
(define (check-len-inv pref front lenf rear lenr)
  (if (>= lenf lenr)
      (check-preF-inv pref front lenf rear lenr)
      (let* ([newpref (force front)]
             [newf (delay (append newpref (reverse rear)))])
        (check-preF-inv newpref newf (+ lenf lenr) null 0))))

;; Maintains queue invariants
(: internal-queue : 
   (All (A) ((Listof A) (Promise (Listof A)) Integer (Listof A) Integer -> (PQueue A))))
(define (internal-queue pref front lenf rear lenr)
  (check-len-inv pref front lenf rear lenr))

;; Enqueues an item into the list
(: enqueue : (All (A) (A (PQueue A) -> (PQueue A))))
(define (enqueue item que)
  (internal-queue (PQueue-preF que)
                  (PQueue-front que)
                  (PQueue-lenf que)
                  (cons item (PQueue-rear que))
                  (add1 (PQueue-lenr que))))


;; Returns the first element in the queue if non empty. Else raises an error
(: head : (All (A) ((PQueue A) -> A)))
(define (head que)
  (if (empty? que)
      (error 'head "Given queue is empty")
      (car (PQueue-preF que))))


;; Removes the first element in the queue and returns the rest
(: tail : (All (A) ((PQueue A) -> (PQueue A))))
(define (tail que)
  (if (empty? que)
      (error 'tail "Given queue is empty")
      (internal-queue (cdr (PQueue-preF que))
                      (delay (cdr (force (PQueue-front que))))
                      (sub1 (PQueue-lenf que))
                      (PQueue-rear que)
                      (PQueue-lenr que))))

(: queue->list : (All (A) ((PQueue A) -> (Listof A))))
(define (queue->list que)
  (if (empty? que)
      null
      (cons (head que) (queue->list (tail que)))))

(: list->queue : (All (A) ((Listof A) -> (PQueue A))))
(define (list->queue items)
  (foldl (inst enqueue A) empty items))

(: queue : (All (A) (A * -> (PQueue A))))
(define (queue . items)
  (foldl (inst enqueue A) empty items))
