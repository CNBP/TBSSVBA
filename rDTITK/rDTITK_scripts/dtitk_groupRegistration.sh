#!/bin/bash

source ~/.bash_profile

TENSOR_FOLDER=$1
SUBSET_REGEX=$2
DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`) 
TEMPLATE=$3

VOX_STEPx=$4
VOX_STEPy=$5
VOX_STEPz=$6

REG_METRIC=$7

DIF_FTOL=$8


for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

COMMAND="dti_rigid_reg $TEMPLATE ${DTI_TENSORS[i]} ${REG_METRIC} ${VOX_STEPx} ${VOX_STEPy} ${VOX_STEPz} 0.01"

$COMMAND

done

REGEX_BASE=`echo $SUBSET_REGEX | cut -d '.' -f 1`
SUBSET_REGEX="${REGEX_BASE}_aff.nii.gz"
DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`)

for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

COMMAND="dti_affine_reg $TEMPLATE ${DTI_TENSORS[i]} ${REG_METRIC} ${VOX_STEPx} ${VOX_STEPy} ${VOX_STEPz} 0.01"

$COMMAND

done

REGEX_BASE=`echo $SUBSET_REGEX | cut -d '.' -f 1`
SUBSET_REGEX="${REGEX_BASE}_aff.nii.gz"
DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`)
for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do
NAME=`basename ${DTI_TENSORS[i]} | cut -d '_' -f 1`
FILENAME=`echo ${DTI_TENSORS[i]} | cut -d '.' -f 1`
MASK="${TENSOR_FOLDER}/${NAME}_mask.nii.gz"

#create Mask
COMMAND="TVtool -in ${DTI_TENSORS[i]} -tr"
$COMMAND

COMMAND="BinaryThresholdImageFilter ${FILENAME}_tr.nii.gz $MASK 0.01 100 1 0"
$COMMAND

COMMAND="dti_diffeomorphic_reg $TEMPLATE ${DTI_TENSORS[i]} ${MASK} 1 6 ${DIF_FTOL}"
echo
echo
echo $COMMAND
echo
echo
$COMMAND

done


