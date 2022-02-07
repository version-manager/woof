# Module API

## `<module>.matrix`

Creates a version matrix that looks like

```txt
<version>|<operating system>|<architecture>|<url>|<release date>
```

Currently, operating system is one of

- `linux`
- `darwin`

Architecture is one of

- `x86`
- `amd64`
- `armv7l`
- `arm64`

```txt
...
v15.9.0|linux|amd64|https://nodejs.org/download/release/v15.9.0/node-v15.9.0-linux-x64.tar.gz|(Released 2021-02-18)
v15.9.0|darwin|amd64|https://nodejs.org/download/release/v15.9.0/node-v15.9.0-darwin-x64.tar.gz|(Released 2021-02-18)
v15.8.0|linux|arm64|https://nodejs.org/download/release/v15.8.0/node-v15.8.0-linux-arm64.tar.gz|(Released 2021-02-02)
v15.8.0|linux|armv7l|https://nodejs.org/download/release/v15.8.0/node-v15.8.0-linux-armv7l.tar.gz|(Released 2021-02-02)
...
```
