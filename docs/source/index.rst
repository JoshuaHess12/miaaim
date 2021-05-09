.. miaaim documentation master file, created by
   sphinx-quickstart on Wed May  5 10:42:56 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.


MIAAIM: multi-modal image alignment and analysis by information manifolds
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. container:: twocol

   .. container:: leftside

      .. figure:: Figure1-2.pdf
         :width: 90%

   .. container:: rightside

      MIAAIM is a software to align and analyze multiple-omics tissue imaging data.
      The workflow includes high-dimensional image compression, registration, and
      tissue state modelling.

      MIAAIM was developed by
      `Joshua Hess <https://github.com/JoshuaHess12>`_ at
      the `Vaccine and Immunotherapy Center at MHG <http://advancingcures.org>`_
      in the labs of `Dr. Ruxandra Sîrbulescu <http://advancingcures.org/sirbulescu-lab/>`_
      and `Dr. Patrick Reeves <http://advancingcures.org/reeves-lab/>`_.
      It is written in `Nextflow <https://www.nextflow.io>`_ with containerized
      workflows to enable modular development and reproducible
      image data integration across diverse computing architectures.

      For an introduction to how MIAAIM is set up and implemented,
      visit the :ref:`quick start <quick start to quick start>`
      guide and implement some of the prototype use cases. For a complete
      description of the project, check our paper on xxx.

.. note::
   MIAAIM is under active development! To update your current version, pull the
   latest release from GitHub with :code:`nextflow pull JoshuaHess12/miaaim`.
   If you pull a new version, please visit for the latest usage instructions for
   new workflows! All updated versions should be backwards compatible
   with previous versions. If you are having trouble implementing a
   pipeline that you are used to, feel free to :ref:`contact <Contact Information to contact>`
   us so we can help.

.. toctree::
   :maxdepth: 3
   :caption: User Guide / Tutorials

   installation
   quick_start
   directory
   workflows
   parameters
   background
   nextflow
   elastix
   configuration
   executors
   provenance
   tutorials
   python
   contributing

.. toctree::
   :maxdepth: 2
   :caption: Releases

   releases

.. toctree::
   :maxdepth: 2
   :caption: Contact

   contact


.. toctree::
   :maxdepth: 2
   :caption: Funding

   funding

.. toctree::
   :maxdepth: 2
   :caption: License

   license

.. toctree::
   :maxdepth: 2
   :caption: Acknowledgements

   acknowledgements


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
