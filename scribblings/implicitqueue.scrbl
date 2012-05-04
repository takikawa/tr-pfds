#lang scribble/manual

@(require "helper.rkt")
@(require (for-label tr-pfds/queue/implicit/main))

@defmodule/this-package[queue/implicit]

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require tr-pfds/queue/implicit/main))

@title{Implicit Queue}

Queues obtained by applying the technique called 
@italic{Implicit Recursive Slowdown}. Provides a amortized
running time of @bold{@italic{O(1)}} for the operations
@scheme[head], @scheme[tail] and @scheme[enqueue].
Implicit Recursive Slowdown combines
laziness and technique called Recursive Slow-Down developed by 
@italic{Kaplan and Tarjan} in their paper 
@italic{Persistant Lists with Catenation via Recursive Slow-Down}.

@;section{Implicit Queue Construction and Operations}

@defform[(Queue A)]{A implicit queue of type @racket[A].}

@defproc[(queue [a A] ...) (Queue A)]{
Function @scheme[queue] creates a Implicit Queue with the 
given inputs. 
@examples[#:eval evaluate

(queue 1 2 3 4 5 6)
]

In the above example, the queue obtained will have 1 as its head element.}


@defthing[empty (Queue Nothing)]{
An empty queue.}

@defproc[(empty? [que (Queue A)]) Boolean]{
Function @scheme[empty?] checks if the given queue is empty or not.

@examples[#:eval evaluate

(empty? (queue 1 2 3 4 5 6))

(empty? empty)
]}

@defproc[(enqueue [a A] [que (Queue A)]) (Queue A)]{
Function@scheme[enqueue] takes an element and a queue and enqueues 
the given element into the queue. 
@examples[#:eval evaluate

(enqueue 10 (queue 1 2 3 4 5 6))
]

In the above example, enqueue adds the element 10 to
of @scheme[(queue 1 2 3 4 5 6)] and returns @scheme[(queue 1 2 3 4 5 6 10)].}

@defproc[(head [que (Queue A)]) A]{
Function @scheme[head] takes a queue and gives the first element in the
queue if queue is not empty else throws an error. 
@examples[#:eval evaluate

(head (queue 1 2 3 4 5 6))
(head empty)
]}

@defproc[(tail [que (Queue A)]) (Queue A)]{
Function @scheme[tail] takes a queue and returns a queue with rest 
elements if its a non empty queue else throws an error. 
@examples[#:eval evaluate

(tail (queue 1 2 3 4 5 6))
(tail empty)
]
In the above example, @scheme[(tail (queue 1 2 3 4 5 6))], removes the head of
the given queue returns @scheme[(queue 2 3 4 5 6)].}


@defproc[(queue->list [que (Queue A)]) (Queue A)]{
Function @scheme[queue->list] takes a queue and returns a list of 
elements. The list will have head of the given queue as its first element.
If the given queue is empty, then it returns an empty list. 

@examples[#:eval evaluate

(queue->list (queue 10 2 34 4 15 6))
(queue->list empty)
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
Function @scheme[remove] is similar to @|racket-filter| but @scheme[remove] removes the elements which match the predicate. 
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

(head+tail empty)

]}


@(close-eval evaluate)
