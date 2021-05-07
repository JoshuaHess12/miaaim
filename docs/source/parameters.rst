.. _Parameter Reference to Parameter Reference:

Parameter Reference
===================
Here we provide parameter options for each workflow in MIAAIM. Commands are added
in the

.. note::
      For up-to-date references of parameters for each workflow, visit the
      :ref:`Workflow GitHub Repositories <Workflow GitHub Repositories to Workflow GitHub Repositories>`

Nextflow
--------

.. csv-table::
      :header: Flag, Description, Options

      :code:`-with-report`, generate provenance report, ""
      :code:`-resume`, resume workflow with cached results, ""
      :code:`--profile`, use indicated configuration profile, "| :code:`standard`
      | :code:`small`
      | :code:`medium`
      | :code:`big`
      | :code:`multi`
      | :code:`hyper`
      | :code:`LSFsmall`
      | :code:`LSFbig_multi`"
      :code:`--start-at`, start workflow at indicated position, "| :code:`input`
      | :code:`hdiprep`
      | :code:`hdireg`"
      :code:`--start-at`, start workflow at indicated position, "| :code:`hdiprep`
      | :code:`hdireg`"
      :code:`--fixed-image`, fixed image for registration, "| :code:`*.ome.tiff`
      | :code:`*.ome.tif`
      | :code:`*.tiff`
      | :code:`*.hdf5`
      | :code:`*.h5`
      | :code:`*.nii`
      | :code:`*.imzml`"
      :code:`--moving-image`, moving image for registration, "| :code:`*.ome.tiff`
      | :code:`*.ome.tif`
      | :code:`*.tiff`
      | :code:`*.hdf5`
      | :code:`*.h5`
      | :code:`*.nii`
      | :code:`*.imzml`"
      :code:`--fixed-pars`, fixed image preprocessing yaml file, "| :code:`*.yaml`
      | see :ref:`HDIprep parameter reference <HDIprep to hdiprep parameters>`"
      :code:`--moving-pars`, moving image preprocessing yaml file, "| :code:`*.yaml`
      | see :ref:`HDIprep parameter reference <HDIprep to hdiprep parameters>`"
      :code:`--elastix-pars`, elastix registration parameters, "| :code:`*.txt`
      | see :ref:`HDIreg parameter reference <HDIreg to hdireg parameters>`"
      :code:`--transformix`, apply transformation matrix, ""
      :code:`--transformix-pars`, transformix parameters, "| :code:`*.txt`
      | see :ref:`HDIreg parameter reference <HDIreg to hdireg parameters>`"

.. note::
      When supplying file names as parameters, do not
      indicate the file's full path -- only include the file name. For example,
      do not enter :code:`--fixed-image path/to/image.ome.tiff`. Instead, enter
      :code:`--fixed-image image.ome.tiff`.

.. warning::
      If your input file is in the :code:`.imzml` format, be sure to include the
      associated :code:`.ibd` file in the same directory that the image is stored.

.. note::
      You can start a workflow at an intermediate step, such as :code:`hdireg`,
      as long as you have the appropriate intermediate files present. :code:`hdiprep`
      produces files with the suffix :code:`_processed`.

.. warning::
      Nextflow does not currently see contents of parameters supplied to the
      registration workflow. This means that resuming your analysis after changing
      elastix parameter files will produce cached results. To fix this, change the file
      name, or start the workflow at the :code:`hdireg` step without using the
      :code:`resume` flag.

.. _HDIprep to hdiprep parameters:

HDIprep
-------

.. _HDIreg to hdireg parameters:

HDIreg
------
