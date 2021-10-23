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
- If the [Nix](https://nixos.org)/[Guix](https://guix.gnu.org/en/download) solution is overkill for you and both [asdf](https://github.com/asdf-vm/asdf) and [sdkman](https://github.com/sdkman/sdkman-cli) don't work for you
- When container engines are overkill
- For my fellow polyglots

## Current Support

- Linux (later Darwin, FreeBSD)
- amd64 (later x86, armv7l, aarch64)

## Example (hypothetical)

```sh
$ cat ./project-dir/.tool-versions
ruby 2.7.0
nodejs 17.0.0
crystal 1.2.1
$ cd ./project-dir # versions will automagically change
$ ruby --version
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux-gnu]
$ node --version
v17.0.0
$ crystal --version
Crystal 1.2.1 [4e6c0f26e] (2021-10-21)

LLVM: 10.0.0
Default target: x86_64-unknown-linux-gnu
```

Compatible in many ways with [asdf](https://asdf-vm.com/manage/configuration.html#tool-versions) and other popular version managers like `rvm` and `nvm`

## Installation

NOTE: `Woof` is currently non-functional with respect to how its advertised

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/woof
```

## Prerequisites (for now)

- cURL
- `sort -w`
- tput (i think optional)
- stty
- clear
- perl (somewhat optional)
- uname
