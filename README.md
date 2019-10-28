# `geo_satellite_download`: R-script to download GOES-16 satellite data and make video animation

This script performs the following actions:
- Downloads GOES-16 satellite data (https://cdn.star.nesdis.noaa.gov/GOES16/ABI/SECTOR/psw/GEOCOLOR/)
- Crops the image (default is focused on California and the Bay Area).
- Combines the cropped images and associated timestamps.
- Then saves out a video file (default `mp4`).

Below is an example output. The script is also a useful reference for those looking to manipulate images in R.

![tmp2-1](https://user-images.githubusercontent.com/5241605/67650471-471b6180-f8fa-11e9-9731-87a24b11edf4.gif)

To run, direct `R` to the repository root directory and type the below.

```R
source('geo_satellite_download.R')
```

Notes:
- Open `geo_satellite_download.R` to edit further from defaults as needed.
- [ImageJ](https://imagej.nih.gov/ij/) is a useful tool for adjusting the crop defaults.
- The script will skip existing files during downloading and cropping. For cropping, delete all files in the directory if want to make a fresh video.

## License

Biafra Ahanonu <bahanonu@gmail.com>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU. Attribution is appreciated, but not required, if parts of the software are used elsewhere.