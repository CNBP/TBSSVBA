#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Projects other data types than FA onto skeleton
#
# Part of MATLAB pipeline

source ~/.bash_profile

DATA_FOLDER=$1
TBSS_FOLDER=$2 
REGEX=$3
THRESH=$4
ALTIM=$5

STAT_FOLDER=$TBSS_FOLDER/stats_$THRESH


echo "merging all upsampled $ALTIM images into single 4D image"
fslmerge -t $TBSS_FOLDER/all_$ALTIM `imglob $DATA_FOLDER/$REGEX`
fslmaths $TBSS_FOLDER/all_$ALTIM -mas $TBSS_FOLDER/mean_FA_mask $TBSS_FOLDER/all_$ALTIM

echo "projecting all_$ALTIM onto mean FA skeleton"
tbss_skeleton -i ${TBSS_FOLDER}/mean_FA -p $THRESH $STAT_FOLDER/mean_FA_skeleton_mask_dst ${FSLDIR}/data/standard/LowerCingulum_1mm ${TBSS_FOLDER}/all_FA $STAT_FOLDER/all_${ALTIM}_skeletonised -a $TBSS_FOLDER/all_$ALTIM