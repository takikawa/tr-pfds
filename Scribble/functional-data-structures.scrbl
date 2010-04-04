#lang scribble/manual

@begin[(require (for-label typed-scheme))]

@title[#:tag "top"]{@bold{Functional Data Structures} in Typed Scheme}
All the data structures below, are influenced by the works of 
@italic{Chris Okasaki, Phil Bagwell} and those that are discussed
in the book @italic{Purely Functional Data Structures} by Chris Okasaki.
And the data structures have been entirely implemented in Typed Scheme.
@author[@link["http://www.ccs.neu.edu/home/krhari"]{Hari Prashanth K R}]

@include-section{streams.scrbl}
@include-section{queue.scrbl}
@include-section{bankers-deque.scrbl}
@include-section{physicists-queue.scrbl}
@include-section{implicitqueue.scrbl}
@include-section{implicitdeque.scrbl}
@include-section{realtimequeue.scrbl}
@include-section{hood-melville-queue.scrbl}
@include-section{realtimedeque.scrbl}
@include-section{bootstrapedqueue.scrbl}
@include-section{binaryrandomaccesslist.scrbl}
@include-section{skewbinaryrandomaccesslist.scrbl}
@include-section{catenable-list.scrbl}
@include-section{vlist.scrbl}
@include-section{binomialheap.scrbl}
@include-section{skewbinomialheap.scrbl}
@include-section{leftistheap.scrbl}
@include-section{splayheap.scrbl}
@include-section{pairingheap.scrbl}
@include-section{lazypairingheap.scrbl}
@include-section{bootstrapedheap.scrbl}

