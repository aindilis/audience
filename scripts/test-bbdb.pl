#!/usr/bin/perl -w

use Data::Dumper;

use BBDB;

use BBDB;
my $x = new BBDB();
foreach my $line (split /\n/, `cat ~/.bbdb`) {
  if ($line !~ /^\s+;/) {
    $x->decode($line);
    print Dumper($x);
  }
}
