#!/bin/bash

#
# Created on 25-09-2016 by Akakpo Luis
#

source ~/.profile

IN_FOLDER=$1
REGEX=$2
TEMPLATE=$3
TRANS_FOLDER=$4
OUT_FOLDER=$5



if [[ ! -f ${OUT_FOLDER} ]]; then
mkdir ${OUT_FOLDER}
fi


IMGS=(`ls ${IN_FOLDER}/$REGEX`)
TRANSFORMS=(`ls ${TRANS_FOLDER}/$REGEX`)

for (( i=0 ; i<${#IMGS[@]} ; i++ )); do

NAME=`basename ${IMGS[i]} |cut -d '.' -f 1`

applywarp -i ${IMGS[i]} -o ${OUT_FOLDER}/${NAME}_reg -r $TEMPLATE -w ${TRANSFORMS[i]}


done

