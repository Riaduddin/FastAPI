#!/bin/bash

# Go to app directory
cd ~/app

# Install dependencies
chmod +x scripts/install_dependencies.sh
./scripts/install_dependencies.sh

# Create systemd service file
sudo tee /etc/systemd/system/fastapi.service << EOF
[Unit]
Description=FastAPI application
After=network.target

[Service]
User=$USER
Group=$USER
WorkingDirectory=/home/$USER/app
Environment="PATH=/home/$USER/app/venv/bin"
ExecStart=/home/$USER/app/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:8000

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon and restart service
sudo systemctl daemon-reload
sudo systemctl restart fastapi
sudo systemctl enable fastapi

# Run health check
chmod +x scripts/health_check.sh
./scripts/health_check.sh