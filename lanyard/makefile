proj = lanyard
SRC = $(wildcard *.tex)
OUT = $(SRC:.tex=.pdf)

all: $(proj).pdf multi.pdf

%.pdf: %.tex 
#	cd fig ; make
	xelatex $<

clean:
	-rm *.{pdf,ps,dvi,fls,aux,bbl,blg,brf,log} *~

deepclean: 
	-rm *.{pdf,ps,dvi,fls,aux,bbl,blg,brf,log} *~
	-rm -rf reg-temp.csv output/ vcard/ mecard/ qrcode/ img/


