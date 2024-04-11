#!/bin/bash

MAKEFILE_FILENAME='./.lmk.mk'

if [ $# -eq 0 ]; then
  $EDITOR $MAKEFILE_FILENAME
elif [ $1 == "p" ]; then
  echo "Printing Makefile"
  echo "---"
  cat $MAKEFILE_FILENAME
  echo "---"
else
  make $1 -f $MAKEFILE_FILENAME -s
fi
