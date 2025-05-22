#!/usr/bin/bash

DOCKERNAME=biodocker

docker build -t $DOCKERNAME .

docker run --rm -it \
       -v ${PWD}/data/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
       $DOCKERNAME "$1"
