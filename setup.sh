#!/bin/bash
# Leave the script if an error is encountered.
set -e

# Setup the general virtual environment for
# data preparation.
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# This can be re-entered manually work through
# the logic in the `data-loading` directory.
deactivate

# Clone the diffusion model repository.
# https://github.com/xuekt98/BBDM
git clone https://github.com/xuekt98/BBDM.git

# Setup the BBDM Conda environment, using more
# publicly available mirrors
cd configs
conda env create -f bbdm-environment.yml
