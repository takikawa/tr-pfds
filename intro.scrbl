#lang scribble/sigplan
@(require (except-in scribble/manual cite) scriblib/autobib
          "bib.rkt")

@title{Functional Data Structures for a Functional Language}

Functional programming requires more than just @racket[lambda];
 library support for programming in a functional style is also required.
  In particular, efficient and persistent functional data
structures are needed in almost every program.  

Scheme does provide one supremely valuable functional
data structure---the linked list.  This is sufficient to support many
forms of functional programming @cite[srfi/1] (although lists are sadly mutable
in most Schemes), but not nearly sufficient.  To truly support efficient
programming in a functional style, additional data structures are need.

Fortunately, the last 15 years have seen the development of many
efficient and useful functional data structures, in particular by @citet[oka] and 
@citet[bagwell-lists bagwell-trie].
These data structures have seen wide use in languages such as Haskell
and Clojure, but have rarely been implemented in Scheme.  

In this paper, we present a comprehensive library of efficient
functional data structures, implemented in Typed Racket@cite[thf-popl], a
recently-developed typed dialect of Racket (formerly PLT Scheme).  
The remainder of the paper is organized as follows.  We first present
an overview of Typed Racket, and describe how typed functional datastructures can interoperate with untyped, imperative code.
  @seclink["fds"]{Section 2} describes the data
structures, with their API and their performance
characteristics. 
In @secref["benchmarks"], we present benchmarks demonstrating that our implemenations are viable for use in real code. We
then detail the experience of using Typed Racket for this project,
both positive and negative.  Finally, we discuss other implementations
and conclude.


@include-section["ts.scrbl"]

@section{Interoperation with External Code}

Most Scheme programs are neither purely functional nor typed.  That
does not prevent them from benefiting from the data structures
presented in this paper, however.  Typed Racket automatically supports
interoperation between typed and untyped code, allowing any program to
use the data structures presented here, regardless of whether it is
typed.  Typed Racket does however enforce its type invariants via
software contracts, which can reduce the performance of the
structures.

Additionally, using these data structures in no way requires
programming in a purely functional style.  An mostly-functional Scheme
program that does not mutate a list can replace that list with a VList
without any problem.  Using functional data structures often adds
persistence and performance without subtracting functionality.