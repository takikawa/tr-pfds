#lang scribble/manual
@(defmodule "../bootstrapedheap.ss")
@(require (for-label "../bootstrapedheap.ss"))

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../bootstrapedheap.ss"))

@title{Bootstrapped Heap}

Bootstrapped Heaps are heaps with efficiant mergining. Bootstrapped Heap
does structural abstraction over other less efficient heap implementation 
to get a worst case running time of @bold{@italic{O(1)}} for the 
operations @scheme[insert], @scheme[find-min/max] and @scheme[merge]
and worst case running time of
@bold{@italic{O(log(n))}} for @scheme[delete-min/max] operation. This 
implementation abstracts over Skew Binomila Heaps. For Skew Binomila Heaps,
see @secref["skewbh"]

@;section{Bootstrapped Heap Construction and Operations}

@defproc[(heap [comp (A A -> Boolean)] [a A] ...) (Heap A)]{
Function @scheme[heap] creates a Bootstrapped Heap with the
given inputs.    
@examples[#:eval evaluate

(heap < 1 2 3 4 5 6)
]

In the above example, the bootstrapped heap obtained will have elements 
1 thru' 6 with < as the comparison function.}


@defproc[(empty? [heap (Heap A)]) Boolean]{
Function @scheme[empty?] checks if the given bootstrapped heap is empty 
or not.    
@examples[#:eval evaluate

(empty? (heap < 1 2 3 4 5 6))

(empty? (heap <))

]}


@defproc[(insert [a A] [heap (Heap A)] ...) (Heap A)]{
Function @scheme[insert] takes an element and a bootstrapped heap and inserts 
the given element into the bootstrapped heap.    
@examples[#:eval evaluate

(insert 10 (heap < 1 2 3 4 5 6))
]

In the above example, insert adds the element 10 to the heap 
@scheme[(heap < 1 2 3 4 5 6)].}

@defproc[(find-min/max [heap (Heap A)]) A]{
Function @scheme[find-min/max] takes a bootstrapped heap and gives the 
largest or the smallest element in the heap if bootstrapped heap is not empty
else throws an error. The element returned is largest or smallest depends on
the comparison function of the heap.    
@examples[#:eval evaluate

(find-min/max (heap < 1 2 3 4 5 6))
(find-min/max (heap > 1 2 3 4 5 6))
(find-min/max (heap <))
]}

@defproc[(delete-min/max [heap (Heap A)]) (Heap A)]{
Function @scheme[delete-min/max] takes a bootstrapped heap and returns the 
same heap without the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap.    
@examples[#:eval evaluate

(delete-min/max (heap < 1 2 3 4 5 6))
(delete-min/max (heap > 1 2 3 4 5 6))
(delete-min/max (heap <))

]

In the above example, 
@scheme[(delete-min/max (heap < 1 2 3 4 5 6))], deletes element
1 from @scheme[(heap < 1 2 3 4 5 6)]. And 
@scheme[(delete-min/max (heap > 1 2 3 4 5 6))], deletes element
6 from @scheme[(heap > 1 2 3 4 5 6)].}

@defproc[(merge [heap1 (Heap A)] [heap2 (Heap A)]) (Heap A)]{
Function @scheme[merge] takes two bootstrapped heaps and returns a 
merged bootstrapped heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap.

@margin-note{If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order.}

@examples[#:eval evaluate

(define bheap1 (heap < 1 2 3 4 5 6))
(define bheap2 (heap (λ: ([a : Integer] 
                                       [b : Integer]) 
                                      (< a b))
                                  10 20 30 40 50 60))
(merge bheap1 bheap2)

]

In the above example, @scheme[(merge bheap1 bheap2)], merges the heaps and
< will become the comparison function for the merged heap. 
}



@defproc[(sorted-list [heap (Heap A)]) (Listof A)]{
Function @scheme[sorted-list] takes a bootstrapped heap and returns a 
list which is sorted according to the comparison function of the heap. 
   
@examples[#:eval evaluate

(sorted-list (heap > 1 2 3 4 5 6))
(sorted-list (heap < 1 2 3 4 5 6))
]

In the above example, @scheme[(sorted-list bheap)], returns 
@scheme[(6 5 4 3 2 1)].}
