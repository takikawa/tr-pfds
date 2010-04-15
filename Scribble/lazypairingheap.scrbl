#lang scribble/manual

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../lazypairingheap.ss"))

@title{Lazy Pairing Heap}

Lazy Pairing Heap is very similar to Pairing Heap. The only difference between 
the two is, as the name suggests, Lazy Pairing Heap is lazy in nature.

@section{Lazy Pairing Heap Construction and Operations}

@subsection{pairingheap}
The function @scheme[pairingheap] creates a Lazy Pairing Heap with the given 
inputs. 
@examples[#:eval evaluate

(pairingheap < 1 2 3 4 5 6)
]

In the above example, the lazy pairing heap obtained will have elements 1 thru' 6 
with < as the comparison function.


@subsection{empty}
An empty lazy pairing heap.

@subsection{empty?}
The function @scheme[empty?] checks if the given lazy pairing heap is empty or not.

@examples[#:eval evaluate

(empty? (pairingheap < 1 2 3 4 5 6))

(empty? (pairingheap <))
]


@subsection{insert}
The function @scheme[insert] takes an element and a lazy pairing heap and inserts 
the given element into the lazy pairing heap. 
@examples[#:eval evaluate

(insert 10 (pairingheap < 1 2 3 4 5 6))
]

In the above example, @scheme[(insert 10 (pairingheap < 1 2 3 4 5 6))] 
adds the element 10 to the heap @scheme[(pairingheap < 1 2 3 4 5 6)].

@subsection{find-min/max}
The function @scheme[find-min/max] takes a lazy pairing heap and gives the 
largest or the smallest element in the heap if lazy pairing heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. 
@examples[#:eval evaluate

(find-min/max (pairingheap < 1 2 3 4 5 6))
(find-min/max (pairingheap > 1 2 3 4 5 6))
(find-min/max (pairingheap <))
]

@subsection{delete-min/max}
The function @scheme[delete-min/max] takes a lazy pairing heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. 
@examples[#:eval evaluate

(delete-min/max (pairingheap < 1 2 3 4 5 6))
(delete-min/max (pairingheap > 1 2 3 4 5 6))
(delete-min/max (pairingheap >))
]

@subsection{merge}
The function @scheme[merge] takes two lazy pairing heaps and returns a 
merged lazy pairing heap. Uses the comparison function in the first heap for
merging and the same function becomes the comparison function for the 
merged heap. 
@examples[#:eval evaluate

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
The function @scheme[sorted-list] takes a lazy pairing heap and returns a list 
which is sorted according to the comparison function of the heap. 
@examples[#:eval evaluate

(define pheap (pairingheap > 1 2 3 4 5 6))

(sorted-list pheap)
]