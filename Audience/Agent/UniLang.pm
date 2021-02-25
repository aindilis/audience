package Audience::Agent::UniLang;

use Audience::Proxy::Message;
use Data::Dumper;
use Manager::Dialog qw(Message);
use UniLang::Util::Message;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = (shift,@_);
}

sub Start {
  my ($self,%args) = (shift,@_);
  my $conf = $UNIVERSAL::audience->Config->CLIConfig;
}

sub Stop {
  my ($self,%args) = (shift,@_);
  $UNIVERSAL::agent->Shutdown;
}

sub Execute {
  my ($self,%args) = (shift,@_);
  $UNIVERSAL::agent->Listen(TimeOut => $args{TimeOut});
}

sub ReceiveMessage {
  my ($self,%args) = (shift,@_);
  # receive and translate the UniLangMessage to an AudienceMessage

  my $um = $args{Message};
  my $am = Audience::Proxy::Message->new();
  $am->TranslateFromUniLangMessage(UniLangMessage => $um);

  # be  sure  to send  an  AudienceMessage  to  the appropriate  place
  # containing the UniLang message.
  $UNIVERSAL::audience->MyProxy->ReceiveAudienceMessage
    (AudienceMessage => $am);
}

sub SendMessage {
  my ($self,%args) = (shift,@_);
  # translate the AudienceMessage to a UniLangMessage and send
  my $am = $args{AudienceMessage};
  my $um = $am->TranslateToUniLangMessage;
  $UNIVERSAL::agent->Send
    (Handle => $UNIVERSAL::agent->Client,
     Message => $um);
}

sub DESTROY {
  my ($self,%args) = (shift,@_);
  $UNIVERSAL::agent->Send
    (Handle => $UNIVERSAL::agent->Client,
     Message => UniLang::Util::Message->new
     (Sender => "Audience",
      Receiver => "UniLang",
      Date => undef,
      Contents => "deregister Audience"));
  $self->Stop;
}

1;
