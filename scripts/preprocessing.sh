#!/bin/bash
# Leave the script if an error is encountered
set -e

# Activate the virtual environment created by `initial_setup.sh`
cd data-loading
source .venv/bin/activate

# Run the notebooks (outputs not printed, images will still be written)
# To save output remove the `-ClearOutputPreprocessor.enabled=True` flag
jupyter nbconvert --ClearOutputPreprocessor.enabled=True \
--to notebook --inplace --execute data_preprocessing.ipynb

jupyter nbconvert --ClearOutputPreprocessor.enabled=True \
--to notebook --inplace --execute supplementary_test_data.ipynb
