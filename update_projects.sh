#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 [<Project ID> | all | proxy]"
	exit 1
}

[[ $# -lt 1 ]] && usage
[[ $# -gt 1 ]] && usage

if [[ $1 == "all" ]]
then
	echo "Updating all projects..."
	cd projects
	for project in * ; do
		echo "Updating project $project..."    
		cd $project
		docker compose -p $HABIDAT_DK_CONTAINER_PREFIX-$project pull 
		docker compose -p $HABIDAT_DK_CONTAINER_PREFIX-$project up -d
		cd ..
	done
	cd ..
elif [[ $1 == "proxy" ]]
then
	echo "Updating proxy containers..."
	docker compose pull
	docker compose up -d
else
	echo "Updating project $1..."
	cd projects/$1
	docker compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 pull 
	docker compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 up -d
	cd ../../
fi
echo "DONE"
