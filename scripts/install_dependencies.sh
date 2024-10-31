#!/bin/bash

# Update package list
sudo apt-get update

# Install Python and pip if not installed
sudo apt-get install -y python3.11 python3.11-venv python3-pip

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    python3.11 -m venv venv
fi

# Activate virtual environment and install dependencies
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt