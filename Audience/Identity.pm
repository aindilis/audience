package Audience::Identity;

@ISA = ("Audience::Contact");

# Purports to encapsulate the basic functionality of an identify.  For
# instance,  one  identity  differs  from  another,  in  that  it  has
# different  contacts,  different   rules  for  contacting,  different
# personality, etc.  Identities can be  used to model other people, as
# well  as   provide  additional  "people"  where   none  really  are.
# Identities  share  many properties  with  Contacts,  except that  we
# control identities directly, something we cannot do with Contacts.

# probably want to just derive from this instead

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw { Contacts ContactRules Personality Type Control }

  ];

sub init {
  my ($self,%args) = @_;
  $self->Contacts();
  $self->ContactRules();
  $self->Personality();

  # other-real, fake
  $self->Type();
  $self->Control();
}

1;

