#!/bin/bash


SEGMENTATION=$1
TRANSFORM_MATs_TEMP=(`ls $2/*.mat`)  
TRANSFORM_MAT_ATLAS=$3
INV_TRANSFORMs_TEMP=(`ls $4/*InverseWarp.nii.gz`)  
INV_TRANSFORM_ATLAS=$5
REF=$6

for (( i=0; i<${#TRANSFORM_MATs_TEMP[@]}; i++ )); do

	FILENAME=`basename ${TRANSFORM_MATs_TEMP[i]} | cut -d '.' -f 1`
	OUTPUTNAME=./segmentation/scmaps_seg/seg_$FILENAME.nii
	COMMAND="WarpImageMultiTransform 3 $SEGMENTATION $OUTPUTNAME --use-NN -i 		${TRANSFORM_MATs_TEMP[i]} -i $TRANSFORM_MAT_ATLAS ${INV_TRANSFORMs_TEMP[i]} $INV_TRANSFORM_ATLAS -R $REF"

	$COMMAND
	
done

