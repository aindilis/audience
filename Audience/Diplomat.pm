package Audience::Diplomat;

use Audience::Diplomat::ACL;
use Audience::Diplomat::OPSEC;
use Audience::Diplomat::Reasoner;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyACL MyReasoner MyOPSEC Medium EventLattice
 ResponseTemplates PendingMessages /

  ];

sub init {
  my ($self,%args) = @_;
  # load all event types
  $self->Medium($args{Medium} || eval `cat $UNIVERSAL::systemdir/data/diplomat/medium`);
  $self->EventLattice
    ($args{EventLattice} || eval `cat $UNIVERSAL::systemdir/data/diplomat/eventlattice`);
  $self->ResponseTemplates
    ($args{ResponseTemplates} || eval `cat $UNIVERSAL::systemdir/data/diplomat/responsetemplates`);
  $self->PendingMessages($args{PendingCommunications} || []);

  # load all relevant modules
  $self->MyACL
    (Audience::Diplomat::ACL->new
     (
      Medium => $self->Medium,
      Events => $self->EventLattice,
      Responses => $self->ResponseTemplates,
     ));
  $self->MyReasoner(Audience::Diplomat::Reasoner->new());
  $self->MyOPSEC(Audience::Diplomat::OPSEC->new());
}

sub ProcessMessage {
  my ($self,%args) = @_;
  push @{$self->MyReasoner->PendingMessages}, $args{Message};
  $self->MyReasoner->InterpretCommunications(Message => $args{Message});
}

sub CheckPermissions {
  my ($self,%args) = @_;
}

sub ActivateResponse {
  my ($self,%args) = @_;
  # most  likely  some  event   has  occured  that  requires  changing
  # permissions.   based  on   the  response  and  reasoning  systems,
  # resulting changes are promulgated
}

sub KeepTrackOfRapport {
  my ($self,%args) = @_;
  # tracks the confidence levels I have in other people. At the end of
  # the day, I determine who has let me down or negatively affected
  # me, if anyone
  while () {
    QueryUser("Who has violated you in some way today");
    QueryUser("What did they do");
    QuertyUser("Anyone Else?");
  }
}

sub GeneratePermissionList {
  my ($self,%args) = @_;
  # based  on rapport  states, and  so forth,  you may  talk  to these
  # individuals
  # you may say "to these individuals"
  # unless of course you would cause emnity
}

sub InterpretCommunications {
  my ($self,%args) = @_;
  # be sure to check for bad words, including in foreign languages.

  # From this  moment (Dec 20  00:57:54 EST 2004)  forth, I may  only talk
  # with people on this list:

  # Since interaction will happen, we  need to recognize in which cases it
  # is permissible and  in which cases it is not.   Exceptions may be made
  # in emergency situations where animosity or physical harm to self would
  # result but must be reported.
}

sub IsolationScore {
  Message(Message => "Your isolation score equalled this today.  Compared to previous days, it was like this.");
}

1;

