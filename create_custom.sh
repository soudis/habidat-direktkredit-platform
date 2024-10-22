#!/bin/bash
set -e

source settings.env

usage(){
	echo "Usage: $0 <ID> <container> <URL>"
	exit 1
}

[[ $# -lt 3 ]] && usage

if [ ! -z $HABIDAT_DK_CERTBOT_SERVICE ];then
	echo "Creating let's encrypt certificates..."
	case "$LETSENCRYPT_EMAIL" in
	  "") email_arg="--register-unsafely-without-email" ;;
	  *) email_arg="--email $LETSENCRYPT_EMAIL" ;;
	esac

	domain_args="-d $3"
	docker compose run --rm --entrypoint "\
	  certbot certonly --webroot -w /var/www/certbot \
	    $email_arg \
	    $domain_args \
	    --agree-tos" $HABIDAT_DK_CERTBOT_SERVICE

	if [[ $# -gt 3 ]]; then
		for domain in "${@:4}"; do
		  	domain_args="-d $domain"
			docker compose run --rm --entrypoint "\
			  certbot certonly --webroot -w /var/www/certbot \
			    $email_arg \
			    $domain_args \
			    --agree-tos" $HABIDAT_DK_CERTBOT_SERVICE	  
		done
	fi	
fi

echo "Add custom config to nginx..."

docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/add_custom.py $1 $2 $3
docker exec $HABIDAT_DK_PROXY_CONTAINER python3 scripts/generate_config.py

DOMAINS=$(cat domains.txt)
echo "VIRTUAL_HOST=$DOMAINS" > domains.env

if [ "$SELFSIGNED" == "true" ]; then
	echo "CERT_NAME=$SELFSIGNED_CERT_NAME" >> domains.env	
else
	echo "LETSENCRYPT_SINGLE_DOMAIN_CERTS=true" >> domains.env
	echo "LETSENCRYPT_HOST=$DOMAINS" >> domains.env
fi

docker compose -p $HABIDAT_DK_CONTAINER_PREFIX up -d 

