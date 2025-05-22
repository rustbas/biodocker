#!/usr/bin/bash

DOCKERNAME=biodocker

docker build -t $DOCKERNAME .

if [ -n "$1" ]; then
    docker run --rm -it \
           -v ${PWD}/data/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
           $DOCKERNAME "$1"
else
    docker run --rm -it \
           -v ${PWD}/data/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
           $DOCKERNAME
fi
