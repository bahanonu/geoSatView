# geoSatView

## Downloads GOES (GEOS-16 or GEOS-17 currently) or [Zoom Earth](zoom.earth) satellite data and makes video animation using [R](https://www.r-project.org/).

![NOAA](https://user-images.githubusercontent.com/5241605/93047255-f0ea0680-f610-11ea-92a0-7839acea87a0.gif)

This script performs the following actions:
- For `NOAA` data:
  - Downloads GOES (GEOS-16 or GEOS-17 currently) satellite data (https://cdn.star.nesdis.noaa.gov/GOES16/ABI/SECTOR/psw/GEOCOLOR/) into `data` folder.
  - Crops the image (default is focused on California and the Bay Area).
  - Combines the cropped images and associated timestamps into a single image and saves to `data_crop` folder.
- For `Zoom Earth` (which includes fire locations) data:
  - Downloads a screenshot at 5 min intervals of the [zoom.earth](zoom.earth) website centered on the West Coast of the United States.
- Then saves out a video file (default `mp4`) to `video` folder.

The script requires `ffmpeg` be installed on users systems if

### Usage
To run:
- Download `R` (or `RStudio`).
- Either download a zip of the repository or make a new folder and clone with `git clone https://github.com/bahanonu/geoSatView.git`.
- Make the working directory in `R` the repository root directory and type the below.
- Alternatively, users can download files to a separate folder by making that folder the active working directory then running `source('path/to/geoSatView.R');geoSatView()`
- Users can choose between NOAA or [zoom.earth](zoom.earth) sources to create the video. Videos are stored in the `data_noaa` or `data_zoom_earth` sub-directories that are created.
- Downloading is parallelized, so output will be stored in `progress.log` in root directory.

```R
source('geoSatView.R')
geoSatView()
```

Users can alternatively call the script without user input by using the available options.

```R
source('geoSatView.R')
geoSatView(
    dataDirList=list(NOAA=file.path(getwd(),'data_noaa/'),zoomEarth=file.path(getwd(),'data_zoom_earth/')),
    userChoice=c("NOAA","zoomEarth"),
    createVidFlag=c(2)
)
```

__Options__
```
dataDirList
    list(), format: c(NOAA="PATH_TO_NOAA_DATA",zoomEarth="PATH_TO_zoomEarth_DATA")
userChoice
    char vector, options: "NOAA", "zoomEarth". Can input both c("NOAA","zoomEarth").
createVidFlag
    vector, options: Binary: 1 = create AVI video, 0 = do not create video, 2 = create using ffmpeg system call (fastest)
```

### Example output

Below is an example output. The script is also a useful reference for those looking to manipulate images in `R` and create videos. The script can also be run from an empty directory, as long as you set that directory as `R`'s working directory.

__NOAA__

![NOAA](https://user-images.githubusercontent.com/5241605/93047255-f0ea0680-f610-11ea-92a0-7839acea87a0.gif)

__Zoom Earth__

![zoomEarth](https://user-images.githubusercontent.com/5241605/93047217-d57efb80-f610-11ea-909e-ab6186a56d5d.gif)

Notes:
- Open `geoSatView.R` to edit further from defaults as needed.
- [ImageJ](https://imagej.nih.gov/ij/) is a useful tool for adjusting the crop defaults.
- The script will skip existing files during downloading and cropping. For cropping, delete all files in the directory if want to make a fresh video.

## License

Copyright (c) 2018–2020 Biafra Ahanonu

This project is licensed under the terms of the MIT license. See LICENSE file for details.