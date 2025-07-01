#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting taming-transformers setup..."

# Create the .txt data info files
find "$HOME/YeastLume/data/train/B" -name "*.png" > fluorescence_train.txt
find "$HOME/YeastLume/data/test/B" -name "*.png" > fluorescence_test.txt

# Clone the VQGAN model
# https://github.com/CompVis/taming-transformers
git clone https://github.com/CompVis/taming-transformers.git
echo "✅ Cloned taming-transformers repository"

# Install Conda
module purge
module load Anaconda3/2024.02-1
echo "✅ Loaded Anaconda module with Conda version: $(conda --version)"

# Set up the taming environment
conda create -n taming python=3.8.5 -y
echo "✅ Created taming Conda environment with Python 3.8.5"
conda activate taming
conda env update --file custom_vqgan.yaml --prune
echo "✅ Updated taming environment using custom_vqgan.yaml"

echo "✅ taming-transformers setup complete!"
