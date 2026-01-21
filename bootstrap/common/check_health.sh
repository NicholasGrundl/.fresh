#!/bin/bash

check_command() {
  if command -v $1 &> /dev/null; then
    echo "$1 is installed"
  else
    echo "$1 is NOT installed"
  fi
}

check_package() {
  if dpkg -s "$1" >/dev/null 2>&1; then
    echo "$1 is installed"
  else
    echo "$1 is NOT installed"
  fi
}

echo "Checking development environment..."

# Check common commands
check_command node
check_command npm
check_command python3
check_command docker
check_command kubectl
check_command gcloud

# Check common packages
check_package build-essential
check_package google-cloud-sdk
check_package tesseract-ocr
check_package ffmpeg

echo "Environment check complete!"