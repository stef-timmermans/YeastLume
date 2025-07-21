#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting taming-transformers setup..."

# Create the .txt data info files
find "$(pwd)/data/train/B" -name "*.png" > fluorescence_rgb_train.txt
find "$(pwd)/data/val/B" -name "*.png" > fluorescence_rgb_val.txt
echo "✅ Wrote image list files"

# Overwrite the taming-transformers template file .txt file paths
sed -i "s|training_images_list_file: OVERWRITTEN_BY_GAN_SETUP_SH|training_images_list_file: $(pwd)/fluorescence_rgb_train.txt|" configs/models/rgb/custom_vqgan.yaml
sed -i "s|test_images_list_file: OVERWRITTEN_BY_GAN_SETUP_SH|test_images_list_file: $(pwd)/fluorescence_rgb_val.txt|" configs/models/rgb/custom_vqgan.yaml
echo "✅ Updated image list file paths in custom_vqgan intermediate yaml file"

# Clone the VQGAN model if it doesn't already exist
# https://github.com/CompVis/taming-transformers
if [ -d "taming-transformers" ]; then
    echo "⚠️ taming-transformers directory already exists; skipping clone"
else
    git clone https://github.com/CompVis/taming-transformers.git
    echo "✅ Cloned taming-transformers repository"
fi

# Overwrite the taming-transformers model instruction template
cp configs/models/rgb/custom_vqgan.yaml taming-transformers/configs/

# Revert root template to prevent committing user paths
git checkout -- configs/models/rgb/custom_vqgan.yaml

cd taming-transformers
echo "✅ Copied custom_vqgan.yaml; reverted repo root git changes; changed into taming-transformers directory"

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

pip install Pillow==9.5.0
echo "✅ Updated manual environment fixes (Pillow)"

echo "✅ taming-transformers setup complete!"
