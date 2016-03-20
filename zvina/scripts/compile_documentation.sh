#!/bin/bash

### Compile LaTeX documentation to pdflatex
#		(Actual context is in documentation_content.tex,
#		 but compilation uses documentation_compile.tex)
# (c) Zarek Siegel
# v1 3/15/2016

pdflatex documentation_compile.tex

rm -f documentation_compile.aux
rm -f documentation_compile.log
rm -f documentation_content.log
rm -f documentation_content.aux

mv documentation_compile.pdf documentation.pdf

open documentation.pdf