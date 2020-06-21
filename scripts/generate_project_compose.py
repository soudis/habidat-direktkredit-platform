#!/usr/bin/env python3
from jinja2 import Environment, FileSystemLoader
import sys, os, logging, secrets

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
    	containerPrefix = os.environ['HABIDAT_DK_CONTAINER_PREFIX'] + '_'

	config = {
		"projectId": sys.argv[1],
		"adminEmail": sys.argv[2],
		"mysqlRootPassword": secrets.token_hex(20),
		"mysqlPassword": secrets.token_hex(20),
		"proxyNetwork": proxyNetwork,
		"containerPrefix": containerPrefix
	}
	
	projectPath = 'projects/' +  config['projectId']

	if not os.path.exists(projectPath):
		os.makedirs(projectPath)
	
	log.info('Generate project site %s' % config['projectId'])
	template = env.get_template('docker-compose.project.yml')
	filename = projectPath + '/docker-compose.yml'
	template.stream(config=config).dump(filename)

	log.info('Generated ' + projectPath + '/docker-compose.yml')

except Exception as e:
	log.error('Unhandled exception')
	log.error(traceback.format_exc())
	exit(1)