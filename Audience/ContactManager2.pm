package Audience::ContactManager2;

use Audience::Contact;
use Audience::ContactManager::SourceManager;
use KBS2::Client;
use Manager::Dialog qw(Message);
use PerlLib::Collection;
use PerlLib::SwissArmyKnife;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySourceManager MyClient Context Configuration /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MySourceManager
    (Audience::ContactManager::SourceManager->new
     ());
  $self->MyClient
    (KBS2::Client->new
     ());
  $self->Context
    ("Org::FRDCSA::Audience::ContactManager");
  my $c = read_file("/var/lib/myfrdcsa/codebases/internal/audience/Audience/ContactManager/contact-manager.conf");
  $self->Configuration(DeDumper($c));
  # print Dumper($self->Configuration);
}

sub SyncContacts {
  my ($self,%args) = @_;
  # $args{Sources};

}

sub SynchronizeAllContactsIntoAudienceContactManagementSystem {
  my ($self,%args) = @_;
  foreach my $source (@sources) {
    # go ahead and extract the information

  }
}

1;
