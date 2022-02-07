# Module API

## `<module>.matrix`

Creates a version matrix that looks like

```txt
<version>|<operating system>|<architecture>|<url>|<release date>
```

Currently, operating system is one of

- `linux`
- `freebsd`
- `darwin`
- `windows`

- `aix` (nodejs)

Architecture is one of

- `amd64`
- `x86`
- `arm64`
- `armv7l`
- `armv6`

- `ppc64` (nodejs)
- `ppc64le` (go, nodejs)
- `s390x` (go, nodejs)

## `<module>install`

- `$1`: url
- `$2`: version (without v)
- `$3` os
- `$4` arch

```txt
...
v1.17.6|linux|amd64|https://go.dev/dl/dl/go1.17.6.linux-amd64.tar.gz
v15.9.0|linux|amd64|https://nodejs.org/download/release/v15.9.0/node-v15.9.0-linux-x64.tar.gz|(Released 2021-02-18)
v15.9.0|darwin|amd64|https://nodejs.org/download/release/v15.9.0/node-v15.9.0-darwin-x64.tar.gz|(Released 2021-02-18)
v15.8.0|linux|arm64|https://nodejs.org/download/release/v15.8.0/node-v15.8.0-linux-arm64.tar.gz|(Released 2021-02-02)
v15.8.0|linux|armv7l|https://nodejs.org/download/release/v15.8.0/node-v15.8.0-linux-armv7l.tar.gz|(Released 2021-02-02)
...
```
