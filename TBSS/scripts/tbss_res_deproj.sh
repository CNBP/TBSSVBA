#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Deprojects voxel for visualisation in standard space
#
# Part of MATLAB pipeline

source ~/.bash_profile

STAT_FOLDER=$1
STAT_IM=$2
THRESH=$3
OUTFILE=$4

cd $STAT_FOLDER

fslmaths ${STAT_IM} -thr $THRESH $OUTFILE
tbss_deproject $OUTFILE 1