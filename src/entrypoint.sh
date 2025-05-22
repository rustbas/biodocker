#!/usr/bin/env bash

DATA_PREFIX="/ref/GRCh38.d1.vd1_mainChr/sepChrs"

./preprocess_script.sh $DATA_PREFIX/FP_SNPs.txt\
                       > $DATA_PREFIX/FP_SNPs_10k_GB38_twoAllelsFormat.tsv

REFERENCE_FILE="$DATA_PREFIX/GRCh38.d1.vd1.fa"

if [ ! -f "$REFERENCE_FILE.fai" ]; then
    samtools faidx $REFERENCE_FILE
fi

python3 main.py \
        --input-file $DATA_PREFIX/FP_SNPs_10k_GB38_twoAllelsFormat.tsv \
        --log-file $DATA_PREFIX/pipeline.log \
        --output-file $DATA_PREFIX/result_file.tsv \
        --reference "$REFERENCE_FILE" \
        --index-file "$REFERENCE_FILE.fai"
