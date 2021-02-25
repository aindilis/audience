#!/usr/bin/perl -w

use Data::Dumper;

use BBDB;

my $names = {};

my $x = new BBDB();
foreach my $line (split /\n/, `cat ~/.bbdb`) {
  if ($line !~ /^\s+;/) {
    $x->decode($line);
    # print Dumper($x);
    my %copy = %$x;
    if (exists $x->{data}) {
      $names->{lc($x->{data}->[0]." ".$x->{data}->[1])} = \%copy;
    }
  }
}

foreach my $person (@ARGV) {
  if (exists $names->{lc($person)}) {
    # print $person."\t";
    print join(", ",@{$names->{lc($person)}->{data}->[6]})."\n";
  }
}
