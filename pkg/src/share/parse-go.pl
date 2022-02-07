#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(switch);
no warnings qw(experimental::smartmatch);

my $text = do { local $/; <STDIN> };
while ($text =~ /<td class="filename".+? href="(?<uri>.*?)".+?<td>(?<kind>.*?)<\/td>.+?<td>(?<os>.*?)<\/td>.+?<td>(?<arch>.*?)<\/td>.+?<tt>(?<checksum>.*?)<\/tt>/gsm) {
	if ($+{kind} eq 'Installer' or $+{kind} eq 'Source') {
		next;
	}

	my $uri = $+{uri};
	my $checksum = $+{checksum};

	my $os = $+{os};
	given($os) {
		when('Linux') { $os = 'linux'; }
		when('FreeBSD') { $os = 'freebsd'; }
		when(/macOS|OS X/sm) { $os = 'darwin'; }
		when('Windows') { $os = 'windows'; }
	}

	my $arch = $+{arch};
	given($arch) {
		when('x86-64') { $arch = 'amd64'; }
		when('ARM64') { $arch = 'arm64'; }
		when('ARMv6') { $arch = 'armv6'; }
	}

	my $version = '';
	if ($uri =~ /go(?<version>.*?)[.][[:alpha:]]/) {
		$version = $+{version};
	}

	print "$version|$os|$arch|https://go.dev$uri\n";
}
