#!/usr/bin/perl -w

# this is  a little  script written for  fun which shows  when various
# people log on and off during the week...

# same script may be used to visualize sinless results

use PerlLib::MySQL;

use Data::Dumper;

my $mysql = PerlLib::MySQL->new(DBName => "unilang");

my $s = "select *,DayOfWeek(Date),TIME_TO_SEC(DATE_FORMAT(Date,\"\%T\")) from messages where Contents like 'ps (logged-in \"quasi\%';";
my $ref1 = $mysql->Do(Statement => $s);

my $binsize = 24;
my $bins = [];
foreach my $key (keys %$ref1) {
  # plot this data in different ways
  # print Dumper($ref1->{$key});
  my $hash = $ref1->{$key};
  my $t = $hash->{'TIME_TO_SEC(DATE_FORMAT(Date,"%T"))'};
  my $dow = $hash->{'DayOfWeek(Date)'} - 1;
  my $bin = int((($t+$dow*86400.0) * $binsize)/86400.0);
  $bins->[$bin] = (defined $bins->[$bin] ? $bins->[$bin] : 0) + 1;
}

my $OUT;
open(OUT,">plot.txt") or die "Cannot open plot.txt\n";
foreach my $i (0..(($binsize*7)-1)) {
  print OUT (defined $bins->[$i] ? $bins->[$i] : 0)."\n";
}
close(OUT);

system "gnuplot -persist plot";
sleep 100;
