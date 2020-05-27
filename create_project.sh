#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID> <Admin E-mail Address> <Project DK URL> [<Platform URL> ...]"
	exit 1
}

[[ $# -lt 3 ]] && usage

echo "Generating docker-compose.yml..."
python3 scripts/generate_project_compose.py $1 $2

echo "Creating database docker container..."
docker-compose -p $1 -f projects/$1/docker-compose.yml up -d db
sleep 10
echo "Creating web app docker container..."
docker-compose -p $1 -f projects/$1/docker-compose.yml up -d web

echo "Creating let's encrypt certificates..."
case "$LETSENCRYPT_EMAIL" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $LETSENCRYPT_EMAIL" ;;
esac

domain_args="-d $3"
docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $email_arg \
    $domain_args \
    --agree-tos" certbot

if [[ $# -gt 3 ]]; then
	for domain in "${@:4}"; do
	  	domain_args="-d $domain"
		docker-compose run --rm --entrypoint "\
		  certbot certonly --webroot -w /var/www/certbot \
		    $email_arg \
		    $domain_args \
		    --agree-tos" certbot	  
	done
fi

echo "Waiting for project app to warm up..."
sleep 30

echo "Add project to nginx..."
docker-compose exec nginx python3 scripts/add_project.py $1 dk_$1_web $3 ${@:4}
docker-compose exec nginx python3 scripts/generate_config.py

