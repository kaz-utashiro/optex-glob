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

use List::Util qw(pairmap);

sub hash_to_spec {
    pairmap {
	if    (not defined $b) { "$a"   }
	elsif ($b =~ /^\d+$/)  { "$a=i" }
	else                   { "$a=s" }
    } %{+shift};
}

sub finalize {
    my($mod, $argv) = @_;
    my $i = (first { $argv->[$_] eq '--' } keys @$argv) // return;
    splice @$argv, $i, 1; # remove '--'
    my @glob = splice @$argv, 0, $i or return;

    use Getopt::Long qw(GetOptionsFromArray);
    Getopt::Long::Configure qw(bundling require_order);
    GetOptionsFromArray \@glob, \%opt, hash_to_spec \%opt
	or die "Option parse error.\n";

    my @glob_re = do {
	if ($opt{regex}) {
	    map qr/$_/, @glob;
	} else {
	    map qr/${ glob_to_regex($_) }/, @glob;
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
    pairmap { $opt{$a} = $b } @_;
}

1;

=encoding utf-8

=head1 NAME

glob - optex filter to glob filenames

=head1 SYNOPSIS

optex -Mglob [ option ] pattern -- command

=head1 DESCRIPTION

This module is used to select filenames given as arguments by pattern.

For example, the following will pass only files matching C<*.c> from
C<*/*> as arguments to C<ls>.

    optex -Mglob '*.c' -- ls */*

There are several unique options that are valid only for this module.

=over 7

=item B<--exclude>

Option C<--exclude> will mean the opposite.

    optex -Mglob --exclude '*.c' -- ls */*

=item B<--regex>

If the C<--regex> option is given, it is evaluated as a regular
expression instead of a glob pattern.

    optex -Mglob --regex '\.c$' -- ls */*

=item B<--path>

With the C<--path> option it matches against the entire path, not just
the filename.

    optex -Mglob --path '\.c$' -- ls */*

=back

Multiple options can be specified at the same time.

    optex -Mglob --exclude --regex --path '^/.*\.c$' -- ls */*

=head1 CONSIDERATION

You should also consider using the B<extglob> feature of L<bash(1)>.

For example, you can use C<!(*.EN).md> would specify files matching
C<*.md> minus those matching C<*.EN.md>.

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__DATA__
