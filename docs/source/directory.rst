Folder Structure
================
Each workflow within MIAAIM produces output in a directory that
reflects the workflow name. For more complete background on workflows and
how to structure parameter files for each, check out the
:ref:`Workflows section <Workflows to Workflows>`.
Here is the current directory structure and optional outputs for each:

 ::

    imageID                         # image name
    ├── input                          # raw input
    │   ├── fixed.ext                       # fixed image
    │   ├── moving.ext                      # moving image
    │   ├── fixed-pars.yaml                 # fixed image processing parameters
    │   ├── moving-pars.yaml                # moving image processing parameters
    │   └── registration-pars.txt           # registration parameters
    ├── hdiprep                        # hdiprep workflow
    │   ├── fixed_processed.nii             # processed fixed image
    │   └── moving_processed.nii            # processed moving image
    ├── hdireg                         # hdireg workflow
    │   ├── elastix                         # registration
    │   │   ├── Iteration.txt                   # optimization log (optional)
    │   │   ├── TransformationParameters.txt    # spatial transformation parameters
    │   │   └── result.nii                      # single-channel export example (optional)
    │   └── transformix                     # FINAL RESULTS FOLDER
    │       ├── moving_result.ext               # exported results
    │       └── fixed.ext                       # fixed image (optional)
    └── patchmap                       # patchmap workflow

MIAAIM is developed to integrate assembled images in the level 2 format. Your
base folder, :code:`imageID` should contain your assembled image sample name.

.. note::
   All you need to supply for MIAAIM are the contents of the :code:`input` folder.
   MIAAIM will automatically create and populate all other folders in the above
   directory tree.

input
-----
All input files should be included in the :code:`input` folder. These include
the raw input images, parameters for preprocessing, and elastix
image registration parameters.

hdiprep
-------
The :code:`hdiprep` folder will contain results for image preparation. These will
be image data sets, either compressed through the HDIprep compression workflow,
or preprocessed using histological image processing options.

.. note::
   Processed data will contain original images' file names with the suffix
   :code:`_processed` appended.

hdireg
-------
The :code:`hdireg` folder will contain results for image registration. The
HDIreg workflow can compose multiple image registration models, indicated by
separate parameter files.

.. note::
   Chaining together registration parameters will be stored as separate
   transformation parameter files, indicated by the order which they were
   applied. For example, and affine registration followed by nonlinear registration
   would produce two parameter files, :code:`TransformationParameters.0.txt` and
   :code:`TransformationParameters.1.txt`. Both of these should be supplied as
   parameters to transformix when producing final results.

patchmap
--------
.. note::
   PatchMAP's implementation in the MIAAIM Nextflow pipeline will be featured in
   version 0.2!
