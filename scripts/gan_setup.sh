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

echo "✅ Starting taming-transformers setup..."

# Set the data working directory
DATA_DIR="$(pwd)/data"
export DATA_DIR
echo "✅ Set DATA_DIR to $DATA_DIR"

# Create the .txt data info files
find "${DATA_DIR}/train/B" -name "*.png" > fluorescence_rgb_train.txt
find "${DATA_DIR}/val/B" -name "*.png" > fluorescence_rgb_val.txt
echo "✅ Wrote image list files"

# Clone the VQGAN model if it doesn't already exist
# https://github.com/CompVis/taming-transformers
if [ -d "taming-transformers" ]; then
    echo "⚠️ taming-transformers directory already exists; skipping clone"
else
    git clone https://github.com/CompVis/taming-transformers.git
    echo "✅ Cloned taming-transformers repository"
fi

# Set up the appropriate configuration file
# Set up for grayscale
if [ "$COLOR_MODE" = "grayscale" ]; then
    echo "Setting up for grayscale..."

    # Overwrite the taming-transformers template file .txt file paths
    cp configs/models/rgb/custom_vqgan.yaml taming-transformers/configs/custom_vqgan.yaml

    sed -i "s|training_images_list_file: OVERWRITTEN_BY_GAN_SETUP_SH|training_images_list_file: $(pwd)/fluorescence_rgb_train.txt|" taming-transformers/configs/custom_vqgan.yaml
    echo "✅ Updated training_images_list_file in custom_vqgan.yaml"

    sed -i "s|test_images_list_file: OVERWRITTEN_BY_GAN_SETUP_SH|test_images_list_file: $(pwd)/fluorescence_rgb_val.txt|" taming-transformers/configs/custom_vqgan.yaml
    echo "✅ Updated test_images_list_file in custom_vqgan.yaml"

# Set up for rgb
elif [ "$COLOR_MODE" = "rgb" ]; then
    echo "Setting up for rgb"
    # TODO

# Catch error
else
    echo "❌ Unsupported COLOR_MODE: $COLOR_MODE"
    exit 1
fi

cd taming-transformers
echo "✅ Copied custom_vqgan.yaml; applied user-specific file paths; changed into taming-transformers directory"

# Remote tracking from sub-repository
rm -rf .git
echo "✅ Removed tracking from taming-transformers"

# Install Conda
module purge
module load Anaconda3/2024.02-1
echo "✅ Loaded Anaconda module with Conda version: $(conda --version)"

# Remove the taming environment if it already exists
conda env remove -n taming -y

# Set up the taming environment
conda create -n taming python=3.8.5 -y
echo "✅ Created taming Conda environment with Python 3.8.5"
conda activate taming
conda env update --file environment.yaml --prune
echo "✅ Updated taming environment using environment.yaml"

# Manual fix for Pillow
pip install Pillow==9.5.0
echo "✅ Updated manual environment fixes (Pillow)"

echo "✅ taming-transformers setup complete!"
