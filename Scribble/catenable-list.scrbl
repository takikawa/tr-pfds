#lang scribble/manual

@title{Catenable List}

Catenable Lists are nothing but lists with efficient catenation. They use 
a data-structucal bootstrapping technique called 
@italic{Structucal Abstraction}. The data structure internally use 
Real Time Queues to realize an amortized running time of @bold{@italic{O(1)}}
for the operations @italic{head, tail, kons, kons-rear}

@section{Catenable List Constructor and Operations}

@subsection{clist}
The function clist creates a Catenable List with the given inputs. For 
example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(clist 1 2 3 4 5 6)
]

In the above example, @scheme[(clist 1 2 3 4 5 6)] gives a Catenable List
which is similar to lists but comes with efficient lookup and update
operations.

@subsection{empty}
A empty clist

@subsection{empty?}
The function @scheme[empty?] takes a Catenable List checks if the given clist is 
empty. For example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(define cal (clist 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? cal)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{kons}
The function @scheme[kons] takes an element and a clist and adds the given
element to the front the given clist. For example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(define cal (clist 1 2 3 4 5 6))

(kons 10 cal)
]

In the above example, @scheme[(kons 10 cal)] returns a 
@scheme[(clist 10 1 2 3 4 5 6)].


@subsection{kons-rear}
The function @scheme[kons-rear] takes an element and a clist and adds the given
element to the rear end the given clist. For example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(define cal (clist 1 2 3 4 5 6))

(kons-rear 10 cal)
]

In the above example, @scheme[(kons 10 cal)] returns 
@scheme[(clist 1 2 3 4 5 6 10)].

@subsection{head}
The function @scheme[head] takes a clist and returns the first element
of the given clist. For example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(define cal (clist 1 2 3 4 5 6))

(head cal)
]

In the above example, @scheme[(head cal)] returns 1, the first element
of the the given clist.


@subsection{tail}
The function @scheme[tail] takes a clist and returns a clist without 
the first element of the given clist. For example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(define cal (clist 1 2 3 4 5 6))

(tail cal)
]

In the above example, @scheme[(tail cal)] returns the rest of the given 
clist, @scheme[(clist 2 3 4 5 6)].



@subsection{merge}
The function @scheme[merge] takes two clists and merges the second clist 
to the end of the second clist.

For example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(define cal1 (clist 1 2 3 4 5 6))
(define cal2 (clist 7 8 9 10))

(merge cal1 cal2)
]

In the above example, @scheme[(merge cal1 cal2)] returns 
@scheme[(clist 1 2 3 4 5 6 7 8 9 10)].


@subsection{clist->list}
The function @scheme[clist->list] takes a clist and gives back a list
of elements which are in the same order as in the clist. For example,
@schememod[
typed-scheme
(require "catenablelist.ss")

(define cal (clist 1 2 3 4 5 6))

(clist->list cal)
]

In the above example, @scheme[(clist->list cal)] returns the list,
@scheme[(1 2 3 4 5 6)].