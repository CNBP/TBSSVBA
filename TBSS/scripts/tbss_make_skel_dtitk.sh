#!/bin/sh

#  dtitk_prepare_tbss.sh
#  
#
#  Created by Luis-Konu Akakpo on 16-08-30.
#

source ~/.bash_profile

WARPED_TENSORS=$1
IMGS=(`ls ${WARPED_TENSORS}/*.nii.gz`)

DATA_FOLDER=$2
REGEX=$3
TBSS_FOLDER=$4


echo "merging all upsampled FA images into single 4D image..."
fslmerge -t $TBSS_FOLDER/all_FA `imglob $DATA_FOLDER/$REGEX`


if [ -f ${TBSS_FOLDER}/subjs.txt ]; then
    rm ${TBSS_FOLDER}/subjs.txt
fi
for (( i=0; i<${#IMGS[@]}; i++ )); do
echo ${IMGS[i]} >> ${TBSS_FOLDER}/subjs.txt
done


echo "creating valid mask and mean FA"
#Create mean FA image
TVMean -in ${TBSS_FOLDER}/subjs.txt -out ${TBSS_FOLDER}/mean_tbss.nii.gz

TVtool -in ${TBSS_FOLDER}/mean_tbss.nii.gz -fa

mv ${TBSS_FOLDER}/mean_tbss_fa.nii.gz ${TBSS_FOLDER}/mean_FA.nii.gz

#Create mean FA mask
fslmaths ${TBSS_FOLDER}/all_FA -max 0 -Tmin -bin ${TBSS_FOLDER}/mean_FA_mask -odt char
fslmaths ${TBSS_FOLDER}/all_FA -mas ${TBSS_FOLDER}/mean_FA_mask ${TBSS_FOLDER}/all_FA

#Create skeleton
echo "skeletonising mean FA"
tbss_skeleton -i ${TBSS_FOLDER}/mean_FA -o ${TBSS_FOLDER}/mean_FA_skeleton

