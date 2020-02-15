#!/bin/bash
# find figures/ -name "*.tex" | xargs -n 1 xelatex

latexindent -w phd_thesis.tex -c /tmp/
latexindent -w all_chapters.tex -c /tmp/
xelatex phd_thesis.tex
biber phd_thesis
xelatex phd_thesis.tex
xelatex phd_thesis_a5.tex
xelatex phd_thesis_a5.tex
xelatex phd_thesis_a5_print
cp phd_thesis.pdf phd_thesis_alameddin_v02.pdf
# cleanlatex
find "`pwd`" -name "*.aux" -delete && find "`pwd`" -name "*.xml" -delete && find "`pwd`" -name "*.bcf" -delete && find "`pwd`" -name "*.bbl" -delete && find "`pwd`" -name "*.blg" -delete && find "`pwd`" -name "*.idx" -delete && find "`pwd`" -name "*.ind" -delete && find "`pwd`" -name "*.lof" -delete && find "`pwd`" -name "*.lot" -delete && find "`pwd`" -name "*.out" -delete && find "`pwd`" -name "*.toc" -delete && find "`pwd`" -name "*.acn" -delete && find "`pwd`" -name "*.acr" -delete && find "`pwd`" -name "*.alg" -delete && find "`pwd`" -name "*.glg" -delete && find "`pwd`" -name "*.glo" -delete && find "`pwd`" -name "*.gls" -delete && find "`pwd`" -name "*.ist" -delete && find "`pwd`" -name "*.fls" -delete && find "`pwd`" -name "*.log" -delete && find "`pwd`" -name "*.fdb_latexmk" -delete && find "`pwd`" -name "*.nav" -delete && find "`pwd`" -name "*.snm" -delete && find "`pwd`" -name "*.synctex.gz" -delete
