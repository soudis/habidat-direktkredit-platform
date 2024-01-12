#!/bin/bash
set -e

source settings.env

echo "Stopping all projects..."
cd projects
for project in * ; do
	echo "Stopping project $project..."    
	cd $project
	docker-compose -p $HABIDAT_DK_CONTAINER_PREFIX-$project stop
	cd ..
done
cd ..
echo "Stopping proxy containers..."
docker-compose -p $HABIDAT_DK_CONTAINER_PREFIX stop
echo "DONE"
