#lang scribble/manual

@(require "helper.rkt")
@(require (for-label pfds/treap))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require pfds/treap))

@title{Treap}

@defmodule[pfds/treap]

Treaps are binary search trees in which each node has both a search key 
and a priority. Its keys are sorted in inorder and its each node priority 
is smaller than the priorities of its children. Because of this, a treap 
is a binary search tree for the keys and a heap for its priorities.
This implementation uses random priorities to achieve good average-case 
performance.

Provides worst case running time of @bold{@italic{O(log(n))}} for the 
operations @racket[insert], @racket[find-min/max] and
@racket[delete-min/max].

@defform[(Treap A)]{A treap of type @racket[A].}

@defproc[(treap [comp (A A -> Boolean)] [a A] ...) (Treap A)]{
Function @racket[treap] creates a Treap with the given 
inputs. Elements are assigned a random between from 0 to 1.
@examples[#:eval evaluate
(treap < 1 2 3 4 5 6)
]

In the above example, the treap obtained will have elements 1 thru' 6 
with @racket[<] as the comparison function.
}

@defproc[(empty? [treap (Treap A)]) Boolean]{
Function @racket[empty?] checks if the given treap is empty or not.
   
@examples[#:eval evaluate

(empty? (treap < 1 2 3 4 5 6))
(empty? (treap <))

]}

@defproc[(contains? [a A] [treap (Treap A)]) Boolean]{
Function @racket[contains?] takes an element and a treap and checks whether or
not that element is contained within the treap.

@examples[#:eval evaluate

(contains? 4 (treap < 1 2 3 4 5 6))
(contains? 4 (treap < 1 2 3 5 6 7))

]}

@defproc[(insert [a A] [treap (Treap A)]) (Treap A)]{
Function @racket[insert] takes an element and a treap and inserts 
the given element into the treap with a random priority between 0 and 1.
@examples[#:eval evaluate

(insert 10 (treap < 1 2 3))

]

In the above example, @racket[insert] adds the element 10 to 
@racket[(treap < 1 2 3)].}

@defproc[(find-min/max [treap (Treap A)]) A]{
Function @racket[find-min/max] takes a treap and gives the 
largest or the smallest element in the treap if treap is not empty
else throws an error. The element returned is largest or smallest depends
on the comparison function of the treap.    
@examples[#:eval evaluate

(find-min/max (treap < 1 2 3 4 5 6))

(find-min/max (treap > 1 2 3 4 5 6))

(find-min/max (treap <))
]}

@defproc[(delete-min/max [treap (Treap A)]) (Treap A)]{
Function @racket[delete-min/max] takes a treap and returns the 
same treap without the min or max element in the given treap. The element 
removed from the treap is max or min depends on the comparison function of the
treap.    
@examples[#:eval evaluate

(delete-min/max (treap < 1 2 3 4 5 6))
(delete-min/max (treap > 1 2 3 4 5 6))
(delete-min/max (treap <))
]

In the above example, @racket[(delete-min/max (treap < 1 2 3 4 5 6))], 
deletes the element 1(min) from the treap. And 
@racket[(delete-min/max (treap > 1 2 3 4 5 6))], deletes 
the element 6(max) from the treap.}


@defproc[(delete [elem A] [treap (Treap A)]) (Treap A)]{
Function @racket[delete] deletes the given element from the given treap.
@examples[#:eval evaluate

(delete 6 (treap < 1 2 3 4 5 6))
(delete 3 (treap > 1 2 3 4 5 6))
(delete 10 (treap <))
]

In the above example, @racket[(delete 6 (treap < 1 2 3 4 5 6))], 
deletes the 6 returns @racket[(treap < 1 2 3 4 5)]. And 
@racket[(delete 3 (treap > 1 2 3 4 5 6))] returns
@racket[(treap > 1 2 4 5 6)].}

@defproc[(treap->list [treap (Treap A)]) (Listof A)]{
Function @racket[treap->list] takes a treap and returns a list
which is sorted according to the comparison function of the treap.
@examples[#:eval evaluate

(treap->list (treap > 1 2 3 4 5 6))
(treap->list (treap < 1 2 3 4 5 6))
]}

@defproc[(map [comparer (C C -> Boolean)]
              [func (A B ... B -> C)] 
              [treap1 (Treap A)]
              [treap2 (Treap B)] ...) (Treap A)]{
Function @racket[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(treap->list (map < add1 (treap < 1 2 3 4 5 6)))

(treap->list (map < * (treap < 1 2 3 4 5 6) (treap < 1 2 3 4 5 6)))
]}

@defproc[(fold [func (C A B ... B -> C)]
               [init C]
               [treap1 (Treap A)]
               [treap2 (Treap B)] ...) C]{
Function @racket[fold] is similar to @|racket-foldl| or @|racket-foldr|
@margin-note{@racket[fold] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(fold + 0 (treap < 1 2 3 4 5 6))

(fold * 1 (treap < 1 2 3 4 5 6) (treap < 1 2 3 4 5 6))
]}

