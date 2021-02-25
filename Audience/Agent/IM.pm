package Audience::Agent::IM;

# use Audience::Contact;

use Data::Dumper;
use Net::XMPP;
use Time::HiRes qw (usleep);
use PerlLib::Collection;
use UniLang::Util::Message;

use Try::Tiny;

# taken from: https://github.com/dap/Net-XMPP/blob/master/examples/client.pl

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Bot NetXMPPClient Connection ScreenName Conversations Contacts
	LastSender LastReceiver /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ScreenName($args{ScreenName} || 'freelifeplanner');
  $self->NetXMPPClient(Net::XMPP::Client->new(debuglevel => 0, debugfile => '/tmp/xmpp.txt'));
  $self->Start();
  $self->SignOnToNetXMPPClient();
}

sub Start {
  my ($self,%args) = @_;
  print "Start IM\n";
  $self->Conversations({});
  $self->NetXMPPClient->SetCallBacks
    (
     # send => \&sendCallBack,
     message => \&InMessage,
     presence => \&InPresence,
     iq => \&InIQ,
    );
}

sub SignOnToNetXMPPClient {
  my ($self,%args) = @_;
  print "\tSignOnToNetXMPPClient\n";

  my $server = $args{Server} || '<REDACTED>';
  my $port = $args{Port} || 5222;
  my $username = $self->ScreenName;
  my $password = $args{Password} || `cat <REDACTED>`;
  chomp $password;
  my $resource = 5280;

  my $status = $self->NetXMPPClient->Connect
    (
     hostname => '<REDACTED>',
     port => $port,
     # tls => 1,
     # timeout => 120,
    );

  if (!(defined($status))) {
    print "ERROR:  Jabber server is down or connection was not allowed.\n";
    print "        ($!)\n";
    exit(0);
  }

  my @result = $self->NetXMPPClient->AuthSend
    (
     username => $username,
     password => $password,
     resource => $resource,
    );

  if ($result[0] ne "ok") {
    print "ERROR: Authorization failed: $result[0] - $result[1]\n";
    exit(0);
  }

  print "Logged in as $username to $server:$port...\n";

  $self->NetXMPPClient->RosterGet();

  print "Getting Roster to tell server to send presence info...\n";

  $self->NetXMPPClient->PresenceSend();

  print "Sending presence to tell world that we are logged in...\n";
}

sub SignOffOfNetXMPPClient {
  my ($self,%args) = @_;
  print "\tSignOffOfNetXMPPClient\n";
  $self->NetXMPPClient->Disconnect();
}

sub ProcessCommand {
  my ($self,%args) = @_;
  print "\tSignOffOfNetXMPPClient\n";

  my $c = $args{Contents};
  my $m = $args{Message};
  my $d = $m->{Data};
  if (exists $d->{IM}) {
    if (exists $d->{IM}{SendMessage}) {
      $UNIVERSAL::agent->QueryAgentReply
	(
	 Message => $m,
	 Data => {
		  _DoNotLog => 1,
		  Result => 'roger, Roger',
		 },
	);
      return $self->SendMessage
	(
	 %{$d->{IM}{SendMessage}},
	);
      $UNIVERSAL::agent
    }
  }
}

sub SendMessage {
  my ($self,%args) = @_;
  my $res = $self->NetXMPPClient->MessageSend
    (
     to => $args{Recipient},
     subject => $args{Subject},
     body => $args{Body},
     thread => $args{Thread},
     priority => ($args{Priority} || 10),
    );
  return $res;
}

sub DESTROY {
  my ($self,%args) = @_;
  print "ERROR: The connection was killed...\n";
  $self->SignOffOfNetXMPPClient;
}

sub InMessage {
  my $sid = shift;
  my $message = shift;

  my $type = $message->GetType();
  my $fromJID = $message->GetFrom("jid");

  my $from = $fromJID->GetUserID();
  my $resource = $fromJID->GetResource();
  my $subject = $message->GetSubject();
  my $body = $message->GetBody();
  print "===\n";
  print "Message ($type)\n";
  print "  From: $from ($resource)\n";
  print "  Subject: $subject\n";
  print "  Body: $body\n";
  print "===\n";
  print $message->GetXML(),"\n";
  print "===\n";

  # now going to have to add to audience queue

}

sub InIQ {
  my $sid = shift;
  my $iq = shift;

  my $from = $iq->GetFrom();
  my $type = $iq->GetType();
  my $query = $iq->GetQuery();
  my $xmlns = $query->GetXMLNS();
  print "===\n";
  print "IQ\n";
  print "  From $from\n";
  print "  Type: $type\n";
  print "  XMLNS: $xmlns";
  print "===\n";
  print $iq->GetXML(),"\n";
  print "===\n";
}

sub InPresence {
  my $sid = shift;
  my $presence = shift;

  my $from = $presence->GetFrom();
  my $type = $presence->GetType();
  my $status = $presence->GetStatus();
  print "===\n";
  print "Presence\n";
  print "  From $from\n";
  print "  Type: $type\n";
  print "  Status: $status\n";
  print "===\n";
  print $presence->GetXML(),"\n";
  print "===\n";
}

sub Execute {
  my ($self,%args) = @_;
  # $args{Timeout};
  try {
    $self->NetXMPPClient->Process(0)
  } catch {
    warn "caught error: $_"; # not $@
  };
}

1;
