package Audience::Proxy::Message::Complaint;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Complaint JustificationIfAny Status /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Complaint($args{Complaint});
  $self->JustificationIfAny($args{JustificationIfAny});
  $self->Status($args{Status});
}

1;
