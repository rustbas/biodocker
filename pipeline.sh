#!/usr/bin/bash

USAGE_MSG="""\
Usage: $0 -e [ENTRYPOINT] -d [DOCKER IMAGE NAME]\
"""

DOCKERNAME=biodocker

while getopts "hd:e:" OPT; do
    case $OPT in
	d)
            DOCKERNAME="$OPTARG"
	    ;;
        h)
            echo "$USAGE_MSG"
            exit 0
            ;;
        e)
            ENTRYPOINT="$OPTARG"
            echo $ENTRYPOINT
            ;;
	\?)
	    echo "Invalid option: $OPT"
	    echo "$USAGE_MSG"
	    exit 1
    esac
done

docker build -t $DOCKERNAME .

if [ -n "$ENTRYPOINT" ]; then
    docker run --rm -it \
           -v ${PWD}/data/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
           $DOCKERNAME "$ENTRYPOINT"
else
    docker run --rm -it \
           -v ${PWD}/data/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
           $DOCKERNAME
fi
