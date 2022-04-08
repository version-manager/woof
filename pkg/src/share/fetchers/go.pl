#!/usr/bin/env perl

use strict;
use warnings;

my $text = do { local $/; <STDIN> };
while ( $text =~
/<td class="filename".+? href="(?<uri>.*?)".+?<td>(?<kind>.*?)<\/td>.+?<td>(?<os>.*?)<\/td>.+?<td>(?<arch>.*?)<\/td>.+?<tt>(?<checksum>.*?)<\/tt>/gsm
) {
    if ( $+{kind} eq 'Installer' or $+{kind} eq 'Source' ) {
        next;
    }

    my $uri      = $+{uri};
    my $checksum = $+{checksum};
    my $os = $+{os};
    my $arch = $+{arch};

    if ($os eq 'Linux') {
        $os = 'linux';
    } elsif ($os eq 'FreeBSD') {
        $os = 'freebsd';
    } elsif ($os =~ /macOS|OS X/sm) {
        $os = 'darwin';
    } elsif ($os eq 'Windows') {
        next;
    } else {
        # TODO do not die
        # die "Unaccounted for os: $os";
    }

    if ($arch eq 'x86-64') {
        $arch = 'amd64';
    } elsif ($arch eq 'x86') {
        $arch = 'x86';
    } elsif ($arch eq 'ARM64') {
        $arch = 'arm64';
    } elsif ($arch eq 'ARMv6') {
        $arch = 'armv6';
    } elsif ($arch eq 'ppc64le') {
        $arch = 'ppc64le';
    } elsif ($arch eq 's390x') {
        $arch = 's390x';
    } else {
        # TODO do not die(as above), print warning
        # print "Unaccounted for arch: $arch";
    }

    my $version = '';
    if ( $uri =~ /go(?<version>.*?)[.][[:alpha:]]/ ) {
        $version = $+{version};
    }

    print "Go|v$version|$os|$arch|https://go.dev$uri\n";
}
