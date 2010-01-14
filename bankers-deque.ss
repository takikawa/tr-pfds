#lang typed-scheme

(require "stream.ss")

(provide Deque dq-empty? dq-cons dq-head dq-tail
         deque dq-snoc dq-last dq-init)
         
;; A Banker's Queue (Maintains length of front >= length of rear)

(define-struct: (A) Deque
  ([front : (Stream A)]
   [lenf  : Integer]
   [rear  : (Stream A)]
   [lenr  : Integer]))

(define inv-c 2)

;; Constants
(define empty (make-Deque (stream null) 0 (stream null) 0))

;; Checks if the given deque is empty
(: dq-empty? : (All (A) ((Deque A) -> Boolean)))
(define (dq-empty? que)
  (eq? (+ (Deque-lenf que) (Deque-lenr que)) 0))


;; A Pseudo-constructor. Maintains the invariants 
;; 1. lenf <= inv-c * lenr
;; 2. lenr <= inv-c * lenf
(: internal-deque : (All (A) ((Deque A) -> (Deque A))))
(define (internal-deque que)
  (cond 
    [(> (Deque-lenf que) (add1 (* (Deque-lenr que) inv-c))) (maintainF que)]
    [(> (Deque-lenr que) (add1 (* (Deque-lenf que) inv-c))) (maintainR que)]
    [else que]))


;; Maintains invariant lenf <= inv-c * lenr
(: maintainF : (All (A) ((Deque A) -> (Deque A))))
(define (maintainF deq)
  (let*: ([new-lenf : Integer (round (/ (+ (Deque-lenf deq) (Deque-lenr deq)) 2))]
          [new-lenr : Integer (- (+ (Deque-lenf deq) (Deque-lenr deq)) new-lenf)]
          [newF : (Stream A) (take new-lenf (Deque-front deq))]
          [newR : (Stream A) (stream-append (Deque-rear deq) 
                                            (stream-reverse (drop new-lenf
                                                                  (Deque-front deq))))])
         (make-Deque newF new-lenf newR new-lenr)))


;; Maintains invariant lenr <= inv-c * lenf
(: maintainR : (All (A) ((Deque A) -> (Deque A))))
(define (maintainR deq)
  (let*: ([new-lenf : Integer (round (/ (+ (Deque-lenf deq) (Deque-lenr deq)) 2))]
          [new-lenr : Integer (- (+ (Deque-lenf deq) (Deque-lenr deq)) new-lenf)]
          [newR : (Stream A) (take (ann new-lenr Integer) (Deque-rear deq))]
          [newF : (Stream A) (stream-append (Deque-front deq) 
                                            (stream-reverse (drop new-lenr
                                                                  (Deque-rear deq))))])
         (make-Deque newF new-lenf newR new-lenr)))


;; Pushes an element into the Deque at the front end
(: dq-cons : (All (A) (A (Deque A) -> (Deque A))))
(define (dq-cons elem deq)
  (internal-deque (make-Deque (stream-cons elem (Deque-front deq))
                              (add1 (Deque-lenf deq))
                              (Deque-rear deq)
                              (Deque-lenr deq))))


;; Pushes an element into the Deque at the rear end
(: dq-snoc : (All (A) (A (Deque A) -> (Deque A))))
(define (dq-snoc elem deq)
  (internal-deque (make-Deque (Deque-front deq)
                              (Deque-lenf deq)
                              (stream-cons elem (Deque-rear deq))
                              (add1 (Deque-lenr deq)))))

