# Module API

Use the Module API to implement a version manager for a particular language. In this repository, the modules are located in `./pkg/src/modules`

## `<module>.table()`

Prints a version table to standard output. Each line of standard output looks like the following:

```txt
<variant>|<version>|<os>|<arch>|<url>[|<comment>]
```

Here are two examples:

```txt
Go|v1.17.6|linux|x86_64|https://go.dev/dl/dl/go1.17.6.linux-amd64.tar.gz
NodeJS|v15.9.0|linux|x86_64|https://nodejs.org/download/release/v15.9.0/node-v15.9.0-linux-x64.tar.gz|2021-02-18
```

To see the exact supported values for `<os>` and `<arch>`, see [roadmap.md](../roadmap.md)

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

Persisted state across installs / uninstalls

## `<module>.switch()`

Called when switching to a particular version

- `$1`: install_dir
- `$2`: module_version

## `<module>.env()`

Called when a module needs to set the environment

## `<module>.dir()`

Called when a module needs to hook into `cd`. For example, the NodeJS module needs to change versions depending on not only `.tool-versions`, but also `.nvm` and `.node-version`

By default, this automatically does the correct parsing of `.tool-versions` for the particular module
