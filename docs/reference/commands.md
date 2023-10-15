# commands

## `plugin-install <name>`

Depending on your input, Woof will intelligently determine where to download the plugin from.

<!-- markdownlint-disable no-bare-urls -->
| Initial String                                      | Final URL                                           |
| --------------------------------------------------- | --------------------------------------------------- |
| blah                                                | https://github.com/version-manager/woof-plugin-blah |
| woof-plugin-blah                                    | https://github.com/version-manager/woof-plugin-blah |
| version-manager/woof-plugin-blah                    | https://github.com/version-manager/woof-plugin-blah |
| github.com/version-manager/woof-plugin-blah         | https://github.com/version-manager/woof-plugin-blah |
| https://github.com/version-manager/woof-plugin-blah | https://github.com/version-manager/woof-plugin-blah |
<!-- markdownlint-enable no-bare-urls -->

If you specify nothing, then you are able to select from a list of first-party plugins.

It is also possible to specify an _absolute_ or a _relative_ path to a plugin directory.
