#lang scribble/manual

@;(require (for-label typed/racket))
@;(provide (for-label all-defined-out))

@title[#:tag "top"]{@bold{Functional Data Structures} in Typed Racket}
All the data structures below, are the works of 
@italic{Chris Okasaki, Phil Bagwell} and those that are discussed
in the book @italic{Purely Functional Data Structures} by Chris Okasaki.
And the data structures have been entirely implemented in Typed Racket.
@author[@link["http://www.ccs.neu.edu/home/krhari"]{Hari Prashanth K R}]

@local-table-of-contents[]

@include-section{queues.scrbl}
@include-section{deques.scrbl}
@include-section{heaps.scrbl}
@include-section{randomaccesslist.scrbl}
@include-section{catenable-list.scrbl}
@include-section{vlist.scrbl}
@include-section{streams.scrbl}
@include-section{redblacktrees.scrbl}
@include-section{tries.scrbl}
@include-section{set.scrbl}
@include-section{treap.scrbl}


@;@subsection[#:tag "Hash List"]{VHash List}
@;A Hash List is a modified VList. Along with data it maintains a hash table.
@;Hence each time the hash-list grows, both the data area and the hash table
@;grow by the same factor. The data structure has been described in the 
@;paper @italic{Fast Functional Lists, Hash-Lists, Deques and 
@;              Variable Length Arrays} by  Phil Bagwell.
@;
@;@subsection[#:tag "Unbalanced Set"]{Unbalanced Set}
@;@subsection[#:tag "Tries"]{Tries}
