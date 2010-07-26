paper.pdf: paper.scrbl bib.rkt intro.scrbl ts.scrbl fds.scrbl utils.rkt
	raco make paper.scrbl
	scribble --latex paper.scrbl
	pdflatex paper.tex
	pdflatex paper.tex