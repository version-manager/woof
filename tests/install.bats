#!/usr/bin/env bats

load './util/init.sh'

setup() {
	eval "$("$BASALT_PACKAGE_DIR/pkg/bin/woof" init bash)"
	export WOOF_INTERNAL_TESTING='yes'
	export WOOF_CONFIG_HOME="$BATS_TEST_TMPDIR/.config"
	export WOOF_CACHE_HOME="$BATS_TEST_TMPDIR/.cache"
	export WOOF_DATA_HOME="$BATS_TEST_TMPDIR/.local/share"
	export WOOF_STATE_HOME="$BATS_TEST_TMPDIR/.local/state"
	cd "$BATS_TEST_TMPDIR"
}

@test "Installing with full plugin path" {
	woof plugin install "$BATS_TEST_DIRNAME/stubs/woof-plugin-basictest"
	woof install basictest/tool1 v1

	run woof plugin list
	[[ "$output" == *basictest* ]]
}
