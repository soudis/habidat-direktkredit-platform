#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <Project ID> <Admin E-mail Address> <URL> [<URL> ...]"
	exit 1
}

[[ $# -lt 3 ]] && usage

export HABIDAT_DK_PROXY_NETWORK=$HABIDAT_DK_PROXY_NETWORK
export HABIDAT_DK_CONTAINER_PREFIX=$HABIDAT_DK_CONTAINER_PREFIX

echo "Generating docker-compose.yml..."
python3 scripts/generate_project_compose.py $1 $2

echo "Pulling docker container..."
docker-compose -p $1 -f projects/$1/docker-compose.yml pull

echo "Creating database docker container..."
docker-compose -p $1 -f projects/$1/docker-compose.yml up -d db
sleep 10
echo "Creating web app docker container..."
docker-compose -p $1 -f projects/$1/docker-compose.yml up -d web

if [ ! -z $HABIDAT_DK_CERTBOT_SERVICE ];then
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
	    --agree-tos" $HABIDAT_DK_CERTBOT_SERVICE

	if [[ $# -gt 3 ]]; then
		for domain in "${@:4}"; do
		  	domain_args="-d $domain"
			docker-compose run --rm --entrypoint "\
			  certbot certonly --webroot -w /var/www/certbot \
			    $email_arg \
			    $domain_args \
			    --agree-tos" $HABIDAT_DK_CERTBOT_SERVICE	  
		done
	fi	
fi

DOMAINS=$(cat domains.txt)
echo "VIRTUAL_HOST=$DOMAINS" > domains.env

if [ $SELFSIGNED == "true" ]; then
	echo "CERT_NAME=$SELFSIGNED_CERT_NAME" >> domains.env	
else
	echo "LETSENCRYPT_SINGLE_DOMAIN_CERTS=true" >> domains.env
	echo "LETSENCRYPT_HOST=$DOMAINS" >> domains.env
fi


echo "Waiting for project app to warm up..."
sleep 30

echo "Add project to nginx..."
docker-compose exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/add_project.py $1 dk_$1_web ${@:3}
docker-compose exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/generate_config.py

docker-compose up -d

