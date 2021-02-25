package Audience::Proxy;

use Audience::Contact;
use Audience::Proxy::Message;
use PerlLib::Collection;

use Data::Dumper;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Contacts IncomingQueue OutgoingQueue /
  ];

sub init {
  my ($self,%args) = @_;
  $self->IncomingQueue(Audience::Proxy::MessageQueue->new());
  $self->OutgoingQueue(Audience::Proxy::MessageQueue->new());
}

sub ReceiveAudienceMessage {
  my ($self,%args) = @_;
  print Dumper($args{AudienceMessage});
  $self->IncomingQueue->Push(Messages => [$args{AudienceMessage}]);
}

sub Execute {
  my ($self,%args) = @_;
  $self->ClassifyIncomingMessages;
  $self->SendMessages;
}

sub ClassifyIncomingMessages {
  my ($self,%args) = @_;
  my $message;
  while (my $m = $self->IncomingQueue->Pop) {
    my $c = $m->Contents;
    if ($c) {
      if ($m->Sender eq "UniLang-Client") {
	if ($c =~ /^(quit|exit)$/) {
	  $self->Stop;
	} elsif ($c =~ /^tell (.*?) that\s*(.*)$/) {
	  # going to have to choose the correct identity to send this under
	  my $receiver = $1;
	  my $contents = $2;
	  # now we would ordinarily want  to do a lookup on identities
	  # and  nicknames, if there  were multiple  nickname matches,
	  # use an adjustable autonomy system
	  $message = Audience::Proxy::Message->new
	    (Sender => "Andrew Dougherty",
	     Receiver => $receiver,
	     Contents => $contents);
	  $self->TellContact(Message => $message);
	  $message = Audience::Proxy::Message->new
	    (Sender => "Audience",
	     Receiver => "UniLang-Client",
	     Date => undef,
	     Contents => "Andrew Dougherty told $1");
	  $self->ReceiveAudienceMessage(AudienceMessage => $message);
	} elsif ($c =~ /^told (.*)$/) {
	  # return the contents of the message queue to a particular
	  # individual
	  my $r = $UNIVERSAL::audience->MyContactManager->LookupRecipient
	    (Recipient => $1);
	  if (exists $r->{Contact}) {
	    $message = Audience::Proxy::Message->new
	      (Sender => "Audience",
	       Receiver => "UniLang-Client",
	       Date => undef,
	       Contents => $r->{Contact}->IncomingQueue->SPrint);
	    $self->ReceiveAudienceMessage(AudienceMessage => $message);
	  } elsif (exists $r->{Failure}) {
	    # send a message back saying that the user was not found, worry
	    # about disambiguating later
	  }
	} elsif ($c =~ /logged-in (.*)/) {
	  # an individual has logged on
	  my $r = $UNIVERSAL::audience->MyContactManager->LookupRecipient
	    (Recipient => $1);
	  if (exists $r->{Contact}) {
	    Discuss(Contact => $r->{Contact});
	  } elsif (exists $r->{Failure}) {
	    # send a message back saying that the user was not found, worry
	    # about disambiguating later
	  }
	} elsif ($c =~ /^OSCAR, (.*)$/) {
	  print "hey!\n";
	  $UNIVERSAL::audience->MyAgentManager->Agents->Contents->{"OSCAR"}->ProcessCommand
	    ($1);
	} elsif ($c =~ /^IM, (.*)$/) {
	  $UNIVERSAL::audience->MyAgentManager->Agents->Contents->{"IM"}->ProcessCommand
	    (
	     Contents => $c,
	    );
	} elsif ($c =~ /^UniLang-Client, (.*)$/) {
	  $message = Audience::Proxy::Message->new
	    (Sender => "Audience",
	     Receiver => "UniLang-Client",
	     Date => undef,
	     Contents => $1);
	  $self->OutgoingQueue->Push(Messages => [$message]);
	} else {
	  # print "Got but don't know what to do with it: $c\n";
	  $message = Audience::Proxy::Message->new
	    (Sender => "Audience",
	     Receiver => "UniLang-Client",
	     Date => undef,
	     Contents => "UniLang-Client, Received: $c");
	  $self->OutgoingQueue->Push(Messages => [$message]);
	}
      } else {
	# for now assume this is an IM
	$message = Audience::Proxy::Message->new
	  (Sender => "Audience",
	   Receiver => $m->Receiver,
	   Date => undef,
	   # Contents => $m->Sender." : $c");
	   Contents => $c);
	$self->OutgoingQueue->Push(Messages => [$message]);
      }
    }
    if (exists $m->Data->{IM}) {
      my $res1 = $UNIVERSAL::audience->MyAgentManager->Agents->Contents->{"IM"}->ProcessCommand
	(
	 Message => $m,
	);
      $message = Audience::Proxy::Message->new
	(
	 Sender => "Audience",
	 Receiver => $m->Sender,
	 Date => undef,
	 Contents => $m->Contents,
	 Data => $res1,
	);
      $self->OutgoingQueue->Push(Messages => [$message]);
    }
  }
}

sub TellContact {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $r = $UNIVERSAL::audience->MyContactManager->LookupRecipient
    (Message => $m);
  if (exists $r->{Contact}) {
    $r->{Contact}->QueueMessageToMe(Message => $m);
  } else {
    $r = $UNIVERSAL::audience->MyIdentityManager->LookupRecipient
      (Message => $m);
    if (exists $r->{Contact}) {
      # this is to one of our identities, send it through Diplomat
      # $r->{Contact}->QueueMessageToMe(Message => $m);
    } elsif (exists $r->{Failure}) {
      # send a message back saying that the user was not found, worry
      # about disambiguating later
    }
  }
}

sub SendMessages {
  my ($self,%args) = @_;
  while (my $m = $self->OutgoingQueue->Pop) {
    # see where its going and send it there
    if ($m->Receiver eq "Diplomat") { # diplomat
      $UNIVERSAL::audience->MyDiplomat->ProcessMessage(Message => $m);
    } elsif ($m->Receiver eq "UniLang-Client") { # unilang
      $UNIVERSAL::audience->MyAgentManager->Agents->Contents->{"UniLang"}->SendMessage
	(AudienceMessage => $m);
    } else {
      if ($m->Sender ne $m->Receiver) {
	# print "Routing:\n".Dumper($m)."\n";
	print "Routing: ".$m->SPrint."\n";
	$UNIVERSAL::audience->MyAgentManager->Agents->Contents->{"UniLang"}->SendMessage
	  (AudienceMessage => $m);
      }
    }
  }
}

1;
