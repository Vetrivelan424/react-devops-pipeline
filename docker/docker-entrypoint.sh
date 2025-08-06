#!/bin/sh
# Docker entrypoint script for React application

set -e

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting React application container..."

# Check if build directory exists
if [ ! -d "/usr/share/nginx/html" ]; then
    log "ERROR: Build directory not found!"
    exit 1
fi

# Check if index.html exists
if [ ! -f "/usr/share/nginx/html/index.html" ]; then
    log "ERROR: index.html not found!"
    exit 1
fi

# Set proper permissions
chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html

# Test nginx configuration
log "Testing Nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    log "Nginx configuration is valid"
else
    log "ERROR: Nginx configuration is invalid!"
    exit 1
fi

# Create log directories if they don't exist
mkdir -p /var/log/nginx
chown nginx:nginx /var/log/nginx

log "Starting Nginx..."

# Execute the main command
exec "$@"

