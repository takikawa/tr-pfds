#lang scribble/sigplan
@(require (except-in scribble/manual cite) scriblib/autobib
          scribble/core scribble/eval
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
All the below mentioned times are CPU times required to obtain the result. 
It includes the time spent on garbage collection and all the times are in 
milliseconds. The results are average of 10 runs and in 
each run the operation is performed 100000 times. 
@subsection{Queue Performance}
Here is the comparison of the time taken by the Banker's Queue (referred 
as BQ) with the time taken by lists to perform the queue 
operations and imperative Queue (referred as IQ) implementation. Since its not
possible to repeat 100000 tail (or dequeue) operations on 1000 or 10000 element
imperative queue, we do not have running time for @scheme[tail] operation for 
imperative Queues in first two cases.

@exact{
\medskip
\begin{tabular}{|c|c|c|c|c|}
\hline
Size & \mbox{} & Bankers' & List & Imperative \\
\hline
\multirow{3}{*}{1000} & \RktSym{head} & 46 & 7 & ? \\
\cline{2-5}
& \RktSym{tail} & 88 & 6 & N/A \\
\cline{2-5}
& \RktSym{enqueue} & 81 & 6478 & 161 \\
\hline
\multirow{3}{*}{10000} & \RktSym{head} & 46 & 7 & ? \\
\cline{2-5}
& \RktSym{tail} & 91 & 8 & N/A \\
\cline{2-5}
& \RktSym{enqueue} & 84 & 48687 & 147 \\
\hline
\multirow{3}{*}{100000} & \RktSym{head} & 47 & 8 & ? \\
\cline{2-5}
& \RktSym{tail} & 93 & 8 & 114 \\
\cline{2-5}
& \RktSym{enqueue} & 85 & 524257 & 171 \\
\hline
\multirow{3}{*}{1000000} & \RktSym{head} & 53 & 8 & ? \\
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
Following is the time taken by the Leftist Heap to perform some of its 
operations. 
@para{For 1000 elements}
@para{@scheme[find-min/max] : 23.}
@para{@scheme[delete-min/max] : 31.}
@para{@scheme[merge] : 1451.}
@para{For 10000 elements}
@para{@scheme[find-min/max] : 26.}
@para{@scheme[delete-min/max] : 4018.}
@para{@scheme[merge] : 2109.}
@para{For 100000 elements}
@para{@scheme[find-min/max] : 27.}
@para{@scheme[delete-min/max] : 4867.}
@para{@scheme[merge] : 2655.}
@para{For 1000000 elements}
@para{@scheme[find-min/max] : 27.}
@para{@scheme[delete-min/max] : 6142.}
@para{@scheme[merge] : 3229.}

@section{Experience with Typed Scheme}
@subsection{Benefits of Typed Scheme}
Several nice features of Typed Scheme together made programming in Typed Scheme 
quiet enjoyable. Firstly, the type error messages in Typed Scheme are very 
clear and easy 
to understand. Exact locations in the code are blamed by the type checker in 
case of type errors. This makes it very easy to debug the type errors. 
@para{Typed Scheme has a very intuitive syntax. 
      For example, the infix operator 
@scheme[→] which is used to write the type of a function. To the left of 
@scheme[→] goes the types of inputs to the function and to its right is the
type of the function's output. Kleene star or Kleene operator, @scheme[*] is 
used to indicate zero or more elements. @scheme[All] or @scheme[∀] is the 
type constructor used by the polymorphic functions etc.} 
@para{Typed Scheme comes with a pretty good test engine which makes it 
      pretty easy to test the code.}

@;(evaluate '(require typed/test-engine/scheme-tests))
@;(evaluate '(require "bankers-queue1.ss"))
@schememod[typed/scheme
           (require typed/test-engine/scheme-tests)
           (require "bankers-queue.ss")
           
           (check-expect (head (queue 4 5 2 3)) 4)
           
           (check-expect (tail (queue 4 5 2 3)) 
                               (queue 5 2 3))]
Above examples illustrate how the tests are written.

@para{Documentation and help manual of PLT Scheme
      in general and Typed Scheme in particular is very well 
      documented and quiet easy to follow and understand.}

@subsection{Disadvantages of Typed Scheme}
Even though overall experience with Typed Scheme was nice, there were
things in Typed Scheme that could bother a programmer.
For instance, it is currently not possible to correctly 
implement Scheme functions such as foldr and foldl because of the 
limitations imposed by Typed Scheme's type system on
variable-arity functions.
@para{The Typed Scheme's type system does not allow polymorphic non-uniform 
      recursive 
      datatype definitions. Because of this limitation, many definitions had
      to be first converted to uniform recursive datatypes before being 
      implemented. For instance, the following definition of Seq 
      structure @cite[oka] is not possible in Typed Scheme.}
      @schemeblock[(define-struct: (A) Seq 
                     ([elem : A] [recur : (Seq (Pair A A))]))
                                                ]
      @para{It has to be converted to not have such a polymorphic recursion 
      before one could continue. Following definition is the converted 
      version of the above definition}
      
      @schemeblock[
                 (define-struct: (A) Elem ([elem : A]))                 
                 (define-struct: (A) Pare 
                   ([pair : (Pair (EP A) (EP A))]))                 
                 (define-type-alias (EP A) 
                   (U (Elem A) (Pare A)))                       
                 (define-struct: (A) Seq
                   ([elem  : (EP A)] [recur : (Seq A)]))]

@para{Typed Scheme treats type @scheme[Int] and 
@scheme[Exact-Positive-Integer] to be different in some 
cases. For example,}
@schemeblock[(vector-append (vector -1 2) (vector 1 2))]
@para{results in the following error}
@para{@schemeerror{Type Checker: Polymorphic function vector-append 
                   could not be applied to arguments:}}
@para{@schemeerror{Domain: (Vectorof a) *}}
@para{@schemeerror{Arguments: (Vectorof Int) (Vectorof 
                   Exact-Positive-Integer)}}
@para{This behavior was quiet unexpected.}
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
@para{Whenever a union of polymorphic types is to be given a alias, 
      Typed Scheme 
      allows the programmer to do so by providing the function 
      @italic{define-type-alias}. But when errors are thrown, or the alias is
      to be displayed, Typed Scheme displays the union of original two types
      instead of displaying the alias name. This made the types confusingly 
      long many times. For example,}
@;(evaluate '(require typed/scheme))
@schemeblock[
(define-struct: (A) Type1 ([elem : A]))           
(define-struct: Mt ())  
(define-type-alias (Union A) 
   (U (Type1 A) Mt))
(: id : (∀ (A) (A Int → (Union A))))
(define (id elem int)
  (if (> int 5) (make-Type1 elem) (make-Mt)))]

@(evaluate '(require typed/scheme))
@(evaluate '(require "test1.ss"))
@interaction[#:eval evaluate
                 (id 5 1)]

@section{Comparison with Other Implementations}
The implementation of the data structures are very faithful to the original
implementations of Purely Functional Data Structures by @citet[oka]
and VLists and others by  @citet[bagwell-trie bagwell-lists]. 
@para{We added more functions to the data structures to make
them much more useful. For example, to each data structure we added a function
to convert the data structure into a list.}
@(evaluate '(require "bankers-queue.ss"))
@interaction[#:eval evaluate
                 (queue->list (queue 1 2 3 4 5 6 -4))]
@para{We added function to delete elements from the 
      @italic{Red-Black Trees}
      which was missing in the original implementation}
@para{All the heap constructor functions take a comparison function of the 
      type @scheme[(A A → Boolean)] as their first argument followed by the 
      elements for the data structure. This implementation of this feature 
      is slightly different in the original work.}
Except for these changes/additions, the implementation is 
structurally similar the original work.


@section{Conclusion}

Efficient and productive functional programming requires efficient and
expressive functional data structures.  In this paper, we present a
comprehensive library of functional data structures, implemented and
available in Typed Scheme. We hope that this enables programmers to
write functional programs, and inspires library writers to use
functional designs and to produce new libraries to enable functional
programming.  

@gen-bib[]
