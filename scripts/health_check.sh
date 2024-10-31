#!/bin/bash

# Wait for application to start
sleep 5

# Check if the application is responding
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000)

if [ $response -eq 200 ]; then
    echo "Application is healthy"
    exit 0
else
    echo "Application is not healthy"
    exit 1
fi