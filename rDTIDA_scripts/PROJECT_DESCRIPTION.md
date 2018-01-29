# rDTIDA

2/09/15

V1.0

## Introduction

This analysis pipeline is meant to analyse the diffusion data obtain on rat pups.
To allow the comparison of two groups, it registers each brain to a reference atlas and quantifies the size of each region (as labeled in the reference atlas).

The Analysis pipeline is composed of 4 main phases :
* I.Preprocessing
* II.Processing
* III.Segmentation
	* III-1 : Template Construction
	* III-2 : Registration to Template
	* III-3 : Registration of Template to Atlas
	* III-4 : Segmentation in Native Space
* IV.Quantification

## The rDTIDA Pipeline

### 0.Study Initialisation
To start a study, one must create a folder s_*study_name* which must contain a folder named "Brains" containing the .fid folders

### I.Preprocessing

#### Description
This first phase computes and creates the different scalar maps derived from the fitting of the tensor to the data.
The different types of scalar maps are the non-diffusion weighted images (B0), fractional anisotropy (FA), radial diffusivity (RAD), mean diffusivity (MD) and the first eigenvalue of the tensor (L1).

### I'. User intervention
Once phase I step is succesfully conducted, one may manually create the masks that will be used in the next phase.
The user may also choose what kind of scalar map will be used for the following phases. This is for the user to choose the more appropriate type of image driving the registration steps.
Also a folder named "Atlas" containing the reference atlas and its segmentation must be added to complete the final steps.

### II.Processing

#### Description
This phase prepares the chosen scalar maps before the segmentation phase. The maps go under several treatments:
* 1. Isotropisation to a user defined resolution
* 2. Masking
* 3. Rescaling (not by default but for some reasons the user may want to artificially modify the voxel's dimensions scale)
* 4. Reorientation


### III.Segmentation

#### Description
This phase conducts the segmentation of each individual map based on the segmentation on the specified atlas. This is done in four steps:
* 1. Construction of a template from the selected maps.
* 2. Regsitration of the remaining maps to the template.
* 3. Registration of the template to the specified atlas.
* 4. Segmentation of the maps by applying the inverse of transforms that warp the map to the template (step 1 or 2) and those that warp the template to the atlas (step 3).



### IV.QUANTIFICATION

#### Description
In this last phase, the size of every labeled zone is quantified (counting the voxels) and this data is summarised for each volume in a table.
