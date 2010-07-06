#lang scribble/manual
@(require "helper.rkt")
@(defmodule "../LeftistHeaps.ss")
@(require (for-label "../LeftistHeaps.ss"))

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../LeftistHeaps.ss"))

@title{Leftist Heap}

Leftist heaps are heap-ordered binary trees that satisfy the 
leftist property: the rank of any left child is at least as large as the rank 
of its right sibling. The rank of a node is defined to be the length of its
right spine (i.e., the rightmost path from the node in question to an empty
node). A simple consequence of the leftist property is that the right spine
of any node is always the shortest path to an empty node.

Provides worst case running time of @bold{@italic{O(log(n))}} for the 
operations @scheme[insert], @scheme[delete-min/max] and @scheme[merge]
and a worst case running
time of @bold{@italic{O(1)}} for @scheme[find-min/max].

@;section{Leftist Heap Construction and Operations}

@defproc[(heap [comp (A A -> Boolean)] [a A] ...) (Heap A)]{
Function @scheme[heap] creates a Leftist Heap with the given 
inputs. 
@examples[#:eval evaluate

(heap < 1 2 3 4 5 6)
]

In the above example, the leftist heap obtained will have elements 1 thru' 6 
with < as the comparison function.}


@defproc[(empty? [heap (Heap A)]) Boolean]{
Function @scheme[empty?] checks if the given leftist heap is empty or not.

@examples[#:eval evaluate

(empty? (heap < 1 2 3 4 5 6))

(empty? empty)
]}

@defproc[(insert [a A] [heap (Heap A)] ...) (Heap A)]{
Function @scheme[insert] takes an element and a leftist heap and inserts 
the given element into the leftist heap. 
@examples[#:eval evaluate

(insert 10 (heap < 1 2 3 4 5 6))
]

In the above example, insert adds the element 10 to the heap 
@scheme[(heap < 1 2 3 4 5 6)].}

@defproc[(find-min/max [heap (Heap A)]) A]{
Function @scheme[find-min/max] takes a leftist heap and gives the 
largest or the smallest element in the heap if leftist heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. 
@examples[#:eval evaluate

(find-min/max (heap < 1 2 3 4 5 6))
(find-min/max (heap > 1 2 3 4 5 6))
(find-min/max (heap <))
]

In the above example, @scheme[(find-min/max lheap)], returns the smallest
element in @scheme[lheap] which happens to be 1.}

@defproc[(delete-min/max [heap (Heap A)]) (Heap A)]{
Function @scheme[delete-min/max] takes a leftist heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. 
@examples[#:eval evaluate

(delete-min/max (heap < 1 2 3 4 5 6))
(delete-min/max (heap > 1 2 3 4 5 6))
(delete-min/max (heap <))
]

In the above example, @scheme[(delete-min/max (heap < 1 2 3 4 5 6))]
deletes min element 1 from the heap and 
@scheme[(delete-min/max (heap > 1 2 3 4 5 6))] deletes max element 6
from the heap.}

@defproc[(merge [lheap1 (Heap A)] [lheap2 (Heap A)]) (Heap A)]{
Function @scheme[merge] takes two leftist heaps and returns a 
merged leftist heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap.

@margin-note{If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order.}

@examples[#:eval evaluate

(define lheap1 (heap < 1 2 3 4 5 6))
(define lheap2 (heap (λ: ([a : Integer] 
                                 [b : Integer]) 
                                (< a b))
                            10 20 30 40 50 60))
(merge lheap1 lheap2)

]

In the above example, @scheme[(merge lheap1 lheap2)], merges the heaps and
< will become the comparison function for the merged heap.}


@defproc[(sorted-list [heap (Heap A)]) (Listof A)]{
Function @scheme[sorted-list] takes a leftist heap and returns a list 
which is sorted according to the comparison function of the heap. 
@examples[#:eval evaluate

(sorted-list (heap > 1 2 3 4 5 6))
(sorted-list (heap < 1 2 3 4 5 6))
]}

@defproc[(map [comparer (C C -> Boolean)]
              [func (A B ... B -> C)] 
              [hep1 (Heap A)]
              [hep2 (Heap B)] ...) (Heap A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(sorted-list (map < add1 (heap < 1 2 3 4 5 6)))

(sorted-list (map < * (heap < 1 2 3 4 5 6) (heap < 1 2 3 4 5 6)))
]}

@defproc[(fold [func (C A B ... B -> C)]
               [init C]
               [hep1 (Heap A)]
               [hep2 (Heap B)] ...) C]{
Function @scheme[fold] is similar to @|racket-foldl| or @|racket-foldr|
@margin-note{@scheme[fold] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(fold + 0 (heap < 1 2 3 4 5 6))

(fold * 1 (heap < 1 2 3 4 5 6) (heap < 1 2 3 4 5 6))
]}

@defproc[(filter [func (A -> Boolean)] [hep (Heap A)]) (Heap A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define hep (heap < 1 2 3 4 5 6))

(sorted-list (filter (λ: ([x : Integer]) (> x 5)) hep))

(sorted-list (filter (λ: ([x : Integer]) (< x 5)) hep))

(sorted-list (filter (λ: ([x : Integer]) (<= x 5)) hep))
]}

@defproc[(remove [func (A -> Boolean)] [hep (Heap A)]) (Heap A)]{
Function @scheme[remove] is similar to @|racket-remove|. 
@examples[#:eval evaluate

(sorted-list (remove (λ: ([x : Integer]) (> x 5))
                    (heap < 1 2 3 4 5 6)))

(sorted-list (remove (λ: ([x : Integer]) (< x 5))
                    (heap < 1 2 3 4 5 6)))

(sorted-list (remove (λ: ([x : Integer]) (<= x 5))
                    (heap < 1 2 3 4 5 6)))
]}
