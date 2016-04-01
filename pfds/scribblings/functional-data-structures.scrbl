#lang scribble/manual

@title[#:tag "top"]{@bold{Functional Data Structures} in Typed Racket}
The data structures in this library are based on the work of
Chris Okasaki and Phil Bagwell, including those in the
@italic{Purely Functional Data Structures} by Okasaki.
All of the data structures are implemented in Typed Racket.

@author[@link["http://www.ccs.neu.edu/home/krhari"]{Hari Prashanth K R}]

@local-table-of-contents[]

@include-section{queues.scrbl}
@include-section{deques.scrbl}
@include-section{heaps.scrbl}
@include-section{randomaccesslist.scrbl}
@;@include-section{catenable-list.scrbl}
@include-section{vlist.scrbl}
@include-section{streams.scrbl}
@include-section{redblacktrees.scrbl}
@include-section{tries.scrbl}
@include-section{treap.scrbl}
