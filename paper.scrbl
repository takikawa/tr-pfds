#lang scribble/sigplan @nocopyright
@(require (except-in scribble/manual cite) scriblib/autobib
          scribble/core scribble/eval scriblib/footnote
          "bib.rkt" "utils.rkt" scribble/decode
          scribble/latex-properties)
@title{Functional Data Structures for Typed Racket}

@(authorinfo "Hari Prashanth K R"
             "Northeastern University"
             "krhari@ccs.neu.edu")

@(authorinfo "Sam Tobin-Hochstadt"             
             "Northeastern University"
             "samth@ccs.neu.edu")

@exact{
\renewcommand{\SConferenceInfo}[2]{}
\renewcommand{\SCopyrightYear}[1]{}
\renewcommand{\SCopyrightData}[1]{}
}

@abstract{
Scheme provides excellent language support for programming in a
functional style, but little in the way of library support.  In this
paper, we present a comprehensive library of functional data
structures, drawing from several sources.  We have implemented the
library in Typed Racket, a typed variant of Racket, allowing us to
maintain the type invariants of the original definitions.}

@include-section["intro.scrbl"]

@include-section["fds.scrbl"]

@;(require scribble/core)
@section[#:tag "benchmarks" #:style (style #f (list (tex-addition "./extra.tex")))]{Benchmarks}
To demonstrate the practical usefulness of purely functional data
structures, we provide microbenchmarks of a selected set of data
structures, compared with both simple implementations based on lists,
and imperative implementations. The list based version is implemented 
in Typed Racket and imperative version is implemented in Racket.
The benchmaking was done on a 2.1 GHz Intel Core 2 Duo (Linux) 
machine and we used Racket version 5.0.0.9 for benchmarking. 

In the tables below, all times are CPU time as reported by Racket,
including garbage collection time. The times mentioned are in milli 
seconds and they are time taken for performing each
operation 100000 times, averaged over 10 runs.
@note{The constructor functions @racket[queue], @racket[heap] and 
      @racket[list] were repeated only 100 times.}
@subsection{Queue Performance}

The table in figure @exact{\ref{fig:queue}} shows the performance of the 
@elemref["physicist queue"]{Physicist's Queue}, 
@elemref["banker's queue"]{Banker's Queue},
@elemref["real-time queue"]{Real-Time Queue} and
@elemref["bootstrapped queue"]{Bootstrapped Queue} compared with an
implementation based on lists, and an imperative queue@cite[cce-queue].
@note{Since 100000 (successive) @racket[tail] (or @racket[dequeue]) operations can not be 
performed on 1000 element queue, we do not have running time for @scheme[tail] operation for 
for these sizes.}

@exact{
\begin{figure*}
\begin{center}
\begin{tabular}{|c|c|c|c|c|c|c|c|}
\hline
Size & Operation & Physicist's & Banker's & Real-Time & Bootstrapped & List & Imperative \\
\hline
\multirow{3}{*}{1000} & \RktSym{queue} & 16 & 72 & 137 & 20 & 6 & 83 \\
\cline{2-8}
& \RktSym{head} & 9 & 14 & 30 & 10 & 6 & 54 \\
\cline{2-8}
@;& \RktSym{tail}@(superscript "3") & N/A & N/A & N/A & N/A & N/A & N/A \\
@;\cline{2-8}
& \RktSym{enqueue} & 10 & 127 & 176 & 22 & 256450 & 73 \\
\hline
\multirow{3}{*}{10000} & \RktSym{queue} & 232 & 887 & 1576 & 227 & 61 & 746 \\
\cline{2-8}
& \RktSym{head} & 8 & 17 & 32 & 2 & 7 & 56 \\
\cline{2-8}
@;& \RktSym{tail}@(superscript "3") & N/A & N/A & N/A & N/A & N/A & N/A \\
@;\cline{2-8}
& \RktSym{enqueue} & 11 & 132 & 172 & 18 & 314710 & 75 \\
\hline
\multirow{3}{*}{100000} & \RktSym{queue} & 3410 & 13192 & 20332 & 2276 & 860 & 11647 \\
\cline{2-8}
& \RktSym{head} & 9 & 16 & 30 & 6 & 8 & 51 \\
\cline{2-8}
& \RktSym{tail} & 412 & 312 & 147 & 20 & 7 & 57 \\
\cline{2-8}
& \RktSym{enqueue} & 12 & 72 & 224 & 18 & 1289370 & 84 \\
\hline
\multirow{3}{*}{1000000} & \RktSym{queue} & 65590 & 182858 & 294310 & 53032 & 31480 & 101383 \\
\cline{2-8}
& \RktSym{head} & 8 & 17 & 30 & 4  & 7 & 56 \\
\cline{2-8}
& \RktSym{tail} & 243 & 1534 & 1078 & 20 & 8 & 61 \\
\cline{2-8}
& \RktSym{enqueue} & 30 & 897 & 1218 & 20 & $\infty$ & 68 \\
\hline
\end{tabular}
\caption{Queue Performance}
\label{fig:queue}
\end{center}
\end{figure*}
}



@subsection{Heap Performance}
The table in figure @exact{\ref{fig:heap}} shows the performance of the 
@elemref["leftist heap"]{Leftist Heap},
@elemref["pairing heap"]{Pairing Heap},
@elemref["binomial heap"]{Binomial Heap} and
@elemref["bootstraped heap"]{Bootstrapped Heap}, compared with an
implementation based on sorted lists, and a simple imperative heap.

@exact{
\begin{figure*}
\begin{center}
\begin{tabular}{|c|c|c|c|c|c|c|c|}
\hline
Size & Operation & Binomial & Leftist & Pairing & Bootstrapped & List & Imperative \\
\hline
\multirow{3}{*}{1000} & \RktSym{heap} & 45 & 192 & 30 & 122 & 9 & 306 \\
\cline{2-8}
& \RktSym{insert} & 36 & 372 & 24 & 218 & 323874 & 623 \\
\cline{2-8}
& \RktSym{find} & 64 & 7 & 6 & 4 & 6 & 8 \\
\cline{2-8}
@;& \RktSym{delete}@(superscript "3") & N/A & N/A & N/A & N/A & N/A \\
@;\cline{2-8}
@;& \RktSym{merge} & 1451 & 13583 & ? \\
\hline
\multirow{3}{*}{10000} & \RktSym{heap} & 422 & 2730 & 340 & 1283 & 76 & 4897 \\
\cline{2-8}
& \RktSym{insert} & 34 & 358 & 28 & 224 & 409051 & 628 \\
\cline{2-8}
& \RktSym{find} & 52 & 9 & 8 & 10 & 7 & 7 \\
\cline{2-8}
@;& \RktSym{delete}@(superscript "3") & N/A & N/A & N/A & N/A & N/A & N\\
@;\cline{2-8}
@;& \RktSym{merge} & 2109 & 161648 & ? \\
\hline
\multirow{3}{*}{100000} & \RktSym{heap} & 6310 & 40580 & 4863 & 24418 & 1010 & 69353 \\
\cline{2-8}
& \RktSym{insert} & 33 & 434 & 30 & 198 & 1087545 & 631 \\
\cline{2-8}
& \RktSym{find} & 63 & 8 & 8 & 10 & 7 & 9 \\
\cline{2-8}
& \RktSym{delete} & 986 & 528 & 462 & 1946 & 7 & 439 \\
\cline{2-8}
@;& \RktSym{merge} & 2655 & $\infty$ & ? \\
\hline
\multirow{3}{*}{1000000} & \RktSym{heap} & 109380 & 471588 & 82840 & 293788 & 11140 & 858661 \\
\cline{2-8}
& \RktSym{insert} & 32 & 438 & 28 & 218 & $\infty$ & 637 \\
\cline{2-8}
& \RktSym{find} & 76 & 9 & 6 & 8 & 7 & 7 \\
\cline{2-8}
& \RktSym{delete} & 1488 & 976 & 1489 & 3063 & 8 & 812 \\
\cline{2-8}
@;& \RktSym{merge} & 3229 & $\infty$ & ? \\
\hline
\end{tabular}
\end{center}
\caption{Heap Performance}
\label{fig:heap}
\end{figure*}
}


@subsection{List Performance}
The below table shows the performance of the 
@elemref["skew-bin-random-access list"]{Skew Binary Random Access List} and
@elemref["vlist"]{VList} compared with in built lists.

@exact{
\medskip
\begin{tabular}{|c|c|c|c|c|}
\hline
Size & Operation & RAList & VList & List \\
\hline
\multirow{3}{*}{1000} & \RktSym{list} & 24 & 51 & 2 \\
\cline{2-5}
& \RktSym{list-ref} & 77 & 86 & 240 \\
\cline{2-5}
& \RktSym{first} & 2 & 9 & 1 \\
\cline{2-5}
& \RktSym{rest} & 20 & 48 & 1 \\
\cline{2-5}
& \RktSym{last} & 178 & 40 & 520 \\
\cline{2-5}
\hline
\multirow{3}{*}{10000} & \RktSym{list} & 263 & 476 & 40 \\
\cline{2-5}
& \RktSym{list-ref} & 98 & 110 & 2538 \\
\cline{2-5}
& \RktSym{first} & 2 & 9 & 1 \\
\cline{2-5}
& \RktSym{rest} & 9 & 28 & 1 \\
\cline{2-5}
& \RktSym{last} & 200 & 52 & 5414 \\
\cline{2-5}
\hline
\multirow{3}{*}{100000} & \RktSym{list} & 2890 & 9796 & 513 \\
\cline{2-5}
& \RktSym{list-ref} & 124 & 131 & 33187 \\
\cline{2-5}
& \RktSym{first} & 3 & 10 & 1 \\
\cline{2-5}
& \RktSym{rest} & 18 & 40 & 1 \\
\cline{2-5}
& \RktSym{last} & 204 & 58 & 77217 \\
\cline{2-5}
\hline
\multirow{3}{*}{1000000} & \RktSym{list} & 104410 & 147510 & 4860 \\
\cline{2-5}
& \RktSym{list-ref} & 172 & 178 & 380960 \\
\cline{2-5}
& \RktSym{first} & 2 & 10 & 1 \\
\cline{2-5}
& \RktSym{rest} & 20 & 42 & 1 \\
\cline{2-5}
& \RktSym{last} & 209 & 67 & 755520 \\
\cline{2-5}
\hline
\end{tabular}}

@section{Experience with Typed Racket}

This project involved writing 5300 lines of Typed Racket code,
including 1300 lines of tests, almost all written by the first author,
who had little previous experience with Typed Racket.  This allows us
to report on the experience of using Typed Racket for a programmer
coming from other languages. 

@subsection{Benefits of Typed Racket}
Several features of Typed Racket makes programming in Typed Racket 
quite enjoyable. First, the type error messages in Typed Racket are very 
clear and easy 
to understand. The type checker highlights precise locations which are
responsible for type errors. This makes it very easy to debug the type errors. 

Second, Typed Racket's syntax is very intuitive, using
      the infix operator 
@scheme[→] for the type of a function. The Kleene star @scheme[*] is 
used to indicate zero or more elements for rest arguments. @scheme[∀] is the 
type constructor used by the polymorphic functions, and so on.

Typed Racket comes with a unit testing framework which makes it
simple to write tests, as in the below example: 

@schemeblock[(require typed/test-engine/scheme-tests)
             (require "bankers-queue.ss")           
             (check-expect (head (queue 4 5 2 3)) 4)           
             (check-expect (tail (queue 4 5 2 3)) 
                                 (queue 5 2 3))]

The @racket[check-expect] form takes the actual and expected value, and
compares them, printing a message at the end summarizing the results
of all tests.

The introductory and reference manuals of Racket in general and
Typed Racket in particular are comprehensive and quite easy to follow
and understand.

@subsection{Disadvantages of Typed Racket} 
Even though overall
experience with Typed Racket was positive, there are negative aspects
to programming in Typed Racket. 


Most significantly for this work, Typed Racket does not support
 polymorphic non-uniform recursive datatype definitions, which are
 used extensively by @citet[oka].  Because of this limitation, many
 definitions had to be first converted to uniform recursive datatypes
 before being implemented. For instance, the following definition of
 @racket[Seq] structure is not allowed by Typed Racket.

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
polymorphic recursion in a future version of Typed Racket.


It is currently not
possible to correctly type Scheme functions such as @racket[foldr] and
@racket[foldl] because of the limitations of Typed Racket's handling
of variable-arity functions@cite[stf-esop].

Typed Racket's use of local type inference also leads to potential
errors, especially in the presence of precise types for Scheme's
numeric hierarchy. For example,
Typed Racket distinguishes integers from positive integers, leading to
a type error in the following expression:
@schemeblock[(vector-append (vector -1 2) (vector 1 2))]
 since the first vector contains integers, and the second positive
 integers, neither of which is a subtype of the other. Working around
 this requires manual annotation to ensure that both vectors have
 element type @racket[Integer].

Although Racket supports extension of the behavior of
primitive operations such as printing and equality on user-defined
data types, Typed Racket currently does not support this.  Thus, it is
not possible to compare any of our data structures accurately using
@racket[equal?], and they are printed opaquely, as seen in the
examples in @secref["fds"].


@;{item{Even though Typed Racket test engine is pretty good, there are couple 
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

Typed Racket allows programmers to name arbitrary type expressions
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
structures for Scheme.  Racket's existing collection of user-provided
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
available in Typed Racket. We hope that this enables programmers to
write functional programs, and inspires library writers to use
functional designs and to produce new libraries to enable functional
programming.  

@subsection[#:style 'unnumbered]{Acknowledgments}

Thanks to Matthias Felleisen for his support of this work, and to
Vincent St-Amour and Carl Eastlund for valuable feedback.  
Sam Tobin-Hochstadt is supported by a grant from the Mozilla Foundation.

@gen-bib[]
