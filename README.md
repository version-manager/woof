# Woof

The version manager to end all version managers

STATUS: IN DEVELOPMENT

## Why?

- Your OS's package manager doesn't contain the latest (or multiple) `$language` versions
  - And/or you don't trust random / less maintained APT repositories, AUR packages, etc.
- You want an OS independent way to install and switch between `$language` versions
  - And/or if you don't want to remember / forget how to use `update-alternatives`, `archlinux-java`, etc.
- You are tired of installing and configuration version managers (or version manager plugins) for every single language
  - And/or you think each version manager comes with its own class of bugs / bad dx, etc.

## Features

- Optionally configurationless
- Can install any language with pure Bash
- Clean Bash code (heavily favors builtins and Bash facilities over external utilities)

## Preview (v0.2.0)

[![asciicast](https://asciinema.org/a/485308.svg)](https://asciinema.org/a/485308)

## Current Support

Woof already supports 34 languages/programs on at least `x86_64`. For more details, see the [roadmap](./docs/roadmap.md)

We attempt to be reasonably compatible with all existing tools. For example, it will read asdf's [.tool-versions](https://asdf-vm.com/manage/configuration.html#tool-versions), nvm's [.nvmrc](https://github.com/nvm-sh/nvm#nvmrc) and read things from popular version managers like `rvm` and `pyenv`

## Prerequisites

External utilities are _only_ used due to necessity or efficiency. The following are used

- cURL
- jq 1.6
- POSIX `mv`, `cat`, `cp`, `uname`, `stty`, `sed`, etc.
- sort (TODO: phase out -V GNUism)
- Optional: `pv`

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/woof
```
