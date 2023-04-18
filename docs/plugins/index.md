# Plugins

Through plugins, you can add support for managing multiple programming languages or tools of your choice.

Each plugin is a Git repository. Best practices include:

- Name the repository `woof-plugin-<name>`
- Add the `woof-plugin` topic or tag to the repository

At a minimum, a plugin must include a manifest. See [Manifest](./manifest.md) for details.

Plugins also contain a `tools` and possibly a `filters` directory. See [Tools](./tools.md) and [Filters](./filters.md) for details.
