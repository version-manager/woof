# shellcheck shell=bash

task.run() {
	./pkg/bin/woof "$@"
}

task.test() {
	bats ./tests
}
