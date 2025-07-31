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

### Result

You'll get a virtual network 10.62.62.0/24 with on it three services:

1. A mysql service on 10.62.62.2 (mysql)
2. A kestrel service runing the .NET 8 API at 10.62.62.3 on port 8062 (public 8062)
3. An apache2 service hosting the UI at 10.62.62.4 on port 80 (public 80)

The API and the UI will also be available on the docker hosts's public IP on pors 80 and 8062, unless 
you choose to change this.

## Configuration

In the .env file you find the following configurable settings. These are explained in the defualt .env
file, but you must change the following values before you compose for the first time:

* MYSQL_ROOT_PASSWORD
* DB_PASSWORD
* CS_INITIAL_PASSWORD_HASH
* CS_BACKUP_SECRET

Failure to change these will allow knowledgable users to connect to these services with the default
password(s), which is of course not desirable.

## First use

Browse to http://localhost:8062/swagger to verify the API is up, check the logs and test an endpoint to
verify the SQL database connection works.

Use ```docker compose logs centaurscoresui``` or ```docker compose logs centaurscoresapi``` or even ```docker compose logs mysql``` to check logs.

Use ```docker compose exec centaurscoresapoi bash``` to get a shell, this is especially useful for the MYSQL container to DB maintenance.

Browse to http://localhost:80/cs to verify that the solution works

Log in using the csadmin user with the password you created when changing the CS_INITIAL_PASSWORD_HASH.

Create a list, select a list, create a competition, create a match => GO.