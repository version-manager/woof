#!/usr/bin/env bats

load './util/init.sh'

@test "Works in base case 1" {
	cat > '.tool-versions' <<-"EOF"
	ruby 2.5.3
	EOF

	declare -gA tools=()
	util.toolversions_parse '.tool-versions' 'tools'
	assert [ "${#tools[@]}" -eq '1' ]
	test_index_object_keys 'tools' '0'
	assert [ "$REPLY" = 'ruby' ]
	assert [ "${tools[ruby]}" = '2.5.3' ]
}

@test "Works in base case 2" {
	cat > '.tool-versions' <<-"EOF"
	 ruby 2.5.3
	EOF

	declare -gA tools=()
	util.toolversions_parse '.tool-versions' 'tools'
	assert [ "${#tools[@]}" -eq '1' ]
	test_index_object_keys 'tools' '0'
	assert [ "$REPLY" = 'ruby' ]
	assert [ "${tools[ruby]}" = '2.5.3' ]
}

@test "Works with multiple versions" {
	cat > '.tool-versions' <<-"EOF"
	nodejs 18.0.0 17.0.1 17.0.0 system
	EOF

	declare -gA tools=()
	util.toolversions_parse '.tool-versions' 'tools'
	assert [ "${#tools[@]}" -eq '1' ]
	test_index_object_keys 'tools' '0'
	assert [ "$REPLY" = 'nodejs' ]
	assert [ "${tools[nodejs]}" = '18.0.0|17.0.1|17.0.0|system' ]
}

@test "Works with comments" {
	cat > '.tool-versions' <<-"EOF"
	nodejs 18.0.0 system# uwu
	# Gamma
	ruby 2.7.0
	EOF

	declare -gA tools=()
	util.toolversions_parse '.tool-versions' 'tools'
	assert [ "${#tools[@]}" -eq '2' ]
	test_index_object_keys 'tools' '0'
	assert [ "$REPLY" = 'nodejs' ]
	assert [ "${tools[nodejs]}" = '18.0.0|system' ]
	test_index_object_keys 'tools' '1'
	assert [ "$REPLY" = 'ruby' ]
	assert [ "${tools[ruby]}" = '2.7.0' ]
}

@test "Works with tabs" {
cat > '.tool-versions' <<-"EOF"
	ruby	2.5.3	2.8.3
	EOF

	declare -gA tools=()
	util.toolversions_parse '.tool-versions' 'tools'
	assert [ "${#tools[@]}" -eq '1' ]
	test_index_object_keys 'tools' '0'
	assert [ "$REPLY" = 'ruby' ]
	assert [ "${tools[ruby]}" = '2.5.3|2.8.3' ]
}
