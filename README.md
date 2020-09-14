# geoSatView

## Downloads GOES (GEOS-16 or GEOS-17 currently) satellite data and makes video animation using [R](https://www.r-project.org/).

This script performs the following actions:
- Downloads GOES (GEOS-16 or GEOS-17 currently) satellite data (https://cdn.star.nesdis.noaa.gov/GOES16/ABI/SECTOR/psw/GEOCOLOR/) into `data` folder.
- Crops the image (default is focused on California and the Bay Area).
- Combines the cropped images and associated timestamps into a single image and saves to `data_crop` folder.
- Then saves out a video file (default `mp4`) to `video` folder.

### Usage
To run, download R then make the working directory in `R` the repository root directory and type the below.

```R
source('geoSatView.R')
```

Below is an example output. The script is also a useful reference for those looking to manipulate images in R and create a video.

![tmp2-1](https://user-images.githubusercontent.com/5241605/67650471-471b6180-f8fa-11e9-9731-87a24b11edf4.gif)

Notes:
- Open `geoSatView.R` to edit further from defaults as needed.
- [ImageJ](https://imagej.nih.gov/ij/) is a useful tool for adjusting the crop defaults.
- The script will skip existing files during downloading and cropping. For cropping, delete all files in the directory if want to make a fresh video.

## License

Copyright (c) 2018–2020 Biafra Ahanonu

This program is free software: you can redistribute it and/or modify it under the terms of the GNU. Attribution is appreciated, but not required, if parts of the software are used elsewhere.