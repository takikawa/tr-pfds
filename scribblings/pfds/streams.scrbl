#lang scribble/manual

@(require "helper.rkt")
@(require (for-label data/stream))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require data/stream))

@title[#:tag "streams"]{Streams}

@defmodule[data/stream]

Streams are nothing but lazy lists. They are similar to ordinary
lists and they provide the same functionality as that of lists. The 
difference between Streams and lists is that they are lazy in nature and 
each cell of a Stream is suspended and is forced only when required. Streams 
have been used in some of the below mentioned data structures. Since
each suspention comes with a little overhead, Streams should be used
only when there is a good enough reason to do so.

@defform[(Stream A)]{A stream of type @racket[A].}

@defproc[(stream [a A] ...) (Stream A)]{
Function stream creates a Stream with the given inputs. 

@examples[#:eval evaluate

(stream 1 2 3 4 5 6)
]

In the above example, the stream obtained will be similar to lists but will
lazy in nature. It will have 1 as its first element.}

@defthing[empty-stream (Stream Nothing)]{
An empty stream.}

@defproc[(empty-stream? [strm (Stream A)]) Boolean]{ 
Function @scheme[empty-stream?] takes a Stream checks if the given 
stream is empty. 
@examples[#:eval evaluate

(empty-stream? (stream 1 2 3 4 5 6))
(empty-stream? empty-stream)

]}


@defproc[(stream-cons [a A] [strm (Stream A)]) (Stream A)]{
Function @scheme[stream-cons] takes an element and a stream and adds 
the given element to the given stream. 
@examples[#:eval evaluate

(stream-cons 10 (stream 1 2 3 4 5 6))
]

In the above example, @scheme[(stream-cons 10 (stream 1 2 3 4 5 6))] 
returns the stream @scheme[(stream 10 1 2 3 4 5 6)].}


@defproc[(stream-car [strm (Stream A)]) A]{
Function @scheme[stream-car] takes a stream and returns the first element
of the given stream. If the given stream is empty, then it throws an error.

@examples[#:eval evaluate

(stream-car (stream 1 2 3 4 5 6))
(stream-car empty-stream)
]}


@defproc[(stream-cdr [strm (Stream A)]) (Stream A)]{
Function @scheme[stream-cdr] takes a stream and returns the same stream 
but without the first element of the given stream. 
@examples[#:eval evaluate

(stream-cdr (stream 1 2 3 4 5 6))
(stream-cdr empty-stream)
]

In the above example, @scheme[(stream-cdr strm)] returns 
@scheme[(stream 2 3 4 5 6)].}


@defproc[(stream-append [strm1 (Stream A)] [strm2 (Stream A)]) (Stream A)]{
Function @scheme[stream-append] takes two streams and creates a new 
stream by appending the second stream to the end of first stream. 

@examples[#:eval evaluate

(define strm1 (stream 1 2 3 4 5 6))

(define strm2 (stream 51 32 42))

(stream-append strm1 strm2)
]

In the above example, @scheme[(stream-append strm1 strm2)] returns the stream,
@scheme[(stream 1 2 3 4 5 6 51 32 42)].}


@defproc[(stream-reverse [strm (Stream A)]) (Stream A)]{
Function @scheme[stream-reverse] takes a streams and gives a reversed
stream back. 
@examples[#:eval evaluate

(stream-reverse (stream 1 2 3 4 5 6))
]

In the above example, @scheme[(stream-reverse (stream 1 2 3 4 5 6))] returns
@scheme[(stream 6 5 4 3 2 1)].}


@defproc[(stream->list [strm (Stream A)]) (Listof A)]{
Function @scheme[stream->list] takes a stream and returns a list
of elements which are in the same order as in the stream. 
@examples[#:eval evaluate

(stream->list (stream 1 2 3 4 5 6))
(stream->list empty-stream)
]}


@defproc[(drop [num Integer] [strm (Stream A)]) (Stream A)]{
Function @scheme[drop] takes an integer(say n) and a stream and creates a
new stream which is same as the given stream but without the first n elements
of the input stream. If the number of elements in the given stream is less 
than n, then @scheme[drop] throws an error.

@examples[#:eval evaluate

(drop 3 (stream 1 2 3 4 5 6))
(drop 10 (stream 1 2 3 4 5 6))
]

In the above example, @scheme[(drop 3 (stream 1 2 3 4 5 6))] returns 
@scheme[(stream 4 5 6)].}



@defproc[(take [num Integer] [strm (Stream A)]) (Stream A)]{
Function @scheme[take] takes an integer(say n) and a stream and creates a
new stream with the first n elements of the input stream. If the number of 
elements in the given stream is less than n, then @scheme[take] throws an 
error. 
@margin-note{@scheme[(take 5 (stream 1))] does not
throw any error because of its lazy nature. @scheme[take] returns a suspension
rather than finishing the whole computation.}
@examples[#:eval evaluate

(take 3 (stream 1 2 3 4 5 6))
(take 5 (stream 1))
]

In the above example, @scheme[(take 3 (stream 1 2 3 4 5 6))] returns
@scheme[(stream 1 2 3)].}

@(close-eval evaluate)
