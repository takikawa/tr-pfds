#lang scribble/manual
@;(defmodule and have the type (RAList A)
@;(require (for-label and have the type (RAList A).

@title{Random Access Lists}

Following Random Access List structures implement and provide the
functions list, empty?, cons, head, tail, list-ref, list-set, drop,
list-length and ->list. The implementations of the two data structures
are based on numerical representations. Binary random access lists uses
the binary number representation and running time of its basic list and
random access operations, in worst-case, is logarithmic. Where as skew
binary random access lists use skew binary number representation and
running time of its basic operations is constant in worst-case. And both
the implementations are polymorphic.  And our benchmarks indicate that
the operations of skew binary random access lists are faster.

@local-table-of-contents[]
@include-section{binaryrandomaccesslist.scrbl}
@include-section{skewbinaryrandomaccesslist.scrbl}
