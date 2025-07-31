#!/bin/bash
set -e

LOCAL_PATH=/var/www/centaurscoresapi

DB_SERVER=${DB_SERVER}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
CS_API_PORT=${CS_API_PORT}
CS_MYSQL_PORT=${CS_MYSQL_PORT}
CS_BACKUP_SECRET=${CS_BACKUP_SECRET}
CS_INITIAL_PASSWORD_HASH=${CS_INITIAL_PASSWORD_HASH}

DOWNLOAD_URL=$(curl -s https://api.github.com/repos/pbijdens/centaur-scores-api/releases/latest | grep browser_download_url | cut -d '"' -f4)

mkdir -p $LOCAL_PATH

rm -rf /tmp/release && mkdir /tmp/release
pushd /tmp/release
curl -sL $DOWNLOAD_URL | tar xvfz -
popd
rm -rf $LOCAL_PATH/*
cp -R /tmp/release/* $LOCAL_PATH
chown -R root:root $LOCAL_PATH
chmod -R a+rX $LOCAL_PATH

cat <<EOT > $LOCAL_PATH/appsettings.Production.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AppSettings": {
    "Secret": "$CS_INITIAL_PASSWORD_HASH",
    "BackupSecret": "$CS_BACKUP_SECRET",
    "AdminACLId": 1,
    "DefaultUser": "csadmin",
    "DefaultUserHash": "$CS_INITIAL_PASSWORD_HASH"
  },  
  "ConnectionStrings": {
    "CentaurScoresDatabase": "server=$DB_SERVER;port=$CS_MYSQL_PORT;database=$DB_NAME;user=$DB_USER;password=$DB_PASSWORD"
  }
}
EOT

curl -sL https://raw.githubusercontent.com/vishnubob/wait-for-it/refs/heads/master/wait-for-it.sh > $LOCAL_PATH/wait-for-it.sh
chmod +x $LOCAL_PATH/wait-for-it.sh
$LOCAL_PATH/wait-for-it.sh -h mysql -p $CS_MYSQL_PORT
sleep 5

export ASPNETCORE_ENVIRONMENT=Production
export ASPNETCORE_URLS="http://*:$CS_API_PORT"
cd $LOCAL_PATH
exec dotnet $LOCAL_PATH/CentaurScores.dll --urls http://0.0.0.0:$CS_API_PORT