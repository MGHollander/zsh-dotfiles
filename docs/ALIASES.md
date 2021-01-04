# Aliases

## Table of content <!-- omit in toc -->

- [Easy navigation](#easy-navigation)
- [Directory shortcuts](#directory-shortcuts)
- [Command shortcuts](#command-shortcuts)
- [Open programs (Mac only)](#open-programs-mac-only)
- [Git](#git)
- [Composer](#composer)
- [Docker & docker-compose shortcuts](#docker--docker-compose-shortcuts)
- [Drush](#drush)
- [Other aliases](#other-aliases)

## Easy navigation

| Alias | Command |
| ------ | ------ |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `.....` | `cd ../../../..` |
| `-` | `cd -` |
| `home` | `cd ~` |

## Directory shortcuts

| Alias | Command |
| ------ | ------ |
| `dl` | `d ~/Downloads` |
| `dt` | `cd ~/Desktop` |
| `dev` | `cd ~/dev` |
| `os` | `cd ~/dev/oneshoe` |
| `p` | `cd ~/dev/personal` |

## Command shortcuts

| Alias | Command |
| ------ | ------ |
| `h` | `history` |

## Open programs (Mac only)

| Alias | Command |
| ------ | ------ |
| `phpstorm` | `open -a PhpStorm` |
| `sourcetree` | `open -a SourceTree` |

## Git

| Alias | Command | Note |
| ------ | ------ | ------ |
| `gco` | `git checkout` |
| `gcd` | `git checkout develop` |
| `gcm` | `git checkout master` |
| `gdt` | `git describe --tags $(git rev-list --tags --max-count=1)` | Return the last tag |
| `gd` | `git diff` |
| `gf` | `git fetch` |
| `gl` | `git pull` |
| `glc` | `git pull origin "$(git_current_branch)"` |
| `gld` | `git pull origin develop` |
| `gp` | `git push` |
| `gpc` | `git push origin "$(git_current_branch)"` |
| `gst` | `git status` |
| `gtl` | <code>git tag --sort=-version:refname &#124; head -n 5</code> | Return the last 5 tags |
| `gclb` | `git-clean-local-branches` | Clean up local branches that do not exist on remote anymore (<https://stackoverflow.com/a/17029936>) |

@TODO: Add Git aliases from `.gitconfig`

## Composer

Composer shortcuts including an unlimited PHP memory limit to prevent errors\
(see <https://getcomposer.org/doc/articles/troubleshooting.md#memory-limit-errors>)

| Alias | Command |
| ------ | ------ |
| `c` | `COMPOSER_MEMORY_LIMIT=-1 composer` |
| `ci` | `c install` |
| `co` | `c outdated` |
| `cr` | `c require` |
| `crm` | `c remove` |
| `cu` | `c update` |

## Docker & docker-compose shortcuts

| Alias | Command |
| ------ | ------ |
| `docker-stop-all` | `docker stop $(docker ps -q)` |
| `dsa` | `docker-stop-all` |
| `dco` | `docker-compose` |
| `dcup` | `docker-compose up -d` |
| `dcs` | `docker-compose stop` |
| `dcd` | `docker-compose down` |
| `dcdv` | `docker-compose down --volumes` |

## Drush

| Alias | Command | Note |
| ------ | ------ | ------ |
| `dse` | `drush sql-dump --result-file="./sql-dump-$(date +'%Y%m%d%H%M%S').sql"` | Export the database as file with the current date and time |
| `dsi` | `drush sql-cli <` | Import a database file |

## Other aliases

| Alias | Note |
| ------ | ------ |
| `uuid` | Generate a uuid (531fedb1-b2b5-42ba-8a8e-04c84d3afb47) |
| `uuidc` | Generate a uuid (531fedb1-b2b5-42ba-8a8e-04c84d3afb47) and copy it to the clipboard |
| `yuuid` | Generate a uuid in yaml format (uuid: 531fedb1-b2b5-42ba-8a8e-04c84d3afb47) |
| `yuuidc` | Generate a uuid in yaml format (uuid: 531fedb1-b2b5-42ba-8a8e-04c84d3afb47) and copy it to the clipboard |
| `randomstr` | Generate a random string of 48 characters |
| `randomstrc` | Generate a random string of 48 characters and copy it to the clipboard |
| `st` |  Open repository in SourceTree from terminal. Usage: `st /path/to/repo` |
| `update` | Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages |
| `ip` | Get external IP address |
| `localip` | Get local IP address |
| `cleanup` | Recursively delete `.DS_Store` files |
| `emptytrash` | Empty the Trash on all mounted volumes and the main HDD. Also, clear Apple's System Logs to improve shell startup speed. Finally, clear download history from quarantine. [https://mths.be/bum](https://mths.be/bum) |
| `show` | Show hidden files in Finder |
| `hide` | Hide hidden files in Finder |
| `hidedesktop` | Hide all desktop icons (useful when presenting) |
| `showdesktop` | Show all desktop icons (useful when presenting) |
| `urlencode` | URL-encode strings |
| `mergepdf` | Merge PDF files. Usage: `mergepdf -o output.pdf input{1,2,3}.pdf` |
| `stfu` and `pumpitup` | Stuff I never really use but cannot delete either because of [http://xkcd.com/530/](http://xkcd.com/530/) |
| `afk` | Lock the screen (when going AFK) |
| `reload` | Reload ZSH config |

| Alias | Command | Note |
| ------ | ------ | ------ |
| `hd` | `hexdump -C` | |
| `md5sum` | `md5` | macOS has no `md5sum`, so use `md5` as a fallback |
| `sha1sum` | `shasum` | macOS has no `sha1sum`, so use `shasum` as a fallback |
