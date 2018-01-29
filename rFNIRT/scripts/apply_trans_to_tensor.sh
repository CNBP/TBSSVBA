#!/bin/bash

#
# Created on 25-09-2016 by Akakpo Luis
#

# WARNING DOES NOT IMPLEMENT THE PPD SCHEME!!
# ONLY ALLOWS THAT IT IS REALLY BAD WITHOUT!!

source ~/.bash_profile

TENSOR_FOLDER=$1
REGEX=$2
TEMPLATE=$3
TRANS_FOLDER=$4
OUT_FOLDER=$5



if [[ ! -f ${OUT_FOLDER} ]]; then
mkdir ${OUT_FOLDER}
fi


TENSORS=(`ls ${TENSOR_FOLDER}/$REGEX`)
TRANSFORMS=(`ls ${TRANS_FOLDER}/$REGEX`)

for (( i=0 ; i<${#TENSORS[@]} ; i++ )); do

NAME=`basename ${TENSORS[i]} |cut -d '.' -f 1`


applywarp -i ${TENSORS[i]} -o ${OUT_FOLDER}/${NAME}_reg -r $TEMPLATE -w ${TRANSFORMS[i]}


done

