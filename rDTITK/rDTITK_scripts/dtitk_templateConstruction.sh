#!/bin/bash

source ~/.bash_profile

export DTITK_SPECIES="RAT"
export DTITK_USE_QSUB=0

TEMPLATE=$1
TENSOR_FOLDER=$2
SUBJS_REGEX=$3
DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBJS_REGEX`)
SUBJS_FILENAME=$4

TRANSFO_FOLDER=$5
CONSTRUCTION_FOLDER=$6
REGISTERED_FOLDER=$7

METRIC=$8
RIG_METRIC=$METRIC
AFF_METRIC=$METRIC
RIG_IT=$9
AFF_IT=${10}
DIFF_TOL=${11}

rm ${TENSOR_FOLDER}/${SUBJS_FILENAME}
for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

#FILENAME=`basename ${DTI_TENSORS[i]}`

echo ${DTI_TENSORS[i]} >> ${TENSOR_FOLDER}/${SUBJS_FILENAME}

done




#RIGID
COMMAND="dti_rigid_population $TEMPLATE ${TENSOR_FOLDER}/${SUBJS_FILENAME} ${RIG_METRIC} ${RIG_IT}"
echo $COMMAND >> jobs.log
$COMMAND

#AFFINE
TEMPLATE="mean_rigid${RIG_IT}.nii.gz"

COMMAND="dti_affine_population $TEMPLATE ${TENSOR_FOLDER}/${SUBJS_FILENAME} ${AFF_METRIC} ${AFF_IT}"
echo $COMMAND >> jobs.log

$COMMAND


#DIFFEOMORPHIC
TEMPLATE="mean_affine${AFF_IT}.nii.gz"
ROOT=`echo ${SUBJS_FILENAME} | cut -d '.' -f  1`
SUBJS_FILENAME=`echo ${ROOT}_aff.txt`
MASK="mask.nii.gz"
#create Mask

COMMAND="TVtool -in mean_affine${AFF_IT}.nii.gz -tr"
echo $COMMAND >> jobs.log
$COMMAND

COMMAND="BinaryThresholdImageFilter mean_affine${AFF_IT}_tr.nii.gz $MASK 0.01 100 1 0"
echo $COMMAND >> jobs.log
$COMMAND

#start registration

COMMAND="dti_diffeomorphic_population $TEMPLATE ${TENSOR_FOLDER}/${SUBJS_FILENAME} $MASK $DIFF_TOL"
echo $COMMAND >> jobs.log
$COMMAND


#Deplacement des fichiers outputs

mv ${TENSOR_FOLDER}/*.aff ${TRANSFO_FOLDER}
mv ${TENSOR_FOLDER}/*.df.nii.gz ${TRANSFO_FOLDER}

mv mean* ${CONSTRUCTION_FOLDER}
mv mask.nii.gz ${CONSTRUCTION_FOLDER}
mv *.log ${CONSTRUCTION_FOLDER}
mv *.txt ${CONSTRUCTION_FOLDER}
mv ${TENSOR_FOLDER}/*.txt ${CONSTRUCTION_FOLDER}

mv ${TENSOR_FOLDER}/*_aff.nii.gz ${REGISTERED_FOLDER}
mv ${TENSOR_FOLDER}/*_diffeo.nii.gz ${REGISTERED_FOLDER}
