#!/bin/bash

source ~/.bash_profile
#echo $PATH

IM=$1
TRANSFORM_MAT=$2
INV_TRANSFORM=$3
REF=$4
OUTPUTNAME=$5

COMMAND="WarpImageMultiTransform 3 $IM $OUTPUTNAME --use-BSpline -i ${TRANSFORM_MAT} ${INV_TRANSFORM} -R $REF"

$COMMAND