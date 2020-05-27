#!/bin/bash
set -e

echo "{}" > projects.json
docker network create direktkredit-proxy
docker-compose up -d
