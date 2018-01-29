#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Deprojects voxel for visualisation in standard space
#
# Part of MATLAB pipeline

source ~/.bash_profile

STAT_FOLDER=$1
STAT_IMG=$2
FA_THRESH=$3
STAT_THRESH=$4

cd $STAT_FOLDER

echo "Masking non significant voxels in stat image"
fslmaths $STAT_IMG -thr $STAT_THRESH stat_thr_tmp
echo "Flipping result image"
fslswapdim stat_thr_tmp -x y z stat_thr_flip_tmp
echo "Combining both to have a symmetric image"
fslmaths stat_thr_tmp -add stat_thr_flip_tmp  symm_stat_thr_tmp

echo "Back - Projecting"
$FSLDIR/bin/tbss_skeleton -i mean_FA_symmetrised -p ${FA_THRESH} mean_FA_symmetrised_skeleton_mask_dst $FSLDIR/data/standard/LowerCingulum_1mm all_FA ${STAT_IMG}_tmp -D symm_stat_thr_tmp
$FSLDIR/bin/immv ${STAT_IMG}_tmp_deprojected ${STAT_IMG}_to_all_FA
#$FSLDIR/bin/imrm *_tmp

