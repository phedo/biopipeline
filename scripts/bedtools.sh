#!/bin/bash

cat $2 | grep -e '^#' > $3
bedtools intersect -a $2 -b $1 >> $3
