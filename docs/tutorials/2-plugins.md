# Plugins

Plugins enable Woof to support a wide variety of languages and runtimes.

The official plugins can be found at [github.com/version-manager](https://github.com/version-manager).

You can find community plugins with the [woof-plugin](https://github.com/topics/woof-plugin) tag on GitHub.

Adding a plugin is simple. First, let's see what plugins you already have. Use the `woof plugin` subcommand for this:

```console
$ woof plugin list
ancillary:
    name: Ancillary Tools
    desc: Semi-popular tools
    tags: N/A
    type: git-repository
    enabled: yes
core:
    name: Core
    desc: Popular tools
    tags: N/A
    type: git-repository
    enabled: yes
```

Note that the output will likely be different in future versions. Let's say we want to install the [woof-plugin-hashicorp](https://github.com/version-manager/woof-plugin-hashicorp). Use the `plugin install` command:

```console
$ woof plugin install woof plugin install https://github.com/version-manager/woof-plugin-hashicorp
Info: Cloned: /home/edwin/.local/state/woof/plugins/woof-plugin-hashicorp
```

Now, you can install any of the tools that this plugin supports. Let's install [Terraform](https://www.terraform.io):

```console
$ woof install hashicorp/terraform
Info: Gathering versions
Warn: Version 'v1.5.3' is already installed for plugin 'hashicorp/terraform'. Switching to that version
Info: Set version 'v1.5.3' as global version
```

As you can see, I chose `v1.5.3` from the GUI. I already have `v1.5.3` version of Terraform installed. Woof automatically switched to that version.
