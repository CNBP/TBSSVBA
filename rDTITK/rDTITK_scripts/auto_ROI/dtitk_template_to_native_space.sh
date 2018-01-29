#!/bin/bash

source ~/.bash_profile


ROI=$1

TRANSFORM_AFF_TEMP=(`ls $2/*.aff`)
DF_FIELD_TEMP=(`ls $3/*.df.nii.gz`)

TARGET=$4

OUTFOLDER=$5

for (( i=0; i<${#TRANSFORM_AFF_TEMP[@]}; i++ )); do
echo
echo

SUBJ_NAME=`basename ${TRANSFORM_AFF_TEMP[i]} | cut -d '.' -f 1 | cut -d '_' -f 1`
FILENAME_AFF=`basename ${TRANSFORM_AFF_TEMP[i]} | cut -d '.' -f 1 | cut -d '_' -f 1,2`
FILENAME_DF=`basename ${DF_FIELD_TEMP[i]} | cut -d '.' -f 1`


OUT_AFF=$2/${FILENAME_AFF}_inv.aff
COMMAND="affine3Dtool -in ${TRANSFORM_AFF_TEMP[i]} -invert -out $OUT_AFF"
$COMMAND

OUT_DF=$3/${FILENAME_DF}.df_inv.nii.gz

COMMAND="dfToInverse -in ${DF_FIELD_TEMP[i]} -out $OUT_DF"
$COMMAND

OUT_COMB=$2/${SUBJ_NAME}_combined.df_inv.nii.gz
COMMAND="dfLeftComposeAffine -df $OUT_DF -aff $OUT_AFF -out $OUT_COMB"
$COMMAND

OUT_ROI=$OUTFOLDER/roi_${SUBJ_NAME}.nii.gz
COMMAND="deformationScalarVolume -in $ROI -trans $OUT_COMB  -interp 1 -out $OUT_ROI -target $TARGET"
$COMMAND


done



