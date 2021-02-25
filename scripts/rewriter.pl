#!/usr/bin/perl -w

# this software is  to rewrite mean things that  other people write to
# the user, in order to invalidate the intended effect of intimidation
# or misspeak.

ProcessFiles(@ARGV);

sub ProcessFiles {
  foreach my $file (@_) {
    my $c = `cat \"$file\"`;
    my $OUT;
    open (OUT,">$file.rewrite") or die "ouch\n";
    print OUT Rewrite($c);
    close (OUT);
  }
}

sub Rewrite {
  my $c = shift;
  return $c;
}
