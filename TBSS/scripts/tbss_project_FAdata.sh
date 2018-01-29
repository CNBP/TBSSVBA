#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Projects data onto skeleton
#
# Part of MATLAB pipeline

source ~/.bash_profile

TBSS_FOLDER=$1
THRESH=$2

STAT_FOLDER=$TBSS_FOLDER/stats_$THRESH

if [ ! -d "$STAT_FOLDER" ]; then
mkdir $STAT_FOLDER
fi

echo "creating skeleton mask using threshold $THRESH"
echo $THRESH > $STAT_FOLDER/thresh.txt
${FSLDIR}/bin/fslmaths ${TBSS_FOLDER}/mean_FA_skeleton -thr $THRESH -bin $STAT_FOLDER/mean_FA_skeleton_mask

echo "creating skeleton distancemap (for use in projection search)"
${FSLDIR}/bin/fslmaths ${TBSS_FOLDER}/mean_FA_mask -mul -1 -add 1 -add $STAT_FOLDER/mean_FA_skeleton_mask $STAT_FOLDER/mean_FA_skeleton_mask_dst
${FSLDIR}/bin/distancemap -i $STAT_FOLDER/mean_FA_skeleton_mask_dst -o $STAT_FOLDER/mean_FA_skeleton_mask_dst

echo "projecting all FA data onto skeleton"
${FSLDIR}/bin/tbss_skeleton -i ${TBSS_FOLDER}/mean_FA -p $THRESH $STAT_FOLDER/mean_FA_skeleton_mask_dst ${FSLDIR}/data/standard/LowerCingulum_1mm ${TBSS_FOLDER}/all_FA $STAT_FOLDER/all_FA_skeletonised -s $STAT_FOLDER/mean_FA_skeleton_mask.nii