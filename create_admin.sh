#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID> <Email>"
	exit 1
}

[[ $# -lt 2 ]] && usage

cd projects/$1

STMT="insert into admin (logon_id, email, passwordHashed, loginCount, createdAt, updatedAt) values ('$2', '$2', 'nohash', 0, NOW(), NOW());"

./execute_sql.sh $1 "$STMT"

cd ../..