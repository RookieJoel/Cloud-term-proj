#!/bin/bash
set -euxo pipefail
exec > /var/log/userdata.log 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y

apt-get install -y \
  apache2 \
  php8.3 \
  libapache2-mod-php8.3 \
  php8.3-mysql \
  php8.3-curl \
  php8.3-gd \
  php8.3-xml \
  php8.3-mbstring \
  php8.3-zip \
  php8.3-intl \
  php-imagick \
  php8.3-soap \
  mariadb-client \
  wget \
  unzip \
  curl

a2enmod rewrite

cat > /etc/apache2/sites-available/000-default.conf <<'APACHECONF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog $${APACHE_LOG_DIR}/error.log
    CustomLog $${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
APACHECONF

systemctl enable apache2
systemctl restart apache2

cd /tmp
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

rm -rf /var/www/html/index.html
cp -r wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

cd /var/www/html
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_user}/" wp-config.php
sed -i "s/password_here/${db_pass}/" wp-config.php
sed -i "s/localhost/${db_host}/" wp-config.php

sed -i "/\/\* That's all/i define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL | MYSQLI_CLIENT_SSL_DONT_VERIFY_SERVER_CERT);" wp-config.php

mkdir -p /home/ubuntu/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL cloud-wordpress" \
  >> /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

wp config shuffle-salts --path=/var/www/html --allow-root

wp core install \
  --url="http://${eip}" \
  --title="Cloud" \
  --admin_user="${admin_user}" \
  --admin_password="${admin_pass}" \
  --admin_email="admin@example.com" \
  --skip-email \
  --path=/var/www/html \
  --allow-root

wp plugin install amazon-s3-and-cloudfront --activate \
  --path=/var/www/html --allow-root

sed -i "/\/\* That's all/i\\
define('AS3CF_SETTINGS', serialize(array(\\
    'provider' => 'aws',\\
    'use-server-roles' => true,\\
    'bucket' => '${bucket_name}',\\
    'region' => '${bucket_region}',\\
    'copy-to-s3' => true,\\
    'serve-from-s3' => true,\\
    'remove-local-file' => false,\\
)));" wp-config.php

chown -R www-data:www-data /var/www/html
systemctl restart apache2

echo "completed"
