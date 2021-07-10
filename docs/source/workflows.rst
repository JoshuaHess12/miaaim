.. _Workflows to Workflows:

Workflows
=========

MIAAIM contains 4 major workflows: (i.) image preparation (ii.) image registration
(iii.) tissue state modelling and (iv.) cross-system/tissue information transfer.
For a comprehensive table of input options for these workflows, see the
:ref:`Parameter Reference <Parameter Reference to Parameter Reference>` section.

Up-to-date input options and docker containerizd versions of each workflow
are available on GitHub:

.. _Workflow GitHub Repositories to Workflow GitHub Repositories:
.. list-table:: Workflow GitHub Repositories
   :widths: 25 25
   :header-rows: 1

   * - Workflow
     - Resource
   * - hdiprep
     - https://github.com/JoshuaHess12/hdi-prep
   * - hdireg
     - https://github.com/JoshuaHess12/hdi-reg
   * - patchmap/i-patchmap
     - https://github.com/JoshuaHess12/patchmap

Image Preparation (HDIprep)
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Image preparation begins the workflow for MIAAIM, and it is designed to provide
processed images to the HDIreg image registration workflow. Processing is carried out
using the containerized `hdi-prep <https://github.com/JoshuaHess12/hdi-prep>`_
Python module. Image preparation can process high-parameter images as well as
histological stains.

HDIprep can chain together multiple operations to process images. Passing arguments
are streamlined through the use of YAML parameter files.

YAML Parameter File Input
-------------------------
HDIprep parses YAML parameter files as Python would. Here are example contents
for a parameter file for image compression:

::

    ProcessingSteps:                               # indicates processing steps
      - RunOptimalUMAP                             # steady state UMAP compression
      - SpatiallyMapUMAP                           # spatial reconstruction of UMAP embedding
      - ExportNifti1                               # export processed image as NIfTI

:code:`ProcessingSteps` in HDIprep are indicated
with the :code:`-` flag. These steps will be run sequentially. Parameters within each
workflow step are indicated as key-value pairs with a colon (:code:`:`) For example,
the above snippet will run steady state UMAP compression using the :code:`RunOptimalUMAP`
function, image reconstruction using the :code:`SpatiallyMapUMAP` function, and will
export an image with the :code:`ExportNifti1` function.

.. note::
    MIAAIM's utilizes the NIfTI format for HDIreg. The HDIprep workflow therefore
    exports processed images using the :code:`ExportNifti1`
    function. NIfTI provides memory-mapping capabilities within Python
    that save RAM in HDIreg. OME-TIF, HDF5, imzML, and NIfTI can be used as input
    formats for HDIprep!

High-Parameter Image Processing
-------------------------------

.. figure:: Figure2-5-panelA.pdf
   :width: 100%

MIAAIM processes high-parameter images using a newly developed image
compression method. This method is based off of UMAP, and it adds functionality
to subsample images for rapid compression. It additionally can embed data in
a dimensionality that optimally preserves data information while minimizing the
necessary dimensionality of the embedding space (number of channels in the
compressed image).

Histological Image Processing
-----------------------------
MIAAIM supports parallelized image smoothing and morphological operations, such
as thresholding to create masks, opening, closing, and filling for histological
image preprocessing. These are typically applied as sequential image processing
options

Image Registration (HDIreg)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: Figure2-5-panelB.pdf
   :width: 100%

Tissue State Modelling (PatchMAP)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: Figure-4-2.pdf
   :width: 100%

Cross-System/Tissue Information Transfer (i-PatchMAP)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
