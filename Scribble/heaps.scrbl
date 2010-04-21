#lang scribble/manual

@title{Heaps}
Following heap structures implement and provide the functions 
empty?, insert, find-min/max, delete-min/max, merge and sorted-list.
All the heaps are polymorphic and have the type (Heap A).

@local-table-of-contents[]
@include-section{binomialheap.scrbl}
@include-section{skewbinomialheap.scrbl}
@include-section{leftistheap.scrbl}
@include-section{splayheap.scrbl}
@include-section{pairingheap.scrbl}
@include-section{lazypairingheap.scrbl}
@include-section{bootstrapedheap.scrbl}