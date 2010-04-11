#lang scribble/manual

@title[#:tag "skewbh"]{Skew Binomial Heap}

Skew Binomial Heaps are Binomial Heaps with hybrid numerical representation
for heaps based on both skew binary numbers. Skew binary number representation
is used since incrementing a skew binary number is quick and simple. Provides
worst case running time of @bold{@italic{O(log(n))}} for the operations 
@italic{find-min delete-min merge}. And worst case running time of 
@bold{@italic{O(1)}} for the @italic{insert} operation.

@section{Skew Binomial Heap Construction and Operations}

@subsection{binomialheap}
The function @scheme[binomialheap] creates a Skew Binomial Heap with the given 
inputs. For example,
@schememod[
typed-scheme
(require "skewbinomialheap.ss")

(binomialheap < 1 2 3 4 5 6)
]

In the above example, the binomial heap obtained will have elements 1 thru' 6 
with < as the comparison function.


@subsection{empty}
An empty binomial heap.

@subsection{empty?}
The function @scheme[empty?] checks if the given binomial heap is empty or not.
For example,
@schememod[
typed-scheme
(require "skewbinomialheap.ss")

(define bheap (binomialheap < 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? bheap)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{insert}
The function @scheme[insert] takes an element and a binomial heap and inserts 
the given element into the binomial heap. Example
@schememod[
typed-scheme
(require "skewbinomialheap.ss")

(define bheap (binomialheap < 1 2 3 4 5 6))

(define new-bheap (insert 10 bheap))
]

In the above example, insert adds the element 10 to the heap bheap.

@subsection{find-min/max}
The function @scheme[find-min/max] takes a binomial heap and gives the 
largest or the smallest element in the heap if binomial heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. For Example
@schememod[
typed-scheme
(require "skewbinomialheap.ss")

(define bheap (binomialheap < 1 2 3 4 5 6))

(find-min/max bheap)
]

In the above example, @scheme[(find-min/max bheap)], returns the smallest
element in @scheme[bheap] which happens to be 1.

@subsection{delete-min/max}
The function @scheme[delete-min/max] takes a binomial heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. For Example
@schememod[
typed-scheme
(require "skewbinomialheap.ss")

(define bheap (binomialheap < 1 2 3 4 5 6))

(delete-min/max bheap)
]

In the above example, @scheme[(delete-min/max bheap)], returns a heap 
without the min element 1.

@subsection{merge}
The function @scheme[merge] takes two binomial heaps and returns a 
merged binomial heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap. For Example
@schememod[
typed-scheme
(require "skewbinomialheap.ss")

(define bheap1 (binomialheap < 1 2 3 4 5 6))
(define bheap2 (binomialheap (λ: ([a : Integer] 
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
The function @scheme[sorted-list] takes a binomial heap and returns a list 
which is sorted according to the comparison function of the heap. For Example
@schememod[
typed-scheme
(require "skewbinomialheap.ss")

(define bheap (binomialheap > 1 2 3 4 5 6))

(sorted-list bheap)
]

In the above example, @scheme[(sorted-list bheap)], returns 
@scheme[(6 5 4 3 2 1)].