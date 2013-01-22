#lang scribble/manual

@(require "helper.rkt")
@(require (for-label pfds/queue/bankers))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require pfds/queue/bankers))

@title{Banker's Queue}

@defmodule[pfds/queue/bankers]

A Queue is nothing but a FIFO data structure. A Banker's Queue is a
amortized queue obtained using Bankers method. It provides a amortized
running time of @bold{@italic{O(1)}} for @scheme[head], @scheme[tail]
and @scheme[enqueue] operations. To obtain this amortized running time,
the data structure uses the techniques, lazy evaluation and
memoization. Banker's Queue internally uses Streams for lazy
evaluation. For Streams, see @secref["streams"]

@defform[(Queue A)]{A banker's queue of type @racket[A].}

@defproc[(queue [a A] ...) (Queue A)]{
Function @scheme[queue] creates a Banker's Queue with the given inputs.

@examples[#:eval evaluate

(queue 1 2 3 4 5 6)
]

In the above example, the queue obtained will have 1 as its head element.
}

@defproc[(empty [t A]) (Queue Nothing)]{
An empty queue instantiated to type t.
@examples[#:eval evaluate
(empty Nothing)
(empty Integer)
]}

@defproc[(empty? [que (Queue A)]) Boolean]{
Function @scheme[empty?] checks if the given queue is empty or not.
   
@examples[#:eval evaluate
(empty? (queue 1 2 3 4 5 6))
(empty? (empty Integer))
]}


@defproc[(enqueue [a A] [que (Queue A)]) (Queue A)]{
Function @scheme[enqueue] takes an element and a queue and adds the given
element into the @scheme[queue].    
@examples[#:eval evaluate

(enqueue 10 (queue 4 5 6))
]

In the above example, @scheme[(enqueue 10 (queue 4 5 6))] enqueues 10 to the 
end of the queue and returns  @scheme[(queue 4 5 6 10)].
}

@defproc[(head [que (Queue A)]) A]{
Function @scheme[head] takes a @scheme[queue] and returns the first element
in the queue if its a non empty queue else throws an error.
@examples[#:eval evaluate

(head (queue 10 4 3 12))

(head (empty Integer))
]}


@defproc[(tail [que (Queue A)]) (Queue A)]{
Function @scheme[tail] takes a queue and returns the same queue 
without the first element. If the queue is empty it throws an error. 
   
@examples[#:eval evaluate

(tail (queue 4 5 6))

(tail (empty Integer))
]

In the above example, @scheme[(tail (queue 4 5 6))], returns
@scheme[(queue 5 6)].
}

@defproc[(queue->list [que (Queue A)]) (Queue A)]{
Function @scheme[queue->list] takes a queue and returns a list of 
elements. The list will have head of the given queue as its first element.

@examples[#:eval evaluate

(queue->list (queue 10 2 34 4 15 6))
(queue->list (empty Integer))
]}


@defproc[(map [func (A B ... B -> C)] 
              [que1 (Queue A)]
              [que2 (Queue B)] ...) (Queue A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(queue->list (map add1 (queue 1 2 3 4 5 6)))

(queue->list (map * (queue 1 2 3 4 5 6) (queue 1 2 3 4 5 6)))
]}

@defproc[(fold [func (C A B ... B -> C)]
               [init C]
               [que1 (Queue A)]
               [que2 (Queue B)] ...) C]{
Function @scheme[fold] is similar to @|racket-foldl| or @|racket-foldr|
@margin-note{@scheme[fold] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(fold + 0 (queue 1 2 3 4 5 6))

(fold * 1 (queue 1 2 3 4 5 6) (queue 1 2 3 4 5 6))
]}

@defproc[(filter [func (A -> Boolean)] [que (Queue A)]) (Queue A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define que (queue 1 2 3 4 5 6))

(queue->list (filter (λ: ([x : Integer]) (> x 5)) que))

(queue->list (filter (λ: ([x : Integer]) (< x 5)) que))

(queue->list (filter (λ: ([x : Integer]) (<= x 5)) que))
]}

@defproc[(remove [func (A -> Boolean)] [que (Queue A)]) (Queue A)]{
Function @scheme[remove] is similar to @|racket-filter| but
@scheme[remove] removes the elements which match the predicate.
@examples[#:eval evaluate

(queue->list (remove (λ: ([x : Integer]) (> x 5))
                     (queue 1 2 3 4 5 6)))

(queue->list (remove (λ: ([x : Integer]) (< x 5))
                     (queue 1 2 3 4 5 6)))

(queue->list (remove (λ: ([x : Integer]) (<= x 5))
                     (queue 1 2 3 4 5 6)))
]}


@defproc[(andmap [func (A B ... B -> Boolean)]
                 [que1 (Queue A)]
                 [que2 (Queue B)] ...) Boolean]{
Function @scheme[andmap] is similar to @|racket-andmap|.

@examples[#:eval evaluate

(andmap even? (queue 1 2 3 4 5 6))

(andmap odd? (queue 1 2 3 4 5 6))

(andmap positive? (queue 1 2 3 4 5 6))

(andmap negative? (queue -1 -2))
]}


@defproc[(ormap [func (A B ... B -> Boolean)]
                [que1 (Queue A)]
                [que2 (Queue B)] ...) Boolean]{
Function @scheme[ormap] is similar to @|racket-ormap|.

@examples[#:eval evaluate

(ormap even? (queue 1 2 3 4 5 6))

(ormap odd? (queue 1 2 3 4 5 6))

(ormap positive? (queue -1 -2 3 4 -5 6))

(ormap negative? (queue 1 -2))
]}

@defproc[(build-queue [size Natural]
                      [func (Natural -> A)])
                      (Queue A)]{
Function @scheme[build-queue] is similar to @|racket-build-list|.
@examples[#:eval evaluate

(queue->list (build-queue 5 (λ:([x : Integer]) (add1 x))))

(queue->list (build-queue 5 (λ:([x : Integer]) (* x x))))

]}

@defproc[(head+tail [que (Queue A)])
                    (Pair A (Queue A))]{
Function @scheme[head+tail] returns a pair containing the head and the tail of
the given queue.
@examples[#:eval evaluate

(head+tail (queue 1 2 3 4 5))

(head+tail (build-queue 5 (λ:([x : Integer]) (* x x))))

(head+tail (empty Integer))

]}


@(close-eval evaluate)
