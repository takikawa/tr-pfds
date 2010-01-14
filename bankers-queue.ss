#lang typed-scheme

;; A Banker's Queue (Maintains length of front >= length of rear)

(define-struct: Queue 
  ([front : ( -> (Listof Any))]
   [lenf  : Integer]
   [rear  : ( -> (Listof Any))]
   [lenr  : Integer]))

;; Suspends an operation for later execution
(: susp : ((Listof Any) -> (-> (Listof Any))))
(define susp
  (lambda (lst)
    (lambda () lst)))


;; Executes a suspended operation
(: exec : ((-> (Listof Any)) -> (Listof Any)))
(define exec
  (lambda (func)
    (func)))


;; Constants
(define ZERO 0)
(define nul (susp '()))
(define empty (make-Queue nul ZERO nul ZERO))

;; Checks if the given queue is empty
(: empty? : (Queue -> Boolean))
(define empty?
  (lambda (que)
    (eq? (Queue-lenf que) ZERO)))


;; A Pseudo-constructor. Maintains the invariant lenf >= lenr
(: internal-queue : (Queue -> Queue))
(define internal-queue
  (lambda (que)
    (if (>= (Queue-lenf que) (Queue-lenr que))
        que
        (make-Queue (susp (append (exec (Queue-front que)) 
                                  (reverse (exec (Queue-rear que)))))
                    (+ (Queue-lenf que) (Queue-lenr que))
                    nul ZERO))))

;; Pushes an element into the queue
(: enqueue : (Any Queue -> Queue))
(define enqueue
  (lambda (elem que)
    (internal-queue (make-Queue (Queue-front que) 
                                (Queue-lenf que) 
                                (susp (cons elem (exec (Queue-rear que))))
                                (add1 (Queue-lenr que))))))

;; Retrieves the head element of the queue
(: head : (Queue -> Any))
(define head
  (lambda (que)
    (if (empty? que)
        (error "Queue is empty" 'head)
        (car (exec (Queue-front que))))))

;; Dequeue operation. Removes the head and returns the rest of the queue
(: tail : (Queue -> Queue))
(define tail
  (lambda (que)
    (if (empty? que)
        (error "Queue is empty" 'head)
        (internal-queue (make-Queue (susp (cdr (exec (Queue-front que)))) 
                                    (sub1 (Queue-lenf que))
                                    (Queue-rear que)
                                    (Queue-lenf que))))))

;; A Queue constructor with the given element
(: queue : (Any * -> Queue))
(define (queue . lst)
  (if (null? lst) 
      empty
      (foldl enqueue empty lst)))


;;------------------------------------------------------------------------
;; Checks if the given two Queues are equal. (Defined for tests)
(: check-eq? : (Queue Queue -> Boolean))
(define check-eq?
  (lambda (que1 que2)
    (and (andmap equal? (exec (Queue-front que1)) (exec (Queue-front que2)))
         (andmap equal? (exec (Queue-rear que1)) (exec (Queue-rear que2))))))

(and 
 (eq? (empty? empty) #t)
 (eq? (empty? (make-Queue (susp '(4 2)) 2 (susp '(4)) 0)) #f)
 
 (eq? (head (make-Queue (susp '(4 2)) 2 (susp '(4)) 1)) 4)
 (eq? (head (make-Queue (susp '(2)) 1 (susp '(4)) 1)) 2)  
 
 (check-eq? (tail (make-Queue (susp '(4)) 1 (susp '(2)) 1)) 
            (make-Queue (susp '(2)) 1 (susp '()) 0))
 (check-eq? (tail (make-Queue (susp '(4 2)) 2 (susp '(4)) 1)) 
            (make-Queue (susp '(2 4)) 2 (susp '()) 0))
 (check-eq? (tail (make-Queue (susp '(4 2)) 2 (susp '(4 5)) 2)) 
            (make-Queue (susp '(2 5 4)) 3 nul 0))
 
 (check-eq? (internal-queue empty) empty)
 (check-eq? (internal-queue (make-Queue (susp '(4 2)) 2 (susp '(4)) 1)) 
            (make-Queue (susp '(4 2)) 2 (susp '(4)) 1))
 (check-eq? (internal-queue (make-Queue (susp '(4 2)) 2 (susp '(4 5)) 2)) 
            (make-Queue (susp '(4 2)) 2 (susp '(4 5)) 2))
 (check-eq? (internal-queue (make-Queue (susp '(4 2)) 2 (susp '(4 5 6)) 3)) 
            (make-Queue (susp '(4 2 6 5 4)) 5 nul 0))
 
 (check-eq? (enqueue 1 empty) (make-Queue (susp '(1)) 1 nul 0))
 (check-eq? (enqueue 4 (make-Queue (susp '(4 2)) 2 nul 0)) 
            (make-Queue (susp '(4 2)) 2 (susp '(4)) 1))
 (check-eq? (enqueue 5 (make-Queue (susp '(4 2)) 2 (susp '(4)) 1)) 
            (make-Queue (susp '(4 2)) 2 (susp '(5 4)) 2))
 (check-eq? (enqueue "6" (make-Queue (susp '(4 2)) 2 (susp '(4 5)) 2)) 
            (make-Queue (susp '(4 2 5 4 "6")) 5 nul 0))
 
 (check-eq? (queue) empty)
 (check-eq? (queue 1 2 3) 
            (make-Queue (susp '(1 2 3)) 3 (susp '()) 0))
 (check-eq? (queue 1) 
            (make-Queue (susp '(1)) 1 nul 0))
 (check-eq? (queue 1 2 3 4) 
            (make-Queue (susp '(1 2 3)) 3 (susp '(4)) 1))
 (check-eq? (queue 1 2 3 4 5) 
            (make-Queue (susp '(1 2 3)) 3 (susp '(5 4)) 2))
 (check-eq? (queue 1 2 3 4 5 6) 
            (make-Queue (susp '(1 2 3)) 3 (susp '(6 5 4)) 3))
 (check-eq? (queue 1 2 3 4 5 6 7) 
            (make-Queue (susp '(1 2 3 4 5 6 7)) 7 (susp '()) 0))
 
 ;; Problem in check-eq?
 (check-eq? (queue '(1) '(2 2) '(3 4) '(5 6 7) '(5)) 
            (make-Queue (susp (list '(1) '(2 2) '(3 4))) 3 (susp (list '(5) '(5 6 7))) 2)))