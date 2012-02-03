#lang scribble/manual
@(require unstable/scribble)
@defmodule/this-package[redblacktrees]
@(require (for-label (planet krhari/pfds:1:0/redblacktrees)))
@(require "helper.rkt")
@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require "redblacktrees.ss"))

@title{Red-Black Trees}

Red-Black Tree is a binary search tree in which every node is colored either 
red or black. The red black trees follow two balance invariants
@itemlist{@item{No red node has a red child.}} 
@itemlist{@item{Every path from root to an empty node has the same 
                number of black nodes.}}
The above two invarients help in balancing the tree.
All the operations @scheme[member?], @scheme[insert]
and @scheme[delete] have worst case running
time of @bold{@italic{O(log(n))}}


@defform[(RedBlackTree A)]{A red-black tree of type @racket[A].}

@defproc[(redblacktree [comp (A A -> Boolean)] [a A] ...) (RedBlackTree A)]{
Function @scheme[redblacktree] creates a Red-Black Tree with the
given inputs. 
@examples[#:eval evaluate

(redblacktree < 1 2 3 4 5)
]

In the above example, the red black tree obtained will have 2 as its root
and < as the comparison function.}

@defproc[(empty? [rbt (RedBlackTree A)]) Boolean]{
Function @scheme[empty?] checks if the given red black tree is empty 
or not. 
@examples[#:eval evaluate

(empty? (redblacktree < 1 2 3 4 5 6))
(empty? (redblacktree <))
]}


@defproc[(insert [a A] [rbt (RedBlackTree A)]) (RedBlackTree A)]{
Function @scheme[insert] takes an element and a red black tree and inserts 
the given element into the red black tree. 
@examples[#:eval evaluate

(insert 10 (redblacktree < 1 2 3 4 5 6))
]

In the above example, insert adds the 10 to
@scheme[(redblacktree < 1 2 3 4 5 6)].}


@defproc[(root [rbt (RedBlackTree A)]) A]{
Function @scheme[root] takes a red black tree and returns the root of the
given tree. 
@examples[#:eval evaluate

(root (redblacktree < 1 2 3 4 5 6))
(root (redblacktree <))
]

In the above example, @scheme[(root (redblacktree < 1 2 3 4 5 6))], returns 2 
which is the root of @scheme[(redblacktree < 1 2 3 4 5 6)].}

@defproc[(member? [rbt (RedBlackTree A)]) Boolean]{
Function @scheme[member?] takes an element and a red black tree and 
checks if the given element is a member of the tree or not. 
@examples[#:eval evaluate

(member? 5 (redblacktree < 1 2 3 4 5 6))
(member? 10 (redblacktree < 1 2 3 4 5 6))
]}

@defproc[(delete-root [rbt (RedBlackTree A)]) (RedBlackTree A)]{
Function @scheme[delete-root] takes a red black tree and deletes the root
element of the given tree. 
@examples[#:eval evaluate

(delete-root (redblacktree < 1 2 3 4 5 6))
(delete-root (redblacktree <))
]

In the above example, @scheme[(delete-root rbtree)], delete the root of 
@scheme[(redblacktree < 1 2 3 4 5 6)] which happens to be 2 in this tree. }

@defproc[(delete [elem A] [rbt (RedBlackTree A)]) (RedBlackTree A)]{
Function @scheme[delete] takes an element and red black tree and deletes 
the given element in the tree if the element is in the tree else throws 
an error. 
@examples[#:eval evaluate

(delete 5 (redblacktree < 1 2 3 4 5 6))

(delete 10 (redblacktree < 1 2 3 4 5 6))
]

In the above example, @scheme[(delete 5 (redblacktree < 1 2 3 4 5 6))], 
deletes 5 in @scheme[(redblacktree < 1 2 3 4 5 6)].}


@defproc[(redblacktree->list [rbt (RedBlackTree A)]) (Listof A)]{
Function @scheme[redblacktree->list] takes a red black tree and returns a 
list of all the elements in the given red black tree. 

@examples[#:eval evaluate

(redblacktree->list (redblacktree > 1 2 3 4 5))
]}


@defproc[(map [comparer (C C -> Boolean)]
              [func (A B ... B -> C)] 
              [rbt1 (RedBlackTree A)]
              [rbt2 (RedBlackTree B)] ...) (RedBlackTree A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(redblacktree->list (map < add1 (redblacktree < 1 2 3 4 5 6)))

(redblacktree->list (map < * (redblacktree < 1 2 3 4 5 6) 
                             (redblacktree < 1 2 3 4 5 6)))
]}

@defproc[(fold [func (C A B ... B -> C)]
               [init C]
               [rbt1 (RedBlackTree A)]
               [rbt2 (RedBlackTree B)] ...) C]{
Function @scheme[fold] is similar to @|racket-foldl| or @|racket-foldr|
@margin-note{@scheme[fold] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(fold + 0 (redblacktree < 1 2 3 4 5 6))

(fold * 1 (redblacktree < 1 2 3 4 5 6) (redblacktree < 1 2 3 4 5 6))
]}

@defproc[(filter [func (A -> Boolean)] [rbt (RedBlackTree A)]) (RedBlackTree A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define rbt (redblacktree < 1 2 3 4 5 6))

(redblacktree->list (filter (λ: ([x : Integer]) (> x 5)) rbt))

(redblacktree->list (filter (λ: ([x : Integer]) (< x 5)) rbt))

(redblacktree->list (filter (λ: ([x : Integer]) (<= x 5)) rbt))
]}

@defproc[(remove [func (A -> Boolean)] [rbt (RedBlackTree A)]) (RedBlackTree A)]{
Function @scheme[remove] is similar to @|racket-filter| but @scheme[remove] removes the elements which match the predicate. 
@examples[#:eval evaluate

(redblacktree->list (remove (λ: ([x : Integer]) (> x 5))
                    (redblacktree < 1 2 3 4 5 6)))

(redblacktree->list (remove (λ: ([x : Integer]) (< x 5))
                    (redblacktree < 1 2 3 4 5 6)))

(redblacktree->list (remove (λ: ([x : Integer]) (<= x 5))
                    (redblacktree < 1 2 3 4 5 6)))
]}

@(close-eval evaluate)
