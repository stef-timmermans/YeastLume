#!/bin/bash
# Leave the script if an error is encountered
set -e

echo "✅ Starting Cellpose setup..."

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
conda env update --file configs/conda/cellpose_environment.yml --prune
echo "✅ Updated cellpose environment using cellpose_environment.yml"

echo "✅ Cellpose setup complete!"
