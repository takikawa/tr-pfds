#lang typed-scheme

(require test-engine/scheme-tests)
(require scheme/base)

(define-struct: (A) Queue 
  ([front : (Listof A)] 
   [back  : (Listof A)]))

;; Checks if the given queue is empty
(: empty? : (All (A) ((Queue A) -> Boolean)))
(define empty?
  (lambda (que)
    (null? (Queue-front que))))

(eq? (empty? (make-Queue '() '())) #t)
(eq? (empty? (make-Queue '(4) '(4))) #f)



;; Enqueues a given element into the queue
(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define enqueue
  (lambda (elem que)
    (if (empty? que)
        (make-Queue (list elem) '())
        (make-Queue (Queue-front que) (cons elem (Queue-back que))))))

(eq? (enqueue 2 (make-Queue '() '())) (make-Queue '(2) '()))
(eq? (enqueue 4 (make-Queue '(2) '())) (make-Queue '(2) '(4)))
(eq? (enqueue 3 (make-Queue '(2) '(4))) (make-Queue '(2) '(3 4)))
(eq? (enqueue 5 (make-Queue '(4 3) '())) (make-Queue '(4 3) '(5)))
(eq? (enqueue "6" (make-Queue '(4 3) '(5))) (make-Queue '(4 3) '("6" 5)))


;; Gives the next element in the queue
(: head : (All (A) ((Queue A) -> A)))
(define head
  (lambda (que)
    (if (empty? que)
        (error "Required non empty queue. Given empty queue " 'head)
        (car (Queue-front que)))))


;(eq? (head (make-Queue '() '())) "Error")
(eq? (head (make-Queue '(4 5) '(6 7))) 4)
(eq? (head (make-Queue '(5) '(6 7))) 5)


;; Gives the Queue with out the first element
(: tail : (All (A) ((Queue A) -> (Queue A))))
(define tail
  (lambda (que)
    (cond 
      [(empty? que) (error "Required non empty queue. Given empty queue " 'tail)]
      [(null? (cdr (Queue-front que))) (make-Queue (reverse (Queue-back que)) '())]
      [else (make-Queue (cdr (Queue-front que)) (Queue-back que))])))

;(eq? (tail (make-Queue '() '())) "Error")
(eq? (tail (make-Queue '(4 5) '(6 7))) (make-Queue '(5) '(6 7)))
(eq? (tail (make-Queue '(5) '(6 7)))   (make-Queue '(7 6) '()))


;; Returns a promise of queue of the given number
(: queue1 : (All (A) ((Queue A) (Listof A) -> (Queue A))))
(define (queue1 que lst)
  (foldl enqueue que lst))

(: queue : (All (A) (A * -> ( -> (Queue A)))))
(define (queue . lst)
  (lambda () (queue1 (make-Queue '() '()) lst)))

(eq? (queue 5) (lambda () (enqueue 5 (make-Queue '() '()))))
(eq? (queue "5") (lambda () (enqueue "5" (make-Queue '() '()))))
