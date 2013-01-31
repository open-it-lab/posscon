proj = lanyard
SRC = $(wildcard *.tex)
OUT = $(SRC:.tex=.pdf)

all: $(proj).pdf multi.pdf

%.pdf: %.tex 
#	cd fig ; make
	pdflatex $<

clean:
	-rm *.{pdf,ps,dvi,fls,aux,bbl,blg,brf,log} *~

deepclean: 
	cd fig ; make clean
	-rm *.{pdf,ps,dvi,fls,aux,bbl,blg,brf,log} *~


