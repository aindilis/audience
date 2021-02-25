package Audience::ContactManager;

use Audience::Contact;
use Manager::Dialog qw(Message);
use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw { ContactDir Contacts }

  ];

sub init {
  my ($self,%args) = @_;
  $self->ContactDir
    ($args{ContactDir} ||
     "<REDACTED>");
  $self->Contacts
    (PerlLib::Collection->new
     (Type => "Audience::Contact"));
  $self->Contacts->Contents({});
}

sub LoadContacts {
  my ($self,%args) = @_;
  Message(Message => "Loading contacts...");
  # should use a more sophisticated system, this will do for now
  my $contactdir = $self->ContactDir;
  my $cnt = 0;
  foreach my $dir (split /\n/,`ls $contactdir`) {
    ++$cnt;
    if (! $UNIVERSAL::audience->Config->CLIConfig->{-d} or $cnt < 10) {
      my $c = Audience::Contact->new
	(IndividualContactDir => "$contactdir/$dir");
      $self->Contacts->Add
	($c->ID => $c);
      print "\t".$c->Print;
    }
  }
  Message(Message => "Done loading contacts.");
}

sub LookupRecipient {
  my ($self,%args) = @_;
  my $m = $args{Message};
  # find the closest recipient, preferably an exact match
  my $r;
  if ($m) {
    $r = $m->Receiver;
  } else {
    $r = $args{Recipient};
  }
  if (exists $self->Contacts->Contents->{$r}) {
    return {Contact => $self->Contacts->Contents->{$r}};
  } elsif (0) {
    return {Failure => 1};
  } else {
    return {Failure => 1};
  }
}

1;
