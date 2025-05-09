[![make-test](https://github.com/djerz/dotfiles/actions/workflows/make-test.yml/badge.svg)](https://github.com/djerz/dotfiles/actions/workflows/make-test.yml)

# dotfiles
Bootstrap my linux devenv

**Table of Contents**

<!-- toc -->

- [About](#about)
  * [Installing](#installing)
  * [Customizing](#customizing)
- [Resources](#resources)
  * [`.vim`](#vim)
- [Contributing](#contributing)
  * [Running the tests](#running-the-tests)

<!-- tocstop -->

## About

### Installing

```console
$ make
```

This will create symlinks from this repo to your home folder.

### Customizing

Save env vars, etc in a `.extra` file, that looks something like
this:

```bash
###
### Git credentials
###

GIT_AUTHOR_NAME="Your Name"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="email@you.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
GH_USER="nickname"
git config --global github.user "$GH_USER"

###
### Gmail credentials for mutt
###
export GMAIL=email@you.com
export GMAIL_NAME="Your Name"
export GMAIL_FROM=from-email@you.com
```

## Contributing

### Running the tests

The tests use [shellcheck](https://github.com/koalaman/shellcheck). You don't
need to install anything. They run in a container.

```console
$ make test
```
