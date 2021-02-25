#!/usr/bin/perl -w

use PerlLib::Util;
use UniLang::Util::TempAgent;

use Data::Dumper;

my $tempagent = UniLang::Util::TempAgent->new;

my $message = $tempagent->MyAgent->QueryAgent
  (
   Receiver => "KBS",
   Contents => 'query ("isa" ?X "person")',
   Data => {
	    _DoNotLog => 1,
	   },
  );

# print Dumper($message);
my $res = DeDumper($message->Contents);
foreach my $list (values %$res) {
  my $name = $list->[1];
  my $email = `/var/lib/myfrdcsa/codebases/internal/audience/scripts/get-email-address-for-person.pl "$name"`;
  chomp $email;
  if ($email) {
    $tempagent->Send
      (
       Receiver => "KBS",
       Contents => "assert (\"has-email\" \"$name\" \"$email\")",
       Data => {
		_DoNotLog => 1,
	       },
      );
  }
}

