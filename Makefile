COMPOSE = docker compose
SERVICE = app

.PHONY: build up down restart logs ps setup shell db migrate test clean

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs -f $(SERVICE)

ps:
	$(COMPOSE) ps

shell:
	$(COMPOSE) exec $(SERVICE) bash

db:
	$(COMPOSE) exec $(SERVICE) bundle exec rails dbconsole

migrate:
	$(COMPOSE) exec $(SERVICE) bundle exec rails db:migrate

test:
	$(COMPOSE) run --rm $(SERVICE) bundle exec rails test

clean:
	$(COMPOSE) down -v --remove-orphans
