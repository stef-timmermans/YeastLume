#!/bin/bash
# Leave the script if an error is encountered
set -e

# Activate the virtual environment created by `initial_setup.sh`
source .venv/bin/activate

# Run the notebook (outputs not printed, images will still be written)
# To save output remove the `-ClearOutputPreprocessor.enabled=True` flag
jupyter nbconvert --ClearOutputPreprocessor.enabled=True \
--to notebook --inplace --execute data-loading/data_preprocessing.ipynb
