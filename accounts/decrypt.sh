#!/bin/bash
set -e

# Point SOPS to the age private key so it can decrypt the file
export SOPS_AGE_KEY_FILE="accounts/key"

# Decrypt to target JSON
sops --decrypt --output-type json accounts/drive.json.enc > accounts/temp.json

# Make JSON single line and remove intermediate file
jq -c . accounts/temp.json > accounts/drive.json
rm accounts/temp.json
