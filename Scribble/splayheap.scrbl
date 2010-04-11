#lang scribble/manual

@title{Splay Heap}

Splay Heaps are very similar to balanced binary search trees. The difference
between the two lies in the fact that Splay Heaps do not maintain any 
explicit balance information. Instead every operation restructures the 
tree with some simple transformations that increase the balance of the
tree. Because of the restructuring on every operation, the worst case
running time of all the operations is @bold{@italic{O(n)}}. But it can 
be easily shown that the amortized running time of is
@bold{@italic{O(log(n))}} for the all the main operations 
@italic{insert find-min delete-min merge}.

@section{Splay Heap Construction and Operations}

@subsection{splayheap}
The function @scheme[splayheap] creates a Splay Heap with the given 
inputs. For example,
@schememod[
typed-scheme
(require "splayheap.ss")

(splayheap < 1 2 3 4 5 6)
]

In the above example, the splay heap obtained will have elements 1 thru' 6 
with < as the comparison function.


@subsection{empty}
An empty splay heap.

@subsection{empty?}
The function @scheme[empty?] checks if the given splay heap is empty or not.
For example,
@schememod[
typed-scheme
(require "splayheap.ss")

(define sheap (splayheap < 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? sheap)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{insert}
The function @scheme[insert] takes an element and a splay heap and inserts 
the given element into the splay heap. Example
@schememod[
typed-scheme
(require "splayheap.ss")

(define sheap (splayheap < 1 2 3 4 5 6))

(define new-sheap (insert 10 sheap))
]

In the above example, @scheme[(insert 10 sheap)] adds the element 10 to
the heap sheap.

@subsection{find-min/max}
The function @scheme[find-min/max] takes a splay heap and gives the 
largest or the smallest element in the heap if splay heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. For Example
@schememod[
typed-scheme
(require "splayheap.ss")

(define sheap1 (splayheap < 1 2 3 4 5 6))
(define sheap2 (splayheap > 1 2 3 4 5 6))

(find-min/max sheap1)
(find-min/max sheap2)
]

In the above example, @scheme[(find-min/max sheap1)], returns the smallest
element in @scheme[sheap1] which happens to be 1. And 
@scheme[(find-min/max sheap2)] gives the largest element in the heap 6.

@subsection{delete-min/max}
The function @scheme[delete-min/max] takes a splay heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. For Example
@schememod[
typed-scheme
(require "splayheap.ss")

(define sheap1 (splayheap < 1 2 3 4 5 6))
(define sheap2 (splayheap > 1 2 3 4 5 6))

(delete-min/max sheap1)
(delete-min/max sheap2)
]

In the above example, @scheme[(delete-min/max sheap1)], deletes the smallest 
element in the heap and gives a heap without the min element 1 in it. 
And @scheme[(delete-min/max sheap2)], returns a heap without the largest
element which is 6.

@subsection{merge}
The function @scheme[merge] takes two splay heaps and returns a 
merged splay heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap. For Example
@schememod[
typed-scheme
(require "splayheap.ss")

(define sheap1 (splayheap < 1 2 3 4 5 6))
(define sheap2 (splayheap (λ: ([a : Integer] 
                                  [b : Integer]) 
                                 (< a b))
                             10 20 30 40 50 60))
(merge sheap1 sheap2)

]

In the above example, @scheme[(merge sheap1 sheap2)], merges the heaps and
< will become the comparison function for the merged heap. If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order. 



@subsection{sorted-list}
The function @scheme[sorted-list] takes a splay heap and returns a list 
which is sorted according to the comparison function of the heap. For Example
@schememod[
typed-scheme
(require "splayheap.ss")

(define sheap (splayheap > 1 2 3 4 5 6))

(sorted-list sheap)
]

In the above example, @scheme[(sorted-list sheap)], returns 
@scheme[(6 5 4 3 2 1)].