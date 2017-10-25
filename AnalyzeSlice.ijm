macro “AnalyzeSlice” {
	//Get pathname for the directory with all our images
	directory = getDirectory("ImageJ")+ "Hippocampus/";
	list = getFileList(directory);//An array of all the files inside the directory
	Array.sort(list);//TODO: figure out if/why sort is actually necessary.
	for (i = 0; i < list.length; i++) {//Loop through all the files in the directory.
		if (endsWith(list[i], ".tif") || endsWith(list[i], ".jpg") || endsWith(list[i], ".JPEG")){
			/*Make sure the file is an image and not 
			some extraneous text file. TODO: Implement more extensions. */
			open(directory+list[i]);//Open the image.				
			run("Split Channels");//Run the "Split Channels" command on the image.
			close();//Close the blue channel.
			close();//Close the green channel. 


			/*Here is where we try to select a certain percentage of pixels. This way,
			We should be able to find a constant % threshold to use to analyze the
			images, which makes for the most objective standard... I think. TODO: Think.*/
			tissueThreshPerc = 97.5;//We only want the highest X% of pixels to be showing 
			//(X= 100-tissueThresPerc).
			nBins = 256;//Range from 0-255 for the histogram. 
			totalPix = getHeight() * getWidth(); //Total pixels in the image.
			getHistogram(values, count, nBins);/*values is an array which counts from 0-255.
			count is an array from 0 to 255 which contains the histogram counts of all pixels.*/
			size = count.length;//Size is equal to the length of count (256).
			cumSum = 0;
			for (j = 0; j<size; j++){/*Now we need to calculate the sum of all values of counts.
				This will give us the number of pixels on the page.*/
  				cumSum += count[j];
				}
			tissueValue = cumSum * (tissueThreshPerc / 100); /*We multiply the sum of all pixels
			by the percentage of pixels we want to see to get how many pixels are contained in
			that % 
			*/
			cumSumValues = count; 
			/*now cumulative Sum of values is an array set equal to count.
			We don't want to use count because we want to keep it's values unchanged in case we 
			need it later.*/
			percentageArr = newArray(nBins);/*Create a new array of 256 values which will hold the % 
			of each pixel. This will show us how to get a target X percent of the pixels highlighed. */
			for (k = 1; k<size; k++){
				cumSumValues[k] += cumSumValues[k-1];
				/*The line above makes it so each value in cumSumValues is equal to the % total of all
				 * The previous (inclusive) pixels combined. 
				   The line below turns the cumSumValue into a percentage. */ 
				percentageArr[k] = cumSumValues[k]/totalPix;
			}
			//getThreshold(lower, upper);
			setAutoThreshold("Default dark");
			for (m = 1; m<size; m++){
				if ((percentageArr[m]*100) >= tissueThreshPerc){
					setThreshold(m, 255);
					m=size;
				}
			}
			run("Analyze Particles...", "size=100-500 display clear summarize");
		}
	}
}	