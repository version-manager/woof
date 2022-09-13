# Woof

The version manager to end all version managers

STATUS: IN DEVELOPMENT

## Why?

- Your OS's package manager doesn't contain the latest (or multiple) `$language` versions
- You want an OS independent way to install and switch between `$language` versions
- You are tired of installing and configuring version managers (or version manager plugins) for every single language
- More repeatable builds

## Features

- _Just Fucking Works_
- Optionally _configurationless_
- Clean Bash code
  - Favors builtins and native Bash facilities over external utilities)
- Supports 34 languages/programs on at least `x86_64` (see [roadmap](./docs/roadmap.md) and [languages](./docs/languages.md) for details)
- Compatible with [.tool-versions](https://asdf-vm.com/manage/configuration.html#tool-versions), nvm's [.nvmrc](https://github.com/nvm-sh/nvm#nvmrc) and read things from popular version managers like `rvm` and `pyenv`
- Fast
  - Uses symlinks, not shims
  - Extremely rarely execs out to external utilities or subshells

## Preview (v0.2.0)

[![asciicast](https://asciinema.org/a/485308.svg)](https://asciinema.org/a/485308)

## Prerequisites

External utilities are _only_ used due to necessity or efficiency. The following are used

- cURL
- jq 1.6
- POSIX `mv`, `cat`, `cp`, `uname`, `stty`,, etc.
- sort (TODO: phase out -V GNUism)
- Optional: `pv`

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/woof
```
