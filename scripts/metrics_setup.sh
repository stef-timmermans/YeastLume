#!/bin/bash
# Leave the script if an error is encountered
set -e

# Move into the metrics directory
cd metrics

# Setup the general virtual environment for metrics
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
