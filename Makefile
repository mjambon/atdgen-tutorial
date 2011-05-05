.PHONY: all demo pdf txt html clean
all: demo pdf txt html

demo:
	cd hello && ./demo.sh
	cd pretty-json && ./demo.sh
	cd inspect-biniou && ./demo.sh
	cd validate && ./demo.sh
	cd modularity && ./demo.sh

pdf: atdgen-tutorial.pdf
txt: atdgen-tutorial.txt
html: atdgen-tutorial.html

TEXFILES = atdgen-tutorial.tex atdgen-tutorial-body.tex

atdgen-tutorial.tex: atdgen-tutorial.mlx
	OCAMLPATH=../..:$$OCAMLPATH \
		camlmix atdgen-tutorial.mlx -o atdgen-tutorial.tex

atdgen-tutorial-body.tex: macros.ml atdgen-tutorial-body.mlx
	OCAMLPATH=../..:$$OCAMLPATH \
		camlmix atdgen-tutorial-body.mlx -o atdgen-tutorial-body.tex

atdgen-tutorial.txt: $(TEXFILES)
	rm -f *.aux
	hevea -fix -text atdgen-tutorial
	iconv -f ISO_8859-1 -t UTF-8 < atdgen-tutorial.txt > ../README

atdgen-tutorial.html: $(TEXFILES)
	rm -f *.aux
	hevea -fix atdgen-tutorial

atdgen-tutorial.pdf: $(TEXFILES)
	pdflatex atdgen-tutorial
	pdflatex atdgen-tutorial
	pdflatex atdgen-tutorial

clean:
	rm -f *~
	rm -f *.aux *.toc *.log *.out *.haux *.htoc *.fls \
		atdgen-tutorial-body.tex atdgen-tutorial.tex \
		atdgen-tutorial.pdf atdgen-tutorial.txt \
		atdgen-tutorial.html \
                *.mlx.ml
	rm -f */*_[tbjv].* */*_[tbjv].* */*~ */*.cm[iox] */*.o
	rm -f hello/hello pretty-json/prettify \
		inspect-biniou/tree inspect-biniou/tree.dat \
		validate/test_resume modularity/test_modularity
