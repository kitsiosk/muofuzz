#!/bin/bash

# Check if test_name and remote_server are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <test_name> <remote_server> [--only-one]"
  exit 1
fi

# Assign the first argument to test_name
test_name=$1

# Assign the second argument to remote_server
remote_server=$2

# Check for the optional parameter
only_one=false
if [ "$3" == "--only-one" ]; then
  only_one=true
fi

# Define remote base path
remote_base_path="/home/ubuntu/experiment-data/${test_name}/experiment-folders"

# Define local base path
local_base_path="fuzzer_logs/${test_name}"

# Create local base path directory if it doesn't exist
mkdir -p "${local_base_path}"

# SSH key file
ssh_key="~/.ssh/id_rsa"

# Check SSH connectivity and if remote base path exists
ssh -i ${ssh_key} ${remote_server} "test -d ${remote_base_path}"
if [ $? -ne 0 ]; then
  echo "Failed to access directory ${remote_base_path} on ${remote_server}. Please check the path and your SSH access."
  exit 1
fi

# Fetch the list of subfolders
subfolders=$(ssh -i ${ssh_key} ${remote_server} "ls ${remote_base_path}")
if [ $? -ne 0 ]; then
  echo "Failed to list subfolders in ${remote_base_path}. Please check the path and your SSH access."
  exit 1
fi

# Iterate over each subfolder
for subfolder in $subfolders; do
  echo "Processing subfolder: ${subfolder}"

  # Define the path to the trial folders
  trial_folders=$(ssh -i ${ssh_key} ${remote_server} "ls -d ${remote_base_path}/${subfolder}/trial-*" 2>/dev/null)

  # Check if trial_folders exist
  if [ -z "$trial_folders" ]; then
    echo "No trial folders found in ${subfolder}"
    continue
  fi

  # Select only one random trial folder if --only-one is specified
  if [ "$only_one" == true ]; then
    trial_folders=$(echo "$trial_folders" | shuf -n 1)
  fi

  # Iterate over each trial folder
  for trial_folder in $trial_folders; do
    echo "Processing trial folder: ${trial_folder}"

    # Define the remote file path
    remote_file="${trial_folder}/results/fuzzer-log.txt"

    # Check if the remote file exists
    if ! ssh -i ${ssh_key} ${remote_server} "test -f ${remote_file}"; then
      echo "File ${remote_file} does not exist."
      continue
    fi

    # Define the local file path
    trial_folder_name=$(basename ${trial_folder})
    local_file="${local_base_path}/${subfolder}_${trial_folder_name}.txt"

    # Copy the file from remote to local
    scp -i ${ssh_key} "${remote_server}:${remote_file}" "${local_file}"

    # Check if scp was successful
    if [ $? -eq 0 ]; then
      echo "Copied ${remote_file} to ${local_file}"
    else
      echo "Failed to copy ${remote_file}"
    fi

    # If only one trial folder is to be fetched, break after processing one
    if [ "$only_one" == true ]; then
      break
    fi
  done
done
