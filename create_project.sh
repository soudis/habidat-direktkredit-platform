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
export HABIDAT_DK_ADD_DOCKER_NETWORK=$HABIDAT_DK_ADD_DOCKER_NETWORK

echo "Generating docker-compose.yml..."
python3 scripts/generate_project_compose.py $1 $2

cd projects/$1

echo "Pulling docker container..."
docker-compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 pull

echo "Creating database docker container..."
docker-compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 db
sleep 10
echo "Creating web app docker container..."
docker-compose -p $HABIDAT_DK_CONTAINER_PREFIX-$1 web

cd ../..

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

if [ "$SELFSIGNED" == "true" ]; then
	echo "CERT_NAME=$SELFSIGNED_CERT_NAME" >> domains.env	
else
	echo "LETSENCRYPT_SINGLE_DOMAIN_CERTS=true" >> domains.env
	echo "LETSENCRYPT_HOST=$DOMAINS" >> domains.env
fi


echo "Waiting for project app to warm up..."
sleep 30

echo "Add project to nginx..."

if [ ! -z $HABIDAT_DK_CONTAINER_PREFIX ]; then
	docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/add_project.py $1 $HABIDAT_DK_CONTAINER_PREFIX-$1-web ${@:3}
else
	docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/add_project.py $1 $$1-web ${@:3}
fi
docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/generate_config.py

docker-compose -p $HABIDAT_DK_CONTAINER_PREFIX up -d 

