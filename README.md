# Woof

Woof is a program and package version manager

Other solutions are either too complex or too fragile. Woof aims to provide a superior out of the box experience

STATUS: IN DEVELOPMENT

## Example (hypothetical)

```sh
$ cat ./project-dir/.tool-versions
ruby 2.7.0
nodejs 17.0.0
crystal 1.2.1
$ cd ./project-dir
$ ruby --version
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux-gnu]
$ node --version
v17.0.0
$ crystal --version
Crystal 1.2.1 [4e6c0f26e] (2021-10-21)

LLVM: 10.0.0
Default target: x86_64-unknown-linux-gnu
```

Compatible in many ways with [asdf](https://asdf-vm.com/manage/configuration.html#tool-versions) and other popular version managers like `rvm and `nvm`

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

basalt global add hyperupcall/woof

## Prerequisites (for now)

- cURL
- `sort -w`
- tput (i think optional)
- stty
- clear
- perl (somewhat optional)

For those that don't use [Nix](https://nixos.org)
