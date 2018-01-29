#!/bin/bash

SCMAPSPATH=./ScMaps/Processed/$3
FIXEDIMAGE=$1
MOVINGIMAGES=(`ls $SCMAPSPATH/$2`) 

RIG_IT=$4
RIG_CONV=$5

AFF_IT=$6
AFF_CONV=$7

SyN_IT=$8
SyN_CONV=$9

METRIC=${10}
METRIC_PARAM=${11}


RIGIDCONVERGENCE="[$RIG_IT,$RIG_CONV,10]"
RIGIDSHRINKFACTORS="8x4x2x1"
RIGIDSMOOTHINGSIGMAS="4x2x1x0vox"

AFFINECONVERGENCE="[$AFF_IT,$AFF_CONV,10]"
AFFINESHRINKFACTORS="8x4x2x1"
AFFINESMOOTHINGSIGMAS="4x2x1x0vox"

SyNCONVERGENCE="[$SyN_IT,$SyN_CONV,10]"
SyNSHRINKFACTORS="6x4x2x1"
SyNSMOOTHINGSIGMAS="3x2x1x0vox"


for (( i=0; i<${#MOVINGIMAGES[@]}; i++ )); do

	METRIC_COMMAND="${METRIC}[${FIXEDIMAGE},${MOVINGIMAGES[i]},1,${METRIC_PARAM},Regular,0.25]"
	#CCMETRIC="CC[${FIXEDIMAGE},${MOVINGIMAGES[i]},1,16,Regular,0.25]"
	#MattesMETRIC="Mattes[${FIXEDIMAGE},${MOVINGIMAGES[i]},1,32,Regular,0.25]"

	RIGIDSTAGE="--initial-moving-transform [${FIXEDIMAGE},${MOVINGIMAGES[i]},1] \
--transform Rigid[0.1] \
--metric ${METRIC_COMMAND} \
--convergence $RIGIDCONVERGENCE \
--shrink-factors $RIGIDSHRINKFACTORS \
--smoothing-sigmas $RIGIDSMOOTHINGSIGMAS"

	AFFINESTAGE="--transform Affine[0.1] \
--metric ${METRIC_COMMAND} \
--convergence $AFFINECONVERGENCE \
--shrink-factors $AFFINESHRINKFACTORS \
--smoothing-sigmas $AFFINESMOOTHINGSIGMAS"

	DEFORMABLESTAGE="--transform SyN[0.1,3,0] \
--metric ${METRIC_COMMAND} \
--convergence $SyNCONVERGENCE \
--shrink-factors $SyNSHRINKFACTORS \
--smoothing-sigmas $SyNSMOOTHINGSIGMAS"


	
	FILENAME=`basename ${MOVINGIMAGES[i]}`
	OUTPUTNAME=./segmentation/transfos_to_template/$FILENAME
	COMMAND="antsRegistration --dimensionality 3 --float 0 -u 1 -w [0.01,0.99] \
--output $OUTPUTNAME \
$RIGIDSTAGE $AFFINESTAGE $DEFORMABLESTAGE"

	echo $COMMAND > ./segmentation/job_to_template_${i}_metriclog.txt
	$COMMAND

done



