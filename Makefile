SHELL := C:/Program Files/Git/bin/bash.exe
.SHELLFLAGS := -c

include .env
export

export PROJECT_ROOT := $(CURDIR)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@read -p "Clear all data? You'll lose all the data! [Y/N]: " ans; \
	if [[ "$$ans" = "Y" || "$$ans" = "y" || "$$ans" = "yes" || "$$ans" = "Yes" ]]; then \
	  docker compose down todoapp-postgres && \
	  rm -rf out/pgdata && \
	  echo "All files was deleted"; \
    else \
      echo "Cleanup was declined"; \
    fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
  		echo "Have no seq! Example: make migrate-create seq=1.0.0"; \
  		exit 1; \
	fi; \
	MSYS_NO_PATHCONV=1 docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
   		echo "Have no action! Example: make migrate-create seq=up"; \
		exit 1; \
  	fi; \
	MSYS_NO_PATHCONV=1 docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"
