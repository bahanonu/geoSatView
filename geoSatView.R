# geoSatView
	# Biafra Ahanonu
	# started: 2018.11.17
	# Script to download GOES16 GEOCOLOR satellite data to help visualize the November 2018 or October 2019 California Camp Fire
	# Will download and make a cropped movie for any GEOCOLOR data.

# changelog
	# 2019.10.27 - Updated handling of cropping and resizing to make more automatic
	# 2019.10.28 - Removed wget call (since Windows systems do not have by default) and let download.file use curl to avoid issues with image files being corrupt when downloaded using wininet method. Save video to its own directory.
	# 2020.08.19 [11:17:03] - If file outside user specified time window, do not add to video.
	# 2020.08.19 [11:36:16] - Added automatic calculation of sunrise and sunset using suncalc package. Will also automatically load previously cropped images if want to re-create the video output after already downloading/cropping images. Added 'av' package loading.
# TODO
	# Add a GUI so users can pick two crop areas and will automatically do the rest

# Load necessary packages
for (i in c(1:2)) {
	lapply(c("xml2","rvest","imager","magick",'grid',"HelpersMG","suncalc","av"),FUN=function(file){if(!require(file,character.only = TRUE)){install.packages(file,dep=TRUE);}})
}

# =================================================
# PARAMETERS
# Set locations for downloading files along with cropped versions
downloadLocation = paste0(getwd(),'/','data/')
downloadLocationCrop = paste0(getwd(),'/','data_crop/')
downloadLocationVideo = paste0(getwd(),'/','video/')

# Automatically get UTC time for sunset and sunrise near San Francisco, CA
sunTime = getSunlightTimes(Sys.Date(),lat = 37.7749, lon = -122.4194,tz = "UTC")
sunsetTime = as.numeric(format(strptime(sunTime$dusk,"%Y-%m-%d %H:%M:%S"),'%H%M'))
sunriseTime = as.numeric(format(strptime(sunTime$dawn,"%Y-%m-%d %H:%M:%S"),'%H%M'))

# Crop parameters in pixels, based on 2400x2400 input images
# See https://cran.r-project.org/web/packages/magick/vignettes/intro.html
# Crop area for zoomed out view
cropWidth = 1000
cropHeight = 1432
cropX = 0
cropY = 597

# Crop area for zoomed in view
cropWidth2 = 252
cropHeight2 = 368
cropX2 = 206
cropY2 = 422

# Crop area for time stamp on bottom
timeWidth = 1242
timeHeight = 42
timeX = 573
timeY = 2358

# Factor to downsample
cropDownsampleFactor = 2

# Binary: 1 = create AVI video, 0 = do not create video
createVidFlag = 1

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

		# Read the image and make combined zoomed in and zoomed out crop image
		frink <- image_read(destfile)
		cropImg = image_crop(frink, paste0(cropWidth,"x",cropHeight,"+",cropX,"+",cropY))

		cropImg2 = image_crop(cropImg, paste0(cropWidth2,"x",cropHeight2,"+",cropX2,"+",cropY2))
		# cropImg2 = image_border(image_background(cropImg2, "black"), "#000000", "5x5")
		cropImg2 = image_border(image_background(cropImg2, "white"), "#FFFFFF", "6x6")

		# Downsample and ensure height is even
		dsHeight = round(data.frame(image_info(cropImg))$height/cropDownsampleFactor)
		dsWidth = round(data.frame(image_info(cropImg))$width/cropDownsampleFactor)

		if((dsHeight %% 2)!=0){
			dsHeight = dsHeight + 1
		}
		if((dsWidth %% 2)!=0){
			dsWidth = dsWidth + 1
		}
		dsDims = paste0(dsWidth,"x")

		cropImg = image_scale(cropImg,dsDims)
		cropImg2 = image_scale(cropImg2,dsDims)
		combineImg = image_append(c(cropImg,cropImg2),stack = FALSE)
		combineImgInfo = data.frame(image_info(combineImg))

		# Get time-stamp and make the same width as total image
		timeImg = image_crop(frink, paste0(timeWidth,"x",timeHeight,"+",timeX,"+",timeY))
		timeImg = image_scale(timeImg,combineImgInfo$width)
		timeImgInfo = data.frame(image_info(timeImg))
		if((timeImgInfo$height %% 2)!=0){
			timeImg = image_crop(timeImg, paste0(timeImgInfo$width,"x",timeImgInfo$height-1,"+",0,"+",0))
		}

		# Combine images with timestamp
		finalImg = image_append(c(combineImg,timeImg),stack = TRUE)
		# finalImg = image_crop(finalImg, paste0(972,"x",732,"+",0,"+",0))
		finalImgInfo = data.frame(image_info(finalImg))

		# Concatenate images to later create video file
		if(createVidFlag==1){
			if(length(videoImg)==0){
				videoImg = finalImg
			}else{
				videoImg = image_join(videoImg,finalImg)
			}
		}

		# print(image_info(finalImg))
		# dev.new()
		# plot(finalImg)
		# stop()

		jpeg(filename=cropDestFile,quality=100,width=finalImgInfo$width,height=finalImgInfo$height)
		grid.raster(finalImg, width=unit(1,"npc"), height=unit(1,"npc"))
		dev.off()
	}else if(file.exists(cropDestFile)&flagGo==TRUE){
		print(paste0(fileNo,'/',nLinks,' | Loading: ',destfile))
		# Load file
		finalImg <- image_read(cropDestFile)
		# Concatenate images to later create video file
		if(createVidFlag==1){
			if(length(videoImg)==0){
				videoImg = finalImg
			}else{
				videoImg = image_join(videoImg,finalImg)
			}
		}
	}else{
		# # Load file
		# finalImg <- image_read(destfile)
		# # Concatenate images to later create video file
		# if(length(videoImg)==0){
		# 	videoImg = finalImg
		# }else{
		# 	videoImg = image_join(videoImg,finalImg)
		# }

		print(paste0(fileNo,'/',nLinks,' | Don\'t copy: ',destfile))
	}
}

# =================================================
# Save as a video for later viewing
if(createVidFlag==1){
	image_write_video(videoImg, path = paste0(downloadLocationVideo,'geo_satellite_download.mp4'), framerate = 40)
}