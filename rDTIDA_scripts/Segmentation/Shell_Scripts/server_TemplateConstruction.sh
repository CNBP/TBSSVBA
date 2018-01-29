#!/bin/bash
CURDIR=`pwd`
COMMAND="antsMultivariateTemplateConstruction2.sh -d 3 -e 0 -i 3 -r 1 -m MI -n 0 -o gl_ -c 1 $CURDIR/rDTIDA/data/scmaps/*.nii.gz"
echo $COMMAND > ./call.txt
$COMMAND
