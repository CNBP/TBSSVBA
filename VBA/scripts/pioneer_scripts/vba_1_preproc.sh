#!/bin/sh
# run from directory tbss prendre plusieurs fichier dans le sous repertoire FA_to_target
FSLDIR=/usr/local/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR path

folder=$1
regex=$2
outfolder=$3
thresh=$4
sigma=$5

if [ ! -d "$outfolder" ]; then
    echo "making folder $folder"
    mkdir $outfolder
fi


echo "Concatenating images to output single 4D image : all_FA_VBM"
${FSLDIR}/bin/fslmerge -t $outfolder/all_FA_VBM `${FSLDIR}/bin/imglob $folder/$regex`

echo "Creating white matter mask from thresholded mean image at $tresh"
${FSLDIR}/bin/fslmaths $outfolder/all_FA_VBM -Tmean -thr $thresh -bin $outfolder/WM_tracks_mask_$thresh -odt char

echo "Smoothing data with kernel of sigma $sigma"
${FSLDIR}/bin/fslmaths $outfolder/all_FA_VBM -s $sigma $outfolder/all_FA_VBM_s$sigma

