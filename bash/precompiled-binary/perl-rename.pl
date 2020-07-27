#!/usr/bin/perl -w

use strict;

use Getopt::Long;
Getopt::Long::Configure('bundling');

my ($verbose, $no_act, $force, $op);

die "Usage: rename [-v] [-n] [-f] perlexpr [filenames]\n"
    unless GetOptions(
	'v|verbose' => \$verbose,
	'n|no-act'  => \$no_act,
	'f|force'   => \$force,
    ) and $op = shift;

$verbose++ if $no_act;

if (!@ARGV) {
    print "reading filenames from STDIN\n" if $verbose;
    @ARGV = <STDIN>;
    chop(@ARGV);
}

for (@ARGV) {
    my $was = $_;
    eval $op;
    die $@ if $@;
    next if $was eq $_; # ignore quietly
    if (-e $_ and !$force)
    {
	warn  "$was not renamed: $_ already exists\n";
    }
    elsif ($no_act or rename $was, $_)
    {
	print "$was renamed as $_\n" if $verbose;
    }
    else
    {
	warn  "Can't rename $was $_: $!\n";
    }
}

__END__

=head1 NAME

rename - renames multiple files

=head1 SYNOPSIS

B<rename> S<[ B<-v> ]> S<[ B<-n> ]> S<[ B<-f> ]> I<perlexpr> S<[ I<files> ]>

=head1 DESCRIPTION

C<rename>
renames the filenames supplied according to the rule specified as the
first argument.
The I<perlexpr> 
argument is a Perl expression which is expected to modify the C<$_>
string in Perl for at least some of the filenames specified.
If a given filename is not modified by the expression, it will not be
renamed.
If no filenames are given on the command line, filenames will be read
via standard input.

=head1 OPTIONS

=over 8

=item B<-v>, B<--verbose>

Verbose: print names of files successfully renamed.

=item B<-n>, B<--no-act>

No Action: show what files would have been renamed.

=item B<-f>, B<--force>

Force: overwrite existing files.

=item B<-h>, B<--help>

Help: There is no help.

=back

=head1 ENVIRONMENT

No environment variables are used.

=cut