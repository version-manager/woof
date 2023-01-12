# shellcheck shell=bash

task.run() {
	./pkg/bin/woof "$@"
}

task.test() {
	bats ./tests
}

task.info() {
	ls ~/.local/state/woof/data-global/bin
	ls ~/.local/state/woof/installed-tools/nodejs/v16.17.0/files/bin/
	ls ~/.local/state/woof/installed-tools/go/v1.19.2/files/bin
}
