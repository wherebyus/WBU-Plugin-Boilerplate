#!/usr/bin/env bash

# Setup script for travis-ci. Installs test WP instance and activates plugin.
# Sanity check: we don't run this script locally, because we're making an assumption
# we're using wbu.dev which we already develop on locally.

# create plugin archive file
zip -qr $WP_PLUGIN_NAME.zip *

# install wp-cli
WP_PATH="tmp"
mkdir -p $WP_PATH
cd $WP_PATH

# install wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

# Set up database.
mysql -e 'CREATE DATABASE IF NOT EXISTS wordpress_test;' -uroot

# installing WP. Important to set URL same for acceptance tests
./wp-cli.phar core download
./wp-cli.phar core config --dbname=wordpress_test --dbuser=root --dbhost=127.0.0.1
./wp-cli.phar core install --url=$WP_CEPT_SERVER --title="WBUTests" --admin_user="admin" --admin_password="password" --admin_email="hello@thenewtropic.com"

./wp-cli.phar plugin install ../$WP_PLUGIN_NAME.zip
./wp-cli.phar plugin activate $WP_PLUGIN_NAME