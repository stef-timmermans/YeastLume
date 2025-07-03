#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting taming-transformers setup..."

# Create the .txt data info files
find "$(pwd)/data/train/B" -name "*.png" > fluorescence_train.txt
find "$(pwd)/data/val/B" -name "*.png" > fluorescence_val.txt
echo "✅ Wrote image list files"

# Overwrite the taming-transformers template file .txt file paths
sed -i "s|training_images_list_file: OVERWRITTEN_BY_GAN_SETUP_SH|training_images_list_file: $(pwd)/fluorescence_train.txt|" custom_vqgan.yaml
sed -i "s|test_images_list_file: OVERWRITTEN_BY_GAN_SETUP_SH|test_images_list_file: $(pwd)/fluorescence_val.txt|" custom_vqgan.yaml
echo "✅ Updated image list file paths in custom_vqgan.yaml"

# Clone the VQGAN model
# https://github.com/CompVis/taming-transformers
git clone https://github.com/CompVis/taming-transformers.git
echo "✅ Cloned taming-transformers repository"

# Overwrite the taming-transformers model instruction template
cp custom_vqgan.yaml taming-transformers/configs/
cd taming-transformers
echo "✅ Moved custom_vqgan.yaml; changed into taming-transformers directory"

# Remote tracking from sub-repository
rm -rf .git
echo "✅ Removed tracking from taming-transformers"

# Install Conda
module purge
module load Anaconda3/2024.02-1
echo "✅ Loaded Anaconda module with Conda version: $(conda --version)"

# Set up the taming environment
conda create -n taming python=3.8.5 -y
echo "✅ Created taming Conda environment with Python 3.8.5"
conda activate taming
conda env update --file environment.yaml --prune
echo "✅ Updated taming environment using environment.yaml"

pip install Pillow==9.5.0
echo "✅ Updated manual environment fixes (Pillow)"

echo "✅ taming-transformers setup complete!"
