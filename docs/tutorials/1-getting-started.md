# Getting Started

You may have experienced the trouble of attempting to use two different versions of the same tool. Whether you wanted to switch between Python 3.9 and Python 3.10 or Node.js 18 and Node.js 20, it is a pain to manage them manually.

Woof solves this. Let's take Node.js as an example. Let's say you wish to install Node.js 18 and 20. You would run the following commands:

```console
$ woof install nodejs
v20.8.1
v20.8.0
v20.7.0
v20.6.1
v20.6.0
v20.5.1
v20.5.0
```

As you can see, it will show an interactive list of Node.js versions that you can install. Select the one you want.

```console
$ woof install nodejs v20.8.1
Info: Gathering versions
Info: Fetching https://nodejs.org/download/release/v20.8.1/node-v20.8.1-linux-x64.tar.gz
############################################################################################################################################################################# 100.0%
Info: Unpacking
Info: Installed v20.8.1
Info: Set version 'v20.8.1' as global version
```

If this is the first version of a tool that you install, then it will automatically be selected as the "default version".

```console
$ node --version
v20.8.1
```

If you already have a default selected, you will need to switch it yourself.

Now, let's install a version 18:

```console
$ woof install nodejs v18.18.2
Info: Gathering versions
Info: Fetching https://nodejs.org/download/release/v18.18.2/node-v18.18.2-linux-x64.tar.gz
############################################################################################################################################################################# 100.0%
Info: Unpacking
Info: Installed v18.18.2
```

Notice that it only installed the verison, it did not automatically swithc to this version. For that, you will need to use the `set-version` command:

```console
$ woof set-version nodejs v18.18.2
Info: Set version 'v18.18.2' as global version
$ node --version
v18.18.2
```
