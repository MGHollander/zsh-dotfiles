# Aliases

## Table of content <!-- omit in toc -->

- [Easy navigation](#easy-navigation)
- [Directory shortcuts](#directory-shortcuts)
- [Command shortcuts](#command-shortcuts)
- [Docker-compose shortcuts](#docker-compose-shortcuts)
- [List & grep aliases](#list--grep-aliases)
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

| Alias | Command | Comment |
| ------ | ------ | ------ |
| `dl` | `d ~/Downloads` |
| `dt` | `cd ~/Desktop` |
| `dev` | `cd ~/dev` |
| `os` | `cd ~/dev/oneshoe` |
| `p` | `cd ~/dev/personal` |

## Command shortcuts

| Alias | Command |
| ------ | ------ |
| `g` | `git` |
| `h` | `history` |

## Docker-compose shortcuts

| Alias | Command |
| ------ | ------ |
| `dco` | `docker-compose` |
| `dcup` | `docker-compose up -d` |
| `dcs` | `docker-compose stop` |
| `dcd` | `docker-compose down` |
| `dcdv` | `docker-compose down --volumes` |

## List & grep aliases

`ls`, `grep`, `fgrep` and `egrep` always return colored output.

| Alias | Command | Note |
| ------ | ------ | ------ |
| `l` | `ls -lF ${colorflag}` | List all files colorized in long format |
| `la` | `ls -laF ${colorflag}` | List all files colorized in long format, including dot files |
| `lsd` | `ls -lF ${colorflag} | grep --color=never '^d'` | List only directories |

## Drush

| Alias | Command | Note |
| ------ | ------ | ------ |
| `dse` | `drush sql-dump --result-file="./sql-dump-$(date +'%Y%m%d%H%M%S').sql"` | Export the database as file with the current date and time |
| `dsi` | `drush sql-cli <` | Import a database file |

## Other aliases

| Alias | Note |
| ------ | ------ |
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
| `reload` | Reload the shell (i.e. invoke as a login shell) |

| Alias | Command | Note |
| ------ | ------ | ------ |
| `hd` | `hexdump -C` | |
| `md5sum` | `md5` | macOS has no `md5sum`, so use `md5` as a fallback |
| `sha1sum` | `shasum` | macOS has no `sha1sum`, so use `shasum` as a fallback |
