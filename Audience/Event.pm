package Audience::Event;

# system for propogating events

use MyFRDCSA;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Predicates Tasks Intentions /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Predicates
    ($args{Predicates} ||
     ["logged-in ?X"]);
}

sub ProcessEvent {
  my ($self,%args) = @_;
  
}

1;
