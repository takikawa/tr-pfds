#lang scribble/manual

@;@(require "stream.ss")AP270301PF0Z945U

@title{Physicist's Queue}

A Queue is nothing but a FIFO data structure. A Physicist's queue ia a
Amortized queues obtained by Physicist's method. Provides a amortized
running time of @bold{@italic{O(1)}} for @italic{head, tail and enqueue}
operations. Physicists's Queue uses lazy evaluation and memoization to get 
this amortized running time.

@section{Physicist's Queue Construction and Operations}

@subsection{pqueue}
The function @scheme[pqueue] creates a Physicist's Queue with the given inputs.
For example,
@schememod[
typed-scheme
(require "physicists-queue.ss")

(pqueue 1 2 3 4 5 6)
]

In the above example, the queue obtained will have 1 as its head element,
2 as the head of its tail and so on.


@subsection{empty}
An empty queue

@subsection{empty?}
The function @scheme[empty?] checks if the given queue is empty or not.
For example,
@schememod[
typed-scheme
(require "physicists-queue.ss")

(define que (pqueue 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? que)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{enqueue}
the function @scheme[enqueue] takes an element and a queue and enqueues 
the given element into the queue. Example
@schememod[
typed-scheme
(require "physicists-queue.ss")

(define que (pqueue 1 2 3 4 5 6))

(define new-queue (enqueue 10 que))
]

In the above example, enqueue adds the element 10 to the queue que. 
new-queue now contains 10 as its last element.

@subsection{head}
The function @scheme[head] takes a queue and gives the first element in the
queue if its a non empty queue else throws an error. Example
@schememod[
typed-scheme
(require "physicists-queue.ss")

(define que (pqueue 1 2 3 4 5 6))

(head que)
]

In the above example, @scheme[(head que)], returns the first element in 
@scheme[que] which happens to be 1.

@subsection{tail}
The function @scheme[tail] takes a queue and returns a queue with rest 
elements if its a non empty queue else throws an error. Example
@schememod[
typed-scheme
(require "physicists-queue.ss")

(define que (pqueue 1 2 3 4 5 6))

(tail que)
]

In the above example, @scheme[(tail que)], returns a queue which has 2
as its new head.


@subsection{queue->list}
The function @scheme[queue->list] takes a queue and returns a list of 
elements. The list will have head of the given queue as its first element.
If the given queue is empty, then it returns an empty list. 
For Example
@schememod[
typed-scheme
(require "physicists-queue.ss")

(define que (pqueue 10 2 34 4 15 6))

(queue->list que)
]

In the above example, @scheme[(queue->list que)], returns the list 
@scheme[(10 2 34 4 15 6)].


@subsection{list->queue}
The function @scheme[list->queue] takes a list and returns a queue of 
elements. The queue will be such that its head will have car of the list.
For Example
@schememod[
typed-scheme
(require "physicists-queue.ss")

(list->queue (list 10 2 34 4 15 6))

]

In the above example, @scheme[(list->queue (list 10 2 34 4 15 6))], gives 
back the queue @scheme[(pqueue 10 2 34 4 15 6)].