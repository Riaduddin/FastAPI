#!/bin/bash
set -e

# Create app directory in the correct location
APP_DIR="/root/app"
sudo mkdir -p $APP_DIR

# Copy all files to the app directory if they're not already there
cp -r ./* $APP_DIR/ || true

# Update package list and install system dependencies
sudo apt-get update
sudo apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3-full \
    curl

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
systemctl restart fastapi

# Wait for service to start and check health with retries
echo "Waiting for application to start..."
for i in {1..12}; do
    echo "Attempt $i of 12..."
    if curl -f http://localhost:8000/health; then
        echo "Application deployed successfully"
        exit 0
    fi
    sleep 5
done

echo "Application is not healthy after 60 seconds"
echo "Checking service status..."
systemctl status fastapi
echo "Checking logs..."
journalctl -u fastapi -n 50
exit 1