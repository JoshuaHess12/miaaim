.. _quick start to quick start:

Quick Start
===========

After you have :ref:`installed Nextflow <install to install>` you can
download the latest version of MIAAIM directly from GitHub by typing::

  git clone https://github.com/JoshuaHess12/miaaim.git  # clone MIAAIM repository

If you have already cloned MIAAIM from GitHub, ensure that you have
the latest version by entering the directory where you are storing MIAAIM and typing
:code:`git pull`

MIAAIM currently contains three prototype use case with pre-configured parameters for
multi-modal image registration.

prototype-001
^^^^^^^^^^^^^

1. prototype-001 is a coupled MALDI-TOF mass spectrometry imaging (MSI) and H&E data
set from a diabetic foot ulcer. Run this example by typing::

  nextflow run JoshuaHess12/miaaim run prototype-001 --fixed-image im1.tiff --moving-image
  im2.tif

Results can be visualized using ImageJ/FIJI:

prototype-002
^^^^^^^^^^^^^

2. prototype-002 is a coupled MALDI-TOF mass spectrometry imaging (MSI) and IMC data
set from a region of interest (ROI) within prototype-001. Run this example by typing::

  nextflow run JoshuaHess12/miaaim run prototype-002 --fixed-image im1.tiff --moving-image
  im2.tif

prototype-003
^^^^^^^^^^^^^

3. prototype-003 is a use case for higher-resolution imaging data, and is a larger
data set, taken from publicly available CYCIF repository. Run this example by typing::

  nextflow run JoshuaHess12/miaaim run prototype-003 --fixed-image im1.tiff --moving-image
  im2.tif
