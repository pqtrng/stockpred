SHELL := /bin/bash
.DEFAULT_GOAL := default
.PHONY:\
	setup-git install-pre-commit \
	lint \
	help default \
	clean \
	build \
	down up prune \

HELP_PADDING = 28
bold := $(shell tput bold)
sgr0 := $(shell tput sgr0)
padded_str := %-$(HELP_PADDING)s
pretty_command := $(bold)$(padded_str)$(sgr0)

include .env

export
DOWN_OPTS = --remove-orphans
UP_OPTS =
PRUNE_OPTS = -f

BUILDKIT = 1
BUILD_OPTS =

JUPYTER_BASE_IMAGE := ${JUPYTER_SCIPY_IMAGE}
JUPYTER_BASE_VERSION := ${JUPYTER_SCIPY_VERSION}

JUPYTER_CHOWN_EXTRA := "/${DATA_DIR}"
JUPYTER_UID := $(shell id -u)
JUPYTER_USERNAME := $(shell id -u -n)

POSTGRES_UID := $(shell id -u)
POSTGRES_GID := $(shell id -g)

install-pre-commit:
	pip3 install pre-commit

setup-git: install-pre-commit
	pre-commit install
	git config branch.autosetuprebase always

lint: install-pre-commit
	@echo "Linting Python files"
	pre-commit run -a

down:
	docker-compose down ${DOWN_OPTS}

prune:
	docker system prune ${PRUNE_OPTS}

clean: down prune
	@echo "Clean up project"

build:
	DOCKER_BUILDKIT = ${BUILDKIT} \
	COMPOSE_DOCKER_CLI_BUILD = ${BUILDKIT} \
	JUPYTER_BASE_IMAGE = ${JUPYTER_BASE_IMAGE} \
	JUPYTER_BASE_VERSION = ${JUPYTER_BASE_VERSION} \
	JUPYTER_TARGET = ${JUPYTER_TARGET} \
	JUPYTER_USERNAME = ${JUPYTER_USERNAME} \
	MLFLOW_VERSION = ${MLFLOW_VERSION} \
	POSTGRES_UID = ${POSTGRES_UID} \
	POSTGRES_GID = ${POSTGRES_GID} \
	docker-compose build ${BUILD_OPTS}

up: ${MLFLOW_ARTIFACT_STORE} ${POSTGRES_STORE}
	JUPYTER_BASE_IMAGE = ${JUPYTER_BASE_IMAGE} \
	JUPYTER_BASE_VERSION = ${JUPYTER_BASE_VERSION} \
	JUPYTER_TARGET = ${JUPYTER_TARGET} \
	JUPYTER_CHOWN_EXTRA = ${JUPYTER_CHOWN_EXTRA} \
	JUPYTER_UID = ${JUPYTER_UID} \
	JUPYTER_USERNAME = ${JUPYTER_USERNAME} \
	JUPYTER_ENABLE_LAB = ${JUPYTER_ENABLE_LAB} \
	POSTGRES_UID = ${POSTGRES_UID} \
	POSTGRES_GID = ${POSTGRES_GID} \
	docker-compose up ${UP_OPTS}


default: clean build up
