#!/usr/bin/env bash
set -e

# Load the saved image ID from update script
if [ -f ./.previous_image_id ]; then
  PREVIOUS_IMAGE=$(cat ./.previous_image_id)
  echo "Rolling back to image ID: $PREVIOUS_IMAGE"
  
  # Tag the previous image as latest
  sudo podman tag $PREVIOUS_IMAGE esp32-web-form-trigger:latest
  
  # Restart the service
  echo "Restarting service with previous image..."
  sudo systemctl restart podman-esp32-trigger
  
  # Monitor logs
  echo "Monitoring logs after rollback (Ctrl+C to stop)..."
  journalctl -fxeu podman-esp32-trigger
else
  echo "No previous image ID found. Cannot roll back."
  exit 1
fi