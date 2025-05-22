#!/bin/bash

# set -xe

if [ -n "$1" ]; then
    INPUT_FILE=$1
else
    echo "Need to provide txt-file!" 1>&2
    exit 1
fi

echo -e "#CHROM\tPOS\tID\tALLELE1\tALLELE2"
awk '{if (NR>1 && $2 != 23) \
    printf "chr%d\t%d\trs%d\t%s\t%s\n",$2,$4,$1,$5,$6}'\
    $INPUT_FILE
