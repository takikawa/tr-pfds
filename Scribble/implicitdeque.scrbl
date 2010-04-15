#lang scribble/manual

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../implicitdeque.ss"))

@title{Implicit Deque}

Deques obtained by applying @italic{Implicit Recursive Slowdown}. 
Provides amortized running time of @bold{@italic{O(1)}} for the 
operations @italic{head, tail, last, init, enqueue-rear and enqueue}.
Implicit Recursive Slowdown combines 
laziness and technique called Recursive Slow-Down developed by 
@italic{Kaplan and Tarjan} in their paper 
@italic{Persistant Lists with Catenation via Recursive Slow-Down}.

@section{Implicit Deque Construction and Operations}

@subsection{deque}
The function @scheme[deque] creates a Implicit Deque with the given inputs. 

@examples[#:eval evaluate

(deque 1 2 3 4 5 6)
]

In the above example, the deque obtained will have 1 as its head element,
2 as the head of its tail and so on.


@subsection{empty}
An empty deque

@subsection{empty?}
The function @scheme[empty?] checks if the given deque is empty or not.

@examples[#:eval evaluate

(empty? (deque 1 2 3 4 5 6))

(empty? empty)
]


@subsection{enqueue}
the function @scheme[enqueue] takes an element and a deque and enqueues 
the given element into the deque. 
@examples[#:eval evaluate

(enqueue 10 (deque 1 2 3 4 5 6))
]

In the above example, enqueue adds the element 10 to 
@scheme[(deque 1 2 3 4 5 6 10)].

@subsection{head}
The function @scheme[head] takes a deque and gives the first element in the
queue if deque is not empty else throws an error. 
@examples[#:eval evaluate

(head (deque 1 2 3 4 5 6))
(head empty)
]

@subsection{last}
The function @scheme[last] takes a deque and gives the last element in the
queue if deque is not empty else throws an error. 
@examples[#:eval evaluate

(last (deque 1 2 3 4 5 6))

(last empty)
]

@subsection{tail}
The function @scheme[tail] takes a deque and returns a deque with rest 
elements if its a non empty deque else throws an error. 
@examples[#:eval evaluate

(tail (deque 1 2 3 4 5 6))
(tail empty)
]

In the above example, @scheme[(tail (deque 1 2 3 4 5 6))], removes 1 
and returns @scheme[(tail (deque 2 3 4 5 6))].


@subsection{init}
The function @scheme[init] takes a deque and returns a deque without the 
last element if its a non empty deque else throws an error. 
@examples[#:eval evaluate

(init (deque 1 2 3 4 5 6))

(init empty)
]

In the above example, @scheme[(init (deque 1 2 3 4 5 6))], removes the 
last element 6 and returns @scheme[(deque 1 2 3 4 5)]

@subsection{deque->list}
The function @scheme[deque->list] takes a deque and returns a list of 
elements. The list will have head of the given deque as its first element.
If the given deque is empty, then it returns an empty list. 

@examples[#:eval evaluate

(define que (deque 10 2 34 4 15 6))

(deque->list que)
]