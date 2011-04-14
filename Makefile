.PHONY: all
all: README.html
	cd hello && ./demo.sh

README.html: README.md
	Markdown.pl README.md > README.html

.PHONY: clean
clean:
	rm -f README.html *~
	rm -f */*_[tbjv].* */*_[tbjv].* */*~ */*.cm[iox] */*.o
	rm -f hello/hello
