#!/bin/bash

# Update package lists
sudo apt update


# Setup Google Cloud SDK repository
if [ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]; then
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  sudo apt update && sudo apt install -y google-cloud-sdk
fi

# Install Docker (if not already installed)
if ! command -v docker &> /dev/null; then
  sudo apt install -y docker.io
  sudo usermod -aG docker $USER
  echo "Please log out and log back in for Docker permissions to take effect"
fi

# Install kubectl (if not already installed)
if ! command -v kubectl &> /dev/null; then
  sudo apt install -y kubectl
fi

# Install packages from required_packages.txt
while read package; do
  if ! dpkg -s "$package" >/dev/null 2>&1; then
    sudo apt install -y "$package"
  else
    echo "$package is already installed"
  fi
done < required_packages.txt


echo "Environment setup complete!"