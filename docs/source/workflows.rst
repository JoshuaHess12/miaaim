Workflows
=========

MIAAIM contains 4 major workflows: (i.) image preparation (ii.) image registration
(iii.) tissue state modelling and (iv.) cross-system/tissue information transfer.
For a list of input options for these workflows, see the
:ref:`Parameter Reference <Parameter Reference to Parameter Reference>` section.

Up-to-date input options and versions for each workflow are available on GitHub:

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
processed images to the image registration workflow. Processing is carried out
using the containerized `hdi-prep <https://github.com/JoshuaHess12/hdi-prep>`_
Python module. Image preparation can process high-parameter images as well as
histological stains.

HDIprep can chain together multiple operations to process images. Passing arguments
are streamlined through the use of YAML parameter files.


YAML Parameter File
-------------------
HDIprep parses YAML parameter files as Python would. Here are example contents
for a parameter file for image compression:

::

    ProcessingSteps:                               # indicates processing steps
      - RunOptimalUMAP:                            # steady state UMAP compression
          n_neighbors: 15                          # neighbors to use for UMAP
          landmarks: 3000                          # spectral landmarks
          metric: 'euclidean'                      # metric
          random_state: 1221                       # set seed for reproducibility
          dim_range: (1,10)                        # steady state compression dimension range
          export_diagnostics: True                 # export steady state compression diagnostics
          output_dir: "path/output-directory"      # output directory
      - SpatiallyMapUMAP                           # spatial reconstruction of UMAP embedding
      - ExportNifti1:                              # export processed image as nifti
          output_dir: "path/output-directory"      # output directory

There are :code:`ProcessingSteps` in this workflow that are indicated
with the :code:`-` flag. These will be run sequentially. Parameters within each
workflow step are indicated as a key-value pair with a colon (:code:`:`) For example,
the above snippet will run steady state UMAP compression, image reconstruction,
and exporting an image with the indicated parameters as key-value pairs.


High-Parameter Image Processing
-------------------------------
MIAAIM processes high-parameter images using a newly developed image
compression method. This method is based off of UMAP, and it adds functionality
to subsample images for rapid compression and to objectively choose embedding
dimensionalities for them. The output

Histological Image Processing
-----------------------------
MIAAIM supports parallelized image smoothing and morphological operations, such
as thresholding to create masks, opening, closing, and filling for histological
image preprocessing.

Image Registration (HDIreg)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tissue State Modelling (PatchMAP)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cross-System/Tissue Information Transfer (i-PatchMAP)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
