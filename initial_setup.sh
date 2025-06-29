#!/bin/bash
# Leave the script if an error is encountered
set -e

# Setup the general virtual environment for data preparation
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# This can be re-entered manually; work through the logic in the
# `data-loading` directory's README.md
deactivate

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

sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-BBDM.yaml
sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f4.yaml
sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f8.yaml
sed "${SED_EXT[@]}" "19s|dataset_path: '.*'|dataset_path: '${DATA_DIR}'|" Template-LBBDM-f16.yaml
cd ..

# Setup the "BBDM" Conda environment
conda env create -f environment.yml
