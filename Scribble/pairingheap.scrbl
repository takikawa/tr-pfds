#lang scribble/manual

@title{Pairing Heap}

Pairing Heap is a type of heap which has a very simple implementation 
and has extremely good performance in practice. Pairing Heaps provide a
worst case running time of @bold{@italic{O(1)}} for the operations 
@italic{insert find-min merge}. And @italic{delete-min} has a amortized
running time of @bold{@italic{O(log(n))}}.

@section{Pairing Heap Construction and Operations}

@subsection{pairingheap}
The function @scheme[pairingheap] creates a Pairing Heap with the given 
inputs. For example,
@schememod[
typed-scheme
(require "pairingheap.ss")

(pairingheap < 1 2 3 4 5 6)
]

In the above example, the pairing heap obtained will have elements 1 thru' 6 
with < as the comparison function.


@subsection{empty}
An empty pairing heap.

@subsection{empty?}
The function @scheme[empty?] checks if the given pairing heap is empty or not.
For example,
@schememod[
typed-scheme
(require "pairingheap.ss")

(define pheap (pairingheap < 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? pheap)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{insert}
The function @scheme[insert] takes an element and a pairing heap and inserts 
the given element into the pairing heap. Example
@schememod[
typed-scheme
(require "pairingheap.ss")

(define pheap (pairingheap < 1 2 3 4 5 6))

(define new-pheap (insert 10 pheap))
]

In the above example, @scheme[(insert 10 pheap)] adds the element 10 to
the heap pheap.

@subsection{find-min/max}
The function @scheme[find-min/max] takes a pairing heap and gives the 
largest or the smallest element in the heap if pairing heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. For Example
@schememod[
typed-scheme
(require "pairingheap.ss")

(define pheap1 (pairingheap < 1 2 3 4 5 6))
(define pheap2 (pairingheap > 1 2 3 4 5 6))

(find-min/max pheap1)
(find-min/max pheap2)
]

In the above example, @scheme[(find-min/max pheap1)], returns the smallest
element in @scheme[pheap1] which happens to be 1. And 
@scheme[(find-min/max pheap2)] gives the largest element in the heap 6.

@subsection{delete-min/max}
The function @scheme[delete-min/max] takes a pairing heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. For Example
@schememod[
typed-scheme
(require "pairingheap.ss")

(define pheap1 (pairingheap < 1 2 3 4 5 6))
(define pheap2 (pairingheap > 1 2 3 4 5 6))

(delete-min/max pheap1)
(delete-min/max pheap2)
]

In the above example, @scheme[(delete-min/max pheap1)], deletes the smallest 
element in the heap and gives a heap without the min element 1 in it. 
And @scheme[(delete-min/max pheap2)], returns a heap without the largest
element which is 6.

@subsection{merge}
The function @scheme[merge] takes two pairing heaps and returns a 
merged pairing heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap. For Example
@schememod[
typed-scheme
(require "pairingheap.ss")

(define pheap1 (pairingheap < 1 2 3 4 5 6))
(define pheap2 (pairingheap (λ: ([a : Integer] 
                                  [b : Integer]) 
                                 (< a b))
                             10 20 30 40 50 60))
(merge pheap1 pheap2)

]

In the above example, @scheme[(merge pheap1 pheap2)], merges the heaps and
< will become the comparison function for the merged heap. If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order. 



@subsection{sorted-list}
The function @scheme[sorted-list] takes a pairing heap and returns a list 
which is sorted according to the comparison function of the heap. For Example
@schememod[
typed-scheme
(require "pairingheap.ss")

(define pheap (pairingheap > 1 2 3 4 5 6))

(sorted-list pheap)
]

In the above example, @scheme[(sorted-list pheap)], returns 
@scheme[(6 5 4 3 2 1)].