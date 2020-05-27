#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID> <Admin E-mail Address> <Project DK URL> [<Platform URL> ...]"
	exit 1
}

[[ $# -lt 3 ]] && usage

echo "Generating docker-compose.yml..."
python3 scripts/generate_project_compose.py $1 $2

echo "Creating docker container..."
docker-compose -p $1 -f projects/$1/docker-compose.yml up -d 

echo "Add project to nginx..."
docker-compose exec nginx python3 scripts/add_project.py $1 dk_$1_web $3 ${@:4}
sleep 30
docker-compose exec nginx python3 scripts/generate_config.py

