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

2.0 Access

The MEVA Known Facility Dataset 1 ("KF1") is approximately 331 hours
of video across 4304 video clips totalling 570 GB. It is available via
Amazon Simple Storage Service (S3) via a no-cost download sponsored by
Amazon's AWS Public Dataset Program. The s3 bucket name is:

  mevadata-public-01

Several command line tools and GUI clients are available for
downloading from S3, e.g. s3cmd, available at
https://s3tools.org/s3cmd . Once installed, commands similar to

$ aws s3 sync s3://mevadata-public-01/drop-01 .
$ aws s3 sync s3://mevadata-public-01/drop-02 .

...will synchronize both drop-01 and drop-02 (described below) into
the current directory.

Kitware does not endorse or warrant the utility of any particular S3
client.  Your use of Amazon S3 is subject to Amazon's Terms of
Use. The accessibility of the MEVA KF1 data from Amazon S3 is provided
"as is" without warranty of any kind, expressed or implied, including,
but not limited to, the implied warranties of merchantability and
fitness for a particular use. Please do not contact Kitware for
assistance with Amazon services.

3.0 Directory Structure & Filenames

The data is divided into several drops; each drop has the same
directory structure. As of this writing, there are three drops:

- drop-01 : 2224 clips / 298 GB / 184 hours
- drop-02 : 1184 clips / 107 GB / 74 hours
- drop-03 : 852 clips / 111 GB / 70 hours
- uav-drop-01 : 45 clips / 26 GB / 4.6 hours

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
id, date, then hour, then videos. Ground-camera data was recorded on several NAS
units whose clocks were synchronized via GPS. The NAS software was
configured to record five-minute clips; however, clips do not all
necessarily start or stop on even five-minute boundaries. A few clips
may be shorter than five minutes due to transmission errors or
collection event anomalies. In particular, some clips in drop-02 were
collected at the beginning of the event and may be shorter than five
minutes.

UAV data was collected by a pair of DJI drones at 3840x2160 @ 30fps;
more details can be found in the UAV data readme at

https://s3.amazonaws.com/mevadata-public-01/uav-drop-01/meva-uav-drop-01-readme.pdf

4.0 MEVA Known Facility Definitions

This 1.0 release of the MEVA dataset releases the MEVA Known Facility
set 1 (KF1). Please see https://mevadata.org for more details.

5.0 License & Citation

The "Multiview Extended Video with Activities" (MEVA) dataset by
Kitware Inc. and the Intelligence Advanced Research Projects Activity
(IARPA) is licensed under a Creative Commons Attribution 4.0
International License (http://creativecommons.org/licenses/by/4.0.)
See LICENSE-MEVA-dataset.txt for the full license, available at
https://mevadata.org/resources/MEVA-data-license.txt .

6.0 Acknowledgment

The Multiview Extended Videos with Activities (MEVA) dataset
collection work is supported by Intelligence Advanced Research
Projects Activity contract number 2017-16110300001.

7.0 Changelog
12-dec-2019: Updated for drop-03
06-nov-2019: Updated for UAV drop-01
30-sep-2019: Updated with sample download commands
24-sep-2019: Updated for drop-02
06-sep-2019: Updated for AWS Public Dataset Program access
21-may-2019: Adapted for mevadata.org
25-mar-2019: Initial release
