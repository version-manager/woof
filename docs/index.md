# Woof

Woof is the version manager to end all version managers.

## Summary

Akin to [asdf](https://github.com/asdf-vm/asdf) and [sdkman](https://sdkman.io), Woof is a multi-tool version manager. That is, it manages the installation of multiple versions for multiple tools simultaneously

Woof supports many popular languages out of the box - see the [Roadmap](docs/roadmap.md) for more details

## Concepts

Woof works so effectively because it is simple. To see implementation details of Woof, see [this page](docs/details.md)

There are two main concepts:

### Modules

Modules are analogous to asdf or sdkman's _plugins_. They represent all the version possibilities of a particular tool. Examples of tools that may have a module include NodeJS, Python, and [Please](https://please.build). Variants are also supported - for example, Python may have at least [cpython](https://github.com/python/cpython), [Nuitka](https://github.com/Nuitka/Nuitka), and [MicroPython](https://micropython.org) variants.

To add support for a new language, tool, or program, write a module. Each module is implemented in a single Bash file. Functionalities of a particular module is a simple Bash function. See the [Module API](docs/api/module.md) for more details.

### Filters

Filters normalize release information for a particular module. For example, it may convert a JSON response from [GitHub's Release API](https://docs.github.com/en/rest/reference/releases) or a [custom release file](https://nodejs.org/download/release/index.json) to a text format that is easier to parse in Bash.

Each module must have a filter. Filters are written in either Bash, [jq](https://stedolan.github.io/jq), or Perl. See the [Filter API](docs/api/filter.md) for more details)
