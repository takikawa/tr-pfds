#lang scribble/manual

@title{Leftist Heap}

Leftist heaps are heap-ordered binary trees that satisfy the 
leftist property: the rank of any left child is at least as large as the rank 
of its right sibling. The rank of a node is defined to be the length of its
right spine (i.e., the rightmost path from the node in question to an empty
node). A simple consequence of the leftist property is that the right spine
of any node is always the shortest path to an empty node.

Provides worst case running time of @bold{@italic{O(log(n))}} for the 
operations @italic{insert delete-min and merge} and a worst case running time of
@bold{@italic{O(1)}} for @italic{find-min}.

@section{Leftist Heap Construction and Operations}

@subsection{leftistheap}
The function @scheme[leftistheap] creates a Leftist Heap with the given 
inputs. For example,
@schememod[
typed-scheme
(require "leftistheap.ss")

(leftistheap < 1 2 3 4 5 6)
]

In the above example, the leftist heap obtained will have elements 1 thru' 6 
with < as the comparison function.


@subsection{empty}
An empty leftist heap.

@subsection{empty?}
The function @scheme[empty?] checks if the given leftist heap is empty or not.
For example,
@schememod[
typed-scheme
(require "leftistheap.ss")

(define lheap (leftistheap < 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? lheap)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{insert}
The function @scheme[insert] takes an element and a leftist heap and inserts 
the given element into the leftist heap. Example
@schememod[
typed-scheme
(require "leftistheap.ss")

(define lheap (leftistheap < 1 2 3 4 5 6))

(define new-lheap (insert 10 lheap))
]

In the above example, insert adds the element 10 to the heap lheap.

@subsection{find-min/max}
The function @scheme[find-min/max] takes a leftist heap and gives the 
largest or the smallest element in the heap if leftist heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. For Example
@schememod[
typed-scheme
(require "leftistheap.ss")

(define lheap (leftistheap < 1 2 3 4 5 6))

(find-min/max lheap)
]

In the above example, @scheme[(find-min/max lheap)], returns the smallest
element in @scheme[lheap] which happens to be 1.

@subsection{delete-min/max}
The function @scheme[delete-min/max] takes a leftist heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. For Example
@schememod[
typed-scheme
(require "leftistheap.ss")

(define lheap (leftistheap < 1 2 3 4 5 6))

(delete-min/max lheap)
]

In the above example, @scheme[(delete-min/max lheap)], returns a heap 
without the min element 1.

@subsection{merge}
The function @scheme[merge] takes two leftist heaps and returns a 
merged leftist heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap. For Example
@schememod[
typed-scheme
(require "leftistheap.ss")

(define lheap1 (leftistheap < 1 2 3 4 5 6))
(define lheap2 (leftistheap (λ: ([a : Integer] 
                                  [b : Integer]) 
                                 (< a b))
                             10 20 30 40 50 60))
(merge lheap1 lheap2)

]

In the above example, @scheme[(merge lheap1 lheap2)], merges the heaps and
< will become the comparison function for the merged heap. If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order. 



@subsection{sorted-list}
The function @scheme[sorted-list] takes a leftist heap and returns a list 
which is sorted according to the comparison function of the heap. For Example
@schememod[
typed-scheme
(require "leftistheap.ss")

(define lheap (leftistheap > 1 2 3 4 5 6))

(sorted-list lheap)
]

In the above example, @scheme[(sorted-list lheap)], returns 
@scheme[(6 5 4 3 2 1)].