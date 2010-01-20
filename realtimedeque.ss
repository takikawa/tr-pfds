#lang typed-scheme

(provide empty empty? enqueue snoc init 
         last head tail rtdeque rtdeque->list)

(require "stream.ss")

(define-struct: (A) RTDeque
  ([front  : (Stream A)]
   [lenf   : Integer]
   [scdulF : (Stream A)]
   [rear   : (Stream A)]
   [lenr   : Integer]
   [scdulR : (Stream A)]))

(define inv-c 2)

(define empty (make-RTDeque (stream null) 0 (stream null)
                                 (stream null) 0 (stream null)))


(: empty? : (All (A) ((RTDeque A) -> Boolean)))
(define (empty? rtdq)
  (zero? (+ (RTDeque-lenf rtdq) (RTDeque-lenr rtdq))))


(: exec-one : (All (A) ((Stream A) -> (Stream A))))
(define (exec-one strem)
  (if (empty-stream? strem)
      null-stream
      (stream-cdr strem)))


(: exec-two : (All (A) ((Stream A) -> (Stream A))))
(define (exec-two strem)
  (exec-one (exec-one strem)))


(: rotateRev : (All (A) ((Stream A) (Stream A) (Stream A) -> (Stream A))))
(define (rotateRev rer frnt accum)
  (if (empty-stream? rer)
      (stream-append (stream-reverse frnt) accum)
      (stream-cons (stream-car rer) 
                   (rotateRev (stream-cdr rer) 
                              (drop inv-c frnt) 
                              (stream-reverse (stream-append (take inv-c frnt)
                                                             accum))))))


(: rotateDrop : (All (A) ((Stream A) Integer (Stream A) -> (Stream A))))
(define (rotateDrop rer num frnt)
  (if (< num inv-c)
      (rotateRev rer (drop num frnt) null-stream)
      (stream-cons (stream-car rer) 
                   (rotateDrop (stream-cdr rer) 
                               (- num inv-c) 
                               (drop inv-c frnt)))))

;; A Pseudo-constructor. Maintains the invariants 
;; 1. lenf <= inv-c * lenr
;; 2. lenr <= inv-c * lenf
(: internal-RTDeque : (All (A) ((RTDeque A) -> (RTDeque A))))
(define (internal-RTDeque que)
  (cond 
    [(> (RTDeque-lenf que) (add1 (* (RTDeque-lenr que) inv-c))) (maintainR que)]
    [(> (RTDeque-lenr que) (add1 (* (RTDeque-lenf que) inv-c))) (maintainF que)]
    [else que]))


;; Maintains invariant lenf <= inv-c * lenr
(: maintainR : (All (A) ((RTDeque A) -> (RTDeque A))))
(define (maintainR rtdq)
  (let*: ([new-lenf : Integer (arithmetic-shift (+ (RTDeque-lenf rtdq) 
                                                   (RTDeque-lenr rtdq)) -1)]
          [new-lenr : Integer (- (+ (RTDeque-lenf rtdq) 
                                    (RTDeque-lenr rtdq)) 
                                 new-lenf)]
          [newF : (Stream A) (take new-lenf (RTDeque-front rtdq))]
          [newR : (Stream A) (rotateDrop (RTDeque-rear rtdq) 
                                         new-lenf
                                         (RTDeque-front rtdq))])
         (make-RTDeque newF new-lenf newF newR new-lenr newR)))


;; Maintains invariant lenr <= inv-c * lenf
(: maintainF : (All (A) ((RTDeque A) -> (RTDeque A))))
(define (maintainF rtdq)
  (let*: ([new-lenf : Integer (arithmetic-shift  (+ (RTDeque-lenf rtdq) 
                                                    (RTDeque-lenr rtdq)) -1)]
          [new-lenr : Integer (- (+ (RTDeque-lenf rtdq) 
                                    (RTDeque-lenr rtdq)) 
                                 new-lenf)]
          [newF : (Stream A)  (rotateDrop (RTDeque-front rtdq)
                                          new-lenr
                                          (RTDeque-rear rtdq))]
          [newR : (Stream A) (take new-lenr (RTDeque-rear rtdq))])
         (make-RTDeque newF new-lenf newF newR new-lenr newR)))


