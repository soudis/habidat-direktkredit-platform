#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID> <URL> [<URL> ...]"
	exit 1
}

echo "Update project..."
docker-compose exec -p $HABIDAT_DK_CONTAINER_PREFIX nginx python3 scripts/update_project.py $1 dk_$1_web ${@:2}
docker-compose exec -p $HABIDAT_DK_CONTAINER_PREFIX nginx python3 scripts/generate_config.py

