#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting BBDM setup..."

# Set the data working directory
DATA_DIR="$(pwd)/data"
export DATA_DIR
echo "✅ Set DATA_DIR to $DATA_DIR"

# Set the full test set data working directory
FULL_TEST_DIR="$(pwd)/full-test-data"
export FULL_TEST_DIR
echo "✅ Set FULL_TEST_DIR to $FULL_TEST_DIR"

# Set the VQGAN checkpoint working directory
VQGAN_DIR="$(pwd)"/checkpoints/VQGAN/last.ckpt
echo "✅ Set VQGAN_DIR to $VQGAN_DIR"

# Overwrite the BBDM template files' data paths
sed -i "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f4.yaml
sed -i "19s|dataset_path: '.*'|dataset_path: '${FULL_TEST_DIR}'|" Template-LBBDM-f4-Full-Test-Set.yaml
echo "✅ Updated dataset_path in BBDM yamls"

sed -i "56s|ckpt_path: '.*'|ckpt_path: '${VQGAN_DIR}'|" Template-LBBDM-f4.yaml
sed -i "56s|ckpt_path: '.*'|ckpt_path: '${VQGAN_DIR}'|" Template-LBBDM-f4-Full-Test-Set.yaml
echo "✅ Updated ckpt_path in BBDM yamls"

# Clone the diffusion model if it doesn't already exist
# https://github.com/xuekt98/BBDM
if [ -d "BBDM" ]; then
    echo "⚠️ BBDM directory already exists; skipping clone"
else
    git clone https://github.com/xuekt98/BBDM.git
    echo "✅ Cloned BBDM repository"
fi

# Overwrite the BBDM environment files and model instruction templates
cp environment.yml BBDM/
cp Template-LBBDM-f4.yaml BBDM/configs/
cp Template-LBBDM-f4-Full-Test-Set.yaml BBDM/configs/

# Revert root templates to prevent committing user paths
git checkout -- Template-LBBDM-f4.yaml
git checkout -- Template-LBBDM-f4-Full-Test-Set.yaml

cd BBDM
echo "✅ Moved environment.yml, Template-LBBDM-f4.yamls; reverted repo root git changes; changed into BBDM directory"

# Remote tracking from sub-repository
rm -rf .git
echo "✅ Removed tracking from BBDM"

# Install Conda
module purge
module load Anaconda3/2024.02-1
echo "✅ Loaded Anaconda module with Conda version: $(conda --version)"

# Remove the BBDM environment if it already exists
conda env remove -n BBDM -y

# Set up the BBDM environment
conda create -n BBDM python=3.9.16 -y
echo "✅ Created BBDM Conda environment with Python 3.9.16"

# Apply the environment file
conda activate BBDM
conda env update --file environment.yml --prune
echo "✅ Updated BBDM environment using environment.yml"

echo "✅ BBDM setup complete!"