# rDTIDA Directory Structure

2/09/15

V1.0

Bold **FolderName** represent a new folder.
Italic *WORD* represent execution variable words. For example *TYPE* may be *FA* or *B0* depending on the user's choice.

## 0.Study Initialisation

* **Brains**
	* **CTL01.fid**
	* **EXP01.fid** (will be represented from step III.2 for clarity reasons)

## I.Preprocessing

* Brains
* **DWVolumes**
	* **no_corr**
		* **CTL01**
			* **CTL01_DWI0.nii**
			* **[…]**
			* **CTL01_DWI*n*.nii**
* **ScMaps**
	* **Native**
		* **B0**
			* **CTL01_B0.nii**
		* **FA**
		* **MD**
		* **RAD**
		* **L1**

## I'.User Intervention

* Brains
* DWVolumes
* ScMaps
* **Masks**
	* **Native**
		* **CTL01_mask.nii**
* **Atlas**
	* ***atlas.nii***
	* ***segmentation.nii***

## II.Processing

* Brains
* DWVolumes
* ScMaps
	* Native
	* **Processed**
		* **B0**
			* **CTL01_B0.nii**
		* **FA**
		* **MD**
		* **RAD**
		* **L1**
* Masks
	* Native
	* **Iso_*voxdim***
* Atlas

## III.Segmentation

### III-1.Template Construction

* Brains
* DWVolumes
* ScMaps
* Masks
* Atlas
* **segmentation**
	* **template**
		* **template0.nii.gz**
	* **transfos_to_template**
		* **CTL01_*TYPE*.nii0GenericAffine.mat**
		* **CTL01_*TYPE*.nii1Warp.nii.gz**
		* **CTL01_*TYPE*.nii1InverseWarp.nii.gz**
	* **template_construction**
		* ***various files (unimportant)***

### III-2.Registration to Template
* Brains
* DWVolumes
* ScMaps
* Masks
* Atlas
* segmentation
	* template
	* transfos_to_template
		* CTL01_*TYPE*.nii0GenericAffine.mat
		* CTL01_*TYPE*.nii1Warp.nii.gz
		* CTL01_*TYPE*.nii1InverseWarp.nii.gz
		* **EXP01_*TYPE*.nii0GenericAffine.mat**
		* **EXP01_*TYPE*.nii1Warp.nii.gz**
		* **EXP01_*TYPE*.nii1InverseWarp.nii.gz**
	* template_construction

### III-3.Registration of Template to Atlas

* Brains
* DWVolumes
* ScMaps
* Masks
* Atlas
* segmentation
	* template
		* template0.nii.gz
		* **template_to_atlas_0GenericAffine.mat**
		* **template_to_atlas_1Warp.nii.gz**
		* **template_to_atlas_1InverseWarp.nii.gz**
	* transfos_to_template
	* template_construction

### III-4.Segmentation in Native Space

* Brains
* DWVolumes
* ScMaps
* Masks
* Atlas
* segmentation
	* template
	* transfos_to_template
	* template_construction
	* **scmaps_seg**
		* **seg_CTL01_*TYPE*.nii**
		* **seg_EXP01_*TYPE*.nii**

## IV.Quantification

* Brains
* DWVolumes
* ScMaps
* Masks
* Atlas
* segmentation
* ***study_name*_morph.csv**
