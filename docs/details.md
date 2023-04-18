# Details

Woof supports global and local versions.

## Approach

Woof neither uses shims or symlinks. Symlinks aren't used because they typically must be recreated, sometimes frequently (ex. `npm -g i http-server`). Shims aren't good since they must be recreated (reshimed) as well, but they have an additional performance overhead.

Instead, Woof manually manages the `PATH`. When initializing, `PATH` is set to the global defaults of each tool. When `cd`'ing, `PATH` is automatically changed, depending on any discovered `.tool-version` files.

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

Use Yarn or `pnpm` if you want global packages to be shared.
