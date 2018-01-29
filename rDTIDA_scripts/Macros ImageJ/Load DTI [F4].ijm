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
