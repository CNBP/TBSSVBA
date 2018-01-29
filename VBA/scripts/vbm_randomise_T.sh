#!/bin/bash
# run from directory tbss prendre plusieurs fichier dans le sous repertoire FA_to_target#

source ~/.bash_profile

IMG_ALL=$1
MASK=$2
DESIGN_G1_SZ=$3
DESIGN_G2_SZ=$4
PERMUTATIONS=$5
OUT_FOLDER=$6

echo "Designing stats matrices"
design_ttest2 ${OUT_FOLDER}/design ${DESIGN_G1_SZ} ${DESIGN_G2_SZ}

time_start=`date +%s`

echo "launching statistical analysis with $perm permutations"
randomise -i ${IMG_ALL} -o ${OUT_FOLDER}/$PERMUTATIONS -m ${MASK} -d ${OUT_FOLDER}/design.mat -t ${OUT_FOLDER}/design.con -n $PERMUTATIONS -T -V

time_end=`date +%s`
time_elapsed=$((time_end - time_start))
echo
echo "--------------------------------------------------------------------------------------"
echo " Execution finished"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s" > ${OUT_FOLDER}/dur.txt
echo "--------------------------------------------------------------------------------------"
