package Audience::Agent::Email;

# use  this to retrieve  and classify  mail into  hate mail,  etc, use
# Justin's corpus, etc.

# use Mail::Classifier;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = (shift,@_);
}

sub StartProcess {
  my ($self,%args) = (shift,@_);
}

sub FetchAllMail {
  my ($self,%args) = (shift,@_);
  my $c =
    [
     "fetchmail --fetchmailrc $UNIVERSAL::systemdir/data/agent/email/fetchmailrc",
     "/var/lib/myfrdcsa/sandbox/fetchyahoo-2.9.0/fetchyahoo-2.9.0/".
     "fetchyahoo --username=<REDACTED> --password=`cat $UNIVERSAL::systemdir/data/agent/email/fetchyahoorc` ".
	"--spoolfile=/var/mail/<REDACTED>",
    ];
}

sub ArchiveMail {
  my ($self,%args) = (shift,@_);
  # archive the mail spool and actually do a bunch of audience
  # specific things to it
}

sub ClassifyNewEmail {
  my ($self,@args) = (shift,@_);
  my $message = Audience::Proxy::Message->new
    (Sender => $sender,
     Receiver => "Andrew Dougherty",
     Date => undef,
     Contents => $contents);
  $UNIVERSAL::audience->MyProxy->ReceiveAudienceMessage
    (AudienceMessage => $message);
}


1;
