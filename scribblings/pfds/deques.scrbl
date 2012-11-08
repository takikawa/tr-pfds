#lang scribble/manual

@title{Deques}
Following Deque data structures implement and provide the functions
deque, empty?, enqueue, enqueue-front, head, tail, last, init and deque->list.
All the deque structures are polymorphic.

@local-table-of-contents[]
@include-section{bankers-deque.scrbl}
@include-section{implicitdeque.scrbl}
@include-section{realtimedeque.scrbl}