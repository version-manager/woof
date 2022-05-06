# Module API

Use the Module API to implement a version manager for a particular language. In this repository, the modules are located in `./pkg/src/modules`

## `<module>.matrix()`

Prints a version matrix to standard output. Each line of standard output looks like:

```txt
<variant>|<version>|<os>|<arch>|<url>[|<comment>]
```

For example,

```txt
Go|v1.17.6|linux|amd64|https://go.dev/dl/dl/go1.17.6.linux-amd64.tar.gz
NodeJS|v15.9.0|linux|amd64|https://nodejs.org/download/release/v15.9.0/node-v15.9.0-linux-x64.tar.gz|2021-02-18
```

To debug this function, use the `woof tool debug-matrix <module>` command

Operating system must be one of:

- `linux`
- `freebsd`
- `darwin`
- `windows`

- `aix`
- `openbsd`
- `netbsd`
- `solaris` (`sunOS`)

Architecture must be one of:

- `amd64`
- `x86`
- `arm64`
- `armv7l`
- `armv6`

- `ppc64` (nodejs)
- `ppc64le` (go, nodejs)
- `s390x` (go, nodejs)
- `riscv64` (zig)

## `<module>.install()`

Downloads and extracts a particular version of a language. The following positional parameters are set:

- `$1`: url
- `$2`: version (does not contain `v` prefix)
- `$3`: os
- `$4`: arch

Set the following variables for installation to complete successfully. `REPLY_DIR` is the only requried variable

- `REPLY_DIR=`
- `REPLY_BINS=()`
- `REPLY_INCLUDES=()`
- `REPLY_LIBS=()`
- `REPLY_MANS=()`
- `REPLY_BASH_COMPLETIONS=()`
- `REPLY_ZSH_COMPLETIONS=()`
- `REPLY_FISH_COMPLETIONS=()`

## `WOOF_MODULE_COMMON_DIR`

Persisted state across installs / uninstalls
