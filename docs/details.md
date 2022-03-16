# Details

## Approach

When creating version managers, there are two approaches: shims and symlinks

### Shims

In essence, the shim layer is an indirection layer that facilities executing the proper version. This is usually implemented with some sort of shell script. The version is derived from the current context, which can include the current tty/pty, current directory, or global version. I don't like shims, primarily because they incur a time penalty; that is, the startup initialization of a shell. This would influence things like benchmarks. This approach also feels dirty to me.

### Symlinks

There is no startup penalty for symlinks, unlike shims. The tradeoff is that it is harder to implement when accounting for the current context. Mainly, extra code needs to be evaluated during the initialization of interactive shells (or just the primary login shell).

## Installing

The installation steps for installing any particular version of any particular module are streamlined.

Unlike similar projects (`asdf`), all plugins (we call them modules) are installed by default. Only the most popular modules are shown by default as not to overwhelm the user.

Not only that, but all code is ran under the same shell context (with the exception of _fetchers_, (of which, many are written for Deno in TypeScript)). Similarly, this contrasts previous approaches since extraneous subshells are minimized to reduce unnecessary performance penalties (especially on platforms like Cygwin, etc.). This also means there is more code reuse between modules
