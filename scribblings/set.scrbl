#lang scribble/manual

@(require "helper.rkt")
@(require (for-label tr-pfds/set))

@defmodule/this-package[set]

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require tr-pfds/set))

@title{Sets}

An simple implementation of sets based on binary trees.


@defform[(Set A)]{A set of type @racket[A].}

@defproc[(set [comp (A A -> Boolean)] [a A] ...) (Set A)]{
Function 
@scheme[set] creates a Set with the given inputs. The function 
requires a comparison function as in this implementation, data is 
maintained in the form of a binary tree which has a lot of advantages 
over a naive set implementation using lists. 
@examples[#:eval evaluate

(set < 1 2 3 4 5)
]

In the above example, the set obtained will have 2 as its root
and < as the comparison function.}

@defproc[(empty? [set (Set A)]) Boolean]{
Function @scheme[empty?] checks if the given set is empty. 
@examples[#:eval evaluate

(empty? (set < 1 2 3 4 5 6))
(empty? (set <))
]}


@defproc[(insert [a A] [set (Set A)]) (Set A)]{
Function 
@scheme[insert] inserts the given element into the set. 
If the given element is alredy in the set, it just ignores it 
i.e. the elements of the set are not duplicated.
@examples[#:eval evaluate

(insert 10 (set < 1 2 3 4 5 6))
(insert 1 (set < 1 2 3 4 5 6))
]

In the first example, insert adds the 10 to
@scheme[(set < 1 2 3 4 5 6)]. In the second example, it just returns
@scheme[(set < 1 2 3 4 5 6)].}


@defproc[(member? [set (Set A)]) Boolean]{
Function @scheme[member?] takes an element and a set and 
checks if the given element is a member of the set. 
@examples[#:eval evaluate

(member? 5 (set < 1 2 3 4 5 6))
(member? 10 (set < 1 2 3 4 5 6))
]}


@defproc[(subset? [set1 (Set A)] [set2 (Set A)]) Boolean]{
Function @scheme[subset?] checks if set2 is a subset of set1. 
@examples[#:eval evaluate

(subset? (set < 1 2 3 4 5 6) (set < 7 8 9))
(subset? (set < 1 2 3 4 5 6) (set < 1 2 3 4 5 6))
(subset? (set < 1 2 3 4 5 6) (set < 2 3))
(subset? (set < 1 2 3 4 5 6) ((inst set Positive-Fixnum) <))
]
In the last example we are instantiating the set to be of type
Positive-Fixnum as it cannot be inferred because of the absence 
of elements.}


@defproc[(union [set1 (Set A)] [set2 (Set A)]) (Set A)]{
Function @scheme[union] returns the union of the two given sets. 
@examples[#:eval evaluate

(union (set < 1 2 3 4 5 6) (set < 7 8 9))
(union (set < 1 2 3 4 5 6) (set < 1 2 3 4 5 6))
]

In the first example, @scheme[union] returns 
@racket[(set < 1 2 3 4 5 6 7 8 9)], and in the second example it returns 
@scheme[(set < 1 2 3 4 5 6)]}


@defproc[(intersection [set1 (Set A)] [set2 (Set A)]) (Set A)]{
Function @scheme[intersection] returns the common elements of the two given sets. 
@examples[#:eval evaluate

(intersection (set < 1 2 3 4 5 6) (set < 7 8 9))
(intersection (set < 1 2 3 4 5 6) (set < 1 2 3 4 5 6))
(intersection (set < 1 2 3 4 5 6) (set < 2 3 10 15))
]

In the first example, @scheme[intersection] returns 
a empty set, and in the second example it returns 
@scheme[(set < 1 2 3 4 5 6)] and in the third, it returns @racket[(set < 2 3)]}


@defproc[(difference [set1 (Set A)] [set2 (Set A)]) (Set A)]{
Function @scheme[difference] returns all the elements in first set 
         that are not in the second set. 
@examples[#:eval evaluate

(difference (set < 1 2 3 4 5 6) (set < 7 8 9))
(difference (set < 1 2 3 4 5 6) (set < 1 2 3 4 5 6))
(difference (set < 1 2 3 4 5 6) (set < 2 3 10 15))
]

In the first example, @scheme[difference] returns 
@scheme[(set < 1 2 3 4 5 6)], and in the second example it returns 
a empty set and in the third, it returns @racket[(set < 1 4 5 6)]}


@defproc[(set->list [set (Set A)]) (Listof A)]{
Function @scheme[set->list] takes a set and returns a 
list containing all the elements of the given set. 

@examples[#:eval evaluate

(set->list (set > 1 2 3 4 5))
]}


@defproc[(map [comparer (C C -> Boolean)]
              [func (A B ... B -> C)] 
              [set1 (Set A)]
              [set2 (Set B)] ...) (Set A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(set->list (map < add1 (set < 1 2 3 4 5 6)))

(set->list (map < * 
                (set < 1 2 3 4 5 6) 
                (set < 1 2 3 4 5 6)))
]}


@defproc[(filter [func (A -> Boolean)] [set (Set A)]) (Set A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(set->list (filter (λ: ([x : Integer]) (> x 5)) 
                   (set < 1 2 3 4 5 6)))

(set->list (filter (λ: ([x : Integer]) (< x 5)) 
                   (set < 1 2 3 4 5 6)))

(set->list (filter (λ: ([x : Integer]) (<= x 5)) 
                   (set < 1 2 3 4 5 6)))
]}


@defproc[(remove [func (A -> Boolean)] [set (Set A)]) (Set A)]{
Function 
@scheme[remove] is similar to @|racket-filter| but 
@scheme[remove] removes the elements which match the predicate. 
@examples[#:eval evaluate

(set->list (remove (λ: ([x : Integer]) (> x 5))
                   (set < 1 2 3 4 5 6)))

(set->list (remove (λ: ([x : Integer]) (< x 5))
                   (set < 1 2 3 4 5 6)))

(set->list (remove (λ: ([x : Integer]) (<= x 5))
                   (set < 1 2 3 4 5 6)))
]}

@(close-eval evaluate)
