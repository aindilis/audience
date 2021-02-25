#!/usr/bin/perl -w


foreach my $line (split /\n/, `grep cn: export.ldif`) {
  if ($line =~ /^cn: (.+)$/) {
    my $cn = $1;
    # $cn =~ s/\'/\\'/g;
    my $c = "ldapdelete -w <REDACTED> -x -D 'cn=admin,dc=frdcsa,dc=org' \"cn=$cn,ou=addressbook,dc=frdcsa,dc=org\"";
    print "$c\n";
    system $c;
  }
}
