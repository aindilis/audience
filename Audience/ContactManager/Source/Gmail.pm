package Audience::ContactManager::Source::Gmail;

use Audience::ContactManager::Source::Gmail::GoogleContactsAPI;
use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Loaded MyContact Axioms /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyContact(Audience::ContactManager::Source::Gmail::GoogleContactsAPI->new());
  $self->Axioms([]);
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = @_;

}

sub LoadSource {
  my ($self,%args) = @_;
  # first of all, load some bbdb specific axioms
  $self->AddAxioms
    (
     Axioms => [
  		["implies", ["gmail-record", "title", \*{'::?ENTRY'}, \*{'::?NAME'}], ["has-fullname", \*{'::?ENTRY'}, \*{'::?NAME'}]],
  		# ["implies", ["gmail-record", "id", \*{'::?ENTRY'}, \*{'::?NAME'}], ["has-fullname", \*{'::?ENTRY'}, \*{'::?NAME'}]],
		# ["implies", ["gmail-record", 'gd$phoneNumber', \*{'::?ENTRY'}, \*{'::?PHONE'}, \*{'::?SCHEME'}], ["has-phone", \*{'::?ENTRY'}, \*{'::?PHONE'}]],
  	       ],
    );
  my $limitedhash =
    {
     'adougher9@gmail.com' => '8Bluskye',
     'andrew.j.dougherty@gmail.com' => 'Theijyarsh2',
    };
  foreach my $username (keys %{$UNIVERSAL::audience->MyContactManager2->Configuration->{accounts}->{Gmail}}) {
    my $emailaddress = $username.'@gmail.com';
    my @contacts = $self->MyContact->get_contacts($emailaddress,$limitedhash->{$emailaddress});
    my $errstr   = $self->MyContact->errstr;
    if ($errstr) {
      die $errstr;
    } else {
      my @axioms;
      my $entryid = 0;
      my $items = {};
      foreach my $entry (@contacts) {
	foreach my $key (keys %$entry) {
	  if (! exists $items->{$key}) {
	    $items->{$key} = [];
	  }
	  push @{$items->{$key}}, $entry->{$key};
	}
	my $entryfn = ["gmail", $username, $entryid];
	# push @axioms, ["gmail-record", "name", $entryfn, $entry->{name}];
	# push @axioms, ["gmail-record", "email", $entryfn, $entry->{email}];

	if (exists $entry->{'gd$phoneNumber'}) {
	  foreach my $item (@{$entry->{'gd$phoneNumber'}}) {
	    # add something about primrary
	    push @axioms, ["gmail-record", 'gd$phoneNumber', $entryfn, $item->{'$t'}, $item->{rel}];
	  }
	}
	if (exists $entry->{'gd$organization'}) {
	  foreach my $item (@{$entry->{'gd$organization'}}) {
	    push @axioms, ["gmail-record", 'gd$organization', $entryfn, $item->{'gd$orgName'}->{'$t'}, $item->{rel}];
	  }
	}
	if (exists $entry->{'gd$email'}) {
	  foreach my $item (@{$entry->{'gd$email'}}) {
	    # add something about primrary
	    push @axioms, ["gmail-record", 'gd$email', $entryfn, $item->{'address'}, $item->{rel}];
	  }
	}
	if (exists $entry->{'gd$postalAddress'}) {
	  foreach my $item (@{$entry->{'gd$postalAddress'}}) {
	    # add something about primrary
	    push @axioms, ["gmail-record", 'gd$postalAddress', $entryfn, $item->{'$t'}, $item->{rel}];
	  }
	}
	if (exists $entry->{'title'}) {
	  push @axioms, ["gmail-record", 'title', $entryfn, $entry->{'title'}->{'$t'}];
	}
	if (exists $entry->{'id'}) {
	  push @axioms, ["gmail-record", 'id', $entryfn, $entry->{'id'}->{'$t'}];
	}
	if (exists $entry->{'updated'}) {
	  push @axioms, ["gmail-record", 'updated', $entryfn, $entry->{'updated'}->{'$t'}];
	}
	if (exists $entry->{'category'}) {
	  foreach my $item (@{$entry->{'category'}}) {
	    # add something about primrary
	    push @axioms, ["gmail-record", 'category', $entryfn, $item->{term}, $item->{scheme}];
	  }
	}
	if (exists $entry->{'gContact$groupMembershipInfo'}) {
	  foreach my $item (@{$entry->{'gContact$groupMembershipInfo'}}) {
	    # add something about primrary
	    push @axioms, ["gmail-record", 'gd$email', $entryfn, $item->{href}, $item->{deleted}];
	  }
	}
	++$entryid;
      }
      $self->AddAxioms
	(
	 Axioms => \@axioms,
	);
    }
  }
  $self->Loaded(1);
}

sub AddAxioms {
  my ($self,%args) = @_;
  # use ImportExport to guess format and convert as needed
  my @axioms;
  foreach my $axiom (@{$args{Axioms}}) {
    push @axioms, $axiom;
  }
  push @{$self->Axioms}, @axioms;
}

1;
