#lang typed-scheme

(provide empty empty? enqueue snoc init 
         last head tail rtdeque rtdeque->list)

(require "stream2.ss")

(define-struct: (A) RTDeque
  ([front  : (Stream A)]
   [lenf   : Integer]
   [scdulF : (Stream A)]
   [rear   : (Stream A)]
   [lenr   : Integer]
   [scdulR : (Stream A)]))

(define inv-c 3)

(define empty (make-RTDeque null-stream 0 null-stream
                            null-stream 0 null-stream))


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
(define (rotateRev frnt rer accum)
  (if (empty-stream? frnt)
      (stream-append (stream-reverse rer) accum)
      (stream-cons (stream-car frnt)
                   (rotateRev (stream-cdr frnt)
                              (drop inv-c rer)
                              (stream-reverse (stream-append (take inv-c rer)
                                                             accum))))))

;(: partial-rev : (All (A) (Integer (Stream A) (Stream A))

(: rotateDrop : (All (A) ((Stream A) Integer (Stream A) -> (Stream A))))
(define (rotateDrop frnt num rer)
  (if (< num inv-c)
      (rotateRev frnt (drop num rer) null-stream)
      (stream-cons (stream-car frnt) 
                   (rotateDrop (stream-cdr frnt) 
                               (- num inv-c) 
                               (drop inv-c rer)))))

(define-type-alias (S A) (Stream A))
;; A Pseudo-constructor. Maintains the invariants 
;; 1. lenf <= inv-c * lenr
;; 2. lenr <= inv-c * lenf

(: internal-RTDeque : 
   (All (A) ((S A) Integer (S A) (S A) Integer (S A) -> (RTDeque A))))
(define (internal-RTDeque fr lenf sf r lenr sr)
  (cond 
    [(> lenf (add1 (* lenr inv-c))) (maintainR fr lenf sf r lenr sr)]
    [(> lenr (add1 (* lenf inv-c))) (maintainF fr lenf sf r lenr sr)]
    [else (make-RTDeque fr lenf sf r lenr sr)]))


;; Maintains invariant lenf <= inv-c * lenr
(: maintainR : 
   (All (A) ((S A) Integer (S A) (S A) Integer (S A) -> (RTDeque A))))
(define (maintainR front lenf sf rear lenr sr)
  (let* ([new-lenf (arithmetic-shift (+ lenf lenr) -1)]
         [new-lenr (- (+ lenf lenr) new-lenf)]
         [newF (take new-lenf front)]
         [newR (rotateDrop rear new-lenf front)])
    (make-RTDeque newF new-lenf newF newR new-lenr newR)))


;; Maintains invariant lenr <= inv-c * lenf
(: maintainF : 
   (All (A) ((S A) Integer (S A) (S A) Integer (S A) -> (RTDeque A))))
(define (maintainF front lenf sf rear lenr sr)
  (let* ([new-lenr (arithmetic-shift  (+ lenf lenr) -1)]
         [new-lenf (- (+ lenf lenr) new-lenr)]
         [newF (rotateDrop front new-lenr rear)]
         [newR (take new-lenr rear)])
    (make-RTDeque newF new-lenf newF newR new-lenr newR)))


;; Pushes an element into the RTDeque at the front end
(: enqueue : (All (A) (A (RTDeque A) -> (RTDeque A))))
(define (enqueue elem rtdq)
  (internal-RTDeque (stream-cons elem (RTDeque-front rtdq))
                    (add1 (RTDeque-lenf rtdq))
                    (exec-one (RTDeque-scdulF rtdq))
                    (RTDeque-rear rtdq)
                    (RTDeque-lenr rtdq)
                    (exec-one (RTDeque-scdulR rtdq))))


;; Pushes an element into the RTDeque at the rear end
(: snoc : (All (A) (A (RTDeque A) -> (RTDeque A))))
(define (snoc elem rtdq)
  (internal-RTDeque (RTDeque-front rtdq)
                    (RTDeque-lenf rtdq)
                    (exec-one (RTDeque-scdulF rtdq))
                    (stream-cons elem (RTDeque-rear rtdq))
                    (add1 (RTDeque-lenr rtdq))
                    (exec-one (RTDeque-scdulR rtdq))))

;; Retrieves the head element of the queue
(: head : (All (A) ((RTDeque A) -> A)))
(define (head rtdq)
  (if (empty? rtdq) 
      (error "Deque is empty :" 'head)
      (let ([front (RTDeque-front rtdq)])
        (if (empty-stream? front) 
            (stream-car (RTDeque-rear rtdq))
            (stream-car front)))))


;; Retrieves the last element of the queue
(: last : (All (A) ((RTDeque A) -> A)))
(define (last rtdq)
  (if (empty? rtdq)
      (error "Deque is empty :" 'last)
      (let ([rear (RTDeque-rear rtdq)])
        (if (empty-stream? rear) 
            (stream-car (RTDeque-front rtdq))
            (stream-car rear)))))

;; Removes the head and returns the rest of the queue
(: tail : (All (A) ((RTDeque A) -> (RTDeque A))))
(define (tail rtdq)
  (if (empty? rtdq) 
      (error "Deque is empty :" 'tail)
      (let ([front (RTDeque-front rtdq)])
        (if (empty-stream? front) 
            empty
            (internal-RTDeque (stream-cdr front) 
                              (sub1 (RTDeque-lenf rtdq))
                              (exec-two (RTDeque-scdulF rtdq))
                              (RTDeque-rear rtdq)
                              (RTDeque-lenr rtdq)
                              (exec-two (RTDeque-scdulR rtdq)))))))

;; Removes the last and returns the RTDeque without the last
(: init : (All (A) ((RTDeque A) -> (RTDeque A))))
(define (init rtdq)
  (if (empty? rtdq) 
      (error "Deque is empty :" 'init)
      (let ([rear (RTDeque-rear rtdq)])
        (if (empty-stream? rear)
            empty
            (internal-RTDeque (RTDeque-front rtdq)
                              (RTDeque-lenf rtdq)
                              (exec-two (RTDeque-scdulF rtdq))
                              (stream-cdr rear)
                              (sub1 (RTDeque-lenr rtdq))
                              (exec-two (RTDeque-scdulR rtdq)))))))

(: rtdeque->list : (All (A) ((RTDeque A) -> (Listof A))))
(define (rtdeque->list dque)
  (if (empty? dque)
      null
      (cons (last dque) (rtdeque->list (init dque)))))


(: list->rtdeque : (All (A) ((Listof A) -> (RTDeque A))))
(define (list->rtdeque lst)
  (foldl (inst enqueue A) empty lst))

;; A RTDeque constructor
(: rtdeque : (All (A) (A * -> (RTDeque A))))
(define (rtdeque . lst)
  (foldl (inst enqueue A) empty lst))

;(rtdeque->list (apply rtdeque (build-list 26 (λ: ([x : Integer]) x))))

(last (init (init (init (init (init (init (init (init (init (init (init (apply rtdeque (build-list 26 (λ: ([x : Integer]) x)))))))))))))))