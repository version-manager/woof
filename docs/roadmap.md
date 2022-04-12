# Roadmap

There are three dimensions of support for each runtime

- Shell
  - Completions
  - Shell init
- Operating System
- Architecture

## Shell

- Bash (WIP)
- Zsh
- Ksh
- Fish
- Elvish
- Oil

## Operating System

See the [Module API]('./module_api.md)

## Architecture

See the [Module API]('./module_api.md)

## Languages

Woof aims to support the following languages / package managers / programs

There are three levels of support:

- None
- Dogfooding (it works on my machine)
- Complete (works everywhere with supporting test suite)

### Buildless Programming Languages

| Language | Current Support | Official Download                                     | Replaces                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| -------- | --------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| NodeJS   | Dogfooding      | [Official](https://github.com/nodejs/node)            | [asdf-node](https://github.com/asdf-vm/asdf-node), [n](https://github.com/tj/n), [nvm](https://github.com/nvm-sh/nvm), [nvm.fish](https://github.com/jorgebucaran/nvm.fish), [nvmw](https://github.com/hakobera/nvmw), [avn](https://github.com/wbyoung/avn), [fnm](https://github.com/Schniz/fnm), [nave](https://github.com/isaacs/nave), [nodist](https://github.com/nullivex/nodist), [nodenv](https://github.com/nodenv/nodenv), [nodebrew](https://github.com/hokaccha/nodebrew) |
| Deno     | Dogfooding      | [Official](https://github.com/denoland/deno)          | [asdf-deno](https://github.com/asdf-community/asdf-deno), [justjavac/dvm](https://github.com/justjavac/dvm), [ghosind/dvm](https://github.com/ghosind/dvm)                                                                                                                                                                                                                                                                                                                             |
| Go       | Dogfooding      | [Official](https://github.com/google/go-github)       | [asdf-golang](https://github.com/kennyp/asdf-golang), [gvm](https://github.com/moovweb/gvm), [stefanmaric/g](https://github.com/stefanmaric/g), [voidint/g](https://github.com/voidint/g), [goenv](https://github.com/syndbg/goenv), [goup](https://github.com/owenthereal/goup), [oo](https://github.com/hit9/oo)                                                                                                                                                                     |
| Crystal  | Dogfooding      | [Official](https://github.com/crystal-lang/crystal)   | [asdf-crystal](https://github.com/asdf-community/asdf-crystal), [crenv](https://github.com/crenv/crenv)                                                                                                                                                                                                                                                                                                                                                                                |
| Nim      | Dogfooding      | [Official](https://github.com/nim-lang/Nim)           | [asdf-nim](https://github.com/asdf-community/asdf-nim), [choosenim](https://github.com/dom96/choosenim)                                                                                                                                                                                                                                                                                                                                                                                |
| Dart     | Dogfooding      | [Official](https://dart.dev)                          | [asdf-dart](https://github.com/PatOConnor43/asdf-dart), [dvm](https://github.com/cbracken/dvm)                                                                                                                                                                                                                                                                                                                                                                                         |
| Zig      | Dogfooding      | [Official](https://github.com/ziglang/zig)            | [asdf-zig](https://github.com/cheetah/asdf-zig)                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Haxe     | Dogfooding      | [Official](https://haxe.org/download)                 | [asdf-haxe](https://github.com/asdf-community/asdf-haxe), [jasononeil/hvm](https://github.com/jasononeil/hvm), [dpeek/hvm](https://github.com/dpeek/hvm)                                                                                                                                                                                                                                                                                                                               |
| Neko     | None            | [Official](https://github.com/HaxeFoundation/neko)    | [asdf-neko](https://github.com/asdf-community/asdf-haxe)                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Elm      | Dogfooding      | [Official](https://github.com/elm/compiler)           | [asdf-elm](https://github.com/asdf-community/asdf-elm)                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| Julia    | Dogfooding      | [Official](https://github.com/JuliaLang/julia)        | [asdf-julia](https://github.com/rkyleg/asdf-julia), [juliavm](https://github.com/pmargreff/juliavm)                                                                                                                                                                                                                                                                                                                                                                                    |
| kubectl  | Dogfooding      | [Official](https://github.com/kubernetes/kubectl)     | [asdf-kubectl](https://github.com/asdf-community/asdf-kubectl), [kubenvz](https://github.com/nutellinoit/kubenvz), [kerl](https://github.com/kerl/kerl)                                                                                                                                                                                                                                                                                                                                |
| Cue      | None            | [Official](https://cuelang.org)                       | [asdf-cue](https://github.com/asdf-community/asdf-cue),[cue-lang](https://github.com/cue-lang/cue)                                                                                                                                                                                                                                                                                                                                                                                     |
| gleam    | None            | [Official](https://github.com/gleam-lang/gleam)       | [asdf-gleam](https://github.com/asdf-community/asdf-gleam)                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Solidity | None            | [Official](https://github.com/ethereum/solidity)      | [asdf-solidity](https://github.com/refillic/asdf-solidity), [svm](https://github.com/web3j/svm)                                                                                                                                                                                                                                                                                                                                                                                        |
| LFE      | None            | [Official](https://lfe.io)                            | [asdf-lfe](https://github.com/asdf-community/asdf-lfe)                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| Peco     | None            | [Official](https://github.com/peco/peco)              | [asdf-peco](https://github.com/asdf-community/asdf-peco)                                                                                                                                                                                                                                                                                                                                                                                                                               |
| fstar    | None            | [Official](https://github.com/FStarLang/FStar)        | [asdf-fstar](https://github.com/asdf-community/asdf-fstar)                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Please   | None            | [Official](https://github.com/thought-machine/please) | [asdf-please](https://github.com/asdf-community/asdf-please)                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Lean     | None            | [Official](https://github.com/leanprover/lean4)       | [asdf-lean](https://github.com/asdf-community/asdf-lean)                                                                                                                                                                                                                                                                                                                                                                                                                               |
| mlton    | None            | [Official](https://github.com/MLton/mlton)            | [asdf-mlton](https://github.com/asdf-community/asdf-mlton)                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Ninja    | None            | [Official](https://github.com/ninja-build/ninja)      | [asdf-ninja](https://github.com/asdf-community/asdf-ninja)                                                                                                                                                                                                                                                                                                                                                                                                                             |
| gh       | Dogfooding      | [Official](https://github.com/cli/cli)                |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |

### Hashicorp

| Item      | Current Support | Official Download                                    | Replaces                                                                                                                                                       |
| --------- | --------------- | ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Boundary  | None            | [Official](https://www.boundaryproject.io/downloads) | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |
| Consul    | None            | [Official](https://www.consul.io/downloads)          | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |
| Nomad     | None            | [Official](https://www.nomad.io/downloads)           | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |
| Packer    | None            | [Official](https://www.packer.io/downloads)          | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |
| Serf      | None            | [Official](https://www.serf.io/downloads.html)       | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |
| Terraform | None            | [Official](https://www.terraform.io/downloads)       | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp), [tfenfv](https://github.com/tfutils/tfenv), [terraenv](https://github.com/aaratn/terraenv) |
| Vagrant   | None            | [Official](https://www.vagrant.io/downloads)         | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |
| Vault     | None            | [Official](https://www.vaultproject.io/downloads)    | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |
| Waypoint  | None            | [Official](https://www.waypointproject.io/downloads) | [asdf-hashicorp](https://github.com/asdf-community/asdf-hashicorp)                                                                                             |

### Buildfull Programming Languages

This requires a modification to the module API, support for patches

| Language | Current Support | Official Download                                 | Replaces                                                                                                                                                                                                   |
| -------- | --------------- | ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PHP      | None            | [Official](https://github.com/php/php-src)        | [asdf-php](https://github.com/asdf-community/asdf-php), [phpenv](https://github.com/phpenv/phpenv), [phpbrew](https://github.com/phpbrew/phpbrew), [php-version](https://github.com/wilmoore/php-version)  |
| Python   | None            | [Official](https://github.com/python/cpython)     | [asdf-python](https://github.com/asdf-vm/asdf-python), [pyenv](https://github.com/pyenv/pyenv), [p](https://github.com/qw3rtman/p), [pvm](https://github.com/DrPandemic/pvm)                               |
| Swift    | None            | [Official](https://github.com/apple/swift)        | [asdf-swift](https://github.com/fcrespo82/asdf-swift), [swiftenv](https://github.com/kylef/swiftenv)                                                                                                       |
| Ruby     | None            | [Official](https://github.com/ruby/ruby)          | [asdf-ruby](https://github.com/asdf-vm/asdf-ruby), [rvm](https://rvm.io), [rbenv](https://github.com/rbenv/rbenv), [chruby](https://github.com/postmodern/chruby), [frum](https://github.com/TaKO8Ki/frum) |
| erlang   | None            | [Official](https://github.com/erlang/otp)         | [asdf-erlang](https://github.com/asdf-vm/asdf-erlang)                                                                                                                                                      |
| Elixir   | None            | [Official](https://github.com/elixir-lang/elixir) | [asdf-elixir](https://github.com/asdf-vm/asdf-elixir), [exenv](https://github.com/exenv/exenv), [kiex](https://github.com/taylor/kiex)                                                                     |
| Meson    | None            | [Official](https://github.com/mesonbuild/meson)   | [asdf-meson](https://github.com/asdf-community/asdf-meson)                                                                                                                                                 |
| HHVM     | None            | [Official](https://docs.hhvm.com/hack)            |                                                                                                                                                                                                            |

### To sort

| Runtime | Current Support | Official Download                                        | Replaces                                                                                                                                                                                              |
| ------- | --------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| R       | None            | [Official](https://www.r-project.org)                    | [asdf-r](https://github.com/asdf-community/asdf-R), [renv](https://github.com/rstudio/renv), [Renv](https://github.com/viking/Renv)                                                                   |
| Java    | None            | [Official](https://github.com/openjdk/jdk)               | [asdf-java](https://github.com/halcyon/asdf-java), [jenv.be](https://www.jenv.be), [sdkman](https://sdkman.io), [jenv](https://github.com/linux-china/jenv), [jabba](https://github.com/shyiko/jabba) |
| Groovy  | None            | [Official](https://github.com/apache/groovy)             | [asdf-groovy](https://github.com/weibemoura/asdf-groovy), [sdkman-groovy](https://sdkman.io/sdks#groovy)                                                                                              |
| Scala   | None            | [Official](https://github.com/lampepfl/dotty)            | [asdf-scala](https://github.com/sylph01/asdf-scala), [sdkman-scala](https://sdkman.io/sdks#scala)                                                                                                     |
| Clojure | None            | [Official](https://github.com/clojure/clojure)           | [clojure](https://github.com/asdf-community/asdf-clojure)                                                                                                                                             |
| Dotty   | None            | [Official](https://github.com/lampepfl/dotty)            | [asdf-dotty](https://github.com/asdf-community/asdf-dotty), [dvm](https://github.com/d-ogxwx/dvm)                                                                                                     |
| Kotlin  | None            | [Official](https://github.com/JetBrains/kotlin)          | [asdf-kotlin](https://github.com/asdf-community/asdf-kotlin), [kotlin-sdkman](https://sdkman.io/sdks#kotlin)                                                                                          |
| GraalVM | None            | [Official](https://github.com/oracle/graal)              | [asdf-graalvm](https://github.com/asdf-community/asdf-graalvm)                                                                                                                                        |
| Haskell | None            | [Official](https://github.com/ghc/ghc)                   | [asdf-haskell](https://github.com/asdf-community/asdf-haskell)                                                                                                                                        |
| Racket  | None            | [Official](https://github.com/racket/racket)             | [asdf-racket](https://github.com/asdf-community/asdf-racket)                                                                                                                                          |
| sml     | None            | [Official](https://smlnj.org)                            | [asdf-sml](https://github.com/asdf-community/asdf-sml)                                                                                                                                                |
| idris   | None            | [Official](https://www.idris-lang.org)                   | [adsf-idris](https://github.com/asdf-community/asdf-idris)                                                                                                                                            |
| idris2  | None            | [Official](https://github.com/idris-lang/Idris2)         | [asdf-idris2](https://github.com/asdf-community/asdf-idris2)                                                                                                                                          |
| Flutter | None            | [Official](https://docs.flutter.dev/get-started/install) | [asdf-flutter](https://github.com/oae/asdf-flutter), [fvm](https://github.com/befovy/fvm)                                                                                                             |

#### Nuances

kubectl: Not yet `.kubectl_version`
Node: Not yet `.node-version`, and `.nvmrc`
Deno: Not yet `.dvmrc`
Ruby: Not yet `.ruby-version` and `.rvmrc`

### Misc

- fortran
- lua
- Dasel
- C
- C++
- C#
- Objective-C?
- Bash
- OPAM / OCAML

### Out of Scope

- Rust because `rustup` is actually good
