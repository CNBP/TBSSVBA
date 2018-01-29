#!/bin/bash

source ~/.bash_profile

TENSOR_FOLDER=$1
SUBSET_REGEX=$2
DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`) 
MODEL=$3
REG_METRIC=$4
OUT_FOLDER=$5
SUBJS_FILENAME=$6

echo "--------------------- Pre- RIGID REGISTRATION ---------------------" > ${OUT_FOLDER}/bootstrap_construction.txt


rm ${OUT_FOLDER}/${SUBJS_FILENAME}
for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

echo ${DTI_TENSORS[i]} >> ${OUT_FOLDER}/${SUBJS_FILENAME}

done



COMMAND="dti_rigid_sn $MODEL ${OUT_FOLDER}/${SUBJS_FILENAME} ${REG_METRIC}"

$COMMAND


#deplacer les fichiers issus de la registration
mv ${TENSOR_FOLDER}/*.aff ${OUT_FOLDER}
mv ${TENSOR_FOLDER}/*_aff.nii.gz ${OUT_FOLDER}


echo $COMMAND >> ${OUT_FOLDER}/bootstrap_construction.txt

