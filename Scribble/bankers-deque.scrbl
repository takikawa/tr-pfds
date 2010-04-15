#lang scribble/manual
@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../bankers-deque.ss"))

@title{Bankers Deque}

Bankers Deques are Amortized double ended deques also known as deque
developed using Bankers method. Provides amortized running time of 
@bold{@italic{O(1)}} for the operations 
@italic{head, tail, last, init, enqueue-rear and enqueue}.
Uses lazy evaluation and memoization to achieve the amortized running time.

@section{Bankers Deque Construction and Operations}

@subsection{deque}
The function @scheme[deque] creates a Bankers Deque with the given inputs. 
@examples[#:eval evaluate

(deque 1 2 3 4 5 6)
]

In the above example, the deque obtained will have 1 as its head element.


@subsection{empty}
An empty deque

@subsection{empty?}
The function @scheme[empty?] checks if the given deque is empty or not.
@examples[#:eval evaluate
(empty? empty)
(empty? (deque 1 2))
]


@subsection{enqueue}
The function @scheme[enqueue] takes an element and a deque and enqueues 
the given element in the deque. 
@examples[#:eval evaluate
(enqueue 10 (deque 3 2 4))
]

In the above example, @scheme[(enqueue 10 deq)] adds the element 10 to 
@scheme[(deque 3 2 4)]. 10 will be the last element in the queue.

@subsection{enqueue-front}
The function @scheme[enqueue-front] takes an element and a deque and puts 
the given element to the front of the given deque. 
@examples[#:eval evaluate

(enqueue-front 10 (deque 5 6 3 4))
]

In the above example, @scheme[(enqueue-front 10 (deque 5 6 3 4))] adds 10
to the front of the @scheme[(deque 5 6 3 4)]. 10 will be the head element.

@subsection{head}
The function @scheme[head] takes a deque and gives the first element in the
deque if deque is not empty else throws an error. 
@examples[#:eval evaluate

(head (deque 5 2 3))

(head empty)
]

In the above example, @scheme[(head empty)] throws an error since the given 
deque is empty.

@subsection{last}
The function @scheme[last] takes a deque and gives the last element in the
queue if deque is not empty else throws an error. 
@examples[#:eval evaluate

(last (deque 1 2 3 4 5 6))

(last empty)
]

In the above example, @scheme[(last empty)]throws an error since the given 
deque is empty.

@subsection{tail}
The function @scheme[tail] takes a deque and returns the given deque 
without the first element if the given deque is non empty else throws an 
error.
@examples[#:eval evaluate

(tail (deque 1 2 3 4 5 6))

(tail empty)
]

In the above example, @scheme[(tail (deque 1 2 3 4 5 6))], removes the head of
the given deque returns @scheme[(deque 2 3 4 5 6)].



@subsection{init}
The function @scheme[init] takes a deque and returns the given deque 
without the last element if the given deque is not empty else throws an error.
@examples[#:eval evaluate

(init (deque 1 2 3 4 5 6))

(init empty)
]

In the above example, @scheme[(init (deque 1 2 3 4 5 6))], removes the 
last element 6 and returns @scheme[(deque 1 2 3 4 5)].


@subsection{deque->list}
The function @scheme[deque->list] takes a deque and returns a list of 
elements. The list will have head of the given deque as its first element.
If the given deque is empty, then it returns an empty list. 
@examples[#:eval evaluate

(define deq (deque 10 2 34 4 15 6))

(deque->list deq)
]