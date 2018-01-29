#!/bin/bash

source ~/.bash_profile

TENSOR_FOLDER=$1
SUBSET_REGEX=$2
DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`) 
MODEL=$3

VOX_STEPx=$4
VOX_STEPy=$5
VOX_STEPz=$6

REG_METRIC=$7

OUT_FOLDER=$8

echo "--------------------- Pre- RIGID REGISTRATION ---------------------" > ${OUT_FOLDER}/bootstrap_construction.txt

for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

COMMAND="dti_rigid_reg $MODEL ${DTI_TENSORS[i]} ${REG_METRIC} ${VOX_STEPx} ${VOX_STEPy} ${VOX_STEPz} 0.01"
$COMMAND


#deplacer les fichiers issus de la registration
FILENAME=`basename ${DTI_TENSORS[i]} | cut -d '.' -f 1`
mv ${TENSOR_FOLDER}/${FILENAME}.aff ${OUT_FOLDER}/${FILENAME}.aff
mv ${TENSOR_FOLDER}/${FILENAME}_aff.nii.gz ${OUT_FOLDER}/${FILENAME}_aff.nii.gz

echo $COMMAND >> ${OUT_FOLDER}/bootstrap_construction.txt

done