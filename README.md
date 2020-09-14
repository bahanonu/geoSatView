# geoSatView

## Downloads GOES (GEOS-16 or GEOS-17 currently) or [Zoom Earth](zoom.earth) satellite data and makes video animation using [R](https://www.r-project.org/).

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
To run, download `R` (or `RStudio`) then make the working directory in `R` the repository root directory and type the below. Users can choose between NOAA or [zoom.earth](zoom.earth) sources to create the video.

```R
source('geoSatView.R')
```

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

This program is free software: you can redistribute it and/or modify it under the terms of the GNU. Attribution is appreciated, but not required, if parts of the software are used elsewhere.