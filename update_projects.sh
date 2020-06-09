#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 [<Project ID> | all | proxy]"
	exit 1
}

[[ $# -lt 2 ]] && usage
[[ $# -gt 2 ]] && usage

if [[ $1 == "all" ]]
then
	echo "Updating all projects..."
	for project in projects/*/ ; do
		echo "Updating project $project..."    
		cd projects/$project
		docker-compose pull 
		docker-compose up -d
		cd ../../
	done
elif [[ $1 == "proxy" ]]
then
	echo "Updating proxy containers..."
	docker-compose pull
	docker-compose up -d
else
	echo "Updating project $1..."
	cd projects/$1
	docker-compose pull 
	docker-compose up -d
	cd ../../
fi
echo "DONE"