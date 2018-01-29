macro "Load DTI [F4]"
{
	setBatchMode(true); 
	while(nImages>0)
	{
		selectImage(nImages);
		close();
	}
	setBatchMode(false); 
	run("DTI Load Matlab");
	
	for (i=1;i<=nImages;i++)
	{
		selectImage(i);
		run("Enhance Contrast", "saturated=0.35");
	}
	
	run("DTI RGB Map Matlab");
	run("Tile");
	run("Synchronize Windows");
	//empty RoiManager
	rois = newArray(roiManager("count"));
  	for (i=0; i<rois.length; i++)
  	{
      rois[i] = i;
	}
	roiManager("Select",rois);
	roiManager("Delete");
}

macro "Save ROIset and place [s]" //screenshot of the ROI superimposed to the RGB image
{
	dir_roi=getDirectory("Choose directory to save ROIset to");
	dir_tif=getDirectory("Choose a different directory for tif images");
	sbjt=getString("Subject name?","X01");
	//save roiSet
	rois = newArray(roiManager("count"));
  	for (i=0; i<rois.length; i++)
  	{
      rois[i] = i;
	}
	roiManager("Select",rois);
	roiManager("Save",dir_roi+sbjt+".zip")
	setBatchMode(true); 
	//determine rgb image
	idx=0;
	for (i=1; i <= nImages && idx==0; i++)
	{
		selectImage(i);
		if (bitDepth()==24) //=RGB image
			idx=i;
	}
	
	for (i=0 ; i<roiManager("count"); i++) 
	{
    selectImage(idx);
    roiManager("select", i);
    run("Capture Image");
    saveAs("Tiff", dir_tif+sbjt+"_roi"+(i+1)+".tif");
	close();
	}
	
}
macro "Batch Measure DTI [F5]" 
{
	
	run("Set Measurements...", "area mean standard redirect=None decimal=3"); 
	dir = getDirectory("Choose a data Directory "); 
	dir_roi = getDirectory("Choose a ROISets Directory"); 
	dir_res = getDirectory("Choose a Results Directory"); 
	setBatchMode(true); 

	list = getFileList(dir); 
	list_roi = getFileList(dir_roi); 
	
	for (i=0; i<list_roi.length; i++) 
	{
		path_roi=dir_roi+list_roi[i];
		
		if (endsWith(path_roi,".zip"))
			roiManager("Open", path_roi); 

		name=split(list_roi[i],"."); //split in basename and extension
		name=name[0];//keep first part
		idx=index(list,name+"/"); // because directory in this folder
		path_imgs=dir+list[idx];
		im_list=getFileList(path_imgs);
		
		for (k=0; k<im_list.length; k++) 
		{
			showProgress((i+1)*(k+1), (list_roi.length)*(im_list.length)); //adapt!!
			run("Clear Results");
			im_path=path_imgs+im_list[k];
			open(im_path);
			// etapes supprimables si modification dans rDTIDA pipeline - MODIF FAITE!
			//run("Flip Vertically", "stack");
			//run("Flip Horizontally", "stack");
			//----------------------
			roiManager("Deselect"); 
			roiManager("Measure");
			saveAs("Results",dir_res+replace(im_list[k],".nii","")+"_res.csv");

		}
		roiManager("Delete");
		close(); 
	}

         if (isOpen("Results")) 
         { 
                selectWindow("Results"); 
                run("Close"); 
         } 
	

} 
function index(a, value) 
{ 
      for (i=0; i<a.length; i++) 
          if (a[i]==value) return i; 
      return -1; 
} 
