#lang scribble/manual

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
For example,
@schememod[
typed-scheme
(require "implicitdeque.ss")

(deque 1 2 3 4 5 6)
]

In the above example, the deque obtained will have 1 as its head element,
2 as the head of its tail and so on.


@subsection{empty}
An empty deque

@subsection{empty?}
The function @scheme[empty?] checks if the given deque is empty or not.
For example,
@schememod[
typed-scheme
(require "implicitdeque.ss")

(define que (deque 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? que)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{enqueue}
the function @scheme[enqueue] takes an element and a deque and enqueues 
the given element into the deque. Example
@schememod[
typed-scheme
(require "implicitdeque.ss")

(define que (deque 1 2 3 4 5 6))

(define new-queue (enqueue 10 que))
]

In the above example, enqueue adds the element 10 to the deque que. 
new-queue now contains 10 as its last element.

@subsection{head}
The function @scheme[head] takes a deque and gives the first element in the
queue if deque is not empty else throws an error. Example
@schememod[
typed-scheme
(require "implicitdeque.ss")

(define que (deque 1 2 3 4 5 6))

(head que)
]

In the above example, @scheme[(head que)], returns the first element in 
@scheme[que] which happens to be 1.

@subsection{last}
The function @scheme[last] takes a deque and gives the last element in the
queue if deque is not empty else throws an error. Example
@schememod[
typed-scheme
(require "implicitdeque.ss")

(define que (deque 1 2 3 4 5 6))

(last que)
]

In the above example, @scheme[(last que)], returns the last element in 
@scheme[que] which is 6.

@subsection{tail}
The function @scheme[tail] takes a deque and returns a deque with rest 
elements if its a non empty deque else throws an error. Example
@schememod[
typed-scheme
(require "implicitdeque.ss")

(define que (deque 1 2 3 4 5 6))

(tail que)
]

In the above example, @scheme[(tail que)], removes the head of the given 
deque 1 in the above example and returns the rest as is.



@subsection{init}
The function @scheme[init] takes a deque and returns a deque without the 
last element if its a non empty deque else throws an error. Example
@schememod[
typed-scheme
(require "implicitdeque.ss")

(define que (deque 1 2 3 4 5 6))

(tail que)
]

In the above example, @scheme[(init que)], removes the last element 6 of the 
given deque and returns the rest of the deque as is.


@subsection{deque->list}
The function @scheme[deque->list] takes a deque and returns a list of 
elements. The list will have head of the given deque as its first element.
If the given deque is empty, then it returns an empty list. 
For Example
@schememod[
typed-scheme
(require "implicitdeque.ss")

(define que (deque 10 2 34 4 15 6))

(deque->list que)
]

In the above example, @scheme[(deque->list que)], returns the list 
@scheme[(10 2 34 4 15 6)].