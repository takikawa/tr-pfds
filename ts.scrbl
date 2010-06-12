#lang scribble/sigplan
@(require (except-in scribble/manual cite) scriblib/autobib
          "bib.rkt")

@title{An Overview of Typed Scheme}

Typed Scheme@cite[thf-popl th-diss] is an
explicitly typed dialect of Scheme, implemented in PLT
Scheme@cite[plt-manual].   Typed Scheme supports both integration with
untyped Scheme code as well as a typechecker which accepts idiomatic
Scheme code.  

While this paper presents the API of the functional data structures,
rather than their implementation, we begin with a brief description of
a few key features of the type system.  

First, Typed Scheme supports explicit polymorphism, which is used
extensively in the functional data structure library.  Type arguments
to polymorphic functions are automatically inferred via @emph{local
type inference}@cite[lti-journal].  Second, Typed Scheme supports
untagged rather than disjoint unions.  Thus, most data structures
presented here are implemented as unions of several distinct structure
types.  