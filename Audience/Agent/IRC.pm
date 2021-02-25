package Audience::Agent::IRC;

# integrate the ERC type stuff here, have ERC send a message to
# Audience, or use a separate handle.  figure out what to do about
# that in general.

# Template Audience agent

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
