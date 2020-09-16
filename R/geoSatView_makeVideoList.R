geoSatView_makeVideoList <- function(downloadLocation,fileListSavePath,createVidFlag,sunsetTime,sunriseTime,downloadLocationVideo,dowloadDir,fileTimeStart=12,fileTimeEnd=16,userChoice="zoomEarth",flagGoIgnore=TRUE,flagGoNegNum=20) {
	# Makes
	# Changelong
		# 2020.09.16 [10:22:03] -  Allow speeding through night time.

	fileList <- list.files(downloadLocation, "jpg")
	nLinks = length(fileList)
	exportFileList = c()
	videoImg = c()
	flagGoCount = flagGoNegNum
	for (fileNo in c(1:nLinks)) {
		fileName = fileList[fileNo]

		# Get the filetime and exclude most night images
		fileTime = as.numeric(substr(fileName,fileTimeStart,fileTimeEnd))
		if(is.na(fileTime)){next}

		if(userChoice=="NOAA"){
			flagGo = fileTime<sunsetTime|fileTime>sunriseTime
			# flagGo = TRUE
		}else if(userChoice=="zoomEarth"){
			flagGo = fileTime>sunriseTime&fileTime<sunsetTime
		}
		if(flagGo==FALSE&flagGoIgnore==TRUE){
			# flagGo = runif(1)>0.8
			if(flagGoCount==flagGoNegNum){
				flagGo = TRUE
			}
			flagGoCount = flagGoCount - 1
			if(flagGoCount==0){
				flagGoCount = flagGoNegNum
			}
		}

		destfile = file.path(downloadLocation,fileName)
		# cropDestFile = paste0(downloadLocationCrop,fileName)

		if(file.exists(destfile)&flagGo==TRUE){
			if(createVidFlag==1){
				print(paste0(fileNo,'/',nLinks,' | Loading: ',destfile))
				# Load file
				finalImg <- image_read(destfile)
				# Concatenate images to later create video file
				if(createVidFlag==1){
					if(length(videoImg)==0){
						videoImg = finalImg
					}else{
						videoImg = image_join(videoImg,finalImg)
					}
				}
			}else if(createVidFlag==2){
				print(paste0(fileNo,'/',nLinks,' | Adding to list: ',destfile))
				exportFileList = c(exportFileList,paste0("file '../",dowloadDir,"/",fileName,"'"))
			}
		}
	}
	write.table(exportFileList, file = fileListSavePath, sep = "\t",row.names = FALSE, col.names = FALSE, quote = FALSE)

	if(createVidFlag==1){
		return(videoImg)
	}else if(createVidFlag==2){
		return(exportFileList)
	}
}