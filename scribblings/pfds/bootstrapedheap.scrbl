#lang scribble/manual

@(require "helper.rkt")
@(require (for-label data/heap/bootstrapped))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require data/heap/bootstrapped))

@title{Bootstrapped Heap}

@defmodule[data/heap/bootstrapped]

Bootstrapped heaps are heaps with efficient merging. The bootstrapped heap is
implemented with structural abstraction over a less efficient heap
implementation to get a worst case running time of @bold{@italic{O(1)}} for the
operations @scheme[insert], @scheme[find-min/max] and @scheme[merge] and worst
case running time of @bold{@italic{O(log(n))}} for @scheme[delete-min/max]
operation. This implementation abstracts over skew binomial heaps. For skew
binomial heaps, see @secref["skewbh"].

@defform[(Heap A)]{A bootstrapped heap of type @racket[A].}

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
Function @scheme[remove] is similar to @|racket-filter| but
@scheme[remove] removes the elements which match the predicate.
@examples[#:eval evaluate

(sorted-list (remove (λ: ([x : Integer]) (> x 5))
                    (heap < 1 2 3 4 5 6)))

(sorted-list (remove (λ: ([x : Integer]) (< x 5))
                    (heap < 1 2 3 4 5 6)))

(sorted-list (remove (λ: ([x : Integer]) (<= x 5))
                    (heap < 1 2 3 4 5 6)))
]}

@defproc[(andmap [func (A B ... B -> Boolean)]
                 [heap1 (Heap A)]
                 [heap2 (Heap B)] ...) Boolean]{
Function @scheme[andmap] is similar to @|racket-andmap|.

@examples[#:eval evaluate

(andmap even? (heap < 1 2 3 4 5 6))

(andmap odd? (heap < 1 2 3 4 5 6))

(andmap positive? (heap < 1 2 3 4 5 6))

(andmap negative? (heap < -1 -2))
]}


@defproc[(ormap [func (A B ... B -> Boolean)]
                [heap1 (Heap A)]
                [heap2 (Heap B)] ...) Boolean]{
Function @scheme[ormap] is similar to @|racket-ormap|.

@examples[#:eval evaluate

(ormap even? (heap < 1 2 3 4 5 6))

(ormap odd? (heap < 1 2 3 4 5 6))

(ormap positive? (heap < -1 -2 3 4 -5 6))

(ormap negative? (heap < 1 -2))
]}

@defproc[(build-heap [size Natural]
                     [func (Natural -> A)]
                     [comp (A A -> Boolean)])
                     (Heap A)]{
Function @scheme[build-heap] is similar to @|racket-build-list| but this
function takes an extra comparison function.

@examples[#:eval evaluate

(sorted-list (build-heap 5 (λ:([x : Integer]) (add1 x)) <))

(sorted-list (build-heap 5 (λ:([x : Integer]) (* x x)) <))

]}

@(close-eval evaluate)
