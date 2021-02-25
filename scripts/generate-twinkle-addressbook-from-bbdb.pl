#!/usr/bin/perl -w

use Data::Dumper;

my $dir = shift;
my $OUT;
open (OUT, ">twinkle.ab");

foreach my $file (split /\n/, `ls $dir/*.vcf`) {
  # my $c = ` "$dir/$file"`;
  use open IN => ":encoding(UTF-16)"; 
  open(IN, "<$file") or die "$file: $!"; 
  my @lines;
  my @sips;
  my $name;
  my $i = 0;
  while ($line = <IN>) {
    if ($line =~ /^fn:(.+)$/i) {
      $name = [$1,$i];
    }
    if ($line =~ /^tel;type=([^:]+):\((\d+)\) (\d+)-(\d+)( x(\d+))?$/i) {
      my $number;
      if (defined $6) {
	$number = "001$2$3$4$6";
      } else {
	$number = "001$2$3$4";
      }
      push @sips, $number;
    }
    push @lines, $line;
    ++$i;
  }
  print Dumper([$name,[@sips]]);
  my $i = 0;

  foreach my $sip (@sips) {
    my @copy = @lines;
    my $n = $name->[0];
    if ($i > 0) {
      $n = $n." $i";
    } else {
      $n = "$n";
    }
    print OUT "$n|||$sip|\n";
  }
}

close(OUT);
