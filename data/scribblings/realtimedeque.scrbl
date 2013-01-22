#lang scribble/manual

@(require "helper.rkt")
@(require (for-label data/deque/real-time))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require data/deque/real-time))

@title{Real-Time Deque}

@defmodule[data/deque/real-time]

Real-Time Deques eliminate the amortization by using two 
techniques @italic{Scheduling} and a variant of Global Rebuilding 
called @italic{Lazy Rebuilding}. The data structure gives a worst 
case running time of @bold{@italic{O(1)}} for the operations 
@scheme[head], @scheme[tail], @scheme[last], @scheme[init],
@scheme[enqueue-front] and @scheme[enqueue].

@defform[(Deque A)]{Real-time double ended queue of type @racket[A].}


@defproc[(deque [a A] ...) (Deque A)]{
Function @scheme[deque] creates a Real-Time Deque with the given inputs. 

@examples[#:eval evaluate

(deque 1 2 3 4 5 6)
]

In the above example, the deque obtained will have 1 as its head element.}


@defproc[(empty [t A]) (Deque A)]{
An empty deque.}

@defproc[(empty? [dq (Deque A)]) Boolean]{
Function @scheme[empty?] checks if the given deque is empty or not.

@examples[#:eval evaluate

(empty? (deque 1 2 3 4 5 6))

(empty? (empty Integer))
]}


@defproc[(enqueue [a A] [deq (Deque A)]) (Deque A)]{
Function @scheme[enqueue] takes an element and a deque and enqueues 
the given element into the deque. 
@examples[#:eval evaluate

(enqueue 10 (deque 1 2 3 4 5 6))
]

In the above example, enqueue adds the element 10 to the  end of 
@scheme[(deque 1 2 3 4 5 6)].}


@defproc[(enqueue-front [a A] [deq (Deque A)]) (Deque A)]{
Function@scheme[enqueue-front] takes an element and a deque and adds 
the given element to the front of deque. 
@examples[#:eval evaluate

(enqueue-front 10 (deque 1 2 3 4 5 6))
]

In the above example, enqueue adds the element 10 to the front of 
@scheme[(deque 1 2 3 4 5 6)] and returns @scheme[(deque 10 1 2 3 4 5 6)].}



@defproc[(head [deq (Deque A)]) A]{
Function @scheme[head] takes a deque and gives the first element in the
deque if deque is not empty else throws an error. 
@examples[#:eval evaluate

(head (deque 1 2 3 4 5 6))
(head (empty Integer))
]}

@defproc[(last [deq (Deque A)]) A]{
Function @scheme[last] takes a deque and gives the last element in the
queue if deque is not empty else throws an error. 
@examples[#:eval evaluate

(last (deque 1 2 3 4 5 6))
(last (empty Integer))
]}


@defproc[(tail [deq (Deque A)]) (Deque A)]{
Function @scheme[tail] takes a deque and returns a deque with rest 
elements if its a non empty deque else throws an error. 
@examples[#:eval evaluate

(tail (deque 1 2 3 4 5 6))
(tail (empty Integer))
]

In the above example, @scheme[(tail (deque 1 2 3 4 5 6))], removes the head
of the given deque returns @scheme[(deque 2 3 4 5 6)].
}


@defproc[(init [deq (Deque A)]) (Deque A)]{
Function @scheme[init] takes a deque and returns a deque without the 
last element if its a non empty deque else throws an error. 
@examples[#:eval evaluate

(init (deque 1 2 3 4 5 6))
(init (empty Integer))
]

In the above example, @scheme[(init (deque 1 2 3 4 5 6))], removes the last 
element 6 of the 
given deque and returns @scheme[(deque 1 2 3 4 5)].
}

@defproc[(deque->list [deq (Deque A)]) (Listof A)]{
Function @scheme[deque->list] takes a deque and returns a list of 
elements. The list will have head of the given deque as its first element.
If the given deque is empty, then it returns an empty list. 

@examples[#:eval evaluate

(deque->list (deque 10 2 34 4 15 6))
]}

