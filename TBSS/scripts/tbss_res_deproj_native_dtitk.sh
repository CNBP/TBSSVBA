#!/bin/bash

source ~/.bash_profile
#echo $PATH

IM=$1
TRANSFORM_AFF=$2
DF_TRANSFORM=$3
REF=$4
OUTPUTNAME=$5

DIR_TRANS=`dirname ${TRANSFORM_AFF} `
NAME_AFF=`basename ${TRANSFORM_AFF} | cut -d '.' -f 1`
NAME=`basename ${TRANSFORM_AFF} | cut -d '_' -f 1`
NAME_DF_INV=`basename ${DF_TRANSFORM} | cut -d '.' -f 1`


if [ ! -f ${DIR_TRANS}/${NAME}_FWarp.df_inv.nii.gz ]; then

affine3Dtool -in ${TRANSFORM_AFF} -invert -out ${DIR_TRANS}/${NAME_AFF}_inv.aff
dfToInverse -in ${DF_TRANSFORM}
dfLeftComposeAffine -df ${DIR_TRANS}/${NAME_DF_INV}.df_inv.nii.gz -aff ${DIR_TRANS}/${NAME_AFF}_inv.aff -out ${DIR_TRANS}/${NAME}_FWarp.df_inv.nii.gz

fi

deformationScalarVolume -in ${IM} -trans ${DIR_TRANS}/${NAME}_FWarp.df_inv.nii.gz -target ${REF} -interp 0 -out ${OUTPUTNAME}
