#lang scribble/manual

@(require "helper.rkt")
@(require (for-label data/catenable-list))

@defmodule[data/catenable-list]

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require data/catenable-list))

@title{Catenable List}

Catenable lists are a list-like data structure with efficient catenation. They
use a bootstrapping technique called @italic{structucal abstraction}. The data
structure internally uses @secref["boot-que"] to realize an amortized running
time of @bold{@italic{O(1)}} for the operations @scheme[first], @scheme[rest],
@scheme[cons] and @scheme[cons-to-end].

@defform[(CatenableList A)]{A catenable list of type @racket[A].}

@defproc[(list [a A] ...) (CatenableList A)]{
Function list creates a catenable list with the given inputs.

@examples[#:eval evaluate

(list 1 2 3 4 5 6)
]

In the above example, @scheme[(list 1 2 3 4 5 6)] gives a Catenable List
which is similar to lists but comes with efficient append operation.}

@defform/none[empty]{
A empty catenable list.}

@defproc[(empty? [catlist (CatenableList A)]) Boolean]{
Function @scheme[empty?] takes a Catenable List checks if the given catenable
list is empty.
@examples[#:eval evaluate

(empty? (list 1 2 3 4 5 6))

(empty? empty)

]}

@defproc[(cons [a A] [catlist (CatenableList A)]) (CatenableList A)]{
Function @scheme[cons] takes an element and a catenable list and adds
the given element to the front the given catenable list.
@examples[#:eval evaluate

(cons 10 (list 1 2 3 4 5 6))
]

In the above example, @scheme[(cons 10 (list 1 2 3 4 5 6))] returns 
@scheme[(list 10 1 2 3 4 5 6)].}


@defproc[(cons-to-end [a A] [catlist (CatenableList A)]) (CatenableList A)]{
Function @scheme[cons-to-end] takes an element and a catenable list and adds
the given element to the rear end the given catenable list.
@examples[#:eval evaluate

(cons-to-end 10 (list 1 2 3 4 5 6))
]

In the above example, @scheme[(cons-to-end 10 (list 1 2 3 4 5 6))] returns 
@scheme[(list 1 2 3 4 5 6 10)].}

@defproc[(first [catlist (CatenableList A)]) A]{
Function @scheme[first] takes a catenable list and returns the first element
of the given catenable list.
@examples[#:eval evaluate

(first (list 1 2 3 4 5 6))
(first empty)
]}


@defproc[(rest [catlist (CatenableList A)]) (CatenableList A)]{
Function @scheme[rest] takes a catenable list and returns a catenable list
without the first element of the given catenable list.
@examples[#:eval evaluate

(rest (list 1 2 3 4 5 6))
(rest empty)
]

In the above example, @scheme[(rest (list 1 2 3 4 5 6))] returns the rest of
the given catenable list, @scheme[(list 2 3 4 5 6)].}


@defproc[(append [cal1 (CatenableList A)] [cal2 (CatenableList A)]) 
         (CatenableList A)]{
Function @scheme[append] takes two catenable lists and appends the second
catenable list to the end of the first catenable list.

  
@examples[#:eval evaluate

(define cal1 (list 1 2 3 4 5 6))
(define cal2 (list 7 8 9 10))

(append cal1 cal2)
]

In the above example, @scheme[(append cal1 cal2)] returns 
@scheme[(list 1 2 3 4 5 6 7 8 9 10)].}


@defproc[(->list [cal (CatenableList A)]) (Listof A)]{
Function @scheme[->list] takes a clist and returns a list
of elements which are in the same order as in the catenable list.
@examples[#:eval evaluate

(->list (list 1 2 3 4 5 6))

(->list empty)
]}

@defproc[(reverse [cal (List A)]) (List A)]{
Function @scheme[reverse] takes a vlist and returns a reversed vlist. 

@examples[#:eval evaluate

(->list (reverse (list 1 2 3 4 5 6)))
]}

@defproc[(map [func (A B ... B -> C)]
              [clst1 (CatenableList A)]
              [clst2 (CatenableList B)] ...) (CatenableList A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(->list (map add1 (list 1 2 3 4 5 6)))

(->list (map * (list 1 2 3 4 5 6) (list 1 2 3 4 5 6)))
]}

@defproc[(foldl [func (C A B ... B -> C)]
                [init C]
                [clst1 (CatenableList A)]
                [clst2 (CatenableList B)] ...) C]{
Function @scheme[foldl] is similar to @|racket-foldl|
@margin-note{@scheme[foldl] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldl + 0 (list 1 2 3 4 5 6))

(foldl * 1 (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))
]}

@defproc[(foldr [func (C A B ... B -> C)]
                [init C]
                [clst1 (CatenableList A)]
                [clst2 (CatenableList B)] ...) C]{
Function @scheme[foldr] is similar to @|racket-foldr|
@margin-note{@scheme[foldr] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldr + 0 (list 1 2 3 4 5 6))

(foldr * 1 (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))
]}


@defproc[(andmap [func (A B ... B -> Boolean)]
                 [lst1 (CatenableList A)]
                 [lst2 (CatenableList B)] ...) Boolean]{
Function @scheme[andmap] is similar to @|racket-andmap|.

@examples[#:eval evaluate

(andmap even? (list 1 2 3 4 5 6))

(andmap odd? (list 1 2 3 4 5 6))

(andmap positive? (list 1 2 3 4 5 6))

(andmap negative? (list -1 -2))
]}


@defproc[(ormap [func (A B ... B -> Boolean)]
                [lst1 (CatenableList A)]
                [lst2 (CatenableList B)] ...) Boolean]{
Function @scheme[ormap] is similar to @|racket-ormap|.

@examples[#:eval evaluate

(ormap even? (list 1 2 3 4 5 6))

(ormap odd? (list 1 2 3 4 5 6))

(ormap positive? (list -1 -2 3 4 -5 6))

(ormap negative? (list 1 -2))
]}

@defproc[(build-list [size Natural]
                     [func (Natural -> A)])
                     (CatenableList A)]{
Function @scheme[build-list] is similar to @|racket-build-list|.
@examples[#:eval evaluate

(->list (build-list 5 (λ:([x : Integer]) (add1 x))))

(->list (build-list 5 (λ:([x : Integer]) (* x x))))

]}

@defproc[(make-list [size Natural]
                    [func A])
                    (CatenableList A)]{
Function @scheme[make-list] is similar to @|racket-make-list|.
@examples[#:eval evaluate

(->list (make-list 5 10))

(->list (make-list 5 'sym))

]}

@defproc[(filter [func (A -> Boolean)] [que (CatenableList A)]) (CatenableList A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define que (list 1 2 3 4 5 6))

(->list (filter (λ: ([x : Integer]) (> x 5)) que))

(->list (filter (λ: ([x : Integer]) (< x 5)) que))

(->list (filter (λ: ([x : Integer]) (<= x 5)) que))
]}

@defproc[(remove [func (A -> Boolean)] [que (CatenableList A)]) (CatenableList A)]{
Function @scheme[remove] is similar to @|racket-filter| but @scheme[remove] removes the elements which match the predicate. 
@examples[#:eval evaluate

(->list (remove (λ: ([x : Integer]) (> x 5))
                (list 1 2 3 4 5 6)))

(->list (remove (λ: ([x : Integer]) (< x 5))
                (list 1 2 3 4 5 6)))

(->list (remove (λ: ([x : Integer]) (<= x 5))
                (list 1 2 3 4 5 6)))
]}

@(close-eval evaluate)