@defproc[(map [func (A B ... B -> C)] 
              [deq1 (Deque A)]
              [deq2 (Deque B)] ...) (Deque A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(deque->list (map add1 (deque 1 2 3 4 5 6)))

(deque->list (map * (deque 1 2 3 4 5 6) (deque 1 2 3 4 5 6)))
]}

@defproc[(foldl [func (C A B ... B -> C)]
                [init C]
                [deq1 (Deque A)]
                [deq2 (Deque B)] ...) C]{
Function @scheme[foldl] is similar to @|racket-foldl|
@margin-note{@scheme[foldl] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldl + 0 (deque 1 2 3 4 5 6))

(foldl * 1 (deque 1 2 3 4 5 6) (deque 1 2 3 4 5 6))
]}

@defproc[(foldr [func (C A B ... B -> C)]
                [init C]
                [deq1 (Deque A)]
                [deq2 (Deque B)] ...) C]{
Function @scheme[foldr] is similar to @|racket-foldr|
@margin-note{@scheme[foldr] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldr + 0 (deque 1 2 3 4 5 6))

(foldr * 1 (deque 1 2 3 4 5 6) (deque 1 2 3 4 5 6))
]}

@defproc[(filter [func (A -> Boolean)] [que (Deque A)]) (Deque A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define que (deque 1 2 3 4 5 6))

(deque->list (filter (λ: ([x : Integer]) (> x 5)) que))

(deque->list (filter (λ: ([x : Integer]) (< x 5)) que))

(deque->list (filter (λ: ([x : Integer]) (<= x 5)) que))
]}

@defproc[(remove [func (A -> Boolean)] [que (Deque A)]) (Deque A)]{
Function @scheme[remove] is similar to @|racket-filter| but
@scheme[remove] removes the elements which match the predicate.
@examples[#:eval evaluate

(deque->list (remove (λ: ([x : Integer]) (> x 5))
                     (deque 1 2 3 4 5 6)))

(deque->list (remove (λ: ([x : Integer]) (< x 5))
                     (deque 1 2 3 4 5 6)))

(deque->list (remove (λ: ([x : Integer]) (<= x 5))
                     (deque 1 2 3 4 5 6)))
]}

@defproc[(andmap [func (A B ... B -> Boolean)]
                 [deq1 (Deque A)]
                 [deq2 (Deque B)] ...) Boolean]{
Function @scheme[andmap] is similar to @|racket-andmap|.

@examples[#:eval evaluate

(andmap even? (deque 1 2 3 4 5 6))

(andmap odd? (deque 1 2 3 4 5 6))

(andmap positive? (deque 1 2 3 4 5 6))

(andmap negative? (deque -1 -2))
]}


@defproc[(ormap [func (A B ... B -> Boolean)]
                [deq1 (Deque A)]
                [deq2 (Deque B)] ...) Boolean]{
Function @scheme[ormap] is similar to @|racket-ormap|.

@examples[#:eval evaluate

(ormap even? (deque 1 2 3 4 5 6))

(ormap odd? (deque 1 2 3 4 5 6))

(ormap positive? (deque -1 -2 3 4 -5 6))

(ormap negative? (deque 1 -2))
]}

@defproc[(build-deque [size Natural]
                      [func (Natural -> A)])
                      (Deque A)]{
Function @scheme[build-deque] is similar to @|racket-build-list|.
@examples[#:eval evaluate

(deque->list (build-deque 5 (λ:([x : Integer]) (add1 x))))

(deque->list (build-deque 5 (λ:([x : Integer]) (* x x))))

]}

@defproc[(head+tail [deq (Deque A)])
                    (Pair A (Deque A))]{
Function @scheme[head+tail] returns a pair containing the head and the tail of
the given deque.
@examples[#:eval evaluate

(head+tail (deque 1 2 3 4 5))

(head+tail (build-deque 5 (λ:([x : Integer]) (* x x))))

(head+tail (empty Integer))

]}

@defproc[(last+init [deq (Deque A)])
                    (Pair A (Deque A))]{
Function @scheme[last+init] returns a pair containing the last element and
the init of the given deque.
@examples[#:eval evaluate

(last+init (deque 1 2 3 4 5))

(last+init (build-deque 5 (λ:([x : Integer]) (* x x))))

(last+init (empty Integer))

]}

@(close-eval evaluate)
