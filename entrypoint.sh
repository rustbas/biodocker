#!/usr/bin/env bash

set -xe

./preprocess_script.sh > FP_SNPs_10k_GB38_twoAllelsFormat.tsv

python3 main.py \
        --input-file FP_SNPs_10k_GB38_twoAllelsFormat.tsv \
        --log-file pipeline.log \
        --output-file result_file.tsv \
        --reference GRCh38.d1.vd1.fa \
        --index-file GRCh38.d1.vd1.fa.fai
