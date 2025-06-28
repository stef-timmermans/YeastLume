#!/bin/bash
# Leave the script if an error is encountered.
set -e

# Remove tracked, user-specific configuration files
rm accounts/drive.json.enc

# Setup the general virtual environment for
# data preparation.
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# This can be re-entered manually; work through
# the logic in the `data-loading` directory's
# README.md.
deactivate

# Clone the diffusion model repository and remove it from tracking
# https://github.com/xuekt98/BBDM
git clone https://github.com/xuekt98/BBDM.git
cd BBDM
rm -rf .git

# Tweak the config file to correctly load in the user-provided dataset
cd configs
sed -i '' "19s|dataset_path: '.*'|dataset_path: '../../data'|" Template-BBDM.yaml
sed -i '' "19s|dataset_path: '.*'|dataset_path: '../../data'|" Template-LBBDM-f4.yaml
sed -i '' "19s|dataset_path: '.*'|dataset_path: '../../data'|" Template-LBBDM-f8.yaml
sed -i '' "19s|dataset_path: '.*'|dataset_path: '../../data'|" Template-LBBDM-f16.yaml
cd ..

# Setup the "BBDM" Conda environment
conda env create -f environment.yml
