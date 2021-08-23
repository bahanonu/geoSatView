# geoSatView
	# Biafra Ahanonu
	# started: 2018.11.17
	# Script to download GOES16 GEOCOLOR satellite data to help visualize the November 2018 or October 2019 California Camp Fire
	# Will download and make a cropped movie for any GEOCOLOR data.
# Inputs
	# dataDirList - list(), format: c(NOAA="PATH_TO_NOAA_DATA",zoomEarth="PATH_TO_zoomEarth_DATA")
	# userChoice - char vector, options: "NOAA", "zoomEarth". Can input both c("NOAA","zoomEarth").
	# createVidFlag - vector, options: Binary: 1 = create AVI video, 0 = do not create video, 2 = create using ffmpeg system call (fastest)

# changelog
	# 2019.10.27 - Updated handling of cropping and resizing to make more automatic
	# 2019.10.28 - Removed wget call (since Windows systems do not have by default) and let download.file use curl to avoid issues with image files being corrupt when downloaded using wininet method. Save video to its own directory.
	# 2020.08.19 [11:17:03] - If file outside user specified time window, do not add to video.
	# 2020.08.19 [11:36:16] - Added automatic calculation of sunrise and sunset using suncalc package. Will also automatically load previously cropped images if want to re-create the video output after already downloading/cropping images. Added 'av' package loading.
	# 2020.08.24 [12:22:03] - Made downloading of the files parallel.
	# 2020.09.11 [11:26:20] - Added additional crop type and save movie file based on system time. Automatically check for and create sub-directories.
	# 2020.09.13 [20:20:02] - Make this function call either NOAA or zoomEarth based download with user options to start.
	# 2020.09.15 [11:50:32] - Wrapped calls to NOAA and Zoom Earth scripts in a function to allow running both in the same run.
	# 2020.09.15 [18:32:21] - Everything inside a function, call with geoSatView.
	# 2020.10.01 [‏‎14:40:25] - Ensure data directories are created.
# TODO
	# Add a GUI so users can pick two crop areas and will automatically do the rest
	# Potentially convert to EBImage for processing images, could be faster.


# =================================================
subfxnLoadPkgs <- function() {
	# Load necessary packages and support files
	for (i in c(1:2)) {
		lapply(c("xml2","rvest","imager","magick",'grid',"HelpersMG","suncalc","av","parallel","webshot","svDialogs","scriptName"),FUN=function(file){if(!require(file,character.only = TRUE)){install.packages(file,dep=TRUE);}})
	}
}

# =================================================
# Necessary functions
thisFileFolder <- function() {
	# Obtains the full path for a script
	# From https://stackoverflow.com/a/15373917
	# cmdArgs <- commandArgs(trailingOnly = FALSE)
	# needle <- "--file="
	# match <- grep(needle, cmdArgs)
	# if (length(match) > 0) {
	# 	# Rscript
	# 	return(dirname(normalizePath(sub(needle, "", cmdArgs[match]))))
	# } else {
	# 	# 'source'd via R console
	# 	return(dirname(normalizePath(sys.frames()[[1]]$ofile)))
	# }
	# @return full path to this script
    cmdArgs = commandArgs(trailingOnly = FALSE)
    needle = "--file="
    match = grep(needle, cmdArgs)
    if (length(match) > 0) {
        # Rscript
        fileNameH = normalizePath(sub(needle, "", cmdArgs[match]))
    } else {
        ls_vars = ls(sys.frames()[[1]])
        if ("fileName" %in% ls_vars) {
            # Source'd via RStudio
            fileNameH = normalizePath(sys.frames()[[1]]$fileName)
        } else {
            # Source'd via R console
            fileNameH = normalizePath(sys.frames()[[1]]$ofile)
        }
    }
    return(dirname(fileNameH))
}
subfxnRunAnalysis <- function(usrChoiceRun,createVidFlag,geoSatViewPath,dataDir) {
	print(sprintf('Running %s analysis.',usrChoiceRun))
	if(usrChoiceRun=="NOAA"){
		print(paste0('Running geoSatView: ',usrChoiceRun))
		geoSatView_noaa(dataDir,createVidFlag)
		# source(file.path(geoSatViewPath,"R","geoSatView_noaa.R"), local=TRUE)
		# source(file.path(geoSatViewPath,"R","geoSatView_noaa.R"))
	}else if(usrChoiceRun=="zoomEarth"){
		print(paste0('Running geoSatView: ',usrChoiceRun))
		geoSatView_zoomEarth(dataDir,createVidFlag)
		# source(file.path(geoSatViewPath,"R","geoSatView_zoomEarth.R"), local=TRUE)
		# source(file.path(geoSatViewPath,"R","geoSatView_zoomEarth.R"))
	}
}

geoSatView <- function(dataDirList=c(),userChoice=c(),createVidFlag=c()){
	# =================================================
	# PARAMETERS
	if(length(dataDirList)==0){
		dataDirList = list()
		dataDirList$NOAA = file.path(getwd(),'data_noaa/')
		dataDirList$zoomEarth = file.path(getwd(),'data_zoom_earth/')
	}

	# =================================================
	# Create sub-directories if they do not already exist.
	for (dirHere in dataDirList) {
		if(dir.exists(dirHere)==TRUE){
			print(paste0('Directory exists: ',dirHere))
		}else{
			print(paste0('Creating: ',dirHere))
			dir.create(dirHere)
		}
	}

	if(length(userChoice)==0){
		# Ask user for type of download
		downloadList = c("NOAA","zoomEarth")
		userChoice = dlg_list(downloadList, multiple = TRUE, preselect = downloadList, title = 'Select satellite download location (for text, space between multiple options)')$res
	}

	if(length(createVidFlag)==0){
		# Ask user
		vidDlgList = c("1 = Save video with R 'av' package","2 = Save video with ffmpeg (faster)")
		createVidFlag = dlg_list(vidDlgList, preselect = vidDlgList[2], title = paste0("1 = Save video with R 'av' package","2 = Save video with ffmpeg"), multiple = TRUE)$res
		createVidFlag = which(vidDlgList %in% createVidFlag)
	}

	if (!length(userChoice)) {
		cat("You canceled the choice\n")
	}else{
		for (usrChoiceHere in userChoice) {
			dataDir =  dataDirList[[usrChoiceHere]]
			subfxnRunAnalysis(usrChoiceHere,createVidFlag,geoSatViewPath,dataDir)
		}
	}
}

# =================================================
# MAIN
# Load helper functions and packages.
subfxnLoadPkgs()
# Load necessary files and get path of function
# geoSatViewPath = thisFileFolder()
source(file.path(thisFileFolder(),"R","geoSatView_makeVideoList.R"))
source(file.path(thisFileFolder(),"R","geoSatView_noaa.R"), local=TRUE)
source(file.path(thisFileFolder(),"R","geoSatView_zoomEarth.R"), local=TRUE)