# Woof

The version manager to end all version managers

STATUS: IN DEVELOPMENT

## Why?

- Your OS's package manager doesn't contain the latest (or multiple) $language versions
  - And/or you don't trust random APT repositories, AUR packages, etc.
- You want an OS independent way to install and switch between $language versions
  - And/or if you don't want to remember how to use `update-alternatives`, `archlinux-java`, etc.
- You are tired of installing and configuration version managers for every single language
- You believe any of the following is overkill, slow, bloated, or is poorly coded
  - [Nix](https://nixos.org)
  - [Guix](https://guix.gnu.org/en/download)
  - [asdf](https://github.com/asdf-vm/asdf)
  - [sdkman](https://github.com/sdkman/sdkman-cli)
  - [Docker](https://www.docker.com) (or containers in general)

## Features

- Optionally configurationless
- Can install any language with pure Bash
- Clean Bash code (uses builtins and Bash facilities over external utilities)

## Use Cases

- Different projects that use $language have different version requirements
- Performance testing
- Rootless installations

## Current Support

Woof plans to support many tens of languages. Currently, there is limited support for NodeJS, Deno, Go, Crystal, Nim, Dart, and the Hashicorp suite of tools. See the full list in [roadmap](./docs/roadmap.md). Furthermore, the following platforms are supported

- Linux (later Darwin, FreeBSD)
- amd64 (later x86, armv7l, aarch64)
- Bash (later Zsh, Ksh, Fish, etc.)

We attempt to be reasonably compatible with all existing tools. For example, it will read asdf's [.tool-versions](https://asdf-vm.com/manage/configuration.html#tool-versions), nvm's [.nvmrc](https://github.com/nvm-sh/nvm#nvmrc) and read things from popular version managers like `rvm` and `pyenv`

## Prerequisites

External utilities are _only_ used due to necessity or efficiency. The following are used

- cURL
- jq 1.6
- POSIX `mv`, `cat`, `cp`, `uname`, `stty`, `sed`, etc.
- sort (GNUism -V) (TODO: phase out)

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/woof
```
