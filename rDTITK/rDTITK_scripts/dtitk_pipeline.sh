#!/bin/bash


../Registration_Analysis/dtitk_preprocessing.sh tensor

../Registration_Analysis/dtitk_preRegistration.sh tensor SAL*_tensor.nii.gz tensor/SALK05_tensor.nii.gz
../Registration_Analysis/dtitk_templateBootstrap.sh tensor SAL*_tensor_aff.nii.gz bootstrapping_subset.txt
../Registration_Analysis/dtitk_templateConstruction.sh tensor/mean_initial.nii.gz tensor SAL*_tensor.nii.gz subjs.txt
