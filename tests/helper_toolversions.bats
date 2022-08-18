#!/usr/bin/env bats

load './util/init.sh'

@test "Works in base case 1" {
	cat > '.tool-versions' <<-"EOF"
	ruby 2.5.3
	EOF

	helper.toolversions_get_versions 'ruby'
	assert [ "${REPLY[0]}" = '2.5.3' ]
	assert [ "${#REPLY[@]}" -eq '1' ]
}

@test "Works in base case 2" {
	cat > '.tool-versions' <<-"EOF"
	 ruby 2.5.3
	EOF

	helper.toolversions_get_versions 'ruby'
	assert [ "${REPLY[0]}" = '2.5.3' ]
	assert [ "${#REPLY[@]}" -eq '1' ]
}

@test "Works with multiple versions" {
	cat > '.tool-versions' <<-"EOF"
	nodejs 18.0.0 17.0.1 17.0.0 system
	EOF

	helper.toolversions_get_versions 'nodejs'
	assert [ "${REPLY[0]}" = '18.0.0' ]
	assert [ "${REPLY[1]}" = '17.0.1' ]
	assert [ "${REPLY[2]}" = '17.0.0' ]
	assert [ "${REPLY[3]}" = 'system' ]
	assert [ "${#REPLY[@]}" -eq '4' ]
}

@test "Works with comments" {
	cat > '.tool-versions' <<-"EOF"
	nodejs 18.0.0 system# uwu
	# Gamma
	ruby 2.7.0
	EOF

	helper.toolversions_get_versions 'nodejs'
	assert [ "${REPLY[0]}" = '18.0.0' ]
	assert [ "${REPLY[1]}" = 'system' ]
	assert [ "${#REPLY[@]}" -eq '2' ]

	helper.toolversions_get_versions 'ruby'
	assert [ "${REPLY[0]}" = '2.7.0' ]
	assert [ "${#REPLY[@]}" -eq '1' ]
}
