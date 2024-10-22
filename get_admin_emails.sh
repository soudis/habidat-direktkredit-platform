#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID or all> [<Project ID to exclude>]"
	exit 1
}

[[ $# -lt 1 ]] && usage

rm -f admin_emails.txt

if [[ $1 == "all" ]]
then
	cd projects
	for project in * ; do
	    if [ "$2" != "$project" ]
	    then
	        cd ..
			./execute_sql.sh $project "select email from admin" | grep @ >> admin_emails.txt
			cd projects
	    fi		
	done
	cd ..
	sort -u admin_emails.txt 
else
  ./execute_sql.sh $1 "select email from admin" | grep @
fi