;; Retrieves the head element of the queue
(: dq-head : (All (A) ((Deque A) -> A)))
(define (dq-head deq)
  (cond 
    [(dq-empty? deq) (error "Deque is empty :" 'dq-head)]
    [(empty-stream? (Deque-front deq)) (stream-car (Deque-rear deq))]
    [else (stream-car (Deque-front deq))]))


;; Retrieves the last element of the queue
(: dq-last : (All (A) ((Deque A) -> A)))
(define (dq-last deq)
  (cond 
    [(dq-empty? deq) (error "Deque is empty :" 'dq-last)]
    [(empty-stream? (Deque-rear deq)) (stream-car (Deque-front deq))]
    [else (stream-car (Deque-rear deq))]))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: dq-tail : (All (A) ((Deque A) -> (Deque A))))
(define (dq-tail deq)
  (cond 
    [(dq-empty? deq) (error "Deque is empty :" 'dq-tail)]
    [(empty-stream? (Deque-front deq)) empty]
    [else (internal-deque (make-Deque (stream-cdr (Deque-front deq)) 
                                      (sub1 (Deque-lenf deq))
                                      (Deque-rear deq)
                                      (Deque-lenr deq)))]))

;; Removes the last and returns the deque without the last
(: dq-init : (All (A) ((Deque A) -> (Deque A))))
(define (dq-init deq)
  (cond 
    [(dq-empty? deq) (error "Deque is empty :" 'dq-init)]
    [(empty-stream? (Deque-rear deq)) empty]
    [else (internal-deque (make-Deque (Deque-front deq) 
                                      (Deque-lenf deq)
                                      (stream-cdr (Deque-rear deq))
                                      (sub1 (Deque-lenr deq))))]))

;; A Deque constructor with the given element
(: deque : (All (A) ((Listof A) -> (Deque A))))
(define (deque lst)
  (foldl (inst dq-snoc A) empty lst))


;------------------------------------------------------------------------
; Checks if the given two deques are equal. (Defined for tests)
(: check-eq? : (All (A) ((Deque A) (Deque A) -> Boolean)))
(define check-eq?
  (lambda (que1 que2)
    (and (andmap equal? 
                 (stream->list (Deque-front que1)) 
                 (stream->list (Deque-front que2)))
         (andmap equal? 
                 (stream->list (Deque-rear que1)) 
                 (stream->list (Deque-rear que2))))))

(and 
 (eq? (dq-empty? empty) #t)
 (eq? (dq-empty? (deque (list 1 2 3))) #f)
 
 (eq? (dq-head (deque (list 1 2 3))) 1)
 (eq? (dq-head (deque (list 5 6 2 3))) 5)
 
 (eq? (dq-last (deque (list 1 2 3))) 3)
 (eq? (dq-last (deque (list 5 6 2 8))) 8)
 
 (check-eq? (dq-tail (deque (list 1 2 3))) 
            (deque (list 2 3)))
 (check-eq? (dq-tail (deque (list 1 2 3 5 7 8)))
            (deque (list 2 3 5 7 8)))
 
 (check-eq? (dq-init (deque (list 1 2 3))) 
            (deque (list 1 2)))
 (check-eq? (dq-init (deque (list 1 2 3 5 7 8)))
            (deque (list 1 2 3 5 7)))
 
 (check-eq? (dq-snoc 1 empty) (deque (list 1)))
 (check-eq? (dq-snoc 4 (deque (list 1 2))) 
            (deque (list 1 2 4)))
 
 (check-eq? (deque null) empty)
 (check-eq? (deque (list 1 2 3))
            (make-Deque (stream '(1)) 1 (stream '(3 2)) 2))
 (check-eq? (deque (list 1))
            (make-Deque null-stream 0 (stream '(1)) 1))
 (check-eq? (deque (list 1 2 3 4))
            (make-Deque (stream '(1)) 1 (stream '(4 3 2)) 3))
 (check-eq? (deque (list 1 2 3 4 5))
            (make-Deque (stream '(1 2)) 2 (stream '(5 4 3)) 3))
 (check-eq? (deque (list 1 2 3 4 5 6))
            (make-Deque (stream '(1 2)) 2 (stream '(6 5 4 3)) 4))
 (check-eq? (deque (list 1 2 3 4 5 6 7))
            (make-Deque (stream '(1 2)) 2 (stream '(7 6 5 4 3)) 5))
 (check-eq? (deque (list 1 2 3 4 5 6 7 8))
            (make-Deque (stream '(1 2 3 4)) 4 (stream '(8 7 6 5)) 4))
 
 ;; Problem in check-eq?
 (check-eq? (deque (list '(1) '(2 2) '(3 4) '(5 6 7) '(5))) 
            (make-Deque (stream (list '(1) '(2 2))) 2 (stream (list '(5) '(5 6 7) '(3 4))) 3)))