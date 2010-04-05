#lang scribble/manual

@title{Bankers Deque}

Bankers Deques are Amortized double ended deques also known as deque
developed using Bankers method. Provides amortized running time of 
@bold{@italic{O(1)}} for the operations 
@italic{head, tail, last, init, enqueue-rear and enqueue}.
Uses lazy evaluation and memoization to achieve the amortized running time.

@section{Bankers Deque Construction and Operations}

@subsection{deque}
The function @scheme[deque] creates a Bankers Deque with the given inputs. 
For example,
@schememod[
typed-scheme
(require "bankers-deque.ss")

(deque 1 2 3 4 5 6)
]

In the above example, the deque obtained will have 1 as its head element.


@subsection{empty}
An empty deque

@subsection{empty?}
The function @scheme[empty?] checks if the given deque is empty or not.
For example,
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 1 2 3 4 5 6))

]

In the above example, @scheme[(empty? deq)] returns @scheme[#f] and 
@scheme[(empty? empty)] returns @scheme[#t].


@subsection{enqueue}
The function @scheme[enqueue] takes an element and a deque and enqueues 
the given element in the deque. Example
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 1 2 3 4 5 6))

(define new-deque  (enqueue 10 deq))
]

In the above example, @scheme[(enqueue 10 deq)] adds the element 10 to the deq.
new-deque now contains 10 as its last element.

@subsection{enqueue-front}
The function @scheme[enqueue-front] takes an element and a deque and puts 
the given element to the front of the given deque. Example
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 1 2 3 4 5 6))

(define new-deque (enqueue-front 10 deq))
]

In the above example, @scheme[(enqueue-front 10 deq)] adds the element 10
to the front of the deq. new-deque now contains 10 as its head element.

@subsection{head}
The function @scheme[head] takes a deque and gives the first element in the
queue if deque is not empty else throws an error. Example
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 1 2 3 4 5 6))

(head deq)
]

In the above example, @scheme[(head deq)], gives back the first element in 
@scheme[deq] which happens to be 1.

@subsection{last}
The function @scheme[last] takes a deque and gives the last element in the
queue if deque is not empty else throws an error. Example
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 1 2 3 4 5 6))

(last deq)
]

In the above example, @scheme[(last deq)], gives back the last element in 
@scheme[deq] which is 6.

@subsection{tail}
The function @scheme[tail] takes a deque and gives back the given deque 
without the first element if the given deque is non empty else throws an 
error.
Example
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 1 2 3 4 5 6))

(tail deq)
]

In the above example, @scheme[(tail deq)], removes the head of the given 
deque in the above example and returns @scheme[(deque 2 3 4 5 6)].



@subsection{init}
The function @scheme[init] takes a deque and gives back the given deque 
without the last element if the given deque is non empty else throws an error.
Example
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 1 2 3 4 5 6))

(tail deq)
]

In the above example, @scheme[(init deq)], removes the last element 6 of the 
given deque and returns @scheme[(deque 1 2 3 4 5)].


@subsection{deque->list}
The function @scheme[deque->list] takes a deque and gives back a list of 
elements. The list will have head of the given deque as its first element.
If the given deque is empty, then it returns an empty list. 
For Example
@schememod[
typed-scheme
(require "bankers-deque.ss")

(define deq (deque 10 2 34 4 15 6))

(deque->list deq)
]

In the above example, @scheme[(deque->list deq)], gives back the list 
@scheme[(10 2 34 4 15 6)].