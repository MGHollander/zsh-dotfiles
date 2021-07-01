# Install Laravel Valet with Mailhog and Xdebug

This guide describes how to install Laravel Valet with Mailhog and Xdebug.

- [Install Laravel Valet](#install-laravel-valet)
- [Install MailHog](#install-mailhog)
  - [Configure PHP to send mail to MailHog](#configure-php-to-send-mail-to-mailhog)
- [Install Xdebug](#install-xdebug)
  - [Configure PHPStorm](#configure-phpstorm)

## Install Laravel Valet

Follow the installation steps on <https://laravel.com/docs/master/valet#installation>.

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

You need to repeat these steps every time you switch to a PHP version you have not been using before.

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

Run `vi /usr/local/etc/php/X.X/conf.d/ext-xdebug.ini` and add the config below (replace the X.X with you PHP version or change the path if it does not match the result from above's command).

```ini
[xdebug]
zend_extension="/path/to/xdebug.so"
xdebug.remote_autostart=1
xdebug.default_enable=1
xdebug.remote_port=9000
xdebug.remote_host=127.0.0.1
xdebug.remote_connect_back=1
xdebug.remote_enable=1
xdebug.idekey=PHPSTORM
```

Replace `/path/to` in the `zend_extension` value with the path the Xdebug installation returned.

Edit you php.ini file and remove `zend_extension="xdebug.so"`. This rule is probably added to the top of the file.

Finally run `valet restart`.

You need to repeat these steps every time you switch to a PHP version you have not been using before.

**Note:** This has been tested with PHP 7.2, 7.3 and 7.4. Instructions might be different for other PHP versions.

### Configure PHPStorm

Next step is to configure PHPStorm. Open PHPStorm and open the preference panel. Go to `Languages & Frameworks > PHP > Debug > DBGp Proxy` and set IDE key to `PHPSTORM`. Next, set Port to `9000`.

After that, go to `Languages & Frameworks > PHP > Debug` and set Xdebug port to `9000`, check Can accept external connections and clear the two Force break at first line… checkboxes.

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

You need to repeat these steps every time you switch to a PHP version you have not been using before.

**Note:** This has been tested with PHP 7.3. Instructions might be different for other PHP versions.

## Install SOLR
