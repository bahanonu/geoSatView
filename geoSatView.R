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
	# 2020.08.24 [12:22:03] - Made downloading of the files parallel.
	# 2020.09.11 [11:26:20] - Added additional crop type and save movie file based on system time. Automatically check for and create sub-directories.
	# 2020.09.13 [20:20:02] - Make this function call either NOAA or zoomEarth based download with user options to start.
# TODO
	# Add a GUI so users can pick two crop areas and will automatically do the rest
	# Potentially convert to EBImage for processing images, could be faster.


# =================================================
# Load necessary packages
for (i in c(1:2)) {
	lapply(c("xml2","rvest","imager","magick",'grid',"HelpersMG","suncalc","av","parallel","webshot","svDialogs"),FUN=function(file){if(!require(file,character.only = TRUE)){install.packages(file,dep=TRUE);}})
}

# Ask user for type of download
userChoice = dlg_list(c("NOAA","zoomEarth"), multiple = TRUE, title='Select satellite download location')$res

# Ask user
vidDlgList = c("1 = Save video with R 'av' package","2 = Save video with ffmpeg (faster)")
createVidFlag = dlg_list(vidDlgList, title=paste0("1 = Save video with R 'av' package","2 = Save video with ffmpeg"), multiple = TRUE)$res
createVidFlag = which(vidDlgList %in% createVidFlag)

thisFileFolder <- function() {
	# From https://stackoverflow.com/a/15373917
	cmdArgs <- commandArgs(trailingOnly = FALSE)
	needle <- "--file="
	match <- grep(needle, cmdArgs)
	if (length(match) > 0) {
		# Rscript
		return(dirname(normalizePath(sub(needle, "", cmdArgs[match]))))
	} else {
		# 'source'd via R console
		return(dirname(normalizePath(sys.frames()[[1]]$ofile)))
	}
}

geoSatViewPath = thisFileFolder()

source(file.path(geoSatViewPath,"R","geoSatView_makeVideoList.R"))

if (!length(userChoice)) {
	cat("You canceled the choice\n")
}else if(userChoice=="NOAA"){
	print(paste0('Running geoSatView: ',userChoice))
	dataDir = 'data_noaa/'
	source(file.path(geoSatViewPath,"R","geoSatView_noaa.R"))
}else if(userChoice=="zoomEarth"){
	print(paste0('Running geoSatView: ',userChoice))
	dataDir = 'data_zoom_earth/'
	source(file.path(geoSatViewPath,"R","geoSatView_zoomEarth.R"))
}