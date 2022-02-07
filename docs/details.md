# Details

## Approach

There are two main approaches: using shims and not.

## Installing

The installation steps for installing any particular version of any particular module are standardized.

Functions in modules should call `err.set` and `return` on error. Although the function `m.ensure` is provided, try to use the former functions instead

### 1. Get version if one isn't already supplied

If a version isn't already supplied on the command line, prompt the user for one. To get the list of all versions for a particular module, the `<module>.matrix` function is called. That function outputs to standard output the format. This is automatically cached for later (at `$XDG_STATE_HOME/woof/cached/<module>-matrix.txt`). Note that the version numbers in this matrix should _always_ begin with `v`

### 2. Install the particular version

Of the specified module, install the specified version. A temporary workspace is created in `$XDG_STATE_HOME/woof/workspace-<module>` to download and extract the content (which is automatically deleted after). In that directory, `<module>.install` is called

After being called, the directory specified by `REPLY_DIR` is moved to its final destination at `$XDG_STATE_HOME/woof/installs/<module>/<vesrion>`
