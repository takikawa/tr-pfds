#lang scribble/manual

@title{Deques}

Double ended queues (or deque) are queues where elements can be added or
removed from either end. The deque data structures provided by this library
implement and provide the following operations: deque, empty?, enqueue,
enqueue-front, head, tail, last, init and deque->list.

@local-table-of-contents[]
@include-section{bankers-deque.scrbl}
@include-section{implicitdeque.scrbl}
@include-section{realtimedeque.scrbl}
