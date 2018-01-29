#!/bin/sh

#Adapté du script tbss_sym du package FSL

source ~/.bash_profile


DATA_FOLDER=$1
REGEX=$2
IM_TYPE=$3
TBSS_FOLDER=$4
THRESH=$5


if [ `${FSLDIR}/bin/imtest $TBSS_FOLDER/all_${IM_TYPE}` -eq 0 ]; then

echo "merging all upsampled ${IM_TYPE} images into single 4D image..."
fslmerge -t $TBSS_FOLDER/all_${IM_TYPE} `imglob $DATA_FOLDER/$REGEX`

fi


cd $TBSS_FOLDER

echo "projecting all data onto symmetrised skeleton"


if [[ $IM_TYPE != *FA* ]]; then
altim="-a all_${IM_TYPE}"
fi


${FSLDIR}/bin/tbss_skeleton -i mean_FA_symmetrised -p $THRESH mean_FA_symmetrised_skeleton_mask_dst ${FSLDIR}/data/standard/LowerCingulum_1mm all_FA all_${IM_TYPE}_symmetrised_skeletonised $altim -s mean_FA_symmetrised_skeleton

echo "flipping, substracting and half-masking 4D skeletonised FA"
C="$FSLDIR/bin/fslswapdim all_${IM_TYPE}_symmetrised_skeletonised -x y z grotsym_all_${IM_TYPE}_symmetrised_flipped"  #> /dev/null
echo
echo $C
echo
$C
C="$FSLDIR/bin/fslmaths all_${IM_TYPE}_symmetrised_skeletonised -sub grotsym_all_${IM_TYPE}_symmetrised_flipped -roi 91 91 0 218 0 182 0 `$FSLDIR/bin/fslval all_FA dim4` all_${IM_TYPE}_skeletonised_left_minus_right"
echo
echo $C
echo
$C

