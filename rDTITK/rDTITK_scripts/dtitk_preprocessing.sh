#!/bin/bash

source ~/.bash_profile

TENSOR_FOLDER=$1
OUTFOLDER=$2
DTI_TENSORS=(`ls $TENSOR_FOLDER/*.nii.gz`)
TENSOR_OUT=$3



#echo "--------------- REORINTING GRADIENT TABLE (NOT REALLY) ---------------" >> $OUTFOLDER/preprocessing.txt
#echo >> $OUTFOLDER/preprocessing.txt

#for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do


#    FILENAME=`basename ${DTI_TENSORS[i]}`

#    COMMAND="TVtool -in ${DTI_TENSORS[i]} -reorient -euler 180 0 0 -out $TENSOR_OUT/$FILENAME"

#	echo $COMMAND >> $OUTFOLDER/preprocessing.txt
#	$COMMAND

#done


echo >> $OUTFOLDER/preprocessing.txt
echo "--------------- CHECKING FOR OUTLIERS ---------------" >> $OUTFOLDER/preprocessing.txt
echo >> $OUTFOLDER/preprocessing.txt

for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

    FILENAME=`basename ${DTI_TENSORS[i]} | cut -d '.' -f 1`

    COMMAND="TVtool -in ${DTI_TENSORS[i]} -norm"

    echo $COMMAND >> $OUTFOLDER/preprocessing.txt
    $COMMAND

    COMMAND="SVtool -in $1/${FILENAME}_norm.nii.gz -stats"

    echo $COMMAND >> $OUTFOLDER/preprocessing.txt
    $COMMAND >> $OUTFOLDER/norm_stats.txt
    echo >> $OUTFOLDER/norm_stats.txt

    COMMAND="rm $1/${FILENAME}_norm.nii.gz"

    echo $COMMAND >> $OUTFOLDER/preprocessing.txt
    $COMMAND


done

echo >> $OUTFOLDER/preprocessing.txt
echo "--------------- CHECKING IF TENSORS ARE SPD ---------------" >> $OUTFOLDER/preprocessing.txt
echo >> $OUTFOLDER/preprocessing.txt

for (( i=0; i<${#DTI_TENSORS[@]}; i++ )); do

    FILENAME=`basename ${DTI_TENSORS[i]}`
    BASENAME=`echo $FILENAME | cut -d '.' -f 1`

    COMMAND="TVtool -in ${DTI_TENSORS[i]} -spd -out $TENSOR_OUT/$FILENAME"

    echo $COMMAND >> $OUTFOLDER/preprocessing.txt
    $COMMAND >> $OUTFOLDER/spd_info.txt
    echo >> $OUTFOLDER/spd_info.txt

#Deuxieme iteration pour voir cb de non-spd il reste (voir spd_info.txt

    COMMAND="TVtool -in ${DTI_TENSORS[i]} -spd -out $TENSOR_OUT/${BASENAME}_2i.nii.gz"

    echo $COMMAND >> $OUTFOLDER/preprocessing.txt
    $COMMAND >> $OUTFOLDER/spd_info.txt
    echo >> $OUTFOLDER/spd_info.txt


    COMMAND="rm $TENSOR_OUT/${BASENAME}_2i.nii.gz"
    echo $COMMAND >> $OUTFOLDER/preprocessing.txt
    $COMMAND

    COMMAND="mv ${TENSOR_FOLDER}/${BASENAME}_nonSPD.nii.gz $OUTFOLDER"
    echo $COMMAND >> $OUTFOLDER/preprocessing.txt
    $COMMAND

done

