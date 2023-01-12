# Details

Woof supports global and local versions. Global versions use symlinks while local versions use shims.

## Approach

Woof uses a hybrid approach by using both shims and symlinks to manage versions.

### Symlinks

Symlinks are used for global versioning. Global versioning is a simple enough case in which shims are not needed. So, go with the ligher weight approach.

### Shims

Shims are used for contextual versioning (per shell, directory, if has tty).

When invoking a command (ex. `python`), the `$PATH` is arranged in such a way that a custom Woof script is invoked instead. This script gathers the current context.

Shims are necessary to evaluate the current context to decide what version of binary to `exec` into. Right now, a shell script is used, but later a faster language will most definitely be used.

## Plugin Installation

Unlike other version managers, Woof can handle different version of many languages without installing any extra plugins.

Woof allows to enable and disable plugins if they are causing trouble.

## Language Specifics

Differences from stock configuration. These explain how `<plugin.env()` is used.

### Deno

We set `DENO_INSTALL_ROOT` to a custom directory.

Global packages installed with `deno install` all install to that directory and coexist. Its installed binaries are appended to the `PATH`.

### Go

Go has a [page](https://go.dev/doc/manage-install) on managing multiple versions of Go, but it only describes doing so with `go install`. Internally, this uses [go/dl](https://go.googlesource.com/dl), but that is of no use to us. [Here](https://stackoverflow.com/a/10847122/9367643) shows an overview of `GOROOT` vs `GOPATH`.

We set `GOROOT` to a custom directory.

Global packages installed with `go install` all install to that directory and coexist. Its installed binaries are appended to the `PATH`.

### NodeJS

Global packages installed with `npm install -g` are installed per-version.

Run `woof tool resymlink` after installing a package (with `npm`) so it appears in the `PATH`.

Use Yarn or `pnpm` if you want global packages to be shared. `PNPM_HOME` is also set.
