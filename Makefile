.PHONY: all demo pdf txt html install clean
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
TUTSRC = $(TEXFILES) \
         config-file/demo.sh config-file/config.atd config-file/config.ml

atdgen-tutorial.tex: atdgen-tutorial.mlx
	OCAMLPATH=../..:$$OCAMLPATH \
		camlmix atdgen-tutorial.mlx -o atdgen-tutorial.tex

atdgen-tutorial-body.tex: macros.ml atdgen-tutorial-body.mlx
	OCAMLPATH=../..:$$OCAMLPATH \
		camlmix atdgen-tutorial-body.mlx -o atdgen-tutorial-body.tex

atdgen-tutorial.txt: $(TUTSRC)
	rm -f *.aux
	hevea -fix -text atdgen-tutorial
	mv atdgen-tutorial.txt atdgen-tutorial.txt.orig
	iconv -f ISO_8859-1 -t UTF-8 < atdgen-tutorial.txt.orig \
		> atdgen-tutorial.txt

atdgen-tutorial.html: $(TUTSRC) \
                      hevea-insert1.html hevea-insert2.html hevea-insert3.html
	rm -f *.aux
	hevea -fix atdgen-tutorial
	sed -i '/<\/STYLE>/ r hevea-insert1.html' atdgen-tutorial.html
	sed -i '/<BODY *>/ r hevea-insert2.html' atdgen-tutorial.html
	sed -i 's/<\/BLOCKQUOTE><\/BODY>/<\/BLOCKQUOTE><!--END-->\n<\/BODY>/' \
		atdgen-tutorial.html
	sed -i -e 's:^<HR SIZE\=2>.*::' atdgen-tutorial.html
	sed -i -e 's:^.*<!--END-->:<!--END-->:' atdgen-tutorial.html
	sed -i '/<!--END-->/ r hevea-insert3.html' atdgen-tutorial.html

atdgen-tutorial.pdf: $(TUTSRC)
	pdflatex atdgen-tutorial
	pdflatex atdgen-tutorial
	pdflatex atdgen-tutorial

install:
	cp atdgen-tutorial.html atdgen-tutorial.txt atdgen-tutorial.pdf \
		../mylifelabs.github.com/
	cd ../mylifelabs.github.com/; \
	git add atdgen-tutorial.html atdgen-tutorial.txt atdgen-tutorial.pdf; \
	git commit -m "Update"; git push

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
