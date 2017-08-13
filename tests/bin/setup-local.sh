# Local script that downloads chromedriver, selenium,
# uses are existing localhost environment and spins everything up
# to do acceptance testing.

# We're making assumptions that we have wp-cli and that we've
# already created a vagrant test instance.

# You'll also need to customize the crap out of this.

# Uncomment these lines to profile the script
# set -x
# PS4='$(date "+%s.%N ($LINENO) + ")'

PLUGIN_NAME='WBU-Plugin-Boilerplate'
TESTWP_NAME='wbu-test'
TESTWP_URL='http://wbu-test.dev'
TESTWP_PATH="$HOME/Sites/vagrant-local/www/$TESTWP_NAME/public_html"
PROJECT_ROOT="$HOME/Sites/$PLUGIN_NAME"
SERVER_PATH="$PROJECT_ROOT/tests/tmp"

CHROME_URL="https://chromedriver.storage.googleapis.com/2.31/chromedriver_mac64.zip"
CHROME_FILENAME="${CHROME_URL##*/}"

SELENIUM_URL="http://selenium-release.storage.googleapis.com/3.4/selenium-server-standalone-3.4.0.jar"
SELENIUM_FILENAME="${SELENIUM_URL##*/}"

# Check if the test URL is up. 
# If not, we can't continue because these are acceptance tests.
# Ref: http://answers.google.com/answers/threadview/id/276934.html
function check {
	if [ $? -ne 0 ] ; then
		echo "Error occurred getting URL $1:"
	if [ $? -eq 6 ]; then
		echo "Unable to resolve host"
	fi
	if [$? -eq 7 ]; then
		echo "Unable to connect to host"
	fi
	exit 1
	fi
}

curl -s -o /dev/null $TESTWP_URL
check;

if [ ! -d "vendor" ]; then
    echo "Didn't find the vendor directory. Did you run composer install yet?"
    exit 1
fi


# Set up the servers
mkdir -p $SERVER_PATH

if [ ! -f "$SERVER_PATH/$CHROME_FILENAME" ]; then
    rm /usr/local/bin/chromedriver
    rm /usr/local/share/chromedriver

    echo "Downloading ChromeDriver..."
    cd "$SERVER_PATH"
    curl -O "$CHROME_URL"
    unzip chromedriver_mac64.zip -d ~/
    rm ~/chromedriver_mac64.zip
    sudo mv -f ~/chromedriver /usr/local/share/
    sudo chmod +x /usr/local/share/chromedriver
    sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
fi

if [ ! -f "$SERVER_PATH/$SELENIUM_FILENAME" ]; then
    echo "Downloading Selenium..."
    cd "$SERVER_PATH"
    curl -O "$SELENIUM_URL"
fi

# wp plugin status --path=$TESTWP_PATH

# zip the plugin-name folder
echo "Preparing the plugin zip file..."
cd $PROJECT_ROOT

#check if plugin is installed, sets exit status to 1 if not found
wp plugin is-installed $PLUGIN_NAME --path=$TESTWP_PATH --allow-root
if [ $? -eq 0 ]; then
	echo "Existing plugin found in WP test build, deleting..."
	wp plugin delete $PLUGIN_NAME --path=$TESTWP_PATH
fi

rm $PLUGIN_NAME.zip
zip -qr $PLUGIN_NAME.zip *
wp plugin install $PLUGIN_NAME.zip --path=$TESTWP_PATH
wp plugin activate $PLUGIN_NAME --path=$TESTWP_PATH

echo "Building Acceptance Tests with Codeception..."
php ./vendor/bin/codecept build

cd $PROJECT_ROOT

echo "Running Selenium..."
pkill -f "java -jar $SERVER_PATH/$SELENIUM_FILENAME"
find . -name 'selenium.log*' -delete
java -jar "$SERVER_PATH/$SELENIUM_FILENAME" -log "$SERVER_PATH/selenium.log" &
sleep 1
while ! grep -m1 'Selenium Server is up and running' < "$SERVER_PATH/selenium.log"; do
    sleep 1
done

echo "Running Acceptance Tests with Codeception..."
php ./vendor/bin/codecept run acceptance --steps

echo "Shutting down Selenium..."
pid=`ps -eo pid,args | grep selenium-server | grep -v grep | cut -c1-6`
kill -9 $pid

# clean up plugin
# echo "Removing plugin from WP test build..."
# wp plugin delete $PLUGIN_NAME --path=$TESTWP_PATH
