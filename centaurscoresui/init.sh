#!/bin/bash
set -e

CS_API_PORT=${CS_API_PORT}
LOCAL_PATH=/var/www/centaurscoresui
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/pbijdens/centaur-scores-ui/releases/latest | grep browser_download_url | cut -d '"' -f4)
DOWNLOAD_URL_APK=$(curl -s https://api.github.com/repos/pbijdens/centaur-scores/releases/latest | grep browser_download_url | grep app-debug.apk | cut -d '"' -f4)
DOWNLOAD_URL_APK_RELEASE=$(curl -s https://api.github.com/repos/pbijdens/centaur-scores/releases/latest | grep browser_download_url | grep app-release.apk | cut -d '"' -f4)

mkdir -p $LOCAL_PATH

rm -rf /tmp/release
mkdir /tmp/release
pushd /tmp/release
curl -sL $DOWNLOAD_URL | tar xvfz -
curl -sL $DOWNLOAD_URL_APK > /tmp/release/app.apk
curl -sL $DOWNLOAD_URL_APK_RELEASE > /tmp/release/app-release.apk
popd
rm -rf $LOCAL_PATH/*
cp -R /tmp/release/* $LOCAL_PATH
chown -R root:root $LOCAL_PATH
chmod -R a+rX $LOCAL_PATH

mkdir -p /etc/apache2/conf-available
cat <<EOT > /etc/apache2/conf-available/centaurscores.conf
<IfModule alias_module>
    Alias /cs $LOCAL_PATH
    Alias /assets /var/www/csassets
</IfModule>

<Directory "$LOCAL_PATH">
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /cs
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_FILENAME} !-l
  RewriteRule . index.html [L]
</IfModule>
AddType application/vnd.android.package-archive .apk
</Directory>

<Location "/cs/">
    Require all granted
</Location>
<Location "/assets/">
    Require all granted
</Location>
EOT

# mv $LOCAL_PATH/assets/configuration.json $LOCAL_PATH/assets/configuration.json.bak
# cat $LOCAL_PATH/assets/configuration.json.bak | sed "s/:8062/:$CS_API_PORT/g" > $LOCAL_PATH/assets/configuration.json

a2enmod rewrite
a2enconf centaurscores
apache2ctl -D FOREGROUND
