#!/bin/bash

cat $1 | grep -e '^#' > $2 && cp $2 $3
cat $1 | grep -e "ANN=.*MODIFIER" | awk '{ if ($8 ~ /LOW|AVERAGE|HIGH/) print >> "'$2'"; else print >> "'$3'" }'
