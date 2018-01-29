#!/bin/sh

#
# Created on 13-10-2016 by Akakpo Luis
#
#
# Part of MATLAB pipeline

#source ~/.bash_profile

DATA_FOLDER=$1
REGEX=$2
FA_THRESH=$3
VBM_FOLDER=$4

echo "merging all FA images into single 4D image..."
fslmerge -t $VBM_FOLDER/all_FA `imglob $DATA_FOLDER/$REGEX`

cd $VBM_FOLDER

# create mean FA
echo "creating valid white matter mask and mean FA"
fslmaths all_FA -max 0 -Tmin -bin mean_FA_mask -odt char
fslmaths all_FA -mas mean_FA_mask all_FA
fslmaths all_FA -Tmean mean_FA
fslmaths mean_FA -thr ${FA_THRESH} -bin wm_mask

#Prend le maximum dans all_FA de 0 et du min sur toutes les images et en crée un masque
#Remplace all_FA par all_FA suite à l'application du masque mean_FA_mask
#crée mean_FA qui est une image moyenne des valeurs FA dans all_FA(image 4D)
