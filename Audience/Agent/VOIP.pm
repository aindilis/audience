package Audience::Agent::VOIP;

# this is an agent to talk to people over the phone, could use some of
# the existing phone based dialog systems, like communicator

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

sub Start {
  my ($self,%args) = (shift,@_);
}

sub Stop {
  my ($self,%args) = (shift,@_);
}

sub Execute {
  my ($self,%args) = (shift,@_);
}

sub Send {
  my ($self,%args) = (shift,@_);
}

sub Receive {
  my ($self,%args) = (shift,@_);
}

1;
