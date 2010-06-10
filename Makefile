all: paper.scrbl
	raco make paper.scrbl
	scribble --pdf paper.scrbl
