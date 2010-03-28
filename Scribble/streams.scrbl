#lang scribble/manual

@title{Streams}

Streams are nothing but lazy lists. They are similar to ordinary
lists and they provide the same functions that lists provide. The 
difference between Streams and lists is that they are in nature and 
each cell of a Stream is suspended is forced only when required. Streams 
have been used in some of the below mentioned data structures. Since
each suspention comes with a little overhead, Streams should be used
only when there is a good enough reason to do so.

@section{Stream Constructor and Operations}

@subsection{stream}
The function stream creates a Stream with the given inputs. For 
example,
@schememod[
typed-scheme
(require "stream.ss")

(stream 1 2 3 4 5 6)
]

In the above example, the stream obtained will be similar to lists but will
lazy in nature. 1 as its head element, 2 as the head of its tail and so on.

@subsection{empty}
A empty stream

@subsection{empty?}
The function @scheme[empty?] takes a Stream checks if the given stream is 
empty. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(define mt empty)
]

In the above example, @scheme[(empty? strm)] returns @scheme[#f] and 
@scheme[(empty? mt)] returns @scheme[#t].


@subsection{stream-cons}
The function @scheme[stream-cons] takes an element and a stream and returns 
a stream with its first element as the given element. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(stream-cons 10 strm)
]

In the above example, @scheme[(stream-cons 10 strm)] returns a stream which 
has 10 as its first element.


@subsection{stream-car}
The function @scheme[stream-car] takes a stream and returns the first element
of the given stream. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(stream-car strm)
]

In the above example, @scheme[(stream-car strm)] returns 1, the first element
of the the given stream.


@subsection{stream-cdr}
The function @scheme[stream-cdr] takes a stream and returns a stream without 
the first element of the given stream. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(stream-cdr strm)
]

In the above example, @scheme[(stream-cdr strm)] returns a stream, without 1, 
the first element of the the given stream.


@subsection{stream-append}
The function @scheme[stream-append] takes two streams and creates a new 
stream in which the second stream is appended to the end of first stream. 
For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm1 (stream 1 2 3 4 5 6))

(define strm2 (stream 51 32 42))

(stream-append strm1 strm2)
]

In the above example, @scheme[(stream-append strm1 strm2)] returns the stream,
@scheme[(stream 1 2 3 4 5 6 51 32 42)].


@subsection{stream-reverse}
The function @scheme[stream-reverse] takes a streams and gives a reversed
stream back. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(stream-reverse strm)
]

In the above example, @scheme[(stream-reverse strm)] returns the stream,
@scheme[(stream 6 5 4 3 2 1)].


@subsection{stream->list}
The function @scheme[stream->list] takes a stream and gives back a list
of elements which are in the same order as in the stream. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(stream->list strm)
]

In the above example, @scheme[(stream->list strm)] returns the list,
@scheme[(1 2 3 4 5 6)].


@subsection{drop}
The function @scheme[drop] takes an integer(say n) and a stream and creates a
new stream which is same as the given stream but without the first n elements
of the input stream. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(drop 3 strm)
]

In the above example, @scheme[(drop 3 strm)] returns the stream,
@scheme[(stream 4 5 6)].



@subsection{take}
The function @scheme[take] takes an integer(say n) and a stream and creates a
new stream with the first n elements of the input stream. For example,
@schememod[
typed-scheme
(require "stream.ss")

(define strm (stream 1 2 3 4 5 6))

(take 3 strm)
]

In the above example, @scheme[(take 3 strm)] returns the stream,
@scheme[(stream 1 2 3)].