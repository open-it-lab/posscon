#!/bin/bash

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` prefix lanyard1 [lanyard2] [lanyard3]"
  exit $E_BADARGS
fi

xelatex --jobname=$1 "\newcommand\one{$2}\newcommand\two{$3}\newcommand\three{$4}\input{multi.tex}"
# cleanup the mess
rm $1.{log,aux}
