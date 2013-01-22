#lang scribble/manual

@(require "helper.rkt")
@(require (for-label pfds/heap/splay))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require pfds/heap/splay))

@title{Splay Heap}

@defmodule[pfds/heap/splay]

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

@defform[(Heap A)]{A splay heap of type @racket[A].}

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
Function @scheme[remove] is similar to @|racket-filter| but @scheme[remove] removes the elements which match the predicate. 
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
