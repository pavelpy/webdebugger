DOCKER_IMAGE_NAME?=webdebugger
DOCKER_IMAGE_TAG?=local

APP_PORT?=8000
APP_DELAY?=0

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)
PYTHON_37_IMAGE?=python:3.7-slim

DOCKER_USER_FLAG?=-u $(shell id -u)
DOCKER_FLAGS?=-t
ifeq ($(INTERACTIVE), 1)
DOCKER_FLAGS:=-it
endif

.PHONY: install_poetry
install_poetry:
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

.PHONY: requirements
requirements:
	poetry install --local

.PHONY: pytest
pytest:
	poetry run pytest -v

.PHONY: build
build:
	docker build --cache-from $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .

.PHONY: docker-pytest
docker-pytest: build
	docker run $(DOCKER_FLAGS) $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) poetry run pytest -v

.PHONY: docker-run
docker-run: build
	docker run -p $(APP_PORT):$(APP_PORT) --env APP_PORT=$(APP_PORT) --env APP_DELAY=$(APP_DELAY) $(DOCKER_FLAGS) $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

.PHONY: docker-shell
docker-shell: build
	docker run -p $(APP_PORT):$(APP_PORT) --env APP_PORT=$(APP_PORT) --env APP_DELAY=$(APP_DELAY) $(DOCKER_FLAGS) $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) sh
