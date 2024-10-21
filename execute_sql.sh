#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID> <SQL string>"
	exit 1
}

[[ $# -lt 2 ]] && usage

cd projects/$1

ROOTPWD=$(cat docker-compose.yml | grep ROOT | cut -f2 -d =)

echo "$2" | docker compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 exec -T db mariadb -u root -"p$ROOTPWD" "dk_$1_db"

cd ../..