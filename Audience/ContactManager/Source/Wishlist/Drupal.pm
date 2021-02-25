package Audience::ContactManager::Source::Template;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Loaded /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = @_;

}

sub LoadSource {
  my ($self,%args) = @_;

  $self->Loaded(1);
}

1;
