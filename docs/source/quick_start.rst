Quick Start
===========

After you have followed installation of Nextflow and required materials, you can
download the latest version of MIAAIM directly from GitHub by typing::

  git clone https://github.com/JoshuaHess12/miaaim.git  # clone MIAAIM repository

If you have already cloned MIAAIM from GitHub, you can ensure that you have
the latest version by entering the directory where you are storing MIAAIM and typing
:code:`git pull`

MIAAIM currently contains an example use case with pre-configured parameters for
registration of two imaging modalities. To run the example quick start, type::

  nextflow run JoshuaHess12/miaaim run example --fixed-image im1.tiff --moving-image
  im2.tif
