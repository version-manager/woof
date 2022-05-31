# shellcheck shell=bash

task.run() {
	./pkg/bin/woof "$@"
}

task.release() {
	fox release
}
