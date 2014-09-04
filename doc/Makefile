#

all:	hydro.ps  hydro_2.ps hydro.pdf

clean:  
	rm -f hydro.ps  hydro_2.ps hydro.pdf

hydro.ps:	hydro.dvi
	dvips hydro -o

hydro.dvi:	hydro.tex
	latex hydro


hydro_2.ps: hydro.ps
	psnup -2 hydro.ps  > hydro_2.ps


hydro.pdf:	hydro.ps
	ps2pdf hydro.ps
