#lang scribble/manual
@(defmodule "../splayheap.ss")
@(require (for-label "../splayheap.ss"))

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../splayheap.ss"))

@title{Splay Heap}

Splay Heaps are very similar to balanced binary search trees. The difference
between the two lies in the fact that Splay Heaps do not maintain any 
explicit balance information. Instead every operation restructures the 
tree with some simple transformations that increase the balance of the
tree. Because of the restructuring on every operation, the worst case
running time of all the operations is @bold{@italic{O(n)}}. But it can 
be easily shown that the amortized running time of is
@bold{@italic{O(log(n))}} for the all the main operations 
@scheme[insert], @scheme[find-min/max], @scheme[delete-min/max]
and @scheme[merge].

@;section{Splay Heap Construction and Operations}

@defproc[(heap [comp (A A -> Boolean)] [a A] ...) (Heap A)]{
Function @scheme[heap] creates a Splay Heap with the given 
inputs. 
@examples[#:eval evaluate

(heap < 1 2 3 4 5 6)
]

In the above example, the splay heap obtained will have elements 1 thru' 6 
with < as the comparison function.}


@defproc[(empty? [heap (Heap A)]) Boolean]{
Function @scheme[empty?] checks if the given splay heap is empty or not.

@examples[#:eval evaluate

(empty? (heap < 1 2 3 4 5 6))

(empty? (heap <))
]}

@defproc[(insert [a A] [heap (Heap A)] ...) (Heap A)]{
Function @scheme[insert] takes an element and a splay heap and inserts 
the given element into the splay heap.  
@examples[#:eval evaluate

(insert 10 (heap < 1 2 3 4 5 6))

]

In the above example, @scheme[(insert 10 (heap < 1 2 3 4 5 6))] adds 10 
to the heap @scheme[(heap < 1 2 3 4 5 6)].}

@defproc[(find-min/max [heap (Heap A)]) A]{
Function @scheme[find-min/max] takes a splay heap and gives the 
largest or the smallest element in the heap if splay heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. 
@examples[#:eval evaluate

(find-min/max (heap < 1 2 3 4 5 6))
(find-min/max (heap > 1 2 3 4 5 6))
(find-min/max (heap <))
]}

@defproc[(delete-min/max [heap (Heap A)]) (Heap A)]{
Function @scheme[delete-min/max] takes a splay heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. 
@examples[#:eval evaluate

(delete-min/max (heap < 1 2 3 4 5 6))
(delete-min/max (heap > 1 2 3 4 5 6))
(delete-min/max (heap >))
]

In the above example, @scheme[(delete-min/max (heap < 1 2 3 4 5 6))] 
deletes the smallest element 1.
And @scheme[(delete-min/max (heap > 1 2 3 4 5 6))] deletes the largest
element 6.}

@defproc[(merge [sheap1 (Heap A)] [sheap2 (Heap A)]) (Heap A)]{
Function @scheme[merge] takes two splay heaps and returns a 
merged splay heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap. 
@margin-note{If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order.}
@examples[#:eval evaluate

(define sheap1 (heap < 1 2 3 4 5 6))
(define sheap2 (heap (λ: ([a : Integer] 
                               [b : Integer]) 
                              (< a b))
                          10 20 30 40 50 60))
(merge sheap1 sheap2)

]

In the above example, @scheme[(merge sheap1 sheap2)], merges the heaps and
< will become the comparison function for the merged heap.}


@defproc[(sorted-list [heap (Heap A)]) (Listof A)]{
Function @scheme[sorted-list] takes a splay heap and returns a list 
which is sorted according to the comparison function of the heap. 
@examples[#:eval evaluate

(sorted-list (heap > 1 2 3 4 5 6))
(sorted-list (heap < 1 2 3 4 5 6))
(sorted-list (heap >))
]}
