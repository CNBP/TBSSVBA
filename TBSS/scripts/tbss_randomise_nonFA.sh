#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Runs statistical analysis on nonFA image
#
# Part of MATLAB pipeline

source ~/.bash_profile

IMG_ALL=$1
MASK=$2
DESIGN_G1_SZ=$3
DESIGN_G2_SZ=$4
PERMUTATIONS=$5
STAT_FOLDER=$6
ALTIM=$7

echo
echo
echo $ALTIM
echo
echo

echo "Designing stats matrices"
design_ttest2 ${STAT_FOLDER}/design ${DESIGN_G1_SZ} ${DESIGN_G2_SZ}

time_start=`date +%s`

echo "launching statistical analysis with $perm permutations"
randomise -i ${IMG_ALL} -o ${STAT_FOLDER}/${ALTIM}_${PERMUTATIONS} -m ${MASK} -d ${STAT_FOLDER}/design.mat -t ${STAT_FOLDER}/design.con -n $PERMUTATIONS --T2 -V

time_end=`date +%s`
time_elapsed=$((time_end - time_start))
echo
echo "--------------------------------------------------------------------------------------"
echo " Execution finished"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s" > ${STAT_FOLDER}/${ALTIM}_dur.txt
echo "--------------------------------------------------------------------------------------"