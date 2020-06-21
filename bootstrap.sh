#!/bin/bash
set -e

echo "{}" > projects.json
echo "" > domains.txt
docker-compose up -d
