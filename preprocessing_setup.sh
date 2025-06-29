#!/bin/bash
# Leave the script if an error is encountered
set -e

# Setup the general virtual environment for data preparation
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# This can be re-entered manually; see the `data-loading`
# directory's README.md
