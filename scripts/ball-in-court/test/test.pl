#!/usr/bin/perl -w

use Data::Dumper;
use Email::Simple;
use Net::IMAP::Client;

my %args;
$args{Host} = "localhost";
$args{Username} = "andrewdo";
$args{Password} = `cat '<REDACTED>'`;
chomp $args{Password};
my $folders = {
	       "INBOX" => 1,
	       "saved-messages" => 1,
	       "action" => 1,
	      };
my $imap = Net::IMAP::Client->new(

				  server => $args{Host},
				  user   => $args{Username},
				  pass   => $args{Password},
				  ssl    => 1, # (use SSL? default no)
				  port   => 993 # (but defaults are sane)

				 ) or die "Could not connect to IMAP server";

if (! $imap->login()) {
  print STDERR "Login failed: " . $imap->last_error . "\n";
  exit(0);
}

$imap->select('saved-messages');

my $messages = $imap->search('ALL');
foreach my $message (@$messages) {
  my $msg = $imap->get_summaries([ $message ])->[0];
  print Dumper(GetEmailSimpleFromNetIMAPClientMsgSummary($msg));
}


sub GetEmailSimpleFromNetIMAPClientMsgSummary {
  my $msg = shift;
  return Email::Simple->new
    (join("\n",
	  "Subject: ".$msg->subject,
	  "From: ".join(", ",map {$_->as_string} @{$msg->from}),
	  "To: ".join(", ",map {$_->as_string} @{$msg->to}),
	  "Date: ".$msg->date,
	  "text"
	 ));
}
