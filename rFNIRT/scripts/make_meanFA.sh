#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Creates tbss skeleton
#
# Part of MATLAB pipeline

source ~/.bash_profile

DATA_FOLDER=$1
REGEX=$2
MRS=$3
OUT_FOLDER=$4

if [[ ! -f ${OUT_FOLDER} ]]; then
mkdir ${OUT_FOLDER}
fi

fslmerge -t $OUT_FOLDER/all_FA `imglob $MRS $DATA_FOLDER/$REGEX `

# create mean FA

fslmaths $OUT_FOLDER/all_FA -Tmean $OUT_FOLDER/MRS_FA_template
fslmaths $OUT_FOLDER/all_FA -max 0 -Tmin -bin $OUT_FOLDER/MRS_FA_template_mask
