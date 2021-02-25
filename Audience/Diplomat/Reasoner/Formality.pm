package Audience::Diplomat::Reasoner;

# A system to model social formality, less important for now

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw /  / ];

sub init {
  my ($self,%args) = @_;
}

sub CheckAppropriateness {
  my ($self,%args) = @_;
}

1;
