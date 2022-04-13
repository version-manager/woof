package util;

sub f_die {
	my $msg = $ARGV[0];

	f_print_err("$msg");
	exit 1;
}

sub f_print_error {
	my $msg = $ARGV[0];

	print STDERR "$msg";
}