# github.com/jeromegamez/dotfiles

Jérôme Gamez's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

## Prerequisites

* macOS
    1. Sign in to iCloud and the App Store
    1. Give Terminal.app full disk access in System Settings -> Privacy & Security -> Full Disk Access and restart, if necessary

## Installation

```shell
sh -c "$(curl -fsLS https://raw.githubusercontent.com/jeromegamez/dotfiles/main/install.sh)"
```

Thank you to [Tom Payne](https://github.com/twpayne) for maintaining [`chezmoi`](https://github.com/twpayne/chezmoi)
and for open sourcing [his own dotfiles](https://github.com/twpayne/dotfiles), which mine are heavily inspired by.

## Goals

* Being able to set up a new computer/server with just one script
* Having a clean home directory by using the the [XDG Base Directory Specification](https://xdgbasedirectoryspecification.com/) wherever possible
* Learning a new tool

## Testing

I'm in the process of putting my current configuration into these dotfiles so that I do a clean install
of my Mac afterward.

To test the progress, I've created a Parallels macOS VM with three snapshots:

1. The initial state is a fresh install with only the prerequisites above being applied. I use this snapshot to test
   the `install.sh` script
1. The second snapshot has the `install.sh` script applied (except installing `chezmoi`)
1. The third snapshot is used for testing changes just in the dotfiles.
