# Woof

Woof is the version manager to end all version managers.

## Summary

Woof is a multi-tool version manager. That is, it manages the installation of multiple versions for multiple tools simultaneously

It is similar to alternatives like [asdf](https://github.com/asdf-vm/asdf), [Hermit](https://github.com/cashapp/hermit), and [sdkman](https://sdkman.io) - but it's superior in many ways

Woof supports many popular languages out of the box - see the [Roadmap](./roadmap.md) for more details

## Concepts

Woof works so effectively because it is simple. To see implementation details of Woof, see [this page](./details.md)

There are two main concepts:

### Plugins

Plugins include code that manage multiple versions and variants of a tool. For example, a plugin named 'Popular Languages' may manage the following:

- NodeJS
  - all versions
- Python
  - all versions
  - all variants ([cpython](https://github.com/python/cpython), [Nuitka](https://github.com/Nuitka/Nuitka), and [MicroPython](https://micropython.org))
- [Please](https://please.build)
  - all versions

To add support for a new language or program, write a plugin. Each plugin is implemented in a single Bash file. Functionalities of a particular plugin is a simple Bash function. See the [Plugin API](./api/plugin.md) for more details.

### Filters

Filters normalize release information for a particular plugin. For example, it may convert a JSON response from [GitHub's Release API](https://docs.github.com/en/rest/reference/releases) or a [custom release file](https://nodejs.org/download/release/index.json) to a text format that is easier to parse in Bash.

Each plugin must have a filter. Filters are written in either Bash, [jq](https://stedolan.github.io/jq), or Perl. See the [Filter API](./api/filter.md) for more details)
