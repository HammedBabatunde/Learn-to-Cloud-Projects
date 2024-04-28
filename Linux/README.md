# Azure Blob Storage File Upload Tool

This tool allows you to upload files to an Azure Blob Storage container using Bash scripts and the Azure CLI. It includes functionality for uploading a single file and uploading multiple files from a directory.

## Prerequisites

1. **Azure CLI**: Make sure you have the Azure CLI installed and configured on your machine.
2. **Azure Storage Account**: You'll need access to an Azure Storage account and the corresponding container where you want to upload the files.
3. **Environment Variables** (optional): You can set environment variables for the Azure Storage account and other settings to avoid entering them in the command every time.

## Usage

### Single File Upload

1. Clone or download the `upload_single_file.sh` script.
2. Set execute permissions for the script using `chmod +x upload_single_file.sh`.
3. Run the script with the following command:
   ```bash
   ./upload_single_file.sh <file_path> <container_name> <storage_account>[<cloud_directory>] [<storage_class>]
    ```
Replace <file_path> <container_name> and <storage_account> with the path to the file you want to upload, azure container name and storage account. Other arguments are optional.

4. Follow the prompts or messages during the upload process.

### Multiple Files Upload

1. Clone or download the upload_multiple_files.sh script.
2. Set execute permissions for the script using chmod +x upload_multiple_files.sh.
3. Run the script with the following command:
```bash
./upload_multiple_files.sh <directory_path> <container_name> <storage_account> [<cloud_directory>] [<storage_class>]
```
Replace <directory_path> <container_name> and <storage_account> with the path to the directory containing the files you want to upload, azure container name and storage account. Other arguments are optional.

4. Follow the prompts or messages during the upload process.

## Usage Examples

### Single File Upload
Upload a single file:
```bash
./upload_single_file.sh /path/to/file.txt my-container my-storage-account
```
Upload a file with a target cloud directory and metadata:
```bash
./upload_single_file.sh /path/to/file.txt my-container my-storage-account my-directory hot
```

### Multiple Files Upload

Upload all files from a directory:
```bash
./upload_multiple_files.sh /path/to/directory my-container my-storage-account
```

Upload files from a directory with a target cloud directory and metadata:
```bash
./upload_multiple_files.sh /path/to/directory my-container my-storage-account my-directory cool
```

## Common Issues
- Azure CLI Not Installed: Ensure you have Azure CLI installed and properly configured.
- Failed Uploads: Check for errors during the upload process and verify your Azure Storage account credentials.
- Existing Files: The script handles existing files in the Azure Blob Storage container by prompting for action (overwrite, skip, or rename).
