#!/bin/sh

#
# Created on 22-08-2016 by Akakpo Luis
#
# Creates tbss skeleton
#
# Part of MATLAB pipeline

source ~/.bash_profile

DATA_FOLDER=$1
REGEX=$2
TBSS_FOLDER=$3


echo "merging all upsampled FA images into single 4D image..."
fslmerge -t $TBSS_FOLDER/all_FA `imglob $DATA_FOLDER/$REGEX`
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
