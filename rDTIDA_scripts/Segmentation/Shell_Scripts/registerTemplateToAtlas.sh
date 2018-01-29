#!/bin/bash

source ~/.bash_profile

FIXEDIMAGE=$1
MOVINGIMAGE=$2

RIG_IT=$3
RIG_CONV=$4

AFF_IT=$5
AFF_CONV=$6

SyN_IT=$7
SyN_CONV=$8

METRIC=${9}
METRIC_PARAM=${10}

RIGIDCONVERGENCE="[$RIG_IT,$RIG_CONV,10]"
RIGIDSHRINKFACTORS="8x4x2x1"
RIGIDSMOOTHINGSIGMAS="3x2x1x0vox"

AFFINECONVERGENCE="[$AFF_IT,$AFF_CONV,10]"
AFFINESHRINKFACTORS="8x4x2x1"
AFFINESMOOTHINGSIGMAS="3x2x1x0vox"

#Param taken from antsMultivariateTemplateConstruction
SyNCONVERGENCE="[$SyN_IT,$SyN_CONV,10]"
SyNSHRINKFACTORS="6x4x2x1"
SyNSMOOTHINGSIGMAS="3x2x1x0vox"

OUTPUTNAME=./segmentation/template/template_to_atlas_

METRIC_COMMAND="${METRIC}[${FIXEDIMAGE},${MOVINGIMAGE},1,${METRIC_PARAM},Regular,0.25]"
#CCMETRIC="CC[${FIXEDIMAGE},${MOVINGIMAGE},1,16,Regular,0.25]"
#MattesMETRIC="Mattes[${FIXEDIMAGE},${MOVINGIMAGE},1,32,Regular,0.25]"

RIGIDSTAGE="--initial-moving-transform [${FIXEDIMAGE},${MOVINGIMAGE},1] \
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

COMMAND="antsRegistration --dimensionality 3 --float 0 -u 1 -v 1 -w [0.01,0.99] \
--output $OUTPUTNAME \
$RIGIDSTAGE $AFFINESTAGE" #$DEFORMABLESTAGE"

echo $COMMAND > ./segmentation/job_temp_to_atlas_metriclog.txt

$COMMAND


	
	
