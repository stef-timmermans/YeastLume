#!/bin/bash
# Leave the script if an error is encountered.

#!/bin/bash
set -e

# Create a SOPS key file (ignored from tracking)
age-keygen -o accounts/key

# Use the key file to create an encrypted version
# of the GCP configuration that can be safely put
# in version control.
AGE_KEY=$(grep "public key:" accounts/key | awk '{print $NF}')
sops --encrypt --age "$AGE_KEY" accounts/drive.json > accounts/drive.json.enc

