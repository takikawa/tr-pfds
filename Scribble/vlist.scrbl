#lang scribble/manual
@(defmodule "../vlist.ss")
@;(defmodule "helper.rkt")
@(require (for-label "../vlist.ss")
          ;(for-label "helper.rkt")
          "helper.rkt")

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../vlist.ss"))

@;{(require (for-label (only-in scheme
                              [map sh:map] 
                              [foldr sh:foldr] 
                              [foldl sh:foldl] 
                              [filter sh:filter])))}
@;(defmodule scheme map)

@title{VList}

A VList is a data structure very similar to noraml Scheme List but the 
corresponding operations are significantly faster for most of the List
operations. Indexing and length operations have a running time of
@bold{@italic{O(1)}} and @bold{@italic{O(lg N)}} respectively compared to 
@bold{@italic{O(N)}} in lists. The data structure has been described in the 
paper @italic{Fast Functional Lists, Hash-Lists, vlists and
              Variable Length Arrays} by  Phil Bagwell.
VLists implementation internally uses @secref["bral"].

@;section{VList Construction and Operations}

@defproc[(list [a A] ...) (List A)]{
Function @scheme[list] creates a vlist with the given inputs. 

@examples[#:eval evaluate

(list 1 2 3 4 5 6)
]

In the above example, the vlist obtained will have 1 as its first element.}


@defthing[empty (List Nothing)]{
An empty vlist.}

@defproc[(empty? [vlst (List A)]) Boolean]{
Function @scheme[empty?] checks if the given vlist is empty or not.

@examples[#:eval evaluate

(empty? (list 1 2 3 4 5 6))

(empty? empty)
]}

@defproc[(cons [a A] [vlst (List A)]) (List A)]{
Function @scheme[cons] takes an element and a vlist and adds 
the given element to the vlist. 
@examples[#:eval evaluate

(cons 10 (list 1 2 3 4 5 6))
]

In the above example, @scheme[cons] adds the element 10 to 
@scheme[(list 1 2 3 4 5 6)] and returns @scheme[(list 10 1 2 3 4 5 6)].}

@defproc[(first [vlst (List A)]) A]{
Function @scheme[first] takes a vlist and gives the first element 
of the given vlist if vlist is not empty else throws an error. 

@examples[#:eval evaluate

(first (list 1 2 3 4 5 6))

(first empty)
]}

@defproc[(last [vlst (List A)]) A]{
Function @scheme[last] takes a vlist and gives the last element in the
vlist if vlist is not empty else throws an error. 
@examples[#:eval evaluate

(last (list 1 2 3 4 5 6))

(last empty)
]}

@defproc[(rest [vlst (List A)]) (List A)]{
Function @scheme[rest] takes a vlist and returns a vlist without the 
first element if the given vlist is not empty. Else throws an error. 

@examples[#:eval evaluate

(rest (list 1 2 3 4 5 6))

(rest empty)
]

In the above example, @scheme[(rest (list 1 2 3 4 5 6))], removes the head
and returns @scheme[(list 2 3 4 5 6)].}


@defproc[(list-ref [vlst (List A)] [index Integer]) A]{
Function @scheme[list-ref] takes a vlist and an index(say n) and gives
the nth element of the given vlist


@examples[#:eval evaluate

(list-ref (list 1 2 3 4 5 6) 0)
(list-ref (list 1 2 3 4 5 6) 3)
(list-ref (list 1 2 3 4 5 6) 10)
]}


@defproc[(length [vlst (List A)]) Integer]{
Function @scheme[length] takes a vlist and gives the number of elements in 
the given vlist. 

@examples[#:eval evaluate

(length (list 1 2 3 4 5 6))
(length empty)
]}


@defproc[(vlist->list [vlst (List A)]) (Listof A)]{
Function @scheme[vlist->list] takes a vlist and returns a normal
scheme list. 
@examples[#:eval evaluate

(vlist->list (list 1 2 3 4 5 6))
(vlist->list empty)
]}


@defproc[(reverse [vlst (List A)]) (List A)]{
Function @scheme[reverse] takes a vlist and returns a reversed vlist. 

@examples[#:eval evaluate

(vlist->list (reverse (list 1 2 3 4 5 6)))
]

In the above example, @scheme[(reverse (list 1 2 3 4 5 6))], returns the 
reversed vlist @scheme[(list 6 5 4 3 2 1)].}


@defproc[(map [func (A B ... B -> C)] 
              [vlst1 (List A)]
              [vlst2 (List B)] ...) (List A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(vlist->list (map add1 (list 1 2 3 4 5 6)))

(vlist->list (map * (list 1 2 3 4 5 6) (list 1 2 3 4 5 6)))
]

In the above example, @scheme[(map add1 (list 1 2 3 4 5 6))] adds 1 to
each element of the given vlist and returns @scheme[(list 2 3 4 5 6 7)].
@scheme[(map * (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))] multiplies
corresponding elements in the two vlists
and returns the vlist @scheme[(list 1 4 9 16 25 36)].}


@defproc[(foldl [func (C A B ... B -> C)]
                 [init C]
                 [vlst1 (List A)]
                 [vlst2 (List B)] ...) C]{
Function @scheme[foldl] is similar to @|racket-foldl|.
@margin-note{@scheme[foldl] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldl + 0 (list 1 2 3 4 5 6))

(foldl * 1 (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))
]}


@defproc[(foldr [func (C A B ... B -> C)] 
                 [init C] 
                 [vlst1 (List A)] 
                 [vlst2 (List B)] ...) C]{
Function @scheme[foldr] is similar to @|racket-foldr|. 
@margin-note{@scheme[foldr] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldr + 0 (list 1 2 3 4 5 6))

(foldr * 1 (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))
]}

@defproc[(filter [func (A -> Boolean)] [vlst (List A)]) (List A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define vlst (list 1 2 3 4 5 6))

(vlist->list (filter (λ:([x : Integer]) (> x 5)) vlst))

(vlist->list (filter (λ:([x : Integer]) (< x 5)) vlst))

(vlist->list (filter (λ:([x : Integer]) (<= x 4)) vlst))
]}
