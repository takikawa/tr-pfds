#lang typed-scheme

(require scheme/promise)

(provide empty empty? enqueue head tail queue->list queue list->queue)

;; Physicists Queue
;; Maintains invariant lenr <= lenf
;; pref is empty only if lenf = 0
(define-struct: (A) Queue ([preF  : (Listof A)]
                            [front : (Promise (Listof A))]
                            [lenf  : Integer]
                            [rear  : (Listof A)]
                            [lenr  : Integer]))

;(define-type-alias (Queue A) (Queue A))

;; Empty Queue
(define empty (make-Queue '() (delay '()) 0 '() 0))

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
      (make-Queue (force front) front lenf rear lenr)
      (make-Queue pref front lenf rear lenr)))


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

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (empty? que)
      null
      (cons (head que) (queue->list (tail que)))))

(: list->queue : (All (A) ((Listof A) -> (Queue A))))
(define (list->queue items)
  (foldl (inst enqueue A) empty items))

(: queue : (All (A) (A * -> (Queue A))))
(define (queue . items)
  (foldl (inst enqueue A) empty items))
