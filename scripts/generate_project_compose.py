#!/usr/bin/env python3
import logging
import os
import secrets
import sys

from jinja2 import Environment, FileSystemLoader

try: 

	log = logging.getLogger()
	log.addHandler(logging.StreamHandler(sys.stdout))
	log.setLevel(logging.INFO)

	file_loader = FileSystemLoader('templates')
	env = Environment(loader=file_loader)	

	if len(sys.argv) < 3:
		log.info('Usage: add_project.py <project identifier> <project admin email>')
		exit(1)

	proxyNetwork = 'direktkredit-proxy'
	if 'HABIDAT_DK_PROXY_NETWORK' in os.environ:
		proxyNetwork = os.environ['HABIDAT_DK_PROXY_NETWORK'];

	containerPrefix = ''
	if 'HABIDAT_DK_CONTAINER_PREFIX' in os.environ and os.environ['HABIDAT_DK_CONTAINER_PREFIX'] != '':
		containerPrefix = os.environ['HABIDAT_DK_CONTAINER_PREFIX'] + '-'

	addDockerNetwork = 'no'
	if 'HABIDAT_DK_ADD_DOCKER_NETWORK' in os.environ and os.environ['HABIDAT_DK_ADD_DOCKER_NETWORK'] != '':
		addDockerNetwork = os.environ['HABIDAT_DK_ADD_DOCKER_NETWORK']

	faqUrl = ''
	if 'HABIDAT_DK_FAQ_URL' in os.environ and os.environ['HABIDAT_DK_FAQ_URL'] != '':
		faqUrl = os.environ['HABIDAT_DK_FAQ_URL']

	adminPassword = secrets.token_urlsafe(8)

	config = {
		"projectId": sys.argv[1],
		"adminEmail": sys.argv[2],
		"adminPassword": adminPassword,
		"mysqlRootPassword": secrets.token_hex(20),
		"mysqlPassword": secrets.token_hex(20),
		"proxyNetwork": proxyNetwork,
		"containerPrefix": containerPrefix,
		"addDockerNetwork": addDockerNetwork,
		"faqUrl": faqUrl
	}
	
	projectPath = 'projects/' +  config['projectId']

	if not os.path.exists(projectPath):
		os.makedirs(projectPath)
	
	log.info('Generate project site %s' % config['projectId'])
	log.info('admin user: ' + sys.argv[2] + ', password: ' + adminPassword)
	template = env.get_template('docker-compose.project.yml')
	filename = projectPath + '/docker-compose.yml'
	template.stream(config=config).dump(filename)

	log.info('Generated ' + projectPath + '/docker-compose.yml')

except Exception as e:
	log.error('Unhandled exception')
	log.error(traceback.format_exc())
	exit(1)