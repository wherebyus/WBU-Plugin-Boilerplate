# WBU Plugin Boilerplate

Taking the [WordPress default boilerplate plugin](https://github.com/DevinVinson/WordPress-Plugin-Boilerplate) and adding travis-ci and codeception integration 

*Why do this?* For easier plugin development internally at WhereBy.Us.

When it comes time to build frodo - the main WordPress Multisite instance that all of our themes and plugins use - we will pull this internally we run our `build.wpe` script, since composer has difficulties with private repos.

## Testing

Codeception is installed for acceptance, functional, and unit testing. We use travis-ci to do this automatically, when someone creates a commit.

### Development

Next steps:
1. Edit `tests/acceptance.suite.yml` to set url of your application. Change `PhpBrowser` to `WebDriver` to enable browser testing.
2. Create your first set of acceptance tests using `codecept g:cest acceptance First`
3. Flesh out the tests in `tests/acceptance/FirstCest.php`
4. Run tests using: `codecept run`

### Testing locally

Make sure you are using frodo, and it's up via `vagrant up`.

### Testing via travis-ci

docker run --name travis-debug -dit travisci/ci-garnet:packer-1499451976 /sbin/init
docker exec -it travis-debug bash -l
su - travis
cd builds
git clone --depth=50 --branch=`[YOUR BRANCH]` `[YOUR REPO]`

And then follow along the /tests/bin/wbu-travis.sh script