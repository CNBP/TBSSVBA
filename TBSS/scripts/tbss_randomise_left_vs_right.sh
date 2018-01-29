#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Runs statistical analysis
#
# Part of MATLAB pipeline

source ~/.bash_profile

IMG_LR=$1
PERMUTATIONS=$2
STAT_FOLDER=$3
ALTIM=$4


echo "Testing L>R..."
time_start=`date +%s`

echo "launching statistical analysis with $perm permutations"
randomise -i ${IMG_LR} -o ${STAT_FOLDER}/${ALTIM}_${PERMUTATIONS}_test_left_bigger -1 -n $PERMUTATIONS --T2 -V

time_end=`date +%s`
time_elapsed=$((time_end - time_start))
echo
echo "--------------------------------------------------------------------------------------"
echo " Execution finished"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s" > ${STAT_FOLDER}/${ALTIM}_LR_dur.txt
echo "--------------------------------------------------------------------------------------"

echo "Testing R>L..."


#invert data and rerun randomise

fslmaths ${IMG_LR} -mul -1 ${IMG_LR}_inv

echo "launching statistical analysis with $perm permutations"
randomise -i ${IMG_LR}_inv -o ${STAT_FOLDER}/${ALTIM}_${PERMUTATIONS}_test_left_smaller -1 -n $PERMUTATIONS --T2 -V

time_end=`date +%s`
time_elapsed=$((time_end - time_start))
echo
echo "--------------------------------------------------------------------------------------"
echo " Execution finished"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s" > ${STAT_FOLDER}/${ALTIM}_RL_dur.txt
echo "--------------------------------------------------------------------------------------"
