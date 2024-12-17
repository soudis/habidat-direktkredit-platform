#!/bin/bash
set -e

source settings.env

echo "Starting all projects..."
cd projects
for project in * ; do
	echo "Starting project $project..."    
	cd $project
	docker compose -p $HABIDAT_DK_CONTAINER_PREFIX-$project down 
	cd ..
done
cd ..
echo "Starting proxy containers..."
docker compose -p $HABIDAT_DK_CONTAINER_PREFIX down
echo "DONE"
