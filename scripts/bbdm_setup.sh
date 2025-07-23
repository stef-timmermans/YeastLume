#!/bin/bash
# Leave the script if an error is encountered
set -e

# Load .env config
if [ -f .env ]; then
    set -a
    source .env
    set +a
else
    echo "❌ .env file not found in project root. Exiting..."
    exit 1
fi

# Ensure COLOR_MODE is set
if [ -z "$COLOR_MODE" ]; then
  echo "❌ COLOR_MODE not set in .env"
  exit 1
fi

echo "✅ Starting BBDM setup..."

# Set the data working directory
DATA_DIR="$(pwd)/data"
export DATA_DIR
echo "✅ Set DATA_DIR to $DATA_DIR"

# Set the VQGAN checkpoint working directory
VQGAN_DIR="$(pwd)"/checkpoints/VQGAN/last.ckpt
echo "✅ Set VQGAN_DIR to $VQGAN_DIR"

# Clone the diffusion model if it doesn't already exist
# https://github.com/xuekt98/BBDM
if [ -d "BBDM" ]; then
    echo "⚠️ BBDM directory already exists; skipping clone"
else
    git clone https://github.com/xuekt98/BBDM.git
    echo "✅ Cloned BBDM repository"
fi

# Set up the appropriate configuration file
# Set up for grayscale
if [ "$COLOR_MODE" = "grayscale" ]; then
    echo "Setting up for grayscale..."
    # TODO

# Set up for rgb
elif [ "$COLOR_MODE" = "rgb" ]; then
    echo "Setting up for rgb"

    # Overwrite the BBDM template file data and checkpoint paths
    cp configs/models/rgb/Template-LBBDM-f4.yaml BBDM/configs/Template-LBBDM-f4.yaml

    sed -i "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" BBDM/configs/Template-LBBDM-f4.yaml
    echo "✅ Updated dataset_path in BBDM yaml"

    sed -i "56s|ckpt_path: '.*'|ckpt_path: '${VQGAN_DIR}'|" BBDM/configs/Template-LBBDM-f4.yaml
    echo "✅ Updated ckpt_path in BBDM yaml"

# Catch error
else
    echo "❌ Unsupported COLOR_MODE: $COLOR_MODE"
    exit 1
fi


cd BBDM
echo "✅ Copied Template-LBBDM-f4.yaml; applied user-specific file paths; changed into BBDM directory"

# Remote tracking from sub-repository
rm -rf .git
cd ..
echo "✅ Removed tracking from BBDM; switched back to project root"

# Install Conda
module purge
module load Anaconda3/2024.02-1
echo "✅ Loaded Anaconda module with Conda version: $(conda --version)"

# Remove the BBDM environment if it already exists
conda env remove -n BBDM -y

# Set up the BBDM environment
conda create -n BBDM python=3.9.16 -y
echo "✅ Created BBDM Conda environment with Python 3.9.16"
conda activate BBDM
conda env update --file configs/conda/bbdm_environment.yml --prune
echo "✅ Updated BBDM environment using bbdm_environment.yml"

echo "✅ BBDM setup complete!"
