##################
# Variables
##################

DOCKER_COMPOSE = docker-compose -f ./.docker/docker-compose.yml
DOCKER_COMPOSE_PHP_FPM_EXEC = ${DOCKER_COMPOSE} exec -u www-data php-fpm

##################
# Docker compose
##################

build:
	${DOCKER_COMPOSE} build

up:
	${DOCKER_COMPOSE} up -d --remove-orphans

stop:
	${DOCKER_COMPOSE} stop

dc_sh:
	${DOCKER_COMPOSE} exec php sh
