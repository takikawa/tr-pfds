#lang typed-scheme

(require "stream.ss")

(define-struct: (A) RTdeque
  ([front  : (Stream A)]
   [lenf   : Integer]
   [scdulF : (Stream A)]
   [rear   : (Stream A)]
   [lenr   : Integer]
   [scdulR : (Stream A)]))

(define inv-c 2)

(define empty-rtdq (make-RTdeque (stream null) 0 (stream null)
                                 (stream null) 0 (stream null)))


(: rtdq-empty? : (All (A) ((RTdeque A) -> Boolean)))
(define (rtdq-empty? rtdq)
  (zero? (+ (RTdeque-lenf rtdq) (RTdeque-lenr rtdq))))


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
(: internal-rtdeque : (All (A) ((RTdeque A) -> (RTdeque A))))
(define (internal-rtdeque que)
  (cond 
    [(> (RTdeque-lenf que) (add1 (* (RTdeque-lenr que) inv-c))) (maintainR que)]
    [(> (RTdeque-lenr que) (add1 (* (RTdeque-lenf que) inv-c))) (maintainF que)]
    [else que]))


;; Maintains invariant lenf <= inv-c * lenr
(: maintainR : (All (A) ((RTdeque A) -> (RTdeque A))))
(define (maintainR rtdq)
  (let*: ([new-lenf : Integer (round (/ (+ (RTdeque-lenf rtdq) (RTdeque-lenr rtdq)) 2))]
          [new-lenr : Integer (- (+ (RTdeque-lenf rtdq) (RTdeque-lenr rtdq)) new-lenf)]
          [newF : (Stream A) (take new-lenf (RTdeque-front rtdq))]
          [newR : (Stream A) (rotateDrop (RTdeque-rear rtdq) 
                                         new-lenf
                                         (RTdeque-front rtdq))])
         (make-RTdeque newF new-lenf newF newR new-lenr newR)))


;; Maintains invariant lenr <= inv-c * lenf
(: maintainF : (All (A) ((RTdeque A) -> (RTdeque A))))
(define (maintainF rtdq)
  (let*: ([new-lenf : Integer (round (/ (+ (RTdeque-lenf rtdq) (RTdeque-lenr rtdq)) 2))]
          [new-lenr : Integer (- (+ (RTdeque-lenf rtdq) (RTdeque-lenr rtdq)) new-lenf)]
          [newF : (Stream A)  (rotateDrop (RTdeque-front rtdq)
                                          new-lenr
                                          (RTdeque-rear rtdq))]
          [newR : (Stream A) (take new-lenr (RTdeque-rear rtdq))])
         (make-RTdeque newF new-lenf newF newR new-lenr newR)))


;; Pushes an element into the rtdeque at the front end
(: rtdq-cons : (All (A) (A (RTdeque A) -> (RTdeque A))))
(define (rtdq-cons elem rtdq)
  (internal-rtdeque (make-RTdeque (stream-cons elem (RTdeque-front rtdq))
                                  (add1 (RTdeque-lenf rtdq))
                                  (exec-one (RTdeque-scdulF rtdq))
                                  (RTdeque-rear rtdq)
                                  (RTdeque-lenr rtdq)
                                  (RTdeque-scdulR rtdq))))


;; Pushes an element into the rtdeque at the rear end
(: rtdq-snoc : (All (A) (A (RTdeque A) -> (RTdeque A))))
(define (rtdq-snoc elem rtdq)
  (internal-rtdeque (make-RTdeque (RTdeque-front rtdq)
                                  (RTdeque-lenf rtdq)
                                  (RTdeque-scdulF rtdq)
                                  (stream-cons elem (RTdeque-rear rtdq))
                                  (add1 (RTdeque-lenr rtdq))
                                  (exec-one (RTdeque-scdulR rtdq)))))

;; Retrieves the head element of the queue
(: rtdq-head : (All (A) ((RTdeque A) -> A)))
(define (rtdq-head rtdq)
  (cond 
    [(rtdq-empty? rtdq) (error "RTdeque is empty :" 'rtdq-head)]
    [(empty-stream? (RTdeque-front rtdq)) (stream-car (RTdeque-rear rtdq))]
    [else (stream-car (RTdeque-front rtdq))]))


;; Retrieves the last element of the queue
(: rtdq-last : (All (A) ((RTdeque A) -> A)))
(define (rtdq-last rtdq)
  (cond 
    [(rtdq-empty? rtdq) (error "RTdeque is empty :" 'rtdq-last)]
    [(empty-stream? (RTdeque-rear rtdq)) (stream-car (RTdeque-front rtdq))]
    [else (stream-car (RTdeque-rear rtdq))]))

;; rtdequeue operation. Removes the head and returns the rest of the queue
(: rtdq-tail : (All (A) ((RTdeque A) -> (RTdeque A))))
(define (rtdq-tail rtdq)
  (cond 
    [(rtdq-empty? rtdq) (error "RTdeque is empty :" 'rtdq-tail)]
    [(empty-stream? (RTdeque-front rtdq)) empty-rtdq]
    [else (internal-rtdeque (make-RTdeque (stream-cdr (RTdeque-front rtdq)) 
                                          (sub1 (RTdeque-lenf rtdq))
                                          (exec-two (RTdeque-scdulF rtdq))
                                          (RTdeque-rear rtdq)
                                          (RTdeque-lenr rtdq)
                                          (exec-two (RTdeque-scdulR rtdq))))]))

;; Removes the last and returns the rtdeque without the last
(: rtdq-init : (All (A) ((RTdeque A) -> (RTdeque A))))
(define (rtdq-init rtdq)
  (cond 
    [(rtdq-empty? rtdq) (error "RTdeque is empty :" 'rtdq-init)]
    [(empty-stream? (RTdeque-rear rtdq)) empty-rtdq]
    [else (internal-rtdeque (make-RTdeque (RTdeque-front rtdq)
                                          (RTdeque-lenf rtdq)
                                          (exec-two (RTdeque-scdulF rtdq))
                                          (stream-cdr (RTdeque-rear rtdq))
                                          (sub1 (RTdeque-lenr rtdq))
                                          (exec-two (RTdeque-scdulR rtdq))))]))

;; A rtdeque constructor with the given element
(: rtdeque : (All (A) ((Listof A) -> (RTdeque A))))
(define (rtdeque lst)
  (foldl (inst rtdq-snoc A) empty-rtdq lst))