;; Pushes an element into the RTDeque at the front end
(: enqueue : (All (A) (A (RTDeque A) -> (RTDeque A))))
(define (enqueue elem rtdq)
  (internal-RTDeque (make-RTDeque (stream-cons elem (RTDeque-front rtdq))
                                  (add1 (RTDeque-lenf rtdq))
                                  (exec-one (RTDeque-scdulF rtdq))
                                  (RTDeque-rear rtdq)
                                  (RTDeque-lenr rtdq)
                                  (RTDeque-scdulR rtdq))))


;; Pushes an element into the RTDeque at the rear end
(: snoc : (All (A) (A (RTDeque A) -> (RTDeque A))))
(define (snoc elem rtdq)
  (internal-RTDeque (make-RTDeque (RTDeque-front rtdq)
                                  (RTDeque-lenf rtdq)
                                  (RTDeque-scdulF rtdq)
                                  (stream-cons elem (RTDeque-rear rtdq))
                                  (add1 (RTDeque-lenr rtdq))
                                  (exec-one (RTDeque-scdulR rtdq)))))

;; Retrieves the head element of the queue
(: head : (All (A) ((RTDeque A) -> A)))
(define (head rtdq)
  (cond 
    [(empty? rtdq) (error "Deque is empty :" 'head)]
    [(empty-stream? (RTDeque-front rtdq)) (stream-car (RTDeque-rear rtdq))]
    [else (stream-car (RTDeque-front rtdq))]))


;; Retrieves the last element of the queue
(: last : (All (A) ((RTDeque A) -> A)))
(define (last rtdq)
  (cond 
    [(empty? rtdq) (error "Deque is empty :" 'last)]
    [(empty-stream? (RTDeque-rear rtdq)) (stream-car (RTDeque-front rtdq))]
    [else (stream-car (RTDeque-rear rtdq))]))

;; RTDequeue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((RTDeque A) -> (RTDeque A))))
(define (tail rtdq)
  (cond 
    [(empty? rtdq) (error "Deque is empty :" 'tail)]
    [(empty-stream? (RTDeque-front rtdq)) empty]
    [else (internal-RTDeque (make-RTDeque (stream-cdr (RTDeque-front rtdq)) 
                                          (sub1 (RTDeque-lenf rtdq))
                                          (exec-two (RTDeque-scdulF rtdq))
                                          (RTDeque-rear rtdq)
                                          (RTDeque-lenr rtdq)
                                          (exec-two (RTDeque-scdulR rtdq))))]))

;; Removes the last and returns the RTDeque without the last
(: init : (All (A) ((RTDeque A) -> (RTDeque A))))
(define (init rtdq)
  (cond 
    [(empty? rtdq) (error "Deque is empty :" 'init)]
    [(empty-stream? (RTDeque-rear rtdq)) empty]
    [else (internal-RTDeque (make-RTDeque (RTDeque-front rtdq)
                                          (RTDeque-lenf rtdq)
                                          (exec-two (RTDeque-scdulF rtdq))
                                          (stream-cdr (RTDeque-rear rtdq))
                                          (sub1 (RTDeque-lenr rtdq))
                                          (exec-two (RTDeque-scdulR rtdq))))]))

(: rtdeque->list : (All (A) ((RTDeque A) -> (Listof A))))
(define (rtdeque->list dque)
  (if (empty? dque)
      null
      (cons (last dque) (rtdeque->list (init dque)))))


;; A RTDeque constructor with the given element
(: rtdeque : (All (A) ((Listof A) -> (RTDeque A))))
(define (rtdeque lst)
  (foldl (inst enqueue A) empty lst))