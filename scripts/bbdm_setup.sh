#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting BBDM setup..."

# Set the data working directory
DATA_DIR="$(pwd)/data"
export DATA_DIR
echo "✅ Set DATA_DIR to $DATA_DIR"

# Set the VQGAN checkpoint working directory
VQGAN_DIR="$(pwd)"/checkpoints/VQGAN/last.ckpt
echo "✅ Set VQGAN_DIR to $VQGAN_DIR"

# Overwrite the BBDM template file target input data and checkpoint path
sed -i "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f4.yaml
sed -i "56s|ckpt_path: '.*'|ckpt_path: '${VQGAN_DIR}'|" Template-LBBDM-f4.yaml
echo "✅ Updated dataset_path in Template-BBDM intermediate yaml file"

# Clone the diffusion model
# https://github.com/xuekt98/BBDM
git clone https://github.com/xuekt98/BBDM.git
echo "✅ Cloned BBDM repository"

# Overwrite the BBDM environment file and model instruction templates
cp environment.yml BBDM/
cp Template-LBBDM-f4.yaml BBDM/configs/

# Revert root template to prevent committing user paths
git checkout -- Template-LBBDM-f4.yaml

cd BBDM
echo "✅ Moved environment.yml, Template-LBBDM-f4.yaml; changed into BBDM directory"

# Remote tracking from sub-repository
rm -rf .git
echo "✅ Removed tracking from BBDM"

# Install Conda
module purge
module load Anaconda3/2024.02-1
echo "✅ Loaded Anaconda module with Conda version: $(conda --version)"

# Set up the BBDM environment
conda create -n BBDM python=3.9.16 -y
echo "✅ Created BBDM Conda environment with Python 3.9.16"
conda activate BBDM
conda env update --file environment.yml --prune
echo "✅ Updated BBDM environment using environment.yml"

echo "✅ BBDM setup complete!"
