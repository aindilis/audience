package Audience::Agent::OSCAR;

# use Audience::Contact;
use MyFRDCSA;

use Data::Dumper;
use Net::OSCAR qw(:standard);
use Time::HiRes qw (usleep);
use PerlLib::Collection;
use UniLang::Util::Message;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Bot OSCAR Connection ScreenName Conversations Contacts
   LastSender LastReceiver Buddies /

  ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Conversations({});
  $self->ScreenName('aindilis');
  $self->OSCAR(Net::OSCAR->new(capabilities => [qw(typing_status buddy_icons)]));
  $self->OSCAR->set_callback_im_in(sub {$self->im_in(@_)});
  $self->OSCAR->set_callback_signon_done(sub {$self->signon_done(@_)});
  $self->OSCAR->set_callback_buddy_in(sub {$self->buddy_in(@_)});
  $self->OSCAR->set_callback_buddy_out(sub {$self->buddy_out(@_)});
}

sub Start {
  my ($self,%args) = (shift,@_);
  $self->SignOnToOSCAR;
}

sub Stop {
  my ($self,%args) = (shift,@_);
  $self->SignOffOfOSCAR;
}

sub Execute {
  my ($self,%args) = (shift,@_);
  $self->OSCAR->do_one_loop();
}

sub PromptForPassword {
  my ($self,%args) = (shift,@_);
  # print "Password: ";
  # my $password = <STDIN>;
  my $pf = "~/.frdcsa/audience/oscar";
  my $password = `cat $pf`;
  chomp $password;
  return $password;
}

sub SignOnToOSCAR {
  my ($self,%args) = (shift,@_);
  $self->OSCAR->signon($self->ScreenName,$self->PromptForPassword) or
			 print "Count not sign in\n";
  print "\nLogged in as <".$self->ScreenName.">\n";
}

sub SignOffOfOSCAR {
  my ($self,%args) = (shift,@_);
  $self->OSCAR->signoff;
}

sub ProcessCommand {
  my ($self,$c) = (shift,shift);
  chomp $c;
  if ($c) {
    if ($c =~ /^IM (.+)$/) {
      $self->LastReceiver($1);
      print "Setting LastReceiver to <$1>\n";
    } elsif ($c =~ /^(quit|exit)$/) {
      $self->SignOffOfOSCAR;
    } elsif ($c =~ /^who$/) {
      foreach my $key (keys %{$self->OSCAR->{userinfo}}) {
	print $self->OSCAR->{userinfo}->{$key}->{online};
	print "\t$key\n";
      }
    } else {
      push @{$self->Conversations->{$self->LastReceiver || $self->LastSender}},
	[$self->ScreenName,$contents];
      $self->OSCAR->send_im($self->LastReceiver || $self->LastSender, $c);
    }
  }
}

sub im_in {
  my ($self,@args) = (shift,@_);
  my($oscar, $sender, $contents, $is_away) = @args;
  $self->LastSender($sender);
  push @{$self->Conversations->{$sender}}, [$sender,$contents];
  my $message = Audience::Proxy::Message->new
    (Sender => $sender,
     Receiver => "Andrew Dougherty",
     Date => undef,
     Contents => $contents);
  $UNIVERSAL::audience->MyProxy->ReceiveAudienceMessage
    (AudienceMessage => $message);
  $message = Audience::Proxy::Message->new
    (Sender => "Audience",
     Receiver => "Emacs-Client",
     Date => undef,
     Contents => "ps (im-in \"$sender\" \"$contents\")");
  $UNIVERSAL::audience->MyProxy->ReceiveAudienceMessage
    (AudienceMessage => $message);
}

sub signon_done {
  my ($self,$oscar) = (shift,@_);
  print "Signon successful\n";
}

sub buddy_in {
  my ($self,@args) = (shift,@_);
  # send a message to event-system that so and so logged on
  my $message = Audience::Proxy::Message->new
    (Sender => "Audience",
     Receiver => "Emacs-Client",
     Date => undef,
     Contents => "ps (logged-in \"".$args[1]."\")");
  $UNIVERSAL::audience->MyProxy->ReceiveAudienceMessage
    (AudienceMessage => $message);
  # begin a conversation with them if they have pending messages
}

sub buddy_out {
  my ($self,@args) = (shift,@_);
  # send a message to event-system that so and so logged off
  my $message = Audience::Proxy::Message->new
    (Sender => "Audience",
     Receiver => "Emacs-Client",
     Date => undef,
     Contents => "ps (logged-out \"".$args[1]."\")");
  $UNIVERSAL::audience->MyProxy->ReceiveAudienceMessage
    (AudienceMessage => $message);
}

sub DESTROY {
  my ($self,@args) = (shift,@_);
  $self->SignOffOfOSCAR;
}

1;
