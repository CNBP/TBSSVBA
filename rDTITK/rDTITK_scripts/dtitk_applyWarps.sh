#!/bin/bash

source ~/.bash_profile

export DTITK_USE_QSUB=0

TENSOR_FOLDER=$1
DTI_TENSORS=(`ls $TENSOR_FOLDER/*_tensor.nii.gz`)

TEMPLATE=$2
SUBJS_FILENAME=$3

VOX_SZx=$4
VOX_SZy=$5
VOX_SZz=$6

OUTPUT_FOLDER=$7


rm ${TENSOR_FOLDER}/${SUBJS_FILENAME}
for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

echo ${DTI_TENSORS[i]} >> ${TENSOR_FOLDER}/${SUBJS_FILENAME}

done


COMMAND="dti_warp_to_template_group ${TENSOR_FOLDER}/${SUBJS_FILENAME} $TEMPLATE  ${VOX_SZx} ${VOX_SZy} ${VOX_SZz}"

$COMMAND



#Deplacement des fichiers outputs

mv ${TENSOR_FOLDER}/*.aff ${OUTPUT_FOLDER}
mv ${TENSOR_FOLDER}/*.df.nii.gz ${OUTPUT_FOLDER}

mv ${TENSOR_FOLDER}/*_aff.nii.gz ${OUTPUT_FOLDER}
mv ${TENSOR_FOLDER}/*_diffeo.nii.gz ${OUTPUT_FOLDER}

mv ${TENSOR_FOLDER}/*.txt ${OUTPUT_FOLDER}
