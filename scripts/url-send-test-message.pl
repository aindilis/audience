#!/usr/bin/perl -w

# use Audience::Agent::IM;
# use Net::XMPP::Client;
use PerlLib::SwissArmyKnife;
# use UniLang::Agent::Agent;
use UniLang::Util::TempAgent;

my $tempagent = UniLang::Util::TempAgent->new();

my $res1 = $tempagent->MyAgent->SendContents
  (
   Receiver => 'Audience',
   Contents => '',
   Data => {
	    _DoNotLog => 1,
	    IM => {
		   SendMessage => {
				   Recipient => '<REDACTED>',
				   Subject => 'test',
				   Body => 'http://dev.freelifeplanner.org/frdcsa/codebases/minor/iem',
				   Thread => 'test',
				   Priority => 10,
				  },
		  },
	   },
  );

print Dumper($res1);

my $res1 = $tempagent->MyAgent->SendContents
  (
   Receiver => 'Audience',
   Contents => '',
   Data => {
	    _DoNotLog => 1,
	    IM => {
		   SendMessage => {
				   Recipient => '<REDACTED>',
				   Subject => 'test',
				   Body => '<a href="http://dev.freelifeplanner.org/frdcsa/codebases/minor/iem">Load IEM</a>',
				   Thread => 'test',
				   Priority => 10,
				  },
		  },
	   },
  );
