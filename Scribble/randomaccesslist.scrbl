#lang scribble/manual
@;(require (for-label and have the type (RAList A).

@title{Random Access Lists}
Following Random Access List structures implement 
and provide the functions ralist, empty?, kons, head, tail, lookup, 
update, drop, list-length and ralist->list . 
Both are polymorphic and have the type (RAList A).
@local-table-of-contents[]
@include-section{binaryrandomaccesslist.scrbl}
@include-section{skewbinaryrandomaccesslist.scrbl}
