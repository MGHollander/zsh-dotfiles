# Install Laravel Valet with Mailhog and Xdebug

This guide describes how to install Laravel Valet with Mailhog and Xdebug.

- [Install Laravel Valet with Mailhog and Xdebug](#install-laravel-valet-with-mailhog-and-xdebug)
  - [Install Laravel Valet](#install-laravel-valet)
  - [Environment variables](#environment-variables)
  - [Install MailHog](#install-mailhog)
    - [Configure PHP to send mail to MailHog](#configure-php-to-send-mail-to-mailhog)
  - [Install Xdebug](#install-xdebug)
    - [Configure PHPStorm](#configure-phpstorm)
  - [Install Memcached](#install-memcached)
  - [Install Apache Solr as a Docker container](#install-apache-solr-as-a-docker-container)
  - [Install Elasticsearch as a Docker container](#install-elasticsearch-as-a-docker-container)
  - [Install Redis](#install-redis)
  - [Known issues](#known-issues)
    - [500 Bad Gateway (upstream sent too big header)](#500-bad-gateway-upstream-sent-too-big-header)

## Install Laravel Valet

Follow the installation steps on <https://laravel.com/docs/master/valet#installation>.
## Environment variables

My nginx config is located in `/usr/local/etc/nginx` and environment variables are already set in the fastcgi_params file.

Append `fastcgi_param APP_ENV development;` to a new line in `/usr/local/etc/nginx/fastcgi_params`

_Source: <https://stackoverflow.com/a/45419230>_

## Install MailHog

Run `brew install mailhog` on your command line. Once MailHog has been installed, you may start it using `brew services start mailhog`.

Now you can access MailHog via <http://localhost:8025/> or <http://127.0.0.1:8025/>.

Run `valet proxy mailhog http://127.0.0.1:8025` to access MailHog via <http://mailhog.test/>.

### Configure PHP to send mail to MailHog

Run `php --ini` to see which ini files PHP is using and copy the path in which additional .ini files are saved.

Run `/usr/local/etc/php/X.X/conf.d/mailhog.ini` and add the config below (replace the X.X with you PHP version or change the path if it does not match the result from above's command).

```ini
; Use mailhog for sending emails
sendmail_path = /usr/local/bin/MailHog sendmail test@test
```

**Note:** You need to repeat these steps every time you switch to a PHP version you have not been using before. You might also need to reconfigure after re-installing/updating a PHP version.

Finally run `valet restart` to activate the

## Install Xdebug

Run `pecl channel-update pecl.php.net` to prepare PECL.

Run `pecl install xdebug` to install Xdebug.
The Xdebug installation returns a path to `xdebug.so` when it has finished installing. This looks something like

```txt
Build process completed successfully
Installing '/usr/local/Cellar/php/7.4.9/pecl/20190902/xdebug.so'
install ok: channel://pecl.php.net/xdebug-2.9.6
Extension xdebug enabled in php.ini
```

Remember the path after **Installing**.

Run `php -m | grep 'xdebug'` to verify if Xdebug was installed. The output should be `xdebug`.

Run `php --ini` to see which ini files PHP is using and copy the path in which additional .ini files are saved.

Run `vi /usr/local/etc/php/X.X/conf.d/ext-xdebug.ini` and add the part of the config below that matches your xdebug version (replace the X.X with you PHP version or change the path if it does not match the result from above's command).
Not sure which xdebug version you have? You get run `php -v | grep -i "xdebug"` to see the xdebug version.

```ini
[xdebug]
zend_extension="/path/to/xdebug.so"

xdebug.idekey=PHPSTORM

; xdebug 2
xdebug.remote_autostart=1
xdebug.default_enable=1
xdebug.remote_port=9000
xdebug.remote_host=127.0.0.1
xdebug.remote_connect_back=1
xdebug.remote_enable=1

; xdebug 3
xdebug.mode=debug
xdebug.start_with_request=yes
xdebug.client_port=9003
xdebug.client_host=127.0.0.1
xdebug.discover_client_host=true
```

Replace `/path/to` in the `zend_extension` value with the path the Xdebug installation returned.

Edit you php.ini file and remove `zend_extension="xdebug.so"`. This rule is probably added to the top of the file.

Finally run `valet restart`.

**Note:** You need to repeat these steps every time you switch to a PHP version you have not been using before. You might also need to reconfigure after re-installing/updating a PHP version.

**Note:** This has been tested with PHP 7.2, 7.3 and 7.4. Instructions might be different for other PHP versions.

**Note:** xdebug 3 uses a different port by default. `9003` instead of `9000`. See <https://xdebug.org/docs/upgrade_guide> for more about the xdebug differences between version 2 and 3.

### Configure PHPStorm

Next step is to configure PHPStorm. Open PHPStorm and open the preference panel. Go to `Languages & Frameworks > PHP > Debug > DBGp Proxy` and set IDE key to `PHPSTORM`. Next, set Port to `9000` or `9003` (depending on your xdebug version and configuration).

After that, go to `Languages & Frameworks > PHP > Debug` and set Xdebug port to `9000` or `9003` (depending on your xdebug version and configuration), check Can accept external connections and clear the two Force break at first line… checkboxes.

Now, you can save the settings and click Start listening for PHP Debug Connections and your debugger should be up and running.

## Install Memcached

Run `brew install libmemcached` to install Memcached on your machine if you haven't yet. You might also need to run `brew install pkg-config`.

Run `pecl channel-update pecl.php.net` to prepare PECL.

Run `pecl install memcached` to install Memcached.
The Xdebug installation returns a path to `memcached.so` when it has finished installing. This looks something like

```txt
Build process completed successfully
Installing '/usr/local/Cellar/php@7.2/7.2.34_4/pecl/20170718/memcached.so'
install ok: channel://pecl.php.net/memcached-3.1.5
Extension memcached enabled in php.ini
```

Remember the path after **Installing**.

Run `php -m | grep 'memcached'` to verify if Memcached was installed. The output should be `memcached`.

Run `php --ini` to see which ini files PHP is using and copy the path in which additional .ini files are saved.

Run `vi /usr/local/etc/php/X.X/conf.d/ext-memcached.ini` and add the config below (replace the X.X with you PHP version or change the path if it does not match the result from above's command).

```ini
[memcached]
extension=/path/to/memcached.so
```

Replace `/path/to` in the `extension` value with the path the Memcached installation returned.

Edit you php.ini file and remove `extension="memcached.so"`. This rule is probably added to the top of the file.

Finally run `valet restart`.

**Note:** You need to repeat these steps every time you switch to a PHP version you have not been using before. You might also need to reconfigure after re-installing/updating a PHP version.

**Note:** This has been tested with PHP 7.3. Instructions might be different for other PHP versions.

## Install Apache Solr as a Docker container

You can use Docker Desktop to get a local Apache Solr server using the following command. Do not forget to change the SOLR_CONFIG_DIR, PROJECT_NAME, Solr version.

SOLR_CONFIG_DIR represents the directory that hold the projects Apache Solr config. A full path should be used, for example `/full/path/to/solr_config`.

**TIP:** If the Solr config is part of the project and it lives in the solr_config directory, then you can use `$PWD/solr_config`. Make sure you run the docker command below from the root directory of the project.

```bash
docker run -d --name solr-5.5 -p 8983:8983 -v SOLR_CONFIG_DIR:/opt/solr/server/solr/configsets/solr-5.5/conf:ro solr:5.5 solr-precreate PROJECT_NAME /opt/solr/server/solr/configsets/solr-5.5
```

Server settings:

```txt
Host: localhost
Path: /
Core: PROJECT_NAME
```

If you have an existing container, then you can start it with the following command.

```bash
docker start CONTAINER_NAME
```

In the example above CONTAINER_NAME is solr-5.5.

## Install Elasticsearch as a Docker container

You can use Docker Desktop to get a local Elasticsearch server using the following command.

```bash
docker run -d --name elasticsearch-7.3 -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.13.3
```

If you have an existing container, then you can start it with the following command.

```bash
docker start CONTAINER_NAME
```

In the example above CONTAINER_NAME is elasticsearch-7.3.

## Install Redis

<https://redfern.dev/articles/laravel-valet-installing-phpredis-with-pecl-homebrew/>

## Known issues

### 500 Bad Gateway (upstream sent too big header)

You might encounter a 500 Bad Gateway. Check the logs via `valet log nginx`. If one of the most recent lines says `upstream sent too big header while reading response header from upstream`, then the below solution might help.

1. Create `~/.config/valet/Nginx/all.conf` with this:

  ```conf
  proxy_buffer_size   4096k;
  proxy_buffers   128 4096k;
  proxy_busy_buffers_size   4096k;
  ```

2. Append this to `/usr/local/etc/nginx/fastcgi_params`

  ```conf
  fastcgi_buffer_size 4096k;
  fastcgi_buffers 128 4096k;
  fastcgi_busy_buffers_size 4096k;
  ```

_**Note:** 4096k is something you need to figure out what best works for you._

_**Source:** <https://github.com/laravel/valet/issues/290#issuecomment-398686133>_
