#!/bin/bash

source ~/.bash_profile

OUT_FOLDER=$1
SUBSET_REGEX=$2
DTI_TENSORS=(`ls $OUT_FOLDER/$SUBSET_REGEX`)

SUBSET_FILENAME=$3

SZx=$4
SZy=$5
SZz=$6

VOX_SZx=$7
VOX_SZy=$8
VOX_SZz=$9

#Create The subset text file for the template initialisation
rm ${OUT_FOLDER}/${SUBSET_FILENAME}
for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

FILENAME=`basename ${DTI_TENSORS[i]}`

echo ${DTI_TENSORS[i]} >> ${OUT_FOLDER}/${SUBSET_FILENAME}

done

# Create template bootstrap
echo >> ${OUT_FOLDER}/bootstrap_construction.txt
echo "--------------------- Averaging rigidly registered subjects ---------------------" >> ${OUT_FOLDER}/bootstrap_construction.txt


COMMAND="TVMean -in ${OUT_FOLDER}/${SUBSET_FILENAME} -out ${OUT_FOLDER}/mean_initial.nii.gz"

echo $COMMAND >> ${OUT_FOLDER}/bootstrap_construction.txt
$COMMAND


COMMAND="TVResample -in ${OUT_FOLDER}/mean_initial.nii.gz -align center -size $SZx $SZy $SZz -vsize ${VOX_SZx} ${VOX_SZy} ${VOX_SZz}"

echo $COMMAND >> ${OUT_FOLDER}/bootstrap_construction.txt
$COMMAND