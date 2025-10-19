#!/bin/bash

# Check if test_name and remote_server are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <test_name> <remote_server>"
  exit 1
fi

# Assign the first argument to test_name
test_name=$1

# Assign the second argument to remote_server
remote_server=$2

# Define remote base path
remote_base_path="/home/ubuntu/report-data/experimental/${test_name}"

# Define local base path
local_base_path="fuzzer_reports/${test_name}"

# Create local base path directory if it doesn't exist
mkdir -p "$(dirname "${local_base_path}")"

# SSH key file
ssh_key="~/.ssh/id_rsa"

# Check if the local directory exists
if [ -d "${local_base_path}" ]; then
  echo "Directory ${local_base_path} already exists. Deleting it..."
  rm -rf "${local_base_path}"
  if [ $? -ne 0 ]; then
    echo "Failed to delete existing directory ${local_base_path}."
    exit 1
  fi
fi

# Check SSH connectivity and if remote base path exists
ssh -i ${ssh_key} ${remote_server} "test -d ${remote_base_path}"
if [ $? -ne 0 ]; then
  echo "Failed to access directory ${remote_base_path} on ${remote_server}. Please check the path and your SSH access."
  exit 1
fi

# Copy the folder from remote to local
scp -i ${ssh_key} -r "${remote_server}:${remote_base_path}" "${local_base_path}"

# Check if scp was successful
if [ $? -eq 0 ]; then
  echo "Copied ${remote_base_path} to ${local_base_path}"
else
  echo "Failed to copy ${remote_base_path}"
fi
