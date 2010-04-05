#lang scribble/manual

@title{Bootstrapped Heap}

Bootstrapped Heaps are heaps with efficiant mergining. Bootstrapped Heap
does structural abstraction over other less efficient heap implementation 
to get a worst case running time of @bold{@italic{O(1)}} for the 
operations @italic{insert find-min merge} and worst case running time of  
@bold{@italic{O(log(n))}} for @italic{delete-min} operation. This 
implementation abstracts over Skew Binomila Heaps. For Skew Binomila Heaps,
see @secref["skewbh"]

@section{Bootstrapped Heap Construction and Operations}

@subsection{bootstrapped-heap}
The function @scheme[bootstrapped-heap] creates a Bootstrapped Heap with the
given inputs. For example,
@schememod[
typed-scheme
(require "bootstrappedheap.ss")

(bootstrapped-heap < 1 2 3 4 5 6)
]

In the above example, the bootstrapped heap obtained will have elements 
1 thru' 6 with < as the comparison function.


@subsection{empty}
An empty bootstrapped heap.

@subsection{empty?}
The function @scheme[empty?] checks if the given bootstrapped heap is empty 
or not. For example,
@schememod[
typed-scheme
(require "bootstrappedheap.ss")

(define bheap (bootstrapped-heap < 1 2 3 4 5 6))

]

In the above example, @scheme[(empty? bheap)] returns @scheme[#f] and 
@scheme[(empty? empty)] returns @scheme[#t].


@subsection{insert}
The function @scheme[insert] takes an element and a bootstrapped heap and inserts 
the given element into the bootstrapped heap. For example
@schememod[
typed-scheme
(require "bootstrappedheap.ss")

(define bheap (bootstrapped-heap < 1 2 3 4 5 6))

(define new-bheap (insert 10 bheap))
]

In the above example, insert adds the element 10 to the heap bheap.

@subsection{find-min/max}
The function @scheme[find-min/max] takes a bootstrapped heap and gives the 
largest or the smallest element in the heap if bootstrapped heap is not empty
else throws an error. The element returned is largest or smallest depends on
the comparison function of the heap. For example
@schememod[
typed-scheme
(require "bootstrappedheap.ss")

(define bheap1 (bootstrapped-heap < 1 2 3 4 5 6))
(define bheap2 (bootstrapped-heap > 1 2 3 4 5 6))

(find-min/max bheap1)
(find-min/max bheap2)
]

In the above example, @scheme[(find-min/max bheap1)], gives back the smallest
element in @scheme[bheap1] which happens to be 1. 
And @scheme[(find-min/max bheap2)], gives back the largest element in 
@scheme[bheap2] which happens to be 6

@subsection{delete-min/max}
The function @scheme[delete-min/max] takes a bootstrapped heap and gives back the 
same heap without the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. For Example
@schememod[
typed-scheme
(require "bootstrappedheap.ss")

(define bheap1 (bootstrapped-heap < 1 2 3 4 5 6))
(define bheap2 (bootstrapped-heap > 1 2 3 4 5 6))

(delete-min/max bheap1)
(delete-min/max bheap2)
]

In the above example, @scheme[(delete-min/max bheap1)], gives back a heap 
without the min element 1. And @scheme[(delete-min/max bheap2)], gives back 
a heap without the max element 6. 

@subsection{merge}
The function @scheme[merge] takes two bootstrapped heaps and gives back a 
merged bootstrapped heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap. For Example
@schememod[
typed-scheme
(require "bootstrappedheap.ss")

(define bheap1 (bootstrapped-heap < 1 2 3 4 5 6))
(define bheap2 (bootstrapped-heap (λ: ([a : Integer] 
                                  [b : Integer]) 
                                 (< a b))
                             10 20 30 40 50 60))
(merge bheap1 bheap2)

]

In the above example, @scheme[(merge bheap1 bheap2)], merges the heaps and
< will become the comparison function for the merged heap. If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order. 



@subsection{sorted-list}
The function @scheme[sorted-list] takes a bootstrapped heap and gives back a 
list which is sorted according to the comparison function of the heap. 
For example
@schememod[
typed-scheme
(require "bootstrappedheap.ss")

(define bheap (bootstrapped-heap > 1 2 3 4 5 6))

(sorted-list bheap)
]

In the above example, @scheme[(sorted-list bheap)], gives back 
@scheme[(6 5 4 3 2 1)].