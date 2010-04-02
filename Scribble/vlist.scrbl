#lang scribble/manual

@title{VList}

A VList is a data structure very similar to noraml Scheme List but the 
corresponding operations are significantly faster than most of the List
operations. Indexing and length operations have a running time of 
@bold{@italic{O(1)}} and @bold{@italic{O(lg N)}} respectively compared to 
@bold{@italic{O(N)}} in lists. The data structure has been described in the 
paper @italic{Fast Functional Lists, Hash-Lists, vlists and 
              Variable Length Arrays} by  Phil Bagwell.

@section{VList Construction and Operations}

@subsection{vlist}
The function @scheme[vlist] creates a vlist with the given inputs. 
For example,
@schememod[
typed-scheme
(require "vlist.ss")

(vlist 1 2 3 4 5 6)
]

In the above example, the vlist obtained will have 1 as its head element,
2 as the head of its tail and so on.


@subsection{empty}
An empty vlist

@subsection{empty?}
The function @scheme[empty?] checks if the given vlist is empty or not.
For example,
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? vlst)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{vcons}
The function @scheme[vcons] takes an element and a vlist and adds 
the given element to the vlist. For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(define new-vlist  (vcons 10 vlst))
]

In the above example, envlstue adds the element 10 to the vlist vlst. 
new-vlist now contains 10 as its first element.

@subsection{first}
The function @scheme[first] takes a vlist and gives the first element 
of the given vlist if vlist is not empty else throws an error. 
For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(first vlst)
]

In the above example, @scheme[(first vlst)], gives back the first element in 
@scheme[vlst] which happens to be 1.

@subsection{last}
The function @scheme[last] takes a vlist and gives the last element in the
vlist if vlist is not empty else throws an error. For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(last vlst)
]

In the above example, @scheme[(last vlst)], gives back the last element in 
@scheme[vlst] which is 6.

@subsection{rest}
The function @scheme[rest] takes a vlist and gives back a vlist without the 
first element if the given vlist is not empty. Else throws an error. 
For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(rest vlst)
]

In the above example, @scheme[(rest vlst)], removes the head of the given 
vlist and returns @scheme[(vlist 1 2 3 4 5 6)].


@subsection{get}
The function @scheme[get] takes an integer(say n) and a vlist and gives
the nth element of the given vlist

For example,
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

]

In the above example, @scheme[(get 0 vlst)] returns 1, 
@scheme[(get 1 vlst)] gives 2 and so on. If the list is empty or if the 
index is larger than the number of elements in the vlist, then get throws
an error.


@subsection{size}
The function @scheme[size] takes a vlist and gives the number of elements in 
the given vlist. 
For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(size vlst)
]

In the above example, @scheme[(size vlst)], gives 6. 
@scheme[(size empty)] gives 0.


@subsection{vlist->list}
The function @scheme[vlist->list] takes a vlist and gives back a normal list
scheme list. Example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(vlist->list vlst)
]

In the above example, @scheme[(vlist->list vlst)], gives 
@scheme[(list 1 2 3 4 5 6)]. @scheme[(vlist->list empty)] 
gives an empty list.


@subsection{reverse}
The function @scheme[reverse] takes a vlist and gives back a reverses vlist. 
For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(reverse vlst)
]

In the above example, @scheme[(reverse vlst)], gives back the reversed
vlist @scheme[(vlist 6 5 4 3 2 1)].


@subsection{vmap}
The function @scheme[vmap] is same as @schememodname[map] except that 
@scheme[vmap] runs works on vlists. For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(define new-vlist  (vmap add1 vlst))

(define new-vlist1  (vmap * vlst vlst))
]

In the above example, @scheme[(vmap add1 vlst)] adds 1 to each element of the
given vlist and gives back @scheme[(vlist 2 3 4 5 6 7)].
@scheme[(vmap * vlst)] multiplies corresponding elements in the two vlists 
and gives back the vlist @scheme[(1 4 9 16 25 36 49)].



@subsection{vmap}
The function @scheme[vmap] is same as @schememodname[map] except that 
@scheme[vmap] runs works on vlists. For example
@schememod[
typed-scheme
(require "vlist.ss")

(define vlst (vlist 1 2 3 4 5 6))

(define new-vlist  (vmap add1 vlst))
]

In the above example, @scheme[(vmap add1 vlst)] adds 1 to each element of the
given vlist and gives back @scheme[(vlist 2 3 4 5 6 7)].