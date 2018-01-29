#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Projects data onto skeleton
#
# Part of MATLAB pipeline

#source ~/.bash_profile

TBSS_FOLDER=$1
THRESH=$2

STAT_FOLDER=$TBSS_FOLDER/stats_$THRESH

if [ ! -d "$STAT_FOLDER" ]; then
mkdir $STAT_FOLDER
fi

echo "creating skeleton mask using threshold $THRESH"
echo $THRESH > $STAT_FOLDER/thresh.txt
fslmaths ${TBSS_FOLDER}/mean_FA_skeleton -thr $THRESH -bin $STAT_FOLDER/mean_FA_skeleton_mask

echo "mask all FA data"
fslmaths ${TBSS_FOLDER}/all_FA -mas $STAT_FOLDER/mean_FA_skeleton_mask $STAT_FOLDER/all_FA_skeletonised

