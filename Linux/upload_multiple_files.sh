#!/bin/bash

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is required but not installed. Please install it."
    exit 1
fi

# Check if files are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <directory_path> [<container_name>] [<storage_account>] [<cloud_directory>] [<storage_class>]"
    exit 1
fi

# Parse command-line arguments
directory="$1"
container="${2:-default-container}"  # Default container name if not provided
storage_account="${3:-default-storage-account}"  # Default storage account if not provided
cloud_directory="$4"  # Optional argument for target cloud directory
storage_class="$5"   # Optional argument for storage class or any other attributes

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory '$directory' not found."
    exit 1
fi

# Upload files from the directory to Azure Blob Storage
for file in "$directory"/*; do
    # Check if the item is a file
    if [ -f "$file" ]; then
        # Check if the file already exists in Azure Blob Storage
        blob_name=$(basename "$file")
        blob_exists=$(az storage blob exists --container-name "$container" --name "$blob_name" --account-name "$storage_account" --auth-mode login --output tsv)

        if [ "$blob_exists" == "True" ]; then
            echo "File '$blob_name' already exists in Azure Blob Storage container '$container'."

            # Prompt user for action
            read -p "Do you want to overwrite the existing file? [y/n]: " overwrite_action

            if [ "$overwrite_action" == "y" ]; then
                # Upload the file to Azure Blob Storage with --overwrite option
                upload_command="az storage blob upload --file '$file' --container-name '$container' --account-name '$storage_account' --auth-mode login --name '$blob_name' --overwrite"
            else
                # Prompt user for a new name
                read -p "Enter a new name for the file: " new_name
                if [ ! -z "$new_name" ]; then
                    # Rename the file using mv command
                    mv "$file" "$directory/$new_name"
                    blob_name="$new_name"

                    # Upload the renamed file to Azure Blob Storage
                    upload_command="az storage blob upload --file '$directory/$blob_name' --container-name '$container' --account-name '$storage_account' --auth-mode login --name '$blob_name'"
                else
                    echo "Skipping file '$blob_name'."
                    continue  # Skip this file and continue with the next one
                fi
            fi
        else
            # Upload the file to Azure Blob Storage
            upload_command="az storage blob upload --file '$file' --container-name '$container' --account-name '$storage_account' --auth-mode login"
        fi

        # Add optional arguments if provided
        if [ ! -z "$cloud_directory" ]; then
            upload_command+=" --path '$cloud_directory/$blob_name'"
        else
            upload_command+=" --name '$blob_name'"
        fi

        if [ ! -z "$storage_class" ]; then
            upload_command+=" --metadata 'storage-class=$storage_class'"
        fi

        # Execute the upload command
        echo "Uploading file '$blob_name' to Azure Blob Storage container '$container'..."
        eval "$upload_command"

        if [ $? -eq 0 ]; then
            echo "File '$blob_name' uploaded successfully to Azure Blob Storage container '$container'."
        else
            echo "Failed to upload file '$blob_name' to Azure Blob Storage container."
        fi
    fi
done

# Generate and display shareable links for uploaded files if container and storage account are provided
if [ $# -ge 3 ]; then
    for file in "$directory"/*; do
        if [ -f "$file" ]; then
            blob_name=$(basename "$file")
            link=$(az storage blob url --container-name "$container" --account-name "$storage_account" --name "$blob_name" --auth-mode login --output tsv)
            echo "Shareable link for '$blob_name': $link"
        fi
    done
fi
