#lang typed-scheme

(provide empty empty? enqueue head tail queue->list queue)
(require scheme/promise scheme/match)

(define-struct: Zero ())
(define-struct: (A) One ([elem : A]))
(define-struct: (A) Two ([fst : A]
                         [snd : A]))
(define-type-alias ZeroOne (All (A) (U Zero (One A))))
(define-type-alias OneTwo (All (A) (U (One A) (Two A))))
(define-struct: (A) Shallow ([elem : (ZeroOne A)]))
(define-struct: (A) Deep ([F : (OneTwo A)]
                          [M : (Promise (Pair (ImplQueue A) (ImplQueue A)))]
                          [R : (ZeroOne A)]))

(define-type-alias ImplQueue (All (A) (U (Shallow A) (Deep A))))

(define empty (make-Shallow (make-Zero)))

(: empty? : (All (A) ((ImplQueue A) -> Boolean)))
(define (empty? que)
  (and (Shallow? que) (Zero? (Shallow-elem que))))

(: enqueue : (All (A) (A (ImplQueue A) -> (ImplQueue A))))
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


(: head : (All (A) ((ImplQueue A) -> A)))
(define (head que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error "Queue is empty :" 'head)]
    [(struct Shallow ((struct One (one)))) one]
    [(struct Deep ((struct One (one)) _ _)) one]
    [(struct Deep ((struct Two (one two)) _ _)) one]))

(: tail : (All (A) ((ImplQueue A) -> (ImplQueue A))))
(define (tail que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error "Queue is empty :" 'tail)]
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


(: queue->list : (All (A) ((ImplQueue A) -> (Listof A))))
(define (queue->list que)
  (if (and (Shallow? que) (Zero? (Shallow-elem que)))
      null
      (cons (head que) (queue->list (tail que)))))

(: queue : (All (A) (A * -> (ImplQueue A))))
(define (queue . lst)
  (foldl (inst enqueue A) (make-Shallow (make-Zero)) lst))