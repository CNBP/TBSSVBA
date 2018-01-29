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
			showProgress((i+1)*(k+1)/(list_roi.length)*(im_list.length)); //adapt!!
			run("Clear Results");
			im_path=path_imgs+im_list[k];
			run("NIfTI-Analyze", "open=["+im_path+"]");

			//open(im_path);
			// etapes supprimables si modification dans rDTIDA pipeline - MODIF FAITE!
			//run("Flip Vertically", "stack");
			//run("Flip Horizontally", "stack");
			//----------------------



			roiManager("Deselect"); 
			roiManager("Measure");
			saveAs("Results",dir_res+replace(im_list[k],".nii","")+"_res.csv");

			for (r=0 ; r<roiManager("count"); r++) 
			{
    				//selectImage(idx);
    				roiManager("select", r);
    				run("Capture Image");
    				saveAs("Tiff", dir_res +"/scrshts/"+replace(im_list[k],".nii","")+"_roi"+(r+1)+".tif");
			}

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
