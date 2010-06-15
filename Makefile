paper.pdf: paper.scrbl bib.rkt intro.scrbl ts.scrbl fds.scrbl
	raco make paper.scrbl
	scribble --pdf paper.scrbl
