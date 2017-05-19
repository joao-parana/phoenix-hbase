#!/bin/bash
set -e

echo "`date` - Criando os usuários no Database Postgres"

psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
  CREATE USER rabreu;
  CREATE DATABASE rabreu;
  GRANT ALL PRIVILEGES ON DATABASE rabreu TO rabreu;
EOSQL

psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
  CREATE USER parana;
  CREATE DATABASE parana;
  GRANT ALL PRIVILEGES ON DATABASE rabreu TO parana;
EOSQL

psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
  CREATE USER root;
  CREATE DATABASE root;
  GRANT ALL PRIVILEGES ON DATABASE rabreu TO root;
EOSQL
