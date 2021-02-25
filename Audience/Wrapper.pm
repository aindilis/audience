package Audience::Wrapper;

use Audience::Contact;
use Audience::Proxy::Message;
use PerlLib::Collection;

use Data::Dumper;

# package allows a person to interact remotely with our systems
# maybe eventually set up a jabber server

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Contact Command Process /
  ];

sub init {
  my ($self,%args) = @_;
  $self->Contact($args{Contact});
  $self->Command($args{Program});
  $self->StartProcess;
}

sub StartProcess {
  my ($self,%args) = @_;

}

1;
