#!/bin/sh

#Adapté du script tbss_sym du package FSL

source ~/.bash_profile


DATA_FOLDER=$1
REGEX=$2
IM_TYPE=$3
TBSS_FOLDER=$4
THRESH=$5


if [ `${FSLDIR}/bin/imtest $TBSS_FOLDER/mean_FA_symmetrised_skeleton_mask_dst` -eq 0 ]; then


echo "merging all upsampled ${IM_TYPE} images into single 4D image..."
fslmerge -t $TBSS_FOLDER/all_${IM_TYPE} `imglob $DATA_FOLDER/$REGEX`

cd $TBSS_FOLDER

# create mean FA
echo "creating valid mask and mean FA"
fslmaths all_FA -max 0 -Tmin -bin mean_FA_mask -odt char
fslmaths all_FA -mas mean_FA_mask all_FA
fslmaths all_FA -Tmean mean_FA

#Prend le maximum dans all_FA de 0 et du min sur toutes les images et en crée un masque
#Remplace all_FA par all_FA suite à l'application du masque mean_FA_mask
#crée mean_FA qui est une image moyenne des valeurs FA dans all_FA(image 4D)


# create skeleton
echo "skeletonising mean FA"
tbss_skeleton -i mean_FA -o mean_FA_skeleton
#crée un squelette de l'image mean_FA


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

