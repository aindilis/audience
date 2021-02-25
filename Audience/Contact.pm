package Audience::Contact;

use Audience::Proxy::MessageQueue;

use Data::Dumper;
use File::Basename;
use Text::Capitalize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw { ID IndividualContactDir Name FirstName LastName StreetAddress
	HouseNumber Street CityAddress City State ZIP Phone AreaCode
	AIM Email AudienceDir IncomingQueue OutgoingQueue LogQueue }

  ];

sub init {
  my ($self,%args) = @_;
  $self->IndividualContactDir($args{IndividualContactDir});
  $self->AudienceDir($self->IndividualContactDir."/.audience");
  my $b = basename($self->IndividualContactDir);
  if ($b =~ /^(.*?)-(.*)$/) {
    $self->FirstName(capitalize($1));
    $self->LastName(capitalize($2));
    $self->ID($self->FirstName." ".$self->LastName);
  } else {
    $self->ID($self->IndividualContactDir);
  }
  $self->IncomingQueue
    (Audience::Proxy::MessageQueue->new
     (StorageFile => $self->AudienceDir."/incomingqueue"));
  $self->OutgoingQueue
    (Audience::Proxy::MessageQueue->new
     (StorageFile => $self->AudienceDir."/outgoingqueue"));
  $self->LogQueue
    (Audience::Proxy::MessageQueue->new
     (StorageFile => $self->AudienceDir."/logqueue"));
  $self->LoadAudienceSpecificData;
  $self->SaveAudienceSpecificData;
}

sub LoadAudienceSpecificData {
  my ($self,%args) = @_;
  # we want to either load or create a file representing this object,
  # so that we can save the queue
  $self->IncomingQueue->Load;
  $self->OutgoingQueue->Load;
}

sub SaveAudienceSpecificData {
  my ($self,%args) = @_;

  # we want to either load or create a file representing this object,
  # so that we can save the queue
  my $dir = $self->AudienceDir;
  if (! -d $dir) {
    system "mkdirhier \"$dir\"";
  }
  $self->IncomingQueue->Save;
  $self->OutgoingQueue->Save;
}

sub QueueMessageToMe {
  my ($self,%args) = @_;
  $self->IncomingQueue->Push(Messages => [$args{Message}]);
  $self->IncomingQueue->Save;
}

sub QueueMessageFromMe {
  my ($self,%args) = @_;
  $self->OutgoingQueue->Push(Messages => [$args{Message}]);
  $self->OutgoingQueue->Save;
}

sub Print {
  my ($self,%args) = @_;
  return $self->ID."\n";
}

1;
