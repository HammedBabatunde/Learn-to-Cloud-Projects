#!/bin/bash

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is required but not installed. Please install it."
    exit 1
fi

# Check if files are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <file1> [<container_name>] [<storage_account>] [<cloud_directory>] [<storage_class>]"
    exit 1
fi

# Parse command-line arguments
file="$1"
container="${2:-default-container}"  # Default container name if not provided
storage_account="${3:-default-storage-account}"  # Default storage account if not provided
cloud_directory="$4"  # Optional argument for target cloud directory
storage_class="$5"   # Optional argument for storage class or any other attributes

# Check if the file exists
if [ ! -f "$file" ]; then
    echo "File '$file' not found."
    exit 1
fi

# Upload the file to Azure Blob Storage
upload_command="az storage blob upload --file '$file' --container-name '$container' --account-name '$storage_account'  --auth-mode login  --output none | pv -p -s $(stat -c "%s" "$file") >/dev/null"

# Add optional arguments if provided
if [ ! -z "$cloud_directory" ]; then
    upload_command+=" --path '$cloud_directory'"
fi

if [ ! -z "$storage_class" ]; then
    upload_command+=" --metadata 'storage-class=$storage_class'"
fi

# Execute the upload command
echo "Uploading file '$file' to Azure Blob Storage container '$container'..."
eval "$upload_command"


if [ $? -eq 64 ]; then
    echo "File uploaded successfully to Azure Blob Storage container '$container'."
else
    echo "Failed to upload file to Azure Blob Storage container."
    exit 1
fi

# Generate and display shareable link if container and storage account are provided
if [ $# -ge 3 ]; then
    link=$(az storage blob url --container-name "$container" --account-name "$storage_account" --name "$(basename "$file")"  --auth-mode login --output tsv)
    echo "Shareable link for '$file': $link"
fi



