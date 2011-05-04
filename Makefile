.PHONY: all
all: README.html
	cd hello && ./demo.sh
	cd pretty-json && ./demo.sh
	cd inspect-biniou && ./demo.sh
	cd validate && ./demo.sh
	cd modularity && ./demo.sh

README.html: README.md
	Markdown.pl README.md > README.html

.PHONY: clean
clean:
	rm -f README.html *~
	rm -f */*_[tbjv].* */*_[tbjv].* */*~ */*.cm[iox] */*.o
	rm -f hello/hello pretty-json/prettify \
		inspect-biniou/tree inspect-biniou/tree.dat \
		validate/test_resume modularity/test_modularity
