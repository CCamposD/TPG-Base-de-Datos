PSQL ?= psql
DB ?= ventas_tp
USER ?= postgres

.PHONY: all reset schema load before indexes after verify

all:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/script-completo.sql

reset:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/00-reset.sql

schema:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/01-create-tables.sql

load:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/02-load-data.sql

before:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/04-explain-original.sql

indexes:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/05-create-indexes.sql

after:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/06-optimized-queries.sql

verify:
	$(PSQL) -v ON_ERROR_STOP=1 -U $(USER) -d $(DB) -f scripts/07-verify-results.sql
