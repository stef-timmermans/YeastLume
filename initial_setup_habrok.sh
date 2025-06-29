#!/bin/bash
# Leave the script if an error is encountered
set -e

# Purge old modules
module purge

# Set the data data working directory
DATA_DIR="$(pwd)/data"
export DATA_DIR

# Clone the diffusion model repository and remove it from tracking
# https://github.com/xuekt98/BBDM
git clone https://github.com/xuekt98/BBDM.git
cd BBDM
rm -rf .git

# Navigate to the config files
cd configs

# Support macOS and Linux calls for `sed`
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_EXT=(-i '')
else
    SED_EXT=(-i)
fi

# Overwrite the BBDM template files' target input data path
sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-BBDM.yaml
sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f4.yaml
sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f8.yaml
sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f16.yaml
cd ..

# Load in a compatible Python version for BBDM
module load Python/3.9.6-GCCcore-11.2.0

# Setup the "BBDM" Conda environment
module load Anaconda3/2024.02-1
conda env create -f environment.yml
