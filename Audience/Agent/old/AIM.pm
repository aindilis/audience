package Audience::Agent::AIM;

# use Audience::Contact;

use Data::Dumper;
use Net::AIM;
use Time::HiRes qw (usleep);
use PerlLib::Collection;
use UniLang::Util::Message;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Bot AIM Connection ScreenName Conversations Contacts
   LastSender LastReceiver /

  ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->ScreenName('suddenmeet');
  $self->AIM(Net::AIM->new);
}

sub Start {
  my ($self,%args) = (shift,@_);
  $self->Conversations({});
  $self->SignOnToAIM;
  $self->AIM->{_conn}->set_handler('im_in', sub {$self->Handler(@_)});
  # $self->AIM->start;
}

sub Stop {
  my ($self,%args) = (shift,@_);
  $self->SignOffOfAIM;
}

sub Execute {
  my ($self,%args) = (shift,@_);
  $self->AIM->do_one_loop();
}

sub PromptForPassword {
  my ($self,%args) = (shift,@_);
  print "Password: ";
  my $password = <STDIN>;
  chomp $password;
  return $password;
}

sub SignOnToAIM {
  my ($self,%args) = (shift,@_);
  $self->Connection
    ($self->AIM->newconn
     (Screenname   => $self->ScreenName,
      Password     => $self->PromptForPassword));
  print "\nLogged in as <".$self->ScreenName.">\n";
}

sub SignOffOfAIM {
  my ($self,%args) = (shift,@_);
  $self->Connection->DESTROY;
  $self->Connection(undef);
}

sub ProcessCommand {
  my ($self,$c) = (shift,shift);
  chomp $c;
  if ($c) {
    if ($c =~ /^IM (.+)$/) {
      $self->LastReceiver($1);
      print "Setting LastReceiver to <$1>\n";
    } elsif ($c =~ /^(quit|exit)$/) {
      $self->SignOffOfAIM;
    } elsif ($c =~ /^list$/) {

    } else {
      push @{$self->Conversations->{$self->LastReceiver || $self->LastSender}}, [$self->ScreenName,$contents];
      $self->AIM->send_im($self->LastReceiver || $self->LastSender, $c);
    }
  }
}

sub Handler {
  my ($self,@args) = (shift,@_);
  # print Dumper(@args);
  my ($aim,$messageobject,$sender,$receive) = @args;
  $self->LastSender($sender);
  my $contents = $messageobject->{args}->[2];
  push @{$self->Conversations->{$sender}}, [$sender,$contents];
  my $new = UniLang::Util::Message->new
    (Sender => "Audience",
     Receiver => "UniLang-Client",
     Date => $UNIVERSAL::agent->GetDate,
     Contents => "UniLang-Client, <$sender>:<$contents>");
  $UNIVERSAL::agent->Send
    (Handle => $UNIVERSAL::agent->Client,
     Message => $new);
}

sub DESTROY {
  my ($self,@args) = (shift,@_);
  $self->SignOffOfAIM;
}

1;

# # Dump of a message
# $VAR1 = bless( {
#                  '_chat_rooms' => undef,
#                  '_config' => {
#                                 'Buddies' => {
#                                                'perlaim' => 'b'
#                                              }
#                               },
#                  '_conn' => bless( {
#                                      '_config' => {},
#                                      '_tocserver' => 'toc.oscar.aol.com',
#                                      '_handler' => {
#                                                      'pause' => sub { "DUMMY" },
#                                                      'im_in' => sub { "DUMMY" },
#                                                      'sign_on' => sub { "DUMMY" }
#                                                    },
#                                      '_authserver' => 'login.oscar.aol.com',
#                                      '_inseq' => 16431,
#                                      '_ignore' => {},
#                                      '_select' => bless( [
#                                                            '',
#                                                            1,
#                                                            undef,
#                                                            undef,
#                                                            undef,
#                                                            undef,
#                                                            \*Symbol::GEN1
#                                                          ], 'IO::Select' ),
#                                      '_debug' => 0,
#                                      '_screenname' => 'suddenmeet',
#                                      '_port' => 9898,
#                                      '_authport' => 5159,
#                                      '_connected' => 1,
#                                      '_maxlinelen' => 1024,
#                                      '_tocport' => 9898,
#                                      '_format' => {
#                                                     'default' => '[%f:%t]  %m  <%d>'
#                                                   },
#                                      '_verbose' => 0,
#                                      '_agent' => 'Net::aim',
#                                      '_chat_rooms' => {},
#                                      '_parent' => $VAR1,
#                                      '_password' => '',
#                                      '_frag' => '',
#                                      '_outseq' => 43516,
#                                      '_socket' => $VAR1->{'_conn'}{'_select'}[6],
#                                      '_auto_reconnect' => 0
#                                    }, 'Net::AIM::Connection' ),
#                  '_queue' => undef,
#                  '_timeout' => 1,
#                  '_qid' => 'a',
#                  '_debug' => 0
#                }, 'Net::AIM' );
# $VAR2 = bless( {
#                  'to' => 'suddenmeet',
#                  'from' => 'aicommander',
#                  'args' => [
#                              'aicommander',
#                              'F',
#                              'What up'
#                            ],
#                  'type' => 'im_in'
#                }, 'Net::AIM::Event' );
# $VAR3 = 'aicommander';
# $VAR4 = 'suddenmeet';
