#!/bin/bash
set -euo pipefail

# Set PROJECT_ID=your-gcloud-proj-id when running the script.
# Usage: PROJECT_ID=<project-id> ./gdeploy.sh

REG=asia-south1-docker.pkg.dev/$PROJECT_ID/wavelength

# Build all services
docker compose build

services=(
  gateway
  playlist
  music
  yt-scraper
  artist
  album
)

for svc in "${services[@]}"; do
  local_image="wavelength/services/$svc:latest"
  remote_image="$REG/$svc:latest"

  echo "Tagging $local_image => $remote_image"
  docker tag "$local_image" "$remote_image"

  echo "Pushing $remote_image"
  docker push "$remote_image"
done

echo "Done pushing all images!"
