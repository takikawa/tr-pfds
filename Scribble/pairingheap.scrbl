#lang scribble/manual

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../pairingheap.ss"))

@title{Pairing Heap}

Pairing Heap is a type of heap which has a very simple implementation 
and has extremely good performance in practice. Pairing Heaps provide a
worst case running time of @bold{@italic{O(1)}} for the operations 
@italic{insert find-min merge}. And @italic{delete-min} has a amortized
running time of @bold{@italic{O(log(n))}}.

@section{Pairing Heap Construction and Operations}

@subsection{pairingheap}
The function @scheme[pairingheap] creates a Pairing Heap with the given 
inputs. 
@examples[#:eval evaluate

(pairingheap < 1 2 3 4 5 6)
]

In the above example, the pairing heap obtained will have elements 1 thru' 6 
with < as the comparison function.


@subsection{empty?}
The function @scheme[empty?] checks if the given pairing heap is empty or not.

@examples[#:eval evaluate

(empty? (pairingheap < 1 2 3 4 5 6))

(empty? (pairingheap <))
]

@subsection{insert}
The function @scheme[insert] takes an element and a pairing heap and inserts 
the given element into the pairing heap. 
@examples[#:eval evaluate

(insert 10 (pairingheap < 1 2 3 4 5 6))
]

In the above example, @scheme[(insert 10 (pairingheap < 1 2 3 4 5 6))] adds 
the element 10 to @scheme[(pairingheap < 1 2 3 4 5 6)].

@subsection{find-min/max}
The function @scheme[find-min/max] takes a pairing heap and gives the 
largest or the smallest element in the heap if pairing heap is not empty
else throws an error. The element returned is max or min depends on the
comparison function of the heap. For 
@examples[#:eval evaluate

(find-min/max (pairingheap < 1 2 3 4 5 6))
(find-min/max (pairingheap > 1 2 3 4 5 6))
(find-min/max (pairingheap >))
]

@subsection{delete-min/max}
The function @scheme[delete-min/max] takes a pairing heap and returns the 
same heap with out the min or max element in the given heap. The element 
removed from the heap is max or min depends on the comparison function of the
heap. For 
@examples[#:eval evaluate

(delete-min/max (pairingheap < 1 2 3 4 5 6))
(delete-min/max (pairingheap > 1 2 3 4 5 6))
(delete-min/max (pairingheap <))
]

In the above example, @scheme[(delete-min/max (pairingheap < 1 2 3 4 5 6))], 
deletes the smallest element 1 in the heap @scheme[(pairingheap < 1 2 3 4 5 6)]. 
And @scheme[(delete-min/max (pairingheap > 1 2 3 4 5 6))] deletes the largest
element which is 6.

@subsection{merge}
The function @scheme[merge] takes two pairing heaps and returns a 
merged pairing heap. Uses the comparison function in the first heap for
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
The function @scheme[sorted-list] takes a pairing heap and returns a list 
which is sorted according to the comparison function of the heap. For 
@examples[#:eval evaluate

(define pheap (pairingheap > 1 2 3 4 5 6))

(sorted-list pheap)
]

In the above example, @scheme[(sorted-list pheap)], returns 
@scheme[(6 5 4 3 2 1)].