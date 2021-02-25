package Audience::Mail::Client;

use Mail::Box::Manager;

# use AntiSpam-Console's Corpus to handle the mail boxes, actually,
# through IMAP

# a system for handling mail, is  used by audience, as well as Setanta
# and so on and so forth.  Has mail severity classifier, etc.

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / File Manager Folder /

  ];

sub init {
  my ($self,%args) = @_;
  $self->File($args{File});
  $self->Manager
    (Mail::Box::Manager->new());
  $self->Folder
    ($self->Manager->open
     (folder => $self->File));
}

sub Messages {
  my ($self,%args) = @_;
  $self->Folder->messages(0,1000)
}

1;
