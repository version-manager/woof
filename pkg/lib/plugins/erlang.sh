# shellcheck shell=bash

erlang.list() {
	local -a versions=()
	mapfile -t versions < <(perl -e 'my $var = do { local $/; <> };
while($var =~ /(?<url>https:\/\/github\.com\/erlang\/otp\/releases\/download\/OTP-(?<version>(?:(?:[0-9]+|\.)+))\/otp_src_.*?\.tar\.gz)/gum) {
	print "$+{version}\n";
}' < <(util.fetch -o- 'https://erlang.org/download/otp_versions_tree.html'))
	versions=("${versions[@]/#/v}")

	ui.select_version 0 "${versions[@]}"
	local selected_version="$REPLY"
	g.stty_deinit
}
