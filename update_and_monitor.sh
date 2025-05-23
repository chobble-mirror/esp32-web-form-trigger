#!/usr/bin/env bash
set -e

# Save the current image ID for potential rollback
CURRENT_IMAGE=$(sudo podman images -q esp32-web-form-trigger:latest)
echo "Current image ID: $CURRENT_IMAGE"
echo $CURRENT_IMAGE > ./.previous_image_id

# Pull the latest image
echo "Pulling latest image..."
sudo podman pull esp32-web-form-trigger

# Restart the service
echo "Restarting service..."
sudo systemctl restart podman-esp32-trigger

# Monitor logs (will run until Ctrl+C)
echo "Monitoring logs (Ctrl+C to stop)..."
echo "If you need to roll back, press Ctrl+C and then run: ./rollback.sh"
journalctl -fxeu podman-esp32-trigger