#!/bin/sh

#Adapté du script tbss_sym du package FSL

source ~/.bash_profile


WARPED_TENSORS=$1
IMGS=(`ls ${WARPED_TENSORS}/*.nii.gz`)

DATA_FOLDER=$2
REGEX=$3
IM_TYPE=$4
TBSS_FOLDER=$5
THRESH=$6


if [ `${FSLDIR}/bin/imtest $TBSS_FOLDER/mean_FA_symmetrised_skeleton_mask_dst` -eq 0 ]; then


echo "merging all upsampled ${IM_TYPE} images into single 4D image..."
fslmerge -t $TBSS_FOLDER/all_${IM_TYPE} `imglob $DATA_FOLDER/$REGEX`


if [ -f ${TBSS_FOLDER}/subjs.txt ]; then
rm ${TBSS_FOLDER}/subjs.txt
fi
for (( i=0; i<${#IMGS[@]}; i++ )); do
echo ${IMGS[i]} >> ${TBSS_FOLDER}/subjs.txt
done


echo "creating valid mask and mean FA"
#Create mean FA image
TVMean -in ${TBSS_FOLDER}/subjs.txt -out ${TBSS_FOLDER}/mean_tbss.nii.gz

TVtool -in ${TBSS_FOLDER}/mean_tbss.nii.gz -fa

mv ${TBSS_FOLDER}/mean_tbss_fa.nii.gz ${TBSS_FOLDER}/mean_FA.nii.gz

#Create mean FA mask
fslmaths ${TBSS_FOLDER}/all_FA -max 0 -Tmin -bin ${TBSS_FOLDER}/mean_FA_mask -odt char
fslmaths ${TBSS_FOLDER}/all_FA -mas ${TBSS_FOLDER}/mean_FA_mask ${TBSS_FOLDER}/all_FA

#Create skeleton
echo "skeletonising mean FA"
tbss_skeleton -i ${TBSS_FOLDER}/mean_FA -o ${TBSS_FOLDER}/mean_FA_skeleton

cd $TBSS_FOLDER

echo "creating a symmetrised skeleton"
$FSLDIR/bin/fslmaths mean_FA_skeleton -thr $THRESH -bin -dilF grotsym_dilated
$FSLDIR/bin/fslswapdim mean_FA -x y z grotsym #> /dev/null : envoie l'output dans le neant
$FSLDIR/bin/fslmaths mean_FA -mas grotsym -add grotsym -div 2 mean_FA_symmetrised
$FSLDIR/bin/tbss_skeleton -i mean_FA_symmetrised -o grotsym_symmetrised_skeleton
$FSLDIR/bin/fslmaths grotsym_symmetrised_skeleton -thr $THRESH -mas grotsym_dilated grotsym_symmetrised_skeleton
$FSLDIR/bin/fslswapdim grotsym_symmetrised_skeleton -x y z grotsym #> /dev/null
$FSLDIR/bin/fslmaths grotsym_symmetrised_skeleton -mas grotsym mean_FA_symmetrised_skeleton
$FSLDIR/bin/fslmaths mean_FA_symmetrised_skeleton -bin mean_FA_symmetrised_skeleton_mask

echo "creating symmetrised skeleton distancemap"
${FSLDIR}/bin/fslmaths mean_FA_mask -mul -1 -add 1 -add mean_FA_symmetrised_skeleton_mask mean_FA_symmetrised_skeleton_mask_dst
${FSLDIR}/bin/distancemap -i mean_FA_symmetrised_skeleton_mask_dst -o mean_FA_symmetrised_skeleton_mask_dst


$FSLDIR/bin/imrm all_FA

fi

