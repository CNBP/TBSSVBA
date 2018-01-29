#!/bin/bash

source ~/.bash_profile

export DTIKT_USE_QSUB=0
export DTITK_SPECIES='RAT'

TENSOR_FOLDER=$1
SUBSET_REGEX=$2
DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`)

TEMPLATE=$3
SUBJS_FILENAME=$4
MASK=$5
REG_METRIC=$6
DIF_FTOL=$7


rm ${TENSOR_FOLDER}/${SUBJS_FILENAME}
for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

echo ${DTI_TENSORS[i]} >> ${TENSOR_FOLDER}/${SUBJS_FILENAME}

done


COMMAND="dti_rigid_sn $TEMPLATE ${TENSOR_FOLDER}/${SUBJS_FILENAME} ${REG_METRIC}"

$COMMAND

#ROOT=`echo ${SUBJS_FILENAME} | cut -d '.' -f  1`
#SUBJS_FILENAME=`echo ${ROOT}_aff.txt`

COMMAND="dti_affine_sn $TEMPLATE ${TENSOR_FOLDER}/${SUBJS_FILENAME} ${REG_METRIC} 1"

$COMMAND

ROOT=`echo ${SUBJS_FILENAME} | cut -d '.' -f  1`
SUBJS_FILENAME=`echo ${ROOT}_aff.txt`

rm ${TENSOR_FOLDER}/${SUBJS_FILENAME}
for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

BASENAME=`echo ${DTI_TENSORS[i]} | cut -d '.' -f 1`
echo  ${BASENAME}_aff.nii.gz >> ${TENSOR_FOLDER}/${SUBJS_FILENAME}

done

COMMAND="dti_diffeomorphic_sn $TEMPLATE ${TENSOR_FOLDER}/${SUBJS_FILENAME} ${MASK} 6 ${DIF_FTOL}"
echo
echo
echo $COMMAND
echo
echo
$COMMAND