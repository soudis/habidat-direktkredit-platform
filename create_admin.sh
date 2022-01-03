#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID> <Admin E-mail Address> <DB root password>"
	exit 1
}

[[ $# -lt 3 ]] && usage

cd projects/$1

echo "insert into admin (logon_id, email, passwordHashed, loginCount) values ('$2', '$2', 'nohash', 0);" | docker-compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 exec mysql -u root -"p$3"

cd ../..