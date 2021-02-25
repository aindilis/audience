#!/usr/bin/perl -w

# use Audience::Agent::IM;
# use Net::XMPP::Client;
use PerlLib::SwissArmyKnife;
# use UniLang::Agent::Agent;
use UniLang::Util::TempAgent;

my $tempagent = UniLang::Util::TempAgent->new();

my $res1 = $tempagent->MyAgent->QueryAgent
  (
   Receiver => 'Audience',
   Contents => '',
   Data => {
	    _DoNotLog => 1,
	    IM => {
		   SendMessage => {
				   Recipient => '<REDACTED>',
				   Subject => 'test',
				   Body => 'This is a test',
				   Thread => 'test',
				   Priority => 10,
				  },
		  },
	   },
  );

print Dumper($res1);
