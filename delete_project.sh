#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID>"
	exit 1
}

[[ $# -lt 1 ]] && usage

docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/delete_project.py $1

cd projects/$1
docker compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 down -v
cd ../../

docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/generate_config.py

rm -rf projects/$1

echo "NOTE: Please manually remove exclusive project domains from domains.env!"

