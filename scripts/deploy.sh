#!/bin/bash
set -e

# Create app directory in the correct location
APP_DIR="/root/app"
sudo mkdir -p $APP_DIR

# Install system dependencies
bash ./install_dependencies.sh

# Install Python 3.11 (since 3.12 is not available in debian bookworm)
sudo apt-get update
sudo apt-get install -y python3.11 python3.11-venv python3-pip python3-full

# Create and activate virtual environment
cd $APP_DIR
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --no-cache-dir -r requirements.txt

# Setup systemd service
cat > /etc/systemd/system/fastapi.service << EOF
[Unit]
Description=FastAPI application
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
ExecStart=$APP_DIR/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:8000

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
systemctl daemon-reload
systemctl enable fastapi
systemctl start fastapi

# Wait for service to start and check health
sleep 5
if curl -f http://localhost:8000/health; then
    echo "Application deployed successfully"
else
    echo "Application is not healthy"
    exit 1
fi