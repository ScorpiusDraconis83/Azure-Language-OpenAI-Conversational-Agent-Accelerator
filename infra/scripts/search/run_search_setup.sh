#!/bin/bash

set -e

product_info_file="product_info.tar.gz"
cwd=$(pwd)
script_dir=$(dirname $(realpath "$0"))
cd ${script_dir}

# Arguments:
storage_account_name=$1
blob_container_name=$2

# Fetch data:
cp ../../data/${product_info_file} .

# Unzip data:
mkdir product_info && mv ${product_info_file} product_info/
cd product_info && tar -xvzf ${product_info_file} && cd ..

# Upload data to storage account blob container:
echo "Uploading files to blob container..."
az storage blob upload-batch \
    --auth-mode login \
    --destination ${blob_container_name} \
    --account-name ${storage_account_name} \
    --source "product_info" \
    --pattern "*.md" \
    --overwrite

# Install requirements:
echo "Installing requirements..."
python3 -m pip install -r requirements.txt

# Run setup:
echo "Running index setup..."
python3 index_setup.py

# Cleanup:
rm -rf product_info/
cd ${cwd}

echo "Search setup complete"
