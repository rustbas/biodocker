#!/bin/bash

# set -xe

echo -e "#CHROM\tPOS\tID\tREF\tALT"
awk '{if (NR>1 && $2 != 23) \
    printf "chr%d\t%d\trs%d\t%s\t%s\n",$2,$4,$1,$5,$6}'\
    ./FP_SNPs.txt
