#!/bin/bash
# Leave the script if an error is encountered
set -e

# Activate the virtual environment created by `preprocessing_setup.sh`
cd data-loading
source .venv/bin/activate

# Run the notebooks (outputs not printed, images will still be written)
# To save output remove the `-ClearOutputPreprocessor.enabled=True` flag

# Primary dataset notebook
jupyter nbconvert --ClearOutputPreprocessor.enabled=True \
--to notebook --inplace --execute data_preprocessing.ipynb

# Full test set notebook
jupyter nbconvert --ClearOutputPreprocessor.enabled=True \
--to notebook --inplace --execute full_test_set_preprocessing.ipynb
