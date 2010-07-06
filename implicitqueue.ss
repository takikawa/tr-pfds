#lang typed-scheme

(provide filter remove
         empty empty? enqueue head tail queue->list queue
         (rename-out [qmap map]) fold)
(require scheme/promise scheme/match)

(define-struct: Zero ())
(define-struct: (A) One ([elem : A]))
(define-struct: (A) Two ([fst : A]
                         [snd : A]))
(define-type-alias ZeroOne (All (A) (U Zero (One A))))
(define-type-alias OneTwo (All (A) (U (One A) (Two A))))
(define-struct: (A) Shallow ([elem : (ZeroOne A)]))
(define-struct: (A) Deep ([F : (OneTwo A)]
                          [M : (Promise (Pair (Queue A) (Queue A)))]
                          [R : (ZeroOne A)]))

(define-type-alias Queue (All (A) (U (Shallow A) (Deep A))))

(define empty (make-Shallow (make-Zero)))

(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? que)
  (and (Shallow? que) (Zero? (Shallow-elem que))))

(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue elem que)
  (match que
    [(struct Shallow ((struct Zero ()))) (make-Shallow (make-One elem))]
    [(struct Shallow ((struct One (one)))) (make-Deep (make-Two one elem)
                                                      (delay (cons empty empty))
                                                      (make-Zero))]
    [(struct Deep (f m (struct Zero ()))) (make-Deep f m (make-One elem))]
    [(struct Deep (f m (struct One (el))))
     (let ([forced-mid (force m)])
       (make-Deep f (delay (cons (enqueue el (car forced-mid))
                                 (enqueue elem (cdr forced-mid))))
                  (make-Zero)))]))


(: head : (All (A) ((Queue A) -> A)))
(define (head que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error 'head "given queue is empty")]
    [(struct Shallow ((struct One (one)))) one]
    [(struct Deep ((struct One (one)) _ _)) one]
    [(struct Deep ((struct Two (one two)) _ _)) one]))

(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error 'tail "given queue is empty")]
    [(struct Shallow ((struct One (one)))) (make-Shallow (make-Zero))]
    [(struct Deep ((struct Two (one two)) m r)) (make-Deep (make-One two) m r)]
    [(struct Deep (_ m r)) 
     (let* ([forced-mid (force m)]
            [carm (car forced-mid)])
       (if (empty? carm) 
           (make-Shallow r)
           (let* ([cdrm (cdr forced-mid)]
                  [fst (head carm)]
                  [snd (head cdrm)]
                  [new-mid (delay (cons (tail carm) (tail cdrm)))])
             (make-Deep (make-Two fst snd) new-mid r))))]))


(: qmap : (All (A C B ...) 
               ((A B ... B -> C) (Queue A) (Queue B) ... B -> (Queue C))))
(define (qmap func que . ques)
  (: in-map : (All (A C B ...) 
                   ((Queue C) (A B ... B -> C) (Queue A) (Queue B) ... B -> 
                              (Queue C))))
  (define (in-map accum func que . ques)
    (if (or (empty? que) (ormap empty? ques))
        accum
        (apply in-map 
               (enqueue (apply func (head que) (map head ques)) accum)
               func 
               (tail que)
               (map tail ques))))
  (apply in-map empty func que ques))


(: fold : (All (A C B ...)
               ((C A B ... B -> C) C (Queue A) (Queue B) ... B -> C)))
(define (fold func base que . ques)
  (if (or (empty? que) (ormap empty? ques))
        base
        (apply fold 
               func 
               (apply func base (head que) (map head ques))
               (tail que)
               (map tail ques))))

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list que)
  (if (and (Shallow? que) (Zero? (Shallow-elem que)))
      null
      (cons (head que) (queue->list (tail que)))))

(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) (make-Shallow (make-Zero)) lst))

(: filter : (All (A) ((A -> Boolean) (Queue A) -> (Queue A))))
(define (filter func que)
  (: inner : (All (A) ((A -> Boolean) (Queue A) (Queue A) -> (Queue A))))
  (define (inner func que accum)
    (if (empty? que)
        accum
        (let ([head (head que)]
              [tail (tail que)])
          (if (func head)
              (inner func tail (enqueue head accum))
              (inner func tail accum)))))
  (inner func que empty))


(: remove : (All (A) ((A -> Boolean) (Queue A) -> (Queue A))))
(define (remove func que)
  (: inner : (All (A) ((A -> Boolean) (Queue A) (Queue A) -> (Queue A))))
  (define (inner func que accum)
    (if (empty? que)
        accum
        (let ([head (head que)]
              [tail (tail que)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (enqueue head accum))))))
  (inner func que empty))
