#lang scribble/manual
@(defmodule "../catenablelist.ss")
@(require (for-label "../catenablelist.ss")
          "helper.rkt")

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../catenablelist.ss"))

@title{Catenable List}

Catenable Lists are nothing but lists with efficient catenation. They use 
a data-structucal bootstrapping technique called 
@italic{Structucal Abstraction}. The data structure internally use 
Real Time Queues to realize an amortized running time of @bold{@italic{O(1)}}
for the operations @scheme[first], @scheme[rest], @scheme[cons] and
@scheme[cons-to-end].

@;section{Catenable List Constructor and Operations}

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

@defproc[(filter [func (A -> Boolean)] [que (CatenableList A)]) (CatenableList A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define que (list 1 2 3 4 5 6))

(->list (filter (λ: ([x : Integer]) (> x 5)) que))

(->list (filter (λ: ([x : Integer]) (< x 5)) que))

(->list (filter (λ: ([x : Integer]) (<= x 5)) que))
]}

@defproc[(remove [func (A -> Boolean)] [que (CatenableList A)]) (CatenableList A)]{
Function @scheme[remove] is similar to @|racket-remove|. 
@examples[#:eval evaluate

(->list (remove (λ: ([x : Integer]) (> x 5))
                (list 1 2 3 4 5 6)))

(->list (remove (λ: ([x : Integer]) (< x 5))
                (list 1 2 3 4 5 6)))

(->list (remove (λ: ([x : Integer]) (<= x 5))
                (list 1 2 3 4 5 6)))
]}
