#!/bin/bash
# Leave the script if an error is encountered
set -e

# Set the data working directory
DATA_DIR="$(pwd)/data"
export DATA_DIR

# Overwrite the BBDM template file target input data paths
sed -i "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-BBDM.yaml

# Clone the diffusion model
# https://github.com/xuekt98/BBDM
git clone https://github.com/xuekt98/BBDM.git

# Overwrite the BBDM environment file for Hábrók fix
mv environment.yml BBDM/
cd BBDM

# Remote tracking from sub-repository
rm -rf .git

# Navigate to the config files
cd configs

# Install Conda
module purge
module load Anaconda3/2024.02-1
conda --version

# Set up the BBDM environment
conda create -n BBDM python=3.9.16 -y
conda activate BBDM
conda env update --file environment.yml --prune
