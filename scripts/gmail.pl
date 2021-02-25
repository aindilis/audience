#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Net::IMAP::Simple::Gmail;

my $server = 'imap.gmail.com';
my $imap = Net::IMAP::Simple::Gmail->new($server);

print Dumper({IMAP => $imap});
$imap->login('adougher9@gmail.com' => '');

my $nm = $imap->select('INBOX');

print Dumper({NM => $nm});
die;

for (my $i = 1; $i <= $nm; $i++) {
  # Get labels on message
  my $labels = $imap->get_labels($msg);
}
