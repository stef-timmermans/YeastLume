#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting BBDM setup..."

# Set the data working directory
DATA_DIR="$(pwd)/data"
export DATA_DIR
echo "✅ Set DATA_DIR to $DATA_DIR"

# Overwrite the BBDM template files target input data paths
sed -i "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-BBDM.yaml
sed -i "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f4.yaml
echo "✅ Updated dataset_path in Template-BBDM.yaml"

# Clone the diffusion model
# https://github.com/xuekt98/BBDM
git clone https://github.com/xuekt98/BBDM.git
echo "✅ Cloned BBDM repository"

# Overwrite the BBDM environment file and model instruction template
cp environment.yml BBDM/
cp Template-BBDM.yaml BBDM/configs/
cp Template-LBBDM-f4.yaml BBDM/configs/
cd BBDM
echo "✅ Moved environment.yml, Template-BBDM.yaml; changed into BBDM directory"

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
