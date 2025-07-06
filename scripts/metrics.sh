#!/bin/bash
# Leave the script if an error is encountered
set -e

# Activate the virtual environment created by `metrics_setup.sh`
cd metrics
source .venv/bin/activate

# Run metrics collection
python evaluate_bbdm.py
