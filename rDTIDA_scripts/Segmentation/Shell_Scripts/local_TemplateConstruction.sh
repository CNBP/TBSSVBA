#!/bin/bash
SCMAP_TYPE=$1
REGEX=$2

INIT_RIG=$3
METRIC=$4
UPDATE_IT=$5

INIT_RIG_IT=$6
INIT_RIG_CONV=$7

RIG_IT=$8
RIG_CONV=$9

AFF_IT=${10}
AFF_CONV=${11}

SyN_IT=${12}
SyN_CONV=${13} #NON USED FOR NOW

nargs=$#

TEMP_CONS_SCRIPT="../Scripts/Segmentation/Shell_Scripts/antsMultivariateTemplateConstruction2_Opt.sh"

#REWRITE PARAMS OF antsMultivariateTemplateConstruction2.sh
#each line that can be modified as been marked by '#customable_*' which allows to replace it with
#user entered values

if [[ $nargs -gt 5 ]]; then
	TEMP_CONS_SCRIPT_CUST="../Scripts/Segmentation/Shell_Scripts/antsMultivariateTemplateConstruction2_custom.sh"
	cp $TEMP_CONS_SCRIPT $TEMP_CONS_SCRIPT_CUST
	

	N=`awk '/#customable_SyN/{print NR}' $TEMP_CONS_SCRIPT_CUST`  #find line number
	REP_STR="MAXITERATIONS=$SyN_IT #CUSTOMIZED"  #new value
	sed -i ''$N's/.*/'"$REP_STR"'/' $TEMP_CONS_SCRIPT_CUST #replace line
	

	N=`awk '/#customable_init_rig/{print NR}' $TEMP_CONS_SCRIPT_CUST`
	REP_STR='stage1="-t Rigid[0.1] ${IMAGEMETRICSET} -c ['$INIT_RIG_IT','$INIT_RIG_CONV',10] -f 8x4x2x1 -s 4x2x1x0 -o ${outdir}\/rigid${i}_" #CUSTOMIZED' #ATTENTION to escape '/' characters!!
	sed -i ''$N's/.*/'"$REP_STR"'/' $TEMP_CONS_SCRIPT_CUST 
	

	N=`awk '/#customable_rig/{print NR}' $TEMP_CONS_SCRIPT_CUST`
	REP_STR='stage1="-t Rigid[0.1] ${IMAGEMETRICLINEARSET} -c ['$RIG_IT','$RIG_CONV',10] -f 8x4x2x1 -s 4x2x1x0" #CUSTOMIZED'
	sed -i ''$N's/.*/'"$REP_STR"'/' $TEMP_CONS_SCRIPT_CUST 
	

	N=`awk '/#customable_aff/{print NR}' $TEMP_CONS_SCRIPT_CUST`
	REP_STR='stage2="-t Affine[0.1] ${IMAGEMETRICLINEARSET} -c ['$AFF_IT','$AFF_CONV',10] -f 8x4x2x1 -s 4x2x1x0" #CUSTOMIZED'
	sed -i ''$N's/.*/'"$REP_STR"'/' $TEMP_CONS_SCRIPT_CUST

	TEMP_CONS_SCRIPT=$TEMP_CONS_SCRIPT_CUST
fi
#QUICK
#TEMP_CONS_SCRIPT="../Scripts/Segmentation/Shell_Scripts/antsMultivariateTemplateConstruction2_Quick.sh"

MAKE_EXEC="chmod +x $TEMP_CONS_SCRIPT"
$MAKE_EXEC

#QUICK
#COMMAND="$TEMP_CONS_SCRIPT -d 3 -e 0 -i 3 -m MI -n 0 -o segmentation/template_construction/rDTIDA_ -c 0 ./ScMaps/Processed/$SCMAP_TYPE/*.nii"

COMMAND="$TEMP_CONS_SCRIPT -d 3 -e 0 -i $UPDATE_IT -r $INIT_RIG -m $METRIC -n 0 -o segmentation/template_construction/ -c 0 ./ScMaps/Processed/$SCMAP_TYPE/$REGEX"


$COMMAND

