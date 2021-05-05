.. miaaim documentation master file, created by
   sphinx-quickstart on Wed May  5 10:42:56 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.


MIAAIM: multi-modal image alignment and analysis by information manifolds
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
MIAAIM is a software to align multiple-omics tissue imaging data.
The worflow includes high-dimensional image compression, registration, and
transforming images to align in the same spatial domain. MIAAIM was developed at
the `Vaccine and Immunotherapy Center at MHG <http://advancingcures.org>`_
in the labs of `Dr. Patrick Reeves <http://advancingcures.org/reeves-lab/>`_
and `Dr. Ruxandra Sîrbulescu <http://advancingcures.org/sirbulescu-lab/>`_.
MIAAIM is written in `Nextflow <https://www.nextflow.io>`_ with containerized
workflows to enable modular development and application across diverse computing
architectures.

MIAIM is under active development! All tutorials are subject to change
in the future. To update your current version, pull the latest release
from GitHub with :code:`nextflow pull JoshuaHess12/miaaim`.

Visit regularly for the latest parameter references and usage instructions!

.. toctree::
   :maxdepth: 3
   :caption: User Guide / Tutorials

   installation
   quick_start
   background
   workflows
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
   :caption: Funding

   funding

.. toctree::
   :maxdepth: 2
   :caption: License

   license

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
