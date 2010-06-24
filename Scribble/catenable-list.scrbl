#lang scribble/manual
@(defmodule "../catenablelist.ss")
@(require (for-label "../catenablelist.ss"))

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

@defproc[(clist [a A] ...) (CatenableList A)]{
Function clist creates a Catenable List with the given inputs. 
  
@examples[#:eval evaluate

(clist 1 2 3 4 5 6)
]

In the above example, @scheme[(clist 1 2 3 4 5 6)] gives a Catenable List
which is similar to lists but comes with efficient append operation.}

@defform/none[empty]{
A empty clist.}

@defproc[(empty? [catlist (CatenableList A)]) Boolean]{
Function @scheme[empty?] takes a Catenable List checks if the given clist is 
empty.   
@examples[#:eval evaluate

(empty? (clist 1 2 3 4 5 6))

(empty? empty)

]}

@defproc[(cons [a A] [catlist (CatenableList A)]) (CatenableList A)]{
Function @scheme[cons] takes an element and a clist and adds the given
element to the front the given clist.   
@examples[#:eval evaluate

(cons 10 (clist 1 2 3 4 5 6))
]

In the above example, @scheme[(cons 10 (clist 1 2 3 4 5 6))] returns 
@scheme[(clist 10 1 2 3 4 5 6)].}


@defproc[(cons-to-end [a A] [catlist (CatenableList A)]) (CatenableList A)]{
Function @scheme[cons-to-end] takes an element and a clist and adds the 
given element to the rear end the given clist.   
@examples[#:eval evaluate

(cons-to-end 10 (clist 1 2 3 4 5 6))
]

In the above example, @scheme[(cons-to-end 10 (clist 1 2 3 4 5 6))] returns 
@scheme[(clist 1 2 3 4 5 6 10)].}

@defproc[(first [catlist (CatenableList A)]) A]{
Function @scheme[first] takes a clist and returns the first element
of the given clist.   
@examples[#:eval evaluate

(first (clist 1 2 3 4 5 6))
(first empty)
]}


@defproc[(rest [catlist (CatenableList A)]) (CatenableList A)]{
Function @scheme[rest] takes a clist and returns a clist without 
the first element of the given clist.   
@examples[#:eval evaluate

(rest (clist 1 2 3 4 5 6))
(rest empty)
]

In the above example, @scheme[(rest (clist 1 2 3 4 5 6))] returns the rest of
the given clist, @scheme[(clist 2 3 4 5 6)].}


@defproc[(append [cal1 (CatenableList A)] [cal2 (CatenableList A)]) 
         (CatenableList A)]{
Function @scheme[append] takes two clists and appends the second clist 
to the end of the first clist.

  
@examples[#:eval evaluate

(define cal1 (clist 1 2 3 4 5 6))
(define cal2 (clist 7 8 9 10))

(append cal1 cal2)
]

In the above example, @scheme[(append cal1 cal2)] returns 
@scheme[(clist 1 2 3 4 5 6 7 8 9 10)].}


@defproc[(clist->list [cal (CatenableList A)]) (Listof A)]{
Function @scheme[clist->list] takes a clist and returns a list
of elements which are in the same order as in the clist.   
@examples[#:eval evaluate

(clist->list (clist 1 2 3 4 5 6))

(clist->list empty)
]

In the above example, @scheme[(clist->list cal)] returns the list,
@scheme[(1 2 3 4 5 6)].}
