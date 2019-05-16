Multiview Extended Video with Activities (MEVA) Dataset README

1.0 Overview

The MEVA dataset was collected as part of the Intelligence Advanced
Research Projects Activity (IARPA) DIVA program
(https://www.iarpa.gov/index.php/research-programs/diva). It is
designed to support performers on the DIVA program and the broader
research community focused on activity detection in data from
simultaneous, multi-camera environments.

The data was collected using a variety of commercial, off-the-shelf
cameras to replicate equipment used in typical real-world
environments. The data may therefore include irregularities not seen
in high-end, research-grade video data. Further, there has been no
post-processing to the data with the exception of rotating data from
camera G639.

2.0 Directory Structure & Filenames

The directory organization follows a video/facility/date/hour/video
clip structure. Video files are typically five minutes in length, and
filenames have the following structure:

YYYY-MM-DD.timestamp-start.timestamp-end.camera-location.camera-number.

For example, file 2018-03-07.16-50-00.16-55-00.admin.G329.avi was:
    * Recorded on March 7, 2018 starting at 16:50:00. 
    * Recording ends at 16:55:00. 
    * The camera was located in/on the admin building (see metadata, below).
    * The camera number was G329. 

The video data is organized into a four-level hierarchy of facility
id, date, then hour, then videos. Data was recorded on several NAS
units whose clocks were synchronized via GPS. The NAS software was
configured to record five-minute clips; however, clips do not all
necessarily start or stop on even five-minute boundaries. A few clips
may be shorter than five minutes due to transmission errors.

3.0 MEVA Known Facility Definitions

This 1.0 release of the MEVA dataset releases the MEVA Known Facility
set 1 (KF1). Various metadata, including a facility site map, camera
model information, and more are on this drive in the â€˜doc/KF1â€™
directory.

4.0 License & Citation

The "Multiview Extended Video with Activities" (MEVA) dataset by
Kitware Inc. and the Intelligence Advanced Research Projects Activity
(IARPA) is licensed under a Creative Commons Attribution 4.0
International License (http://creativecommons.org/licenses/by/4.0.)
See LICENSE-MEVA-dataset.txt for the full license.

5.0 Acknowledgment 

The Multiview Extended Videos with Activities (MEVA) dataset
collection work is supported by Intelligence Advanced Research
Projects Activity contract number 2017-16110300001.

6.0 Changelog
25-mar-2019: Initial release
