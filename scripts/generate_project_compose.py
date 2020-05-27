#!/usr/bin/env python3
from jinja2 import Environment, FileSystemLoader
import sys, os, logging, secrets

try: 

	log = logging.getLogger()
	log.addHandler(logging.StreamHandler(sys.stdout))
	log.setLevel(logging.INFO)

	if len(sys.argv) < 3:
		log.info('Usage: add_project.py <project identifier> <project admin email>')
		exit(1)

	config = {
		"projectId": sys.argv[1],
		"adminEmail": sys.argv[2],
		"mysqlRootPassword": secrets.token_hex(20),
		"mysqlPassword": secrets.token_hex(20),
		"sendgridUser": os.environ['SENDGRID_USER'],
		"sendgridPassword": os.environ['SENDGRID_PASSWORD']
	}
	
	projectPath = 'projects/' +  config.projectId

	if not os.path.exists(projectPath):
		os.makedirs(projectPath)
	
	log.info('Generate single project site %s' % projectId)
	template = env.get_template('templates/docker-compose.project.yml')
	filename = projectPath + '/docker-compose.yml'
	template.stream(config=config).dump(filename)

	log.info('Generated ' + projectPath + '/docker-compose.yml')

except Exception as e:
	log.error('Unhandled exception')
	log.error(traceback.format_exc())
	exit(1)