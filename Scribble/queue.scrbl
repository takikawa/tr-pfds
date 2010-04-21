#lang scribble/manual
@(require scribble/eval)
@(provide (for-label (all-from-out)))
@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../bankers-queue-streams.ss"))

@title{Banker's Queue}

A Queue is nothing but a FIFO data structure. A Banker's Queue is a
amortized queue obtained using Bankers method. It provides a amortized
running time of @bold{@italic{O(1)}} for @italic{head, tail and enqueue}
operations. To obtain this amortized running time, the data structure
uses the techniques, lazy evaluation and memoization. Banker's Queue
internally uses Streams for lazy evaluation. For Streams, see 
@secref["streams"]

@;section{Banker's Queue Construction and Operations}

@defproc[(queue [a A] ...) (Queue A)]{
The function @scheme[queue] creates a Banker's Queue with the given inputs.

@examples[#:eval evaluate

(queue 1 2 3 4 5 6)
]

In the above example, the queue obtained will have 1 as its head element.
}

@defform/none[empty]{
An empty queue}

@defproc[(empty? [que (Queue A)]) Boolean]{
The function @scheme[empty?] checks if the given queue is empty or not.
   
@examples[#:eval evaluate
(empty? (queue 1 2 3 4 5 6))
(empty? empty)
]}


@defproc[(enqueue [a A] [que (Queue A)]) (Queue A)]{
The function @scheme[enqueue] takes an element and a queue and adds the given
element into the @scheme[queue].    
@examples[#:eval evaluate

(enqueue 10 (queue 4 5 6))
]

In the above example, @scheme[(enqueue 10 (queue 4 5 6))] enqueues 10 to the 
end of the queue and returns  @scheme[(queue 4 5 6 10)].
}

@defproc[(head [que (Queue A)]) A]{
The function @scheme[head] takes a @scheme[queue] and returns the first element
in the queue if its a non empty queue else throws an error.
@examples[#:eval evaluate

(head (queue 10 4 3 12))

(head empty)
]}


@defproc[(tail [que (Queue A)]) (Queue A)]{
The function @scheme[tail] takes a queue and returns the same queue 
without the first element. If the queue is empty it throws an error. 
   
@examples[#:eval evaluate

(tail (queue 4 5 6))

(tail empty)
]

In the above example, @scheme[(tail (queue 4 5 6))], returns
@scheme[(queue 5 6)].
}

@defproc[(queue->list [que (Queue A)]) (Queue A)]{
The function @scheme[queue->list] takes a queue and returns a list of 
elements. The list will have head of the given queue as its first element.

@examples[#:eval evaluate

(queue->list (queue 10 2 34 4 15 6))
(queue->list empty)
]}
