Folder Structure
================
Each process within the MIAAIM workflow produces output in a directory that
reflects the process name. Here is the current MIAAIM workflow.

 ::

    imageID               # image name
    ├── input             # raw input
    ├── hdiprep           # hdiprep workflow
    ├── hdireg            # hdireg workflow
    │   ├── elastix       # registration
    │   └── transformix   # results
    └── patchmap          # patchmap

MIAAIM is developed to integrate assembled images in the level 2 format. Your
base folder, :code:`imageID` should contain your assembled image sample name.

All input files, including
