geoSatView_zoomEarth <- function(dataDir,createVidFlag){
# Biafra Ahanonu
# Started: 2020.09.11 [‏‎18:46:52]
# Downloads and makes a video from zoom.earth
# Requires ffmpeg if createVidFlag==2
# Changelog
	# 2020.09.13 [20:10:19] - ffmpeg concat requires paths relative to the text file, fix so that is what is done.
	# 2020.09.15 [16:43:22] - Add parallel support for downloading

# =================================================
# Setup cluster
# detect the number of cores
n.cores <- detectCores()

# =================================================
# PARAMETERS

# SAVE LOCATIONS
# dataDir = dataDirList[[userChoice]]
# dowloadDir = file.path(dataDir,'data')
dowloadDir = file.path('data')
downloadLocation = file.path(dataDir,'data')
downloadLocationCrop = file.path(dataDir,'data_crop')
downloadLocationVideo = file.path(dataDir,'video')

# Int: download up to this number of days ago
daysPast = 7
# Get the start end end times
startTime = paste0(Sys.Date()-daysPast,",00:00")
endTime = paste0(Sys.Date(),paste0(","),format(Sys.time(),'%H:%M'))
timeSetp = seq.POSIXt(from=as.POSIXct(strptime(startTime, "%Y-%m-%d,%H:%M"),tz = "UTC"),
	   to=as.POSIXct(strptime(endTime, "%Y-%m-%d,%H:%M"),tz = "UTC"),
	   by="5 min")

# https://zoom.earth/#view=44,-140.6,5z/date=,-7/layers=fires
zoomEarthBaseUrl = "https://zoom.earth/#view=44,-140.6,5z/date=%s,-7/layers=fires"

# Int: size of chunks for webshot
chunkSize = 50

# Automatically get UTC time for sunset and sunrise near San Francisco, CA
sunTime = getSunlightTimes(Sys.Date(),lat = 37.7749, lon = -122.4194,tz = "America/Los_Angeles")
sunsetTime = as.numeric(format(strptime(sunTime$dusk,"%Y-%m-%d %H:%M:%S"),'%H%M'))
sunriseTime = as.numeric(format(strptime(sunTime$dawn,"%Y-%m-%d %H:%M:%S"),'%H%M'))

# VIDEO SETTINGS
# Binary: 1 = create AVI video, 0 = do not create video, 2 = create using ffmpeg system call (fastest)
# createVidFlag = 2
framerate = 60
runID = format(Sys.time(),'%Y_%m_%d_%H-%M-%S')
fileListSavePath = file.path(downloadLocationVideo,paste0('geoSatView_zoomEarth_vidList_',runID,'.txt'))
videoName = paste0('geoSatView_zoomEarth_',runID,'.mp4')
videoName = file.path(downloadLocationVideo,videoName)

# =================================================
# HELPER FUNCTIONS
webshotDownload <- function(urlListInput,fileListInput,delayInput=0.5){
	webshot(urlListInput, file = fileListInput,
		zoom = 2, vwidth = 1500, vheight = 700,
		cliprect = c(175,400,960, 550),
		delay = delayInput)
}

downloadImagesZoomEarth <- function(i,urlList,fileList,chunkSize,nFiles){
	# Download in chunks (to avoid errors) using webshot
	library(webshot)
	if(nFiles>0){
		# for (i in seq(1,nFiles,chunkSize)) {
			if((i+chunkSize)>nFiles){
				endI = nFiles
			}else{
				endI = i+(chunkSize-1)
			}
			sliceI = c(i:endI)
			print(c(i,endI))
			webshotDownload(urlList[sliceI],fileList[sliceI],0.5)
		# }
	}else{
		print('Do not need to download files.')
	}
}

downloadImagesZoomEarthRe <- function(chunkSize,urlList,fileList,chunkSize2,nFiles){
	# Download in chunks (to avoid errors) using webshot
	library(webshot)
	if(nFiles>0){
		# Re-download any incomplete or incorrectly downloaded date-time screen captures
		urlListRe = c()
		fileListRe = c()
		fileSizeRe = c()
		for (fileNo in c(1:nFiles)) {
			fileSizeH = file.info(fileList[fileNo])$size
			fileSizeRe = c(fileSizeRe,fileSizeH)
			if(fileSizeH<178744|!file.exists(fileList[fileNo])){
				urlListRe = c(urlListRe,urlList[fileNo])
				fileListRe = c(fileListRe,fileList[fileNo])
			}
		}
		if(length(urlListRe)>0){
			webshotDownload(urlListRe,fileListRe,1)
		}else{
			print('Do not need to re-download files.')
		}
	}
}

# =================================================
# Create sub-directories if they do not already exist.
for (dirHere in c(downloadLocation,downloadLocationCrop,downloadLocationVideo)) {
	if(dir.exists(dirHere)==TRUE){
		print(paste0('Directory exists: ',dirHere))
	}else{
		print(paste0('Creating: ',dirHere))
		dir.create(dirHere)
	}
}

# =================================================
# MAIN
urlList = c()
fileList = c()

for (i in c(1:length(timeSetp))) {
	if(substr(timeSetp[i],12,16)!=""){
		filePathH = file.path(downloadLocation,paste0(substr(timeSetp[i],1,10),"_",substr(timeSetp[i],12,13),substr(timeSetp[i],15,16),'.jpg'))
		if(!file.exists(filePathH)){
			# urlList = c(urlList,paste0(zoomEarthBaseUrl,substr(timeSetp[i],1,10),",",substr(timeSetp[i],12,16),",-7/layers=fires"))
			thisURL = sprintf(zoomEarthBaseUrl,paste0(substr(timeSetp[i],1,10),",",substr(timeSetp[i],12,16)))
			urlList = c(urlList,thisURL)
			print(paste0(substr(timeSetp[i],1,10),"_",substr(timeSetp[i],12,13),substr(timeSetp[i],15,16),'.jpg'))
			fileList = c(fileList,filePathH)
		}
	}
}

nFiles = length(fileList)

if(nFiles>0){
	system.time({
		clust <- makeCluster(n.cores,outfile="progress_zoomEarth.log")
		successList <- parLapply(clust,
			seq(1,nFiles,chunkSize),
			fun=downloadImagesZoomEarth,
			urlList=urlList,fileList=fileList,chunkSize=chunkSize,nFiles=nFiles)
	})
	# system.time({
	# 	clust <- makeCluster(n.cores,outfile="progress_zoomEarth.log")
	# 	successList <- parLapply(clust,
	# 		seq(1,nFiles,chunkSize),
	# 		fun=downloadImagesZoomEarthRe,
	# 		urlList=urlList,fileList=fileList,chunkSize=chunkSize,nFiles=nFiles)
	# })
	downloadImagesZoomEarthRe(chunkSize,urlList,fileList,chunkSize,nFiles)

	stopCluster(clust)
}


# =================================================
# Save as a video for later viewing
if(createVidFlag==2){
	# Make and save out files list
	exportFileListTmp = geoSatView_makeVideoList(downloadLocation,fileListSavePath,createVidFlag,sunsetTime,sunriseTime,downloadLocationVideo,dowloadDir)

	shellCmd = paste0('ffmpeg.exe -r "',framerate,'" -f concat -safe 0 -i ',fileListSavePath,' -c:v libx264 -pix_fmt yuv420p "',videoName,'"')
	shell(shellCmd)
	# system(shellCmd)
}else if(createVidFlag==1){
	# Make and save out files list
	videoImg = geoSatView_makeVideoList(downloadLocation,fileListSavePath,createVidFlag,sunsetTime,sunriseTime,downloadLocationVideo,dowloadDir)
	image_write_video(videoImg, path = videoName, framerate = 40)
}else{
	print('Invalid video create settings.')
}

}