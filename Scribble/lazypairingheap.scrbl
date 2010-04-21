#lang scribble/manual
@(require (for-label "../lazypairingheap.ss"))

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../lazypairingheap.ss"))

@title{Lazy Pairing Heap}

Lazy Pairing Heap is very similar to Pairing Heap. The only difference between
the two is, as the name suggests, Lazy Pairing Heap is lazy in nature.

@;section{Lazy Pairing Heap Construction and Operations}

@defproc[(heap [comp (A A -> Boolean)] [a A] ...) (Heap A)]{
Function @scheme[heap] creates a Lazy Pairing Heap with the given 
inputs. 
@examples[#:eval evaluate

(heap < 1 2 3 4 5 6)
]

In the above example, the lazy pairing heap obtained will have elements 1 thru' 6 
with < as the comparison function.}


@;subsection{empty}
@;An empty lazy pairing heap.

@defproc[(empty? [heap (Heap A)]) Boolean]{
Function @scheme[empty?] checks if the given lazy pairing heap is empty or not.

@examples[#:eval evaluate

(empty? (heap < 1 2 3 4 5 6))

(empty? (heap <))
]}


@defproc[(insert [a A] [heap (Heap A)] ...) (Heap A)]{
Function @scheme[insert] takes an element and a lazy pairing heap and inserts 
the given element into the lazy pairing heap. 
@examples[#:eval evaluate

(insert 10 (heap < 1 2 3 4 5 6))
]

In the above example, @scheme[(insert 10 (heap < 1 2 3 4 5 6))] 
adds the element 10 to the heap @scheme[(heap < 1 2 3 4 5 6)].}

@defproc[(find-min/max [heap (Heap A)]) A]{
Function @scheme[find-min/max] takes a lazy pairing heap and gives the 
largest or the smallest element in the heap if lazy pairing heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. 
@examples[#:eval evaluate

(find-min/max (heap < 1 2 3 4 5 6))
(find-min/max (heap > 1 2 3 4 5 6))
(find-min/max (heap <))
]}

@defproc[(delete-min/max [heap (Heap A)]) (Heap A)]{
Function @scheme[delete-min/max] takes a lazy pairing heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. 
@examples[#:eval evaluate

(delete-min/max (heap < 1 2 3 4 5 6))
(delete-min/max (heap > 1 2 3 4 5 6))
(delete-min/max (heap >))
]}

@defproc[(merge [pheap1 (Heap A)] [pheap2 (Heap A)]) (Heap A)]{
Function @scheme[merge] takes two lazy pairing heaps and returns a 
merged lazy pairing heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap.

@margin-note{If the comparison
functions do not have the same properties, merged heap might lose its 
heap-order.}

@examples[#:eval evaluate

(define pheap1 (heap < 1 2 3 4 5 6))
(define pheap2 (heap (λ: ([a : Integer] 
                                 [b : Integer]) 
                                (< a b))
                            10 20 30 40 50 60))
(merge pheap1 pheap2)

]

In the above example, @scheme[(merge pheap1 pheap2)], merges the heaps and
< will become the comparison function for the merged heap.}



@defproc[(sorted-list [heap (Heap A)]) (Listof A)]{
Function @scheme[sorted-list] takes a lazy pairing heap and returns a list 
which is sorted according to the comparison function of the heap. 
@examples[#:eval evaluate

(sorted-list (heap > 1 2 3 4 5 6))
(sorted-list (heap < 1 2 3 4 5 6))
]}
