package Audience::IdentityManager;

use Audience::Identity;
use System::Rig;

use Data::Dumper;

@ISA = ("Audience::ContactManager");

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / MyRig /
  ];

sub init {
  my ($self,%args) = @_;
  $self->MyRig(System::Rig->new);
}

sub LookupRecipient {
  my ($self,%args) = @_;

}

sub GenerateNewIdentity {
  my ($self,%args) = @_;
  my $id = $self->MyRig->GenerateIdentity;
  my $obj = Audience::Identity->new(%$id);
  $self->AddContact($obj);
}

1;
