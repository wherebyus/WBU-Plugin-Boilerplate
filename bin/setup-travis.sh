#!/usr/bin/env bash

# Setup script for travis-ci. Installs test WP instance and activates plugin.
# Sanity check: we don't run this script locally, because we're making an assumption
# we're using wbu.dev which we already develop on locally.

# install wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

# Set up database.
mysql -e 'CREATE DATABASE IF NOT EXISTS wordpress_test;' -uroot

# installing WP. Important to set URL same for acceptance tests
./wp-cli.phar core download
mv wp-config.php _wp-config.php
./wp-cli.phar core config --dbname=wordpress_test --dbuser=root --dbhost=127.0.0.1
./wp-cli.phar core install --url=$WP_CEPT_SERVER --title="WBUTests" --admin_user="admin" --admin_password="password" --admin_email="hello@thenewtropic.com"

mv $WP_PLUGIN_SHORTNAME wp-content/plugins

# activating test plugin. 
# No need for the 'wp plugin install' command because it's already in the repo.
./wp-cli.phar plugin activate $WP_PLUGIN_SHORTNAME

# preparing data for test
# ./wp term create "Game of Drones" category
# ./wp post create --post_type=page --post_status=publish --post_title='Submit a Post' --post_content="[user-submitted-posts]"

# updating plugin options: enabling "Game of Drones" category, disabling captcha
# ./wp option set usp_options '{"default_options":0,"author":1,"categories":["1","2"],"number-approved":-1,"redirect-url":"","error-message":"There was an error. Please ensure that you have added a title, some content, and that you have uploaded only images.","min-images":0,"max-images":1,"min-image-height":0,"min-image-width":0,"max-image-height":1500,"max-image-width":1500,"usp_name":"show","usp_url":"show","usp_title":"show","usp_tags":"show","usp_category":"show","usp_images":"hide","upload-message":"Please select your image(s) to upload.","usp_form_width":"300","usp_question":"1 + 1 =","usp_response":"2","usp_casing":0,"usp_captcha":"hide","usp_content":"show","success-message":"Success! Thank you for your submission.","usp_form_version":"current","usp_email_alerts":1,"usp_email_address":"davert.php@mailican.com","usp_use_author":0,"usp_use_url":0,"usp_use_cat":0,"usp_use_cat_id":"","usp_include_js":1,"usp_display_url":"","usp_form_content":"","usp_richtext_editor":0,"usp_featured_images":0}' --format=json
