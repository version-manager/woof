# Woof

Woof is the version manager to end all version managers.

## Summary

Akin to [asdf](https://github.com/asdf-vm/asdf) and [sdkman](https://sdkman.io), Woof is a multi-tool version manager. That is, it manages the installation of multiple versions for multiple tools simultaneously

Woof supports many popular languages out of the box - see the [Roadmap](./docs/roadmap) for more details

## Concepts

There are a few concepts that make Woof work so effectively. To see implementation details of Woof, see [this page](./docs/details.md)

### Module

Modules are analogous to asdf or sdkman's _plugins_. They represent all the version posibilities of a particular tool. Examples of tools that may have a module include NodeJS, Python, and [Please](https://please.build).

To add support for a new language, tool, or program, write a module. Each module is implemented in a single Bash file. Functionalities of a particular module is a simple Bash function. See the [Module API](./docs/module_api.md) for more details.

### Filters

Filters normalize release information for a particular module. For example, it may convert a JSON response from [GitHub's Release API](https://docs.github.com/en/rest/reference/releases) or a [custom JSON file](https://nodejs.org/download/release/index.json) to a text format that is easier to parse in Bash.

Each module must have a filter. Filters are written in either Bash, [jq](https://stedolan.github.io/jq), or Perl. See the [Filter API](./docs/filter_api.md) for more details)
