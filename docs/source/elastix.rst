Elastix Basics
==============
MIAAIM's core registration component utilizes the `elastix <https://elastix.lumc.nl>`_
image registration library. Elastix provides a multitude of similarity measures,
transformation models, optimizers, and interolators  for image alignment.
For a complete list of these, see the elastix documentation, in particular the
`manual <https://github.com/SuperElastix/elastix/wiki/Documentation>`_.

Registration Parameter Files (Elastix)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Inputs
------
Input to elastix requires a text document parameter file that indicates
the settings and algorithms to be used for image registration. Example parameter
files that would typically be used for MIAAIM registration are stored in the
`templates <>`_ directory within the MIAAIM GitHub repository.

Outputs
-------

Multi-channel Input
^^^^^^^^^^^^^^^^^^^

Help the Registration with Manual Landmarks
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Applying Transformations (Transformix)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
After elastix has calculated the transformation parameters needed to align images,
MIAAIM, applies the transformation to each channel of the moving image using
elastix's native transformix function.

Inputs
------

Outputs
-------
