#lang scribble/manual

@title{Hood-Melville Queue}

Similar to Real-Time Queues in many ways. But the implementation is
much more complicated than Real-Time Queue. Uses a technique called 
@italic{Global Rebuilding}. The data structure gives a worst case 
running time of @bold{@italic{O(1)}} for the operations 
@italic{head, tail and enqueue}.

@section{Hood-Melville Construction and Operations}

@subsection{queue}
The function @scheme[queue] creates a Hood-Melville with the 
given inputs. For example,
@schememod[
typed-scheme
(require "hood-melville-queue.ss")

(queue 1 2 3 4 5 6)
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
(require "hood-melville-queue.ss")

(define que (queue 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? que)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{enqueue}
the function @scheme[enqueue] takes an element and a queue and enqueues 
the given element into the queue. Example
@schememod[
typed-scheme
(require "hood-melville-queue.ss")

(define que (queue 1 2 3 4 5 6))

(define new-queue (enqueue 10 que))
]

In the above example, enqueue adds the element 10 to the queue que. 
new-queue now contains 10 as its last element.

@subsection{head}
The function @scheme[head] takes a queue and gives the first element in the
queue if queue is not empty else throws an error. Example
@schememod[
typed-scheme
(require "hood-melville-queue.ss")

(define que (queue 1 2 3 4 5 6))

(head que)
]

In the above example, @scheme[(head que)], returns the first element in 
@scheme[que] which happens to be 1.

@subsection{tail}
The function @scheme[tail] takes a queue and returns a queue with rest 
elements if its a non empty queue else throws an error. Example
@schememod[
typed-scheme
(require "hood-melville-queue.ss")

(define que (queue 1 2 3 4 5 6))

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
(require "hood-melville-queue.ss")

(define que (queue 10 2 34 4 15 6))

(queue->list que)
]

In the above example, @scheme[(queue->list que)], returns the list 
@scheme[(10 2 34 4 15 6)].