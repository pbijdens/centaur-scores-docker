# Docker composition for centaurscores

## Description

This folder contains a docker compose configuration for a complete CentaurScores set up. This includes
both the API, the UI and the MySQL server for the data. All data is stored in a local folder. The
installation can be cusotmized by editing the contents of these local folders.

## Commands

Start the containers with:

```sh
docker compose up --build -d
```

Tear down the containers with

```sh
docker compose down
```

MySQL server health check

```sh
docker inspect --format "{{.State.Health.Status}}" "$(docker-compose ps -q mysql)"
```

### Layout

You get a virtual network 10.62.62.0/24 with on it three services:

1. A mysql service on 10.62.62.2 (mysql)
2. A kestrel service runing the .NET 8 API at 10.62.62.3 on port 8062 (public 8062)
3. An apache2 service hosting the UI at 10.62.62.4 on port 80 (public 80)

## Configuration

In the .env file you find the following configurable settings. These are explained quickly here:

* **CS_SQL_FOLDER**
  Path to the volume for the MYSQL files, relative to this file, can be absolute
* **CS_ASSETS_FOLDER**
  Path to the local assets folder, relative to this file, can be absolute
* **MYSQL_ROOT_PASSWORD**
  The root password used on the MySQL database. Will be used ot create the MYSQL database if this does
  not exist already.
* **DB_NAME**
  The name of the database to be used.
* **DB_USER**
  The username used by the API server to connect to the database
* **DB_PASSWORD**
  The password used for the DB_USER
