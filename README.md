# Woof

The version manager to end all version managers

STATUS: IN DEVELOPMENT

Woof plans to support at least 15+ languages from the getgo. See the full list in [roadmap](./docs/roadmap.md)

## Why?

- Different projects on your development machine require different versions of $language
- Your OS's package manager doesn't contain latest version of $language
- Want an OS independent way to install and switch between $language (`apt`, `pacman`, `update-alternatives`, `archlinux-java`)
- Don't want to use superuser privileges to install language
- Don't want to install a million different version managers for different languages
- Need to quickly switch between different versions (i.g. performance testing)
- If the [Nix](https://nixos.org)/[Guix](https://guix.gnu.org/en/download) solution is overkill for you and you neither want to use [asdf](https://github.com/asdf-vm/asdf) nor [sdkman](https://github.com/sdkman/sdkman-cli)
- If you agree containers are overkill for this particular solution
- For my fellow polyglots

## Current Support

- Linux (later Darwin, FreeBSD, Solaris, OpenBSD)
- amd64 (later x86, armv7l, aarch64)
- Bash (later Zsh, etc.)

Compatible in many ways with [asdf](https://asdf-vm.com/manage/configuration.html#tool-versions) and other popular version managers like `rvm` and `nvm`

## Installation

NOTE: Woof is currently non-functional with respect to how its advertised

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/woof
```

## Prerequisites

These are the _only_ external utilities required

- cURL
- sort (GNUism -V)
- tput
- stty
- clear
- uname
- perl (somewhat optional)
