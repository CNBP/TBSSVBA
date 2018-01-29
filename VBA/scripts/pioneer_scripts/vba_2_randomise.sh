#!/bin/sh
# run from directory tbss prendre plusieurs fichier dans le sous repertoire FA_to_target#

#ATTENTION SCRIPT NON GENERAL! MODIFIER LE NOM DE L IMAGE D'INPUT ET DU MASQUE
statsfolder=$1
perm=$2

cd $statsfolder
echo "Designing stats matrices"

if [ ! -f design.mat ]; then
    design_ttest2 design 11 11
fi

time_start=`date +%s`

echo "launching statistical analysis with $perm permutations"
randomise -i all_FA_VBM_s0.2 -o vbm_$perm -m WM_tracks_mask_0.4 -d design.mat -t design.con -n $perm -T -V

time_end=`date +%s`
time_elapsed=$((time_end - time_start))
echo
echo "--------------------------------------------------------------------------------------"
echo " Execution finished"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s" > dur.txt
echo "--------------------------------------------------------------------------------------"