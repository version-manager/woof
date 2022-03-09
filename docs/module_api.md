# Module API

Implementations of version controlling a particular language are defined in a module. This page documents the API contract

## `<module>.matrix()`

Prints a version matrix to standard output

The structure is the following. The comment is optional

```txt
<variant>|<version>|<os>|<arch>|<url>|<comment>
```

Here are some examples

```txt
Go|v1.17.6|linux|amd64|https://go.dev/dl/dl/go1.17.6.linux-amd64.tar.gz
NodeJS|v15.9.0|linux|amd64|https://nodejs.org/download/release/v15.9.0/node-v15.9.0-linux-x64.tar.gz|(Released 2021-02-18)
Nim|v1.2.14|linux|amd64|https://nim-lang.org//download/nim-1.2.14-linux_x64.tar.xz
Dart|v2.9.3|linux|armv7|https://storage.googleapis.com/dart-archive/channels/stable/release/2.16.0/sdk/dartsdk-linux-arm-release.zip
```

Currently, operating system must be one of

- `linux`
- `freebsd`
- `darwin`
- `windows`

- `aix` (nodejs)
- `openbsd` (hashicorp)
- `netbsd` (hashicorp)
- `solaris` / `sunOS` (hashicorp, nodejs)

Architecture must be one of

- `amd64`
- `x86`
- `arm64`
- `armv7l`
- `armv6`

- `ppc64` (nodejs)
- `ppc64le` (go, nodejs)
- `s390x` (go, nodejs)

The operating system and architecture _must_ be normalized

## `<module>.install()`

Downloads and extracts a particular version of a module and sets variables for installation

The following positional parameters are set

- `$1`: url
- `$2`: version (does not contain `v` prefix)
- `$3` os
- `$4` arch

Set the following variables for installation to complete successfully. `REPLY_DIR` is necessary while `REPLY_BINS` is obviously strongly recommended

- `REPLY_DIR=`
- `REPLY_BINS=()`
- `REPLY_MANS=()`
- `REPLY_BASH_COMPLETIONS=()`
- `REPLY_ZSH_COMPLETIONS=()`
- `REPLY_FISH_COMPLETIONS=()`
