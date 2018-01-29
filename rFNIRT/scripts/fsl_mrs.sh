#!/bin/bash

#
# Created on 25-09-2016 by Akakpo Luis
#

#source ~/.profile

IN_FOLDER=$1
REGEX=$2
MASK_FOLDER=$3
OUT_FOLDER=$4



if [[ ! -f ${OUT_FOLDER} ]]; then
mkdir ${OUT_FOLDER}
fi

JOB_FOLDER=${OUT_FOLDER}/JOBS
WARP_FOLDER=${OUT_FOLDER}/WARPS
JACOB_FOLDER=${OUT_FOLDER}/JACOB
LOG_FOLDER=${OUT_FOLDER}/LOGS
MAT_FOLDER=${OUT_FOLDER}/MAT
FIELD_FOLDER=${OUT_FOLDER}/FIELDS
SCORES_FOLDER=${OUT_FOLDER}/SCORES

mkdir ${JOB_FOLDER}
mkdir ${WARP_FOLDER}
mkdir ${JACOB_FOLDER}
mkdir ${LOG_FOLDER}
mkdir ${MAT_FOLDER}
mkdir ${FIELD_FOLDER}
mkdir ${SCORES_FOLDER}

IMGS=(`ls ${IN_FOLDER}/$REGEX`)
MASKS=(`ls ${MASK_FOLDER}/$REGEX`)

#FNIRT PARAMETERS ARE THE DEFAULT SCALED TO OUR RESOLUTION (CONSIDERING A DEFAULT RESOLUTION OF 1x1x1mm)
count=0
cpu_count=`cat /proc/cpuinfo | grep processor | wc -l`
job_count=0

total_jobs=$((((((${#IMGS[@]}*${#IMGS[@]}))))-${#IMGS[@]}))
#waiters=(((($total_jobs/(($cpu_count-1))))-1))
#waiter_count=0
#wait_bool=0

echo -e "\nRunning a total of $total_jobs registrations (FLIRT+FNIRT)\n"

for (( i=0 ; i<${#IMGS[@]} ; i++ )); do

    for (( j=0 ; j<${#IMGS[@]} ; j++ )); do

        if [ $i -ne $j ]; then 
             F=`basename ${IMGS[i]} | cut -d '.' -f 1`
             G=`basename ${IMGS[j]} | cut -d '.' -f 1`

             qscript="job_${F}_to_${G}.txt"

              lin_it="fsl4.1-flirt -in ${IMGS[i]} -ref ${IMGS[j]} -out ${OUT_FOLDER}/${F}_to_${G} -inweight ${MASKS[i]} -omat ${MAT_FOLDER}/mat_${F}_to${G} -dof 12"
              nonlin_it="fsl4.1-fnirt --in=${IMGS[i]} --ref=${IMGS[j]} --aff=${MAT_FOLDER}/mat_${F}_to${G} --cout=${WARP_FOLDER}/${F}_to_${G}_warp --iout=${OUT_FOLDER}/${F}_to_${G}_fnirt --fout=${FIELD_FOLDER}/field_${F}_to_${G} --jout=${JACOB_FOLDER}/jacob_${F}_to_${G} --logout=${LOG_FOLDER}/log_${F}_to_${G} --inmask=${MASKS[i]} --refmask=${MASKS[j]} --warpres=0.5,0.5,0.5 --infwhm=0.4,0.3,0.15,0.15 --reffwhm=0.3,0.15,0,0 --biasres=3.5,3.5,3.5"



             def_score="fsl4.1-fslmaths ${WARP_FOLDER}/${F}_to_${G}_warp -sqr -Tmean ${F}_to_${G}_couts_tmp;
             fsl4.1-fslstats ${F}_to_${G}_couts_tmp -M -P 50 > ${SCORES_FOLDER}/MSF_${F}_to_${G}_warp.txt;
             fsl4.1-imrm ${F}_to_${G}_couts_tmp"

             
             echo -e ${lin_it} "\n" ${nonlin_it} "\n" ${def_score} > ${JOB_FOLDER}/$qscript


             if [ $count -lt $(($cpu_count-1)) ]; then
                  ((job_count++))
                  echo -e "\nRUNNING PROCESS $job_count \n"
                  bash ${JOB_FOLDER}/$qscript &
                  pids[${count}]=$!
                  ((count++))

             else
                  echo -e "\nwaiting\n"
                  for pid in ${pids[*]}; do
                  wait $pid 
                  ((count--))

                  done
                  
                  bash ${JOB_FOLDER}/$qscript &
                  ((count++))
                  ((job_count++))
                  echo -e "\nRUNNING PROCESS $job_count \n"
             fi
         fi
    done

done

