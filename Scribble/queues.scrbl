#lang scribble/manual

@title{Queues}
Following queue structures implement and provide the functions 
empty?, enqueue, head, tail, queue and queue->list. All the queue 
structures are polymorphic and have the type (Queue A).

@local-table-of-contents[]
@include-section{queue.scrbl}
@include-section{physicists-queue.scrbl}
@include-section{implicitqueue.scrbl}
@include-section{bootstrapedqueue.scrbl}
@include-section{realtimequeue.scrbl}
@include-section{hood-melville-queue.scrbl}