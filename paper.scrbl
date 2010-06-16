#lang scribble/sigplan
@(require (except-in scribble/manual cite) scriblib/autobib
          scribble/core scribble/eval scriblib/footnote
          "bib.rkt" "utils.rkt"
          scribble/latex-properties)
@title{Functional Data Structures in Typed Scheme}

@(authorinfo "Hari Prashanth K R"
             "Northeastern University"
             "krhari@ccs.neu.edu")

@(authorinfo "Sam Tobin-Hochstadt"
             "Northeastern University"
             "samth@ccs.neu.edu")


@abstract{
Scheme provides excellent base language support for programming in a
functional style, but little in the way of library support.  In this
paper, we present a comprehensive library of functional data
structures, drawing from several sources.  We have implemented the
library in Typed Scheme, a typed variant of PLT Scheme, allowing us to
maintain the type invariants of the original definitions.}

@include-section["intro.scrbl"]

@include-section["fds.scrbl"]

@;(require scribble/core)
@section[#:style (style #f (list (tex-addition "./extra.tex")))]{Benchmarks}
To demonstrate the practical usefulness of purely functional data
structures, we provide microbenchmarks of a selected set of data
structures, compared with both simple implementations based on lists,
and imperative implementations.

In the tables below, all times are CPU time as reported by PLT Scheme,
including garbage collection time.  The times are for performing each
operation 100000 times, averaged over 10 runs.

@subsection{Queue Performance}

The below table shows the performance of the 
@elemref["bankers queue"]{Banker's Queue}, compared with an
implementation based on lists, and an imperative queue@cite[cce-queue].
@note{Since its not
possible to repeat 100000 @racket[tail] (or @racket[dequeue]) operations on 1000 or 10000 element
imperative queue, we do not have running time for @scheme[tail] operation for 
imperative queues for these sizes.}

@exact{
\medskip
\begin{tabular}{|c|c|c|c|c|}
\hline
Size & Operation & Bankers' & List & Imperative \\
\hline
\multirow{3}{*}{1000} & \RktSym{head} & 46 & 7 & N/A \\
\cline{2-5}
& \RktSym{tail} & 88 & 6 & N/A \\
\cline{2-5}
& \RktSym{enqueue} & 81 & 6478 & 161 \\
\hline
\multirow{3}{*}{10000} & \RktSym{head} & 46 & 7 & N/A \\
\cline{2-5}
& \RktSym{tail} & 91 & 8 & N/A \\
\cline{2-5}
& \RktSym{enqueue} & 84 & 48687 & 147 \\
\hline
\multirow{3}{*}{100000} & \RktSym{head} & 47 & 8 & 114 \\
\cline{2-5}
& \RktSym{tail} & 93 & 8 & 114 \\
\cline{2-5}
& \RktSym{enqueue} & 85 & 524257 & 171 \\
\hline
\multirow{3}{*}{1000000} & \RktSym{head} & 53 & 8 & 101 \\
\cline{2-5}
& \RktSym{tail} & 94 & 8 & 101 \\
\cline{2-5}
& \RktSym{enqueue} & 87 & $\infty$ & 152 \\
\hline
\end{tabular}}


@;{
@para{For 1000 elements}
@para{@scheme[head] : BQ : 46. Lists : 7.}
@para{@scheme[tail] : BQ : 88. Lists : 6.}
@para{@scheme[enqueue] : BQ : 81. Lists : 6478. IQ : 161.}
@para{For 10000 elements}
@para{@scheme[head] : BQ : 46. Lists : 7.}
@para{@scheme[tail] : BQ : 91. Lists : 8.}
@para{@scheme[enqueue] : BQ : 84. Lists : 48687. IQ : 147.}
@para{For 100000 elements}
@para{@scheme[head] : BQ : 47. Lists : 8.}
@para{@scheme[tail] : BQ : 93. Lists : 8. IQ : 114.}
@para{@scheme[enqueue] : BQ : 85. Lists : 524257. IQ : 172.}
@para{For 1000000 elements}
@para{@scheme[head] : BQ : 53. Lists : 8.}
@para{@scheme[tail] : BQ : 94. Lists : 8. IQ : 101.}
@para{@scheme[enqueue] : BQ : 87. Lists : Took too long to finish. IQ : 152.}
}

@subsection{Heap Performance}
The below table shows the performance of the 
@elemref["leftist heap"]{Leftist Heap}, compared with an
implementation based on sorted lists, and a simple imperative heap.

@;{
   @para{For 1000 elements}
@para{@scheme[find-min/max] : LH : 23. Lists : 6. IH : 28.}
@para{@scheme[delete-min/max] : LH : 3379. Lists : 8. IH : N/A.}
@para{@scheme[merge] : LH : 1451. Lists : 3921. IH : .}
@para{For 10000 elements}
@para{@scheme[find-min/max] : LH : 26. Lists : 7. IH : 31.}
@para{@scheme[delete-min/max] : LH : 4018. Lists : 8. IH : N/A.}
@para{@scheme[merge] : LH : 2109. Lists : 44482. IH : .}
@para{For 100000 elements}
@para{@scheme[find-min/max] : LH : 27. Lists : 7. IH : 32.}
@para{@scheme[delete-min/max] : LH : 4867. Lists : 9. IH : 2752.}
@para{@scheme[merge] : LH : 2655. Lists : 441794. IH : .}
@para{For 1000000 elements}
@para{@scheme[find-min/max] : LH : 29. Lists : 7. IH : 37.}
@para{@scheme[delete-min/max] : LH: 6142. Lists : 8. IH : 4386.}
@para{@scheme[merge] : LH : 3229. Lists : infny. IH : .}
}
@exact{
\medskip
\begin{tabular}{|c|c|c|c|c|}
\hline
Size & Operation & Leftist & List & Imperative \\
\hline
\multirow{3}{*}{1000} & \RktSym{insert} & 424 & 323874 & 855 \\
\cline{2-5}
& \RktSym{find} & 23 & 6 & 28 \\
\cline{2-5}
& \RktSym{delete} & 3379 & 8 & N/A \\
\cline{2-5}
@;& \RktSym{merge} & 1451 & 13583 & ? \\
\hline
\multirow{3}{*}{10000} & \RktSym{insert} & 457 & 409051 & 826 \\
\cline{2-5}
& \RktSym{find} & 26 & 7 & 31 \\
\cline{2-5}
& \RktSym{delete} & 4018 & 8 & N/A \\
\cline{2-5}
@;& \RktSym{merge} & 2109 & 161648 & ? \\
\hline
\multirow{3}{*}{100000} & \RktSym{insert} & 469 & 1087545 & 748 \\
\cline{2-5}
& \RktSym{find} & 27 & 7 & 32 \\
\cline{2-5}
& \RktSym{delete} & 4867 & 9 & 2752 \\
\cline{2-5}
@;& \RktSym{merge} & 2655 & $\infty$ & ? \\
\hline
\multirow{3}{*}{1000000} & \RktSym{insert} & 471 & $\infty$ & 717 \\
\cline{2-5}
& \RktSym{find} & 29 & 7 & 37 \\
\cline{2-5}
& \RktSym{delete} & 6142 & 8 & 4386 \\
\cline{2-5}
@;& \RktSym{merge} & 3229 & $\infty$ & ? \\
\hline
\end{tabular}}

@section{Experience with Typed Scheme}

This project involved writing 5300 lines of Typed Scheme code,
including 1300 lines of tests, almost all written by the first author,
who had little previous experience with Typed Scheme.  This allows us
to report on the experience of using Typed Scheme for a programmer
coming from other languages. 

@subsection{Benefits of Typed Scheme}
Several features of Typed Scheme makes programming in Typed Scheme 
quite enjoyable. First, the type error messages in Typed Scheme are very 
clear and easy 
to understand. The type checker highlights precise locations which are
responsible for type errors. This makes it very easy to debug the type errors. 

Second, Typed Scheme's syntax is very intuitive, using
      the infix operator 
@scheme[→] for the type of a function. The Kleene star @scheme[*] is 
used to indicate zero or more elements for rest arguments. @scheme[∀] is the 
type constructor used by the polymorphic functions, and so on.

Typed Scheme comes with a unit testing framework which makes it
simple to write tests, as in the below example: 

@schemeblock[(require typed/test-engine/scheme-tests)
             (require "bankers-queue.ss")           
             (check-expect (head (queue 4 5 2 3)) 4)           
             (check-expect (tail (queue 4 5 2 3)) 
                                 (queue 5 2 3))]

The @racket[check-expect] form takes the actual and expected value, and
compares them, printing a message at the end summarizing the results
of all tests.

The introductory and reference manuals of PLT Scheme in general and
Typed Scheme in particular are comprehensive and quite easy to follow
and understand.

@subsection{Disadvantages of Typed Scheme} 
Even though overall
experience with Typed Scheme was positive, there are negative aspects
to programming in Typed Scheme. 


Most significantly for this work, Typed Scheme does not support
 polymorphic non-uniform recursive datatype definitions, which are
 used extensively by @citet[oka].  Because of this limitation, many
 definitions had to be first converted to uniform recursive datatypes
 before being implemented. For instance, the following definition of
 @racket[Seq] structure is not allowed by Typed Scheme.

 @schemeblock[(define-struct: (A) Seq 
                ([elem : A] [recur : (Seq (Pair A A))]))]
The definition must be converted not to use polymorphic
recursion, as follows:
      
      @schemeblock[
                 (define-struct: (A) Elem ([elem : A]))                 
                 (define-struct: (A) Pare 
                   ([pair : (Pair (EP A) (EP A))]))                 
                 (define-type (EP A) (U (Elem A) (Pare A)))                       
                 (define-struct: (A) Seq
                   ([elem  : (EP A)] [recur : (Seq A)]))]
Unfortunately, this translation introduces the possibility of illegal
states that the typechecker is unable to rule out.  We hope to support
polymorphic recursion in a future version of Typed Scheme.


It is currently not
possible to correctly type Scheme functions such as @racket[foldr] and
@racket[foldl] because of the limitations of Typed Scheme's handling
of variable-arity functions@cite[stf-esop].

Typed Scheme's use of local type inference also leads to potential
errors, especially in the presence of precise types for Scheme's
numeric hierarchy. For example,
Typed Scheme distinguishes integers from positive integers, leading to
a type error in the following expression:
@schemeblock[(vector-append (vector -1 2) (vector 1 2))]
 since the first vector contains integers, and the second positive
 integers, neither of which is a subtype of the other. Working around
 this requires manual annotation to ensure that both vectors have
 element type @racket[Integer].

Although PLT Scheme supports extension of the behavior of
primitive operations such as printing and equality on user-defined
data types, Typed Scheme currently does not support this.  Thus, it is
not possible to compare any of our data structures accurately using
@racket[equal?], and they are printed opaquely, as seen in the
examples in @secref["fds"].


@;{item{Even though Typed Scheme test engine is pretty good, there are couple 
        of draw backs in it. For example,
        @schememod[typed/scheme
                   (require "bankers-queue.ss")
                   (require typed/test-engine/scheme-tests)
                   (check-expect (tail (queue 1 2 3)) 
                                 (queue 2 3))]
        @para{The above test fails saying that the two given queues are 
              different even though the contents of the queues are same. In 
              order to get around with this limitation of the test engine and
              test the programs, for each data structure, we had to implement a
              function which converts the data structure into a list. For
              example, all queue data structures have the function 
              @scheme[queue->list].}}}

Typed Scheme allows programmers to name arbitrary type expressions
with the @racket[define-type] form.  However, the type printer does
not take into account definitions of polymorphic type aliases when
printing types, leading to the internal implementations of some types
being exposed, as in @secref["catenable"]. This makes
the printing of types confusingly long and difficult to understand,
especially in error messages.

@section{Comparison with Other Implementations}
Our implementations of the presented data structures are very faithful to the original
implementations of Purely Functional Data Structures by @citet[oka]
and VLists and others by @citet[bagwell-trie bagwell-lists]. 
In some cases, we provide additional operations, such as for
converting queues to lists.
@(evaluate '(require "bankers-queue.ss"))
@interaction[#:eval evaluate
                 (queue->list (queue 1 2 3 4 5 6 -4))]
We also added an to delete elements from the 
      Red-Black Trees, 
      which was absent in the original implementation.
Finally, the heap constructor functions take an explicit comparison function of the 
      type @scheme[(A A → Boolean)] as their first argument followed by the 
      elements for the data structure, whereas the original
      presentation uses ML functors for this purpose.
With the above exceptions, the implementation is 
structurally similar the original work.

We know of no existing comprehensive library of functional data
structures for Scheme.  PLT Scheme's existing collection of user-provided
libraries, PLaneT@cite[planet], contains an implementation of Random
Access Lists@cite[dvh-ra], as well as a collection of several
functional data structures@cite[galore].  

VLists and several other functional data structures have recently been
popularized by Clojure@cite[clojure], a new dialect of Lisp for the
Java Virtual Machine.

@section{Conclusion}

Efficient and productive functional programming requires efficient and
expressive functional data structures.  In this paper, we present a
comprehensive library of functional data structures, implemented and
available in Typed Scheme. We hope that this enables programmers to
write functional programs, and inspires library writers to use
functional designs and to produce new libraries to enable functional
programming.  

@gen-bib[]
