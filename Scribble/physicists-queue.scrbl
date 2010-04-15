#lang scribble/manual

@;@(require "stream.ss")AP270301PF0Z945U
@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../physicists-queue.ss"))

@title{Physicist's Queue}

A Queue is nothing but a FIFO data structure. A Physicist's queue ia a
Amortized queues obtained by Physicist's method. Provides a amortized
running time of @bold{@italic{O(1)}} for @italic{head, tail and enqueue}
operations. Physicists's Queue uses lazy evaluation and memoization to get 
this amortized running time.

@section{Physicist's Queue Construction and Operations}

@subsection{queue}
The function @scheme[pqueue] creates a Physicist's Queue with the given inputs.

@examples[#:eval evaluate

(queue 1 2 3 4 5 6)
]

In the above example, the queue obtained will have 1 as its head element,
2 as the head of its tail and so on.


@subsection{empty}
An empty queue

@subsection{empty?}
The function @scheme[empty?] checks if the given queue is empty or not.

@examples[#:eval evaluate

(empty? (queue 1 2 3 4 5 6))

(empty? empty)
]


@subsection{enqueue}
the function @scheme[enqueue] takes an element and a queue and enqueues 
the given element into the queue. 
@examples[#:eval evaluate

(enqueue 10 (queue 1 2 3 4 5 6))
]

In the above example, enqueue adds the element 10 to the end of the
@scheme[(queue 1 2 3 4 5 6)].

@subsection{head}
The function @scheme[head] takes a queue and gives the first element in the
queue if its a non empty queue else throws an error. 
@examples[#:eval evaluate

(head (queue 1 2 3 4 5 6))
(head empty)
]

@subsection{tail}
The function @scheme[tail] takes a queue and returns a queue with rest 
elements if its a non empty queue else throws an error. 
@examples[#:eval evaluate

(tail (queue 1 2 3 4 5 6))

(tail empty)
]

In the above example, @scheme[(tail (queue 1 2 3 4 5 6))], returns 
@scheme[(queue 2 3 4 5 6)].


@subsection{queue->list}
The function @scheme[queue->list] takes a queue and returns a list of 
elements. The list will have head of the given queue as its first element.
If the given queue is empty, then it returns an empty list. 

@examples[#:eval evaluate

(define que (queue 10 2 34 4 15 6))

(queue->list que)
]


@subsection{list->queue}
The function @scheme[list->queue] takes a list and returns a queue of 
elements. The queue will be such that its head will have car of the list.

@examples[#:eval evaluate

(list->queue (list 10 2 34 4 15 6))

]

In the above example, @scheme[(list->queue (list 10 2 34 4 15 6))], returns 
the queue @scheme[(queue 10 2 34 4 15 6)].