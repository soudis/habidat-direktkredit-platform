#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <container> <database> <root password> <database dump file>"
	exit 1
}


[[ $# -lt 4 ]] && usage

echo "Deleting old data..."
echo "SET FOREIGN_KEY_CHECKS = 0;" > tmp_deletetables.sql
docker exec $1 mysqldump -u root -p$3 $2 --add-drop-table --no-data | grep "DROP TABLE" >> tmp_deletetables.sql
echo "SET FOREIGN_KEY_CHECKS = 1;" >> tmp_deletetables.sql
cat tmp_deletetables.sql | docker exec -i $1 mysql -u root -p$3 $2
echo "Import new data from $4..."
cat $4 | docker exec -i $1 mysql -u root -p$3 $2 

