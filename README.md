# MIAAIM: multi-modal image alignment and analysis by information manifolds
MIAAIM is a software to align multiple-omics tissue imaging data. The worflow includes high-dimensional image compression, registration, and transforming images to align in the same spatial domain. MIAAIM was developed at the [Vaccine and Immunotherapy Center at MGH](http://advancingcures.org) in the labs of [Dr. Patrick Reeves](http://advancingcures.org/reeves-lab/) and [Dr. Ruxandra Sîrbulescu](http://advancingcures.org/sirbulescu-lab/). MIAAIM is written in [Nextflow](https://www.nextflow.io) with containerized workflows to enable modular development and application across diverse computing architectures.

## Installation 
MIAAIM uses nextflow, which requires [Java 8 or later](http://www.oracle.com/technetwork/java/javase/downloads/index.html).

### Linux / OS X
To get started with MIAAIM:
1. [Install Docker](https://docs.docker.com/get-docker/). You can ensure that Docker is available to your system using the command `docker images`
2. [Install Nextflow](https://www.nextflow.io) using `curl -s https://get.nextflow.io | bash`

### Windows
To run Nextflow in Windows, you will need to [install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) prior to installing Nextflow. To do this, follow these steps:
1. Open Windows Powershell as administrator.
2. Download WSL by typing `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
3. Enable virtual machine `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
4. Download the latest Linux kernel update package (https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi).
5. Set WSL2 as your default kernel by typing `wsl --set-default-version 2`
6. Install linux distribution -- we have tested MIAAIM successfully using [Ubuntu 20.04 LTS](https://www.microsoft.com/store/apps/9n6svws3rx71).
7. Open your Ubuntu installation (you will be asked to set up your installation by providing a user name and password)
8. Within the Ubuntu shell enter the following commands to install necessary components for Nextflow and pulling the MIAAIM repository from GitHub:
```bash
sudo apt update
sudo apt install openjdk-14-jre-headless
curl -s https://get.nextflow.io | bash
sudo apt-get -y install git
```
9. Now [install Docker](https://docs.docker.com/get-docker/) for windows and allow it to connect with your WSL2 (see [here](https://docs.docker.com/docker-for-windows/wsl/) for details).
You should now be able to run nextflow and MIAAIM within your installed WSL!

## Quick Start

## Funding
This work is supported by philanthropic funding at the Vaccine and Immunotherapy Center. Josh Hess is supported by an [NSF Graduate Research Fellowship](https://nsfgrfp.org)