@defproc[(filter [func (A -> Boolean)] [treap (Treap A)]) (Treap A)]{
Function @racket[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define trp (treap < 1 2 3 4 5 6))

(treap->list (filter (λ: ([x : Integer]) (> x 5)) trp))

(treap->list (filter (λ: ([x : Integer]) (< x 5)) trp))

(treap->list (filter (λ: ([x : Integer]) (<= x 5)) trp))
]}

@defproc[(remove [func (A -> Boolean)] [treap (Treap A)]) (Treap A)]{
Function @racket[remove] is similar to @|racket-filter| but
@racket[remove] removes the elements which satisfy the predicate.
@examples[#:eval evaluate

(treap->list (remove (λ: ([x : Integer]) (> x 5))
                     (treap < 1 2 3 4 5 6)))

(treap->list (remove (λ: ([x : Integer]) (< x 5))
                     (treap < 1 2 3 4 5 6)))

(treap->list (remove (λ: ([x : Integer]) (<= x 5))
                     (treap < 1 2 3 4 5 6)))
]}

@defproc[(andmap [func (A B ... B -> Boolean)]
                 [treap1 (Treap A)]
                 [treap2 (Treap B)] ...) Boolean]{
Function @racket[andmap] is similar to @|racket-andmap|.

@examples[#:eval evaluate

(andmap even? (treap < 1 2 3 4 5 6))

(andmap odd? (treap < 1 2 3 4 5 6))

(andmap positive? (treap < 1 2 3 4 5 6))

(andmap negative? (treap < -1 -2))
]}


@defproc[(ormap [func (A B ... B -> Boolean)]
                [treap1 (Treap A)]
                [treap2 (Treap B)] ...) Boolean]{
Function @racket[ormap] is similar to @|racket-ormap|.

@examples[#:eval evaluate

(ormap even? (treap < 1 2 3 4 5 6))

(ormap odd? (treap < 1 2 3 4 5 6))

(ormap positive? (treap < -1 -2 3 4 -5 6))

(ormap negative? (treap < 1 -2))
]}

@defproc[(build-treap [size Natural]
                      [func (Natural -> A)]
                      [comp (A A -> Boolean)])
                      (Treap A)]{
Function @racket[build-treap] is similar to @|racket-build-list| but this
function takes an extra comparison function.

@examples[#:eval evaluate

(treap->list (build-treap 5 (λ:([x : Integer]) (add1 x)) <))

(treap->list (build-treap 5 (λ:([x : Integer]) (* x x)) <))

]}

@section{Priorities}

The following functions allow the user to manipulate node priorities. Treaps
containing nodes with manually set priorities cannot guarantee
@bold{@italic{O(log(n))}} running times, and care should be taken in selecting
appropriate priorities if one wants to avoid @bold{@italic{O(n)}} running times.

@defproc[(treap/priority [comp (A A -> Boolean)] [a (Pairof A Real)] ...) (Treap A)]{
Function @racket[treap] creates a Treap with the given inputs each assigned the priority
they are paired with.
@examples[#:eval evaluate
(treap/priority < '(1 . 3) '(2 . 2) '(3 . 8) '(4 . 7) '(5 . 1) '(6 . 4))
]

In the above example, the treap obtained will have elements 1 thru' 6 
with @racket[<] as the comparison function.
}

@defproc[(insert/priority [a A] [priority Real] [treap (Treap A)]) (Treap A)]{
Function @racket[insert] takes an element, priority and a treap and inserts 
the given element into the treap with a specified priority.
@examples[#:eval evaluate

(insert/priority 10 -4 (treap < 1 2 3))
(root (insert/priority 10 -4 (treap < 1 2 3)))
(root (insert/priority 10 4 (treap < 1 2 3)))

]

In the above examples, @racket[insert/priority] adds the element 10 to 
@racket[(treap < 1 2 3)] with varying priorities.}

@defproc[(root [treap (Treap A)]) A]{
Function @racket[root] returns the value of the node at the root of the given
treap.

@examples[#:eval evaluate

(root (treap < 1 2 3))
(root (treap/priority symbol<? '(a . 4) '(b . 7) '(c . 2)))
]

The root node is always the node with the lowest priority.}

@defproc[(root/priority [treap (Treap A)]) Real]{
Function @racket[root/priority] gives the priority of the root node in the given
treap, which is the smallest priority in the treap.

@examples[#:eval evaluate

(root/priority (treap/priority symbol<? '(a . 4) '(b . 7) '(c . 2)))

]}

@defproc[(delete-root [treap (Treap A)]) (Treap A)]{
Function @racket[delete-root] deletes the root node (with the smallest priority)
from the treap.

@examples[#:eval evaluate

(root (delete-root (treap/priority symbol<? '(a . 4) '(b . 7) '(c . 2))))

]}

@(close-eval evaluate)
