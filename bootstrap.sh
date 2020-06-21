#!/bin/bash
set -e

echo "{}" > projects.json
echo "" > domains.txt
echo "" > domains.env
docker-compose up -d
