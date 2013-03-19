#!/bin/bash

EXPECTED_ARGS=7
E_BADARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` output fname lname title org qrcode badge"
  exit $E_BADARGS
fi

xelatex --jobname=$1 "\newcommand\fname{$2}\newcommand\lname{$3}\newcommand\titlename{$4}\newcommand\orgname{$5}\newcommand\qrcode{$6}\newcommand\badge{$7}\input{lanyard.tex}"
# cleanup the mess
rm $1.{log,aux}
