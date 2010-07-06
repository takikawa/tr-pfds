#lang typed-scheme

(require "stream.ss")

(provide filter remove
         empty? empty enqueue-front head tail deque enqueue last init
         deque->list foldr (rename-out [dqmap map] [dqfoldl foldl]))

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
      (error 'head "given deque is empty")
      (let ([front (Deque-front deq)])
        (if (empty-stream? front) 
            (stream-car (Deque-rear deq))
            (stream-car front)))))


;; Retrieves the last element of the queue
(: last : (All (A) ((Deque A) -> A)))
(define (last deq)
  (if (empty? deq) 
      (error 'last "given deque is empty")
      (let ([rear (Deque-rear deq)])
        (if (empty-stream? rear) 
            (stream-car (Deque-front deq))
            (stream-car rear)))))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: tail : (All (A) ((Deque A) -> (Deque A))))
(define (tail deq)
  (if (empty? deq) 
      (error 'tail "given deque is empty")
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
      (error 'init "given deque is empty")
      (let ([rear (Deque-rear deq)])
        (if (empty-stream? rear)
            empty
            (internal-deque (Deque-front deq) 
                            (Deque-lenf deq)
                            (stream-cdr rear)
                            (sub1 (Deque-lenr deq)))))))


(: dqmap : (All (A C B ...) 
               ((A B ... B -> C) (Deque A) (Deque B) ... B -> (Deque C))))
(define (dqmap func que . ques)
  (: in-map : (All (A C B ...) 
                   ((Deque C) (A B ... B -> C) (Deque A) (Deque B) ... B -> 
                              (Deque C))))
  (define (in-map accum func que . ques)
    (if (or (empty? que) (ormap empty? ques))
        accum
        (apply in-map 
               (enqueue (apply func (head que) (map head ques)) accum)
               func 
               (tail que)
               (map tail ques))))
  (apply in-map empty func que ques))


(: foldr : (All (A C B ...)
               ((C A B ... B -> C) C (Deque A) (Deque B) ... B -> C)))
(define (foldr func base que . ques)
  (if (or (empty? que) (ormap empty? ques))
        base
        (apply foldr 
               func 
               (apply func base (head que) (map head ques))
               (tail que)
               (map tail ques))))


(: dqfoldl : (All (A C B ...)
               ((C A B ... B -> C) C (Deque A) (Deque B) ... B -> C)))
(define (dqfoldl func base que . ques)
  (if (or (empty? que) (ormap empty? ques))
        base
        (apply dqfoldl 
               func 
               (apply func base (last que) (map last ques))
               (init que)
               (map init ques))))


(: deque->list : (All (A) ((Deque A) -> (Listof A))))
(define (deque->list deq)
  (if (empty? deq)
      null
      (cons (head deq) (deque->list (tail deq)))))

;; A Deque constructor with the given element
(: deque : (All (A) (A * -> (Deque A))))
(define (deque . lst)
  (foldl (inst enqueue A) empty lst))


(: filter : (All (A) ((A -> Boolean) (Deque A) -> (Deque A))))
(define (filter func que)
  (: inner : (All (A) ((A -> Boolean) (Deque A) (Deque A) -> (Deque A))))
  (define (inner func que accum)
    (if (empty? que)
        accum
        (let ([head (head que)]
              [tail (tail que)])
          (if (func head)
              (inner func tail (enqueue head accum))
              (inner func tail accum)))))
  (inner func que empty))


(: remove : (All (A) ((A -> Boolean) (Deque A) -> (Deque A))))
(define (remove func que)
  (: inner : (All (A) ((A -> Boolean) (Deque A) (Deque A) -> (Deque A))))
  (define (inner func que accum)
    (if (empty? que)
        accum
        (let ([head (head que)]
              [tail (tail que)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (enqueue head accum))))))
  (inner func que empty))
