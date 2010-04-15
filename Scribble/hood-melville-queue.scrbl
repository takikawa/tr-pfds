#lang scribble/manual
@(require scribble/eval)
@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../hood-melville-queue.ss"))
@title{Hood-Melville Queue}

Similar to Real-Time Queues in many ways. But the implementation is
much more complicated than Real-Time Queue. Uses a technique called 
@italic{Global Rebuilding}. The data structure gives a worst case 
running time of @bold{@italic{O(1)}} for the operations 
@italic{head, tail and enqueue}.

@section{Hood-Melville Construction and Operations}

@subsection{queue}
The function @scheme[queue] creates a Hood-Melville with the 
given inputs. 
@examples[#:eval evaluate

(queue 1 2 3 4 5 6)
]

In the above example, the queue obtained will have 1 as its head element.


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

In the above example, enqueue adds the element 10 to
@scheme[(queue 1 2 3 4 5 6)].

@subsection{head}
The function @scheme[head] takes a queue and gives the first element in the
queue if queue is not empty else throws an error. 
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

In the above example, @scheme[(tail (queue 1 2 3 4 5 6))], returns the 
@scheme[(queue 1 2 3 4 5 6)].


@subsection{queue->list}
The function @scheme[queue->list] takes a queue and returns a list of 
elements. The list will have head of the given queue as its first element.
If the given queue is empty, then it returns an empty list. 
For 
@examples[#:eval evaluate

(define que (queue 10 2 34 4 15 6))

(queue->list que)
]