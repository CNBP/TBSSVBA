macro "Save ROIset and place [s]" //screenshot of the ROI superimposed to the RGB image
{
	// A ADAPTER !!
	pluginPath="/Applications/ImageJ/plugins/DTI ROI - L.A./directories.txt";

	// Read saved path

	str=File.openAsString(pluginPath);
	lines=split(str,"\n");
	dir_roi=lines[0];
	dir_tif=lines[1];

	Dialog.create("Select directories");
	Dialog.addMessage("Do you want to change the current directories for saving the ROI' Sets and ROI's position screenshot?\n");
	Dialog.addMessage("ROI Sets directory : " + dir_roi)
	Dialog.addMessage("ROI Screenshots directory : " + dir_tif + "\n")
	Dialog.addCheckbox("Change Directories?",false);
	Dialog.show();
	changeDir=Dialog.getCheckbox();

	if (changeDir)
	{
		// Get directories
		dir_roi=getDirectory("Choose directory to save ROIset to");
		dir_tif=getDirectory("Choose a different directory for tif images");
	
		// Save locations to file
		fileID=File.open(pluginPath);
		print(fileID,dir_roi + "\n" + dir_tif);
		File.close(fileID);
	}

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
