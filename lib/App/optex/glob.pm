package App::optex::glob;

our $VERSION = '0.01';

use v5.14;
use warnings;
use utf8;
use Data::Dumper;

use List::Util qw(first);
use Hash::Util qw(lock_keys);
use Text::Glob qw(glob_to_regex);
use File::Basename qw(basename);

my %opt = (
    regex   => undef,
    path    => undef,
    exclude => undef,
);
lock_keys %opt;

sub initialize {
    our($mod, $argv) = @_;
}

sub finalize {
    our($mod, $argv);
    my $i = first { $argv->[$_] eq '--' } keys @$argv;
    $i // return;
    splice @$argv, $i, 1; # remove '--'
    my @glob = splice @$argv, 0, $i or return;
    my @glob_re = do {
	if ($opt{regex}) {
	    map { qr/$_/ } @glob;
	} else {
	    map { qr/${ glob_to_regex($_) }/ } @glob;
	}
    };
    my($match, $unmatch) = $opt{exclude} ? (0, 1) : (1, 0);
    my $test = sub {
	local $_ = shift;
	-e or return 1;
	$_ = basename($_) if not $opt{path};
	for my $re (@glob_re) {
	    /$re/ and return $match;
	}
	return $unmatch;
    };
    @$argv = grep $test->($_), @$argv;
}

sub set {
    while (my($k, $v) = splice @_, 0, 2) {
	$opt{$k} = $v;
    }
}

=encoding utf-8

=head1 NAME

glob - optex filter to glob filenames

=head1 SYNOPSIS

optex -Mglob pattern -- command

=head1 DESCRIPTION

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__DATA__
