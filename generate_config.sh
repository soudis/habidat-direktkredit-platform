#!/bin/bash
set -e

source settings.env

echo "Generate nginx config..."
docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/generate_config.py

