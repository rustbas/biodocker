#!/usr/bin/bash

USAGE_MSG="""\
Usage: $0 -e [ENTRYPOINT] -d [DOCKER IMAGE NAME] -v [DATA FOLDER]\
"""

DOCKERNAME=biodocker
DATA_FOLDER="${PWD}/data/"

while getopts "hd:e:v:" OPT; do
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
            if [ "$OPTARG" = "run" ]; then
                ENTRYPOINT="./entrypoint.sh"
            fi
            echo $ENTRYPOINT
            ;;
        v)
            DATA_FOLDER="$OPTARG"
            echo "$DATA_FOLDER"
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
           -v ${DATA_FOLDER}:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
           $DOCKERNAME "$ENTRYPOINT"
else
    docker run --rm -it \
           -v ${DATA_FOLDER}:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
           $DOCKERNAME
fi
