package Audience::AgentManager;

use Manager::Dialog qw(Message);
use PerlLib::Collection;

use Data::Dumper;
use Time::HiRes qw (usleep);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw/ Agents InvokedAgents Timeout /

  ];

sub init {
  my ($self,%args) = @_;
  Message(Message => "Starting AgentManager...");
  $self->InvokedAgents
    ($args{Agents} || []);
  $self->Agents
    (PerlLib::Collection->new
     (Type => "Audience::Agent"));
  $self->Agents->Contents({});
  $self->Timeout($args{Timeout} || 0.05);
  foreach my $agent (@{$self->InvokedAgents}) {
    if (OneOf(Item => $agent,
	      Set => \@registeredagents)) {
      require "Audience/Agent/$agent.pm";
      my $a = "Audience::Agent::$agent"->new();
      $self->Agents->Add
	($agent => $a);
    }
  }
}

sub OneOf {
  return 1;
}

sub StartAgents {
  my ($self,%args) = @_;
  Message(Message => "Starting agents...");
  foreach my $agent ($self->Agents->Values) {
    $agent->Start;
  }
}

sub StopAgents {
  my ($self,%args) = @_;
  Message(Message => "Stopping agents...");
  foreach my $agent ($self->Agents->Values) {
    $agent->Stop;
  }
}

sub Execute {
  my ($self,%args) = @_;
  Message(Message => "Connecting to UniLang...");
  while (1) {
    $self->Listen(Timeout => $self->Timeout);
    # sleep a little while
    usleep(100);
  }
}

sub Listen {
  my ($self,%args) = @_;
  foreach my $agent ($self->Agents->Values) {
    $agent->Execute(TimeOut => $args{Timeout});
  }
  $UNIVERSAL::audience->MyProxy->Execute;
  # for each of the other agents listen for them
}

1;
