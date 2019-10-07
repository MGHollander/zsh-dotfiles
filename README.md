# Marc's dotfiles

Heavily stripped version of [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles).

I chose to leave every possible file in a subfolder to keep my home dir as clean as possible and keep my own custom files separate from the other files.

## Table of content <!-- omit in toc -->

- [Installation](#installation)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Aliases](#aliases)
- [EditorConfig](#editorconfig)
- [Add custom commands without creating a new fork](#add-custom-commands-without-creating-a-new-fork)
- [Using two Git identities to seperate work and personal accounts](#using-two-git-identities-to-seperate-work-and-personal-accounts)
- [Terminal completion](#terminal-completion)
- [Help](#help)
  - [Git Completion not working](#git-completion-not-working)
- [Contact](#contact)
- [To do](#to-do)

## Installation

Run `git clone git@gitlab.com:MGHollander/dotfiles.git` in the root of your user directory.

Add to `~/.bashrc` or `~/.bash_profile`:

```bash
# Load custom dotfiles
source ~/dotfiles/.bashrc;
```

**NOTE:** On Mac you have to change the default background en font color of the terminal.

Add to `~/.gitconfig`

```ini
# Load custom git config
[include]
    path = ~/dotfiles/.gitconfig
```

**NOTE:** Some git config files might be overwritten by Git GUI tools. For  example: My `~/dotfiles/.gitignore` wasn't loading. When I checked my `~/.gitconfig` the `excludesfile` variable was overwritten by Sourcetree. Therefore I have to configure my own global .gitignore in the Sourcetree settings.

## Keyboard shortcuts

[My favorite keyboard shortcuts](KEYBOARD-SHORTCUTS.md)

## Aliases

[All available aliases](ALIASES.md)

## EditorConfig

If you want to use the `.editorconfig` then you have to move it to the root of the user directory.

## Add custom commands without creating a new fork

If `~/dotfiles/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

## Using two Git identities to seperate work and personal accounts

Às of [Git 2.13.0](https://github.com/git/git/blob/v2.13.0/Documentation/RelNotes/2.13.0.txt) there is a possibility to [include confitional config](https://git-scm.com/docs/git-config#_conditional_includes). This is usefull when you use your machine for both work and private.

An example of how I use it.

My `~/.gitconfig`:

```ini
[user]
    name = Marc Hollander
    email = my@personal.mail

[includeIf "gitdir:~/dev/work/"]
    path = ~/.gitconfig-work
```

My `~/.gitconfig-work`:

```ini
[user]
    name = Marc Hollander (Work)
    email = my@work.mail
```

By default my commits will be in name of my personal account. When I commit something from a repository inside the `~/dev/work/` directory, then it will be in name of my work account.

## Terminal completion

Git completion is add to the dotfiles. You can add paths to the `CDPATH` variable in `.exports` for shortcuts when you use the `cd` command.

## Help

### Git Completion not working

Run `chmod -X ~/.git-completion.bash` and restart your terminal. ([source](http://thegeekywizard.com/2014/03/autocomplete-for-git-mac-osx-terminal/))

## Contact

Please [create an issue](https://gitlab.com/MGHollander/dotfiles/issues) if you have any questions or suggestions.

## To do

- Add a list with all functionalies included in the dotfiles. Describe things that happen in files that do not have aliases or functions, but do have useful functionalities (.bash_prompt, .exports, etc.).
- Check if the original dotfiles contain an installer and (re)add this to my version. Also add new stuff such as bash-completion (via Homebrew) and drush. Maybe run `brew services list` to see what is installed via Homebrew.
