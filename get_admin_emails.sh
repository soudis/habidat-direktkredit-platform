#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID or all>"
	exit 1
}

[[ $# -lt 1 ]] && usage

rm admin_emails.txt

if [[ $1 == "all" ]]
then
	echo "get admin email addresses for all projects..."
	cd projects
	for project in * ; do
		cd ..
		./execute_sql.sh $1 "select email from admin" | grep @ >> ../../admin_emails.txt
		cd projects
	done
	cd ..
	sort admin_emails.txt | uniq > admin_emails.txt
	echo "saved email addresses to admin_emails.txt"
else
  ./execute_sql.sh $1 "select email from admin" | grep @
fi
