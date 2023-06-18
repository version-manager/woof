# Tools

Tools are located in `$XDG_STATE_HOME/woof/tools`. For example, if we are installing NodeJS (_nodejs_) version _20.3.0_ with plugin _[woof-plugin-core](https://github.com/version-manager/woof-plugin-core/tree/main/tools)_, then the tarball will be unpacked at `$XDG_STATE_HOME/woof/tools/core/nodejs/v20.4.0`

The directory might contain something like:

```text
bin/
CHANGELOG.md
include/
lib/
LICENSE
README.md
share/
.woof_/
```

The `.woof_` directory contains cached information about this particular installation. It includes the following files:

#### `data.txt`

```text
bins=./bin
mans=./share/man/man1
```

#### `done`

An empty file. If it exists, it means the installation has completed successfully. If it doesn't exist, it means that the installation was interrupted midway (and this directory was erroneously not removed).
