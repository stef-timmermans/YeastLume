#!/bin/bash
# Leave the script if an error is encountered
set -e

# Move into the metrics directory
cd metrics

# Use modern Python version
module load Python/3.10.8-GCCcore-12.2.0

# Setup the general virtual environment for metrics
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
