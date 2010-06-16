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
functional data structures, implemented in Typed Scheme@cite[thf-popl], a
recently-developed typed dialect of PLT Scheme.  
The remainder of the paper is organized as follows.  We first present
an overview of Typed Scheme.  @seclink["fds"]{Section 2} describes the data
structures, with their API and their performance
characteristics. 
In @secref["benchmarks"], we present benchmarks demonstrating that our implemenations are viable for use in real code. We
then detail the experience of using Typed Scheme for this project,
both positive and negative.  Finally, we discuss other implementations
and conclude.


@include-section["ts.scrbl"]
