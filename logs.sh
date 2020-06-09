#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 [<Project ID> | proxy] [parameters...]"
	exit 1
}

LOG_PARAMETERS="--tail=500 -t"

[[ $# -lt 2 ]] && usage
[[ $# -gt 2 ]] && LOG_PARAMETERS=${@:2}

if [[ $1 == "proxy" ]]
then
	docker-compose logs $LOG_PARAMETERS nginx
else
	cd projects/$1
	docker-compose logs $LOG_PARAMETERS nginx
	cd ../..
fi
