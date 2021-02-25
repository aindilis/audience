package Audience::Diplomat::IssueTracker;

# keeps track of what issues are alive or dead

use Manager::Dialog qw(Message SubsetSelect Choose Approve);

use Data::Dumper;
use Decision::ACL;
use Decision::ACL::Rule;
use Decision::ACL::Constants qw(:rule);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Medium Events Responses ACL / ];

sub init {
  my ($self,%args) = @_;
  $self->ACL(Decision::ACL->new());
}

sub Execute {
  my ($self,%args) = @_;
}

1;
