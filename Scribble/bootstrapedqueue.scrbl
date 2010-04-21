#lang scribble/manual

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../bootstrapedqueue.ss"))

@title{Bootstraped Queue}

Bootstrapped Queue use a structural bootstrapping technique called 
@italic{Structural Decomposition}. The data structure gives a worst 
case running time of @bold{@italic{O(1)}} for the operation 
@italic{head} and @bold{@italic{O(log*(n))}} for 
@italic{tail and enqueue}. Internally uses @secref["rtq"].

@;section{Bootstraped Queue Construction and Operations}

@defproc[(queue [a A] ...) (Queue A)]{
The function @scheme[queue] creates a Bootstraped Queue with the 
given inputs.  
@examples[#:eval evaluate

(queue 1 2 3 4 5 6)
]

In the above example, the queue obtained will have 1 as its first element.}


@defform/none[empty]{
An empty queue.}

@defproc[(empty? [que (Queue A)]) Boolean]{
The function @scheme[empty?] checks if the given queue is empty or not.
 
@examples[#:eval evaluate

(empty? (queue 1 2 3 4 5 6))

(empty? empty)
]}

@defproc[(enqueue [a A] [que (Queue A)]) (Queue A)]{
The function @scheme[enqueue] takes an element and a queue and enqueues 
the given element into the queue.  
@examples[#:eval evaluate

(enqueue 10 (queue 1 2 3 4 5 6))

]

In the above example, @scheme[(enqueue 10 (queue 1 2 3 4 5 6))] adds the 
10 to the queue @scheme[(queue 1 2 3 4 5 6)]. 10 as its last element.}

@defproc[(head [que (Queue A)]) A]{
The function @scheme[head] takes a queue and gives the first element in the
queue if queue is not empty else throws an error.  
@examples[#:eval evaluate

(head (queue 1 2 3 4 5 6))
(head empty)
]}

@defproc[(tail [que (Queue A)]) (Queue A)]{
The function @scheme[tail] takes a queue and returns the same queue without
the first element of the given queue if its a non empty queue else throws an 
error.  
@examples[#:eval evaluate

(tail (queue 1 2 3 4 5 6))

(tail empty)
]

In the above example, @scheme[(tail (queue 1 2 3 4 5 6))], removes the head of
the given queue returns @scheme[(queue 2 3 4 5 6)].}


@defproc[(queue->list [que (Queue A)]) (Queue A)]{
The function @scheme[queue->list] takes a queue and returns a list of 
elements. The list will have head of the given queue as its first element.
If the given queue is empty, then it returns an empty list. 
 
@examples[#:eval evaluate

(queue->list (queue 10 2 34 4 15 6))
(queue->list empty)
]}