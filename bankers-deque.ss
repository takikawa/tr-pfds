#lang typed-scheme

(require "stream.ss")

(provide empty? empty enqueue-front head tail
         deque enqueue last init deque->list)
         
;; A Banker's Queue (Maintains length of front >= length of rear)

(define-struct: (A) Deque
  ([front : (Stream A)]
   [lenf  : Integer]
   [rear  : (Stream A)]
   [lenr  : Integer]))

(define inv-c 2)

;; Constants
(define empty (make-Deque empty-stream 0 empty-stream 0))

;; Checks if the given deque is empty
(: empty? : (All (A) ((Deque A) -> Boolean)))
(define (empty? que)
  (zero? (+ (Deque-lenf que) (Deque-lenr que))))


;; A Pseudo-constructor. Maintains the invariants 
;; 1. lenf <= inv-c * lenr
;; 2. lenr <= inv-c * lenf
(: internal-deque : 
   (All (A) ((Stream A) Integer (Stream A) Integer -> (Deque A))))
(define (internal-deque front lenf rear lenr)
  (cond 
    [(> lenf (add1 (* lenr inv-c))) (maintainF front lenf rear lenr)]
    [(> lenr (add1 (* lenf inv-c))) (maintainR front lenf rear lenr)]
    [else (make-Deque front lenf rear lenr)]))


;; Maintains invariant lenf <= inv-c * lenr
(: maintainF : (All (A) ((Stream A) Integer (Stream A) Integer -> (Deque A))))
(define (maintainF front lenf rear lenr)
  (let* ([new-lenf (arithmetic-shift (+ lenf lenr) -1)]
         [new-lenr (- (+ lenf lenr) new-lenf)]
         [newF (take new-lenf front)]
         [newR (stream-append rear (stream-reverse (drop new-lenf front)))])
    (make-Deque newF new-lenf newR new-lenr)))


;; Maintains invariant lenr <= inv-c * lenf
(: maintainR : (All (A) ((Stream A) Integer (Stream A) Integer -> (Deque A))))
(define (maintainR front lenf rear lenr)
  (let* ([new-lenf (arithmetic-shift (+ lenf lenr) -1)]
         [new-lenr (- (+ lenf lenr) new-lenf)]
         [newR (take (ann new-lenr Integer) rear)]
         [newF (stream-append front (stream-reverse (drop new-lenr rear)))])
    (make-Deque newF new-lenf newR new-lenr)))


;; Pushes an element into the Deque at the front end
(: enqueue-front : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue-front elem deq)
  (internal-deque (stream-cons elem (Deque-front deq))
                  (add1 (Deque-lenf deq))
                  (Deque-rear deq)
                  (Deque-lenr deq)))


;; Pushes an element into the Deque at the rear end
(: enqueue : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue elem deq)
  (internal-deque (Deque-front deq)
                  (Deque-lenf deq)
                  (stream-cons elem (Deque-rear deq))
                  (add1 (Deque-lenr deq))))

;; Retrieves the head element of the queue
(: head : (All (A) ((Deque A) -> A)))
(define (head deq)
  (if (empty? deq)
      (error "Deque is empty :" 'head)
      (let ([front (Deque-front deq)])
        (if (empty-stream? front) 
            (stream-car (Deque-rear deq))
            (stream-car front)))))


;; Retrieves the last element of the queue
(: last : (All (A) ((Deque A) -> A)))
(define (last deq)
  (if (empty? deq) 
      (error "Deque is empty :" 'last)
      (let ([rear (Deque-rear deq)])
        (if (empty-stream? rear) 
            (stream-car (Deque-front deq))
            (stream-car rear)))))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((Deque A) -> (Deque A))))
(define (tail deq)
  (if (empty? deq) 
      (error "Deque is empty :" 'tail)
      (let ([front (Deque-front deq)])
        (if (empty-stream? front) 
            empty
            (internal-deque (stream-cdr front) 
                            (sub1 (Deque-lenf deq))
                            (Deque-rear deq)
                            (Deque-lenr deq))))))

;; Removes the last and returns the deque without the last
(: init : (All (A) ((Deque A) -> (Deque A))))
(define (init deq)
  (if (empty? deq)
      (error "Deque is empty :" 'init)
      (let ([rear (Deque-rear deq)])
        (if (empty-stream? rear)
            empty
            (internal-deque (Deque-front deq) 
                            (Deque-lenf deq)
                            (stream-cdr rear)
                            (sub1 (Deque-lenr deq)))))))

(: deque->list : (All (A) ((Deque A) -> (Listof A))))
(define (deque->list deq)
  (if (empty? deq)
      null
      (cons (head deq) (deque->list (tail deq)))))

;; A Deque constructor with the given element
(: deque : (All (A) (A * -> (Deque A))))
(define (deque . lst)
  (foldl (inst enqueue A) empty lst))