#lang scribble/manual

@(require "helper.rkt")
@(require (for-label data/vlist))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require data/vlist))

@title{VList}

@defmodule[data/vlist]

A VList is a data structure very similar to noraml Scheme List but the 
corresponding operations are significantly faster for most of the List
operations. Indexing and length operations have a running time of
@bold{@italic{O(1)}} and @bold{@italic{O(lg N)}} respectively compared to 
@bold{@italic{O(N)}} in lists. The data structure has been described in the 
paper @italic{Fast Functional Lists, Hash-Lists, vlists and
              Variable Length Arrays} by  Phil Bagwell.
VLists implementation internally uses @secref["sbral"].

@defform[(List A)]{A vlist type @racket[A].}

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


@defproc[(->list [vlst (List A)]) (Listof A)]{
Function @scheme[->list] takes a vlist and returns a normal
scheme list. 
@examples[#:eval evaluate

(->list (list 1 2 3 4 5 6))
(->list empty)
]}


@defproc[(reverse [vlst (List A)]) (List A)]{
Function @scheme[reverse] takes a vlist and returns a reversed vlist. 

@examples[#:eval evaluate

(->list (reverse (list 1 2 3 4 5 6)))
]}


@defproc[(map [func (A B ... B -> C)] 
              [vlst1 (List A)]
              [vlst2 (List B)] ...) (List A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(->list (map add1 (list 1 2 3 4 5 6)))

(->list (map * (list 1 2 3 4 5 6) (list 1 2 3 4 5 6)))
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


@defproc[(andmap [func (A B ... B -> Boolean)]
                 [lst1 (List A)]
                 [lst2 (List B)] ...) Boolean]{
Function @scheme[andmap] is similar to @|racket-andmap|.

@examples[#:eval evaluate

(andmap even? (list 1 2 3 4 5 6))

(andmap odd? (list 1 2 3 4 5 6))

(andmap positive? (list 1 2 3 4 5 6))

(andmap negative? (list -1 -2))
]}


@defproc[(ormap [func (A B ... B -> Boolean)]
                [lst1 (List A)]
                [lst2 (List B)] ...) Boolean]{
Function @scheme[ormap] is similar to @|racket-ormap|.

@examples[#:eval evaluate

(ormap even? (list 1 2 3 4 5 6))

(ormap odd? (list 1 2 3 4 5 6))

(ormap positive? (list -1 -2 3 4 -5 6))

(ormap negative? (list 1 -2))
]}

@defproc[(build-list [size Natural]
                     [func (Natural -> A)])
                     (List A)]{
Function @scheme[build-list] is similar to @|racket-build-list|.
@examples[#:eval evaluate

(->list (build-list 5 (λ:([x : Integer]) (add1 x))))

(->list (build-list 5 (λ:([x : Integer]) (* x x))))

]}

@defproc[(make-list [size Natural]
                    [func A])
                    (List A)]{
Function @scheme[make-list] is similar to @|racket-make-list|.
@examples[#:eval evaluate

(->list (make-list 5 10))

(->list (make-list 5 'sym))

]}

@defproc[(filter [func (A -> Boolean)] [vlst (List A)]) (List A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define vlst (list 1 2 3 4 5 6))

(->list (filter (λ:([x : Integer]) (> x 5)) vlst))

(->list (filter (λ:([x : Integer]) (< x 5)) vlst))

(->list (filter (λ:([x : Integer]) (<= x 4)) vlst))
]}

@defproc[(second [lst (List A)]) A]{
Function @scheme[second] returns the second element of the list.

@examples[#:eval evaluate

(second (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(third [lst (List A)]) A]{
Function @scheme[third] returns the third element of the list.

@examples[#:eval evaluate

(third (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(fourth [lst (List A)]) A]{
Function @scheme[fourth] returns the fourth element of the list.

@examples[#:eval evaluate

(fourth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(fifth [lst (List A)]) A]{
Function @scheme[fifth] returns the fifth element of the list.

@examples[#:eval evaluate

(fifth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(sixth [lst (List A)]) A]{
Function @scheme[sixth] returns the sixth element of the list.

@examples[#:eval evaluate

(sixth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(seventh [lst (List A)]) A]{
Function @scheme[seventh] returns the seventh element of the list.

@examples[#:eval evaluate

(seventh (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(eighth [lst (List A)]) A]{
Function @scheme[eighth] returns the eighth element of the list.

@examples[#:eval evaluate

(eighth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(ninth [lst (List A)]) A]{
Function @scheme[ninth] returns the ninth element of the list.

@examples[#:eval evaluate

(ninth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(tenth [lst (List A)]) A]{
Function @scheme[tenth] returns the tenth element of the list.

@examples[#:eval evaluate

(tenth (list 1 2 3 4 5 6 7 8 9 10 11))
]}

@(close-eval evaluate)
