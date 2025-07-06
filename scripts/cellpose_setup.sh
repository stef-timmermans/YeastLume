#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting Cellpose setup..."

# Clone the segmentation model if it doesn't already exist
# https://github.com/MouseLand/cellpose
if [ -d "cellpose" ]; then
    echo "⚠️cellpose directory already exists; skipping clone"
else
    git clone https://github.com/MouseLand/cellpose.git
    echo "✅ Cloned Cellpose repository"
fi

cd cellpose
echo "✅ Changed into cellpose directory"

# Remote tracking from sub-repository
rm -rf .git
echo "✅ Removed tracking from cellpose"

# Install Conda
module purge
module load Anaconda3/2024.02-1
echo "✅ Loaded Anaconda module with Conda version: $(conda --version)"

# Remove the cellpose environment if it already exists
conda env remove -n cellpose -y

# Set up the cellpose environment
conda create -n cellpose python=3.8.5 -y
echo "✅ Created cellpose Conda environment with Python 3.8.5"
conda activate cellpose
conda env update --file environment.yml --prune
echo "✅ Updated cellpose environment using environment.yml"

echo "✅ Cellpose setup complete!"
