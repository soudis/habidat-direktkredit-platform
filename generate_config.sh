#!/bin/bash
set -e

source settings.env

echo "Generate nginx config..."
docker-compose exec -p $HABIDAT_DK_CONTAINER_PREFIX nginx python3 scripts/generate_config.py

