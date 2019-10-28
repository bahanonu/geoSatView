# Biafra Ahanonu
# started: 2018.11.17
# Script to download GOES16 GEOCOLOR satellite data to help visualize the November 2018 or October 2019 California Camp Fire

# changelog
	# 2019.10.27 - Updated handling of cropping and resizing to make more automatic
	# 2019.10.28 - Removed wget call (since Windows systems do not have by default) and let download.file use curl to avoid issues with image files being corrupt when downloaded using wininet method. Save video to its own directory.
# TODO
	# Add a GUI so users can pick two crop areas and will automatically do the rest

# Load necessary packages
for (i in c(1:2)) {
	lapply(c("xml2","rvest","imager","magick",'grid',"HelpersMG"),FUN=function(file){if(!require(file,character.only = TRUE)){install.packages(file,dep=TRUE);}})
}

# =================================================
# Set locations for downloading files along with cropped versions
downloadLocation = paste0(getwd(),'/','data/')
downloadLocationCrop = paste0(getwd(),'/','data_crop/')
downloadLocationVideo = paste0(getwd(),'/','video/')

# Parameters
sunsetTime = 0060
sunriseTime = 1410
# Crop parameters in pixels, based on 2400x2400 input images
# See https://cran.r-project.org/web/packages/magick/vignettes/intro.html
cropWidth = 996
cropHeight = 1430
cropX = 0
cropY = 597

cropWidth2 = 250
cropHeight2 = 366
cropX2 = 206
cropY2 = 422

timeWidth = 1242
timeHeight = 42
timeX = 573
timeY = 2358

cropDownsampleFactor = 2

# =================================================
# Download parameters and information
# GEOS16 GEOCOLOR URL
URL <- "https://cdn.star.nesdis.noaa.gov/GOES16/ABI/SECTOR/psw/GEOCOLOR/"

# Read in the HTML tree
pg <- read_html(URL)
# Parse out only largest scale GEOS16 images
urlList = html_attr(html_nodes(pg, "a"), "href")
print(head(urlList))
# urlList = urlList[grep('1200x1200',urlList)]
urlList = urlList[grep('2400x2400',urlList)]
urlList = urlList[grep('GOES16',urlList)]

# =================================================
# Download
successList = c()
nLinks = length(urlList)
for (fileNo in c(1:nLinks)) {
	fileName = urlList[fileNo]
	destfile = paste0(downloadLocation,fileName)
	fileURL = paste0(URL,fileName)
	successList[fileNo] = 0
	if(!file.exists(destfile)){
		print(paste0(fileNo,'/',nLinks,' | Downloading: ',destfile))
		res = 0
		res <- tryCatch(
			# download.file(fileURL,
			# 	destfile=destfile,
			# 	method="wget"),
			# wget(fileURL,destfile=destfile,quiet=TRUE,cacheOK = FALSE),
			download.file(fileURL,destfile=destfile,quiet=TRUE,cacheOK = FALSE,method="curl"),
		error=function(e) 1)
		if(length(res)==0||res==0){
			successList[fileNo] = 1
		}else{
			successList[fileNo] = 0
		}
		# if(dat!=1) load("./data/samsungData.rda")
	}else{
		print(paste0(fileNo,'/',nLinks,' | Already downloaded: ',destfile))
		successList[fileNo] = 1
	}
}

# =================================================
# Find all image files, crop, and save to alternative folder
fileList <- list.files(downloadLocation, "jpg")
nLinks = length(fileList)
videoImg = c()

for (fileNo in c(1:nLinks)) {
	fileName = fileList[fileNo]
	destfile = paste0(downloadLocation,fileName)
	cropDestFile = paste0(downloadLocationCrop,fileName)

	# Get the filetime and exclude most night images
	fileTime = as.numeric(substr(fileName,8,11))
	if(is.na(fileTime)){next}
	flagGo = fileTime<sunsetTime|fileTime>sunriseTime

	if(!file.exists(cropDestFile)&flagGo==TRUE){
		print(paste0(fileNo,'/',nLinks,' | Copying: ',destfile))
		# file.copy(destfile,cropDestFile)
		# system(paste0("copy ",destfile," ",cropDestFile))

		# Crop image
		frink <- image_read(destfile)
		cropImg = image_crop(frink, paste0(cropWidth,"x",cropHeight,"+",cropX,"+",cropY))

		cropImg2 = image_crop(cropImg, paste0(cropWidth2,"x",cropHeight2,"+",cropX2,"+",cropY2))
		# cropImg2 = image_border(image_background(cropImg2, "black"), "#000000", "5x5")
		cropImg2 = image_border(image_background(cropImg2, "white"), "#FFFFFF", "5x5")

		cropImg = image_scale(cropImg,"x700")
		cropImg2 = image_scale(cropImg2,"x700")
		combineImg = image_append(c(cropImg,cropImg2),stack = FALSE)
		combineImgInfo = data.frame(image_info(combineImg))

		timeImg = image_crop(frink, paste0(timeWidth,"x",timeHeight,"+",timeX,"+",timeY))
		# Make time-stamp the same width as total image
		timeImg = image_scale(timeImg,combineImgInfo$width)

		finalImg = image_append(c(combineImg,timeImg),stack = TRUE)
		finalImg = image_crop(finalImg, paste0(972,"x",732,"+",0,"+",0))
		finalImgInfo = data.frame(image_info(finalImg))

		# Concatenate images to later create video file
		if(length(videoImg)==0){
			videoImg = finalImg
		}else{
			videoImg = image_join(videoImg,finalImg)
		}
		# print(image_info(finalImg))
		# dev.new()
		# plot(finalImg)
		# stop()

		jpeg(filename=cropDestFile,quality=100,width=finalImgInfo$width,height=finalImgInfo$height)
		grid.raster(finalImg, width=unit(1,"npc"), height=unit(1,"npc"))
		dev.off()
		# stop()
	}else{
		# Load file
		finalImg <- image_read(destfile)
		# Concatenate images to later create video file
		if(length(videoImg)==0){
			videoImg = finalImg
		}else{
			videoImg = image_join(videoImg,finalImg)
		}

		print(paste0(fileNo,'/',nLinks,' | Don\'t copy: ',destfile))
	}
}

# Save as a video for later viewing
image_write_video(videoImg, path = paste0(downloadLocationVideo,'geo_satellite_download.mp4'), framerate = 20)