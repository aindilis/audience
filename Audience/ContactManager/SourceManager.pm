package Audience::ContactManager::SourceManager;

use KBS2::Client;
use KBS2::ImportExport;
use Manager::Dialog qw(Message SubsetSelect);
use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ListOfSources MySources MyImportExport MyClient /

  ];

sub init {
  my ($self,%args) = @_;
  Message(Message => "Initializing sources...");
  my @names = map {$_ =~ s/.pm$//; $_}
    grep(/\.pm$/,split /\n/,
	 `ls $UNIVERSAL::systemdir/Audience/ContactManager/Source`);
  $self->ListOfSources(\@names);
  $self->MySources
    (PerlLib::Collection->new
     (Type => "Audience::ContactManager::Source"));
  $self->MySources->Contents({});
  foreach my $name (@{$self->ListOfSources}) {
    Message(Message => "Initializing Audience/ContactManager/Source/$name.pm...");
    require $UNIVERSAL::systemdir."/Audience/ContactManager/Source/$name.pm";
    my $s = "Audience::ContactManager::Source::$name"->new();
    $self->MySources->Add
      ($name => $s);
  }
  $self->MyImportExport(KBS2::ImportExport->new);
}

sub ListSources {
  my ($self,%args) = @_;
  print join("\n", $self->MySources->Keys)."\n\n";
}

sub UpdateSources {
  my ($self,%args) = @_;
  Message(Message => "Updating sources...");

  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  delete $args{Sources};

  foreach my $key (@keys) {
    Message(Message => "Updating $key...");
    $self->MySources->Contents->{$key}->UpdateSource(%args);
  }
}

sub LoadSources {
  my ($self,%args) = @_;
  Message(Message => "Loading sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  delete $args{Sources};

  foreach my $key (@keys) {
    Message(Message => "Loading $key...");
    $self->MySources->Contents->{$key}->LoadSource(%args);
  }
}

sub ProcessAxioms {
  my ($self,%args) = @_;
  Message(Message => "Loading sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  delete $args{Sources};

  my @axioms;
  foreach my $key (@keys) {
    push @axioms, @{$self->MySources->Contents->{$key}->Axioms};
  }
  # make some initial guesses at what these are, using a standardized
  # guessing algorithm

  # come up with link rules

  if (1) {
    my $res = $self->MyImportExport->Convert
      (
       Input => \@axioms,
       InputType => "Interlingua",
       OutputType => "Emacs String",
      );
    if ($res->{Success}) {
      print $res->{Output}."\n";
    }
  }

  if (0) {
    $self->MyClient
      (KBS2::Client->new);
    foreach my $axiom (@axioms) {
      print Dumper($axiom);
      my $res = $self->MyClient->Send
	(
	 Assert => [$axiom],
	 InputType => "Interlingua",
	 Context => "Org::FRDCSA::Audience::ContactManager2",
	 QueryAgent => 1,
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      if ($res->{Success}) {
	print "Success!\n";
      } else {
	# die Dumper($res);
      }
    }
  }
}

# sub Search {
#   my ($self,%args) = @_;
#   my @ret;
#   my $ar = {};
#   if ($args{Filter}) {
#     $ar->{Filter} = $args{Filter}
#   }
#   if ($args{Criteria}) {
#     $ar->{Criteria} = $args{Criteria} || $self->GetSearchCriteria;
#   }
#   $ar->{Sources} = $args{Sources} if $args{Sources};
#   $ar->{Search} = $args{Search} if $args{Search};
#   foreach my $sys (sort @{$self->SearchSources(%$ar)}) {
#     push @ret, $sys;
#   }
#   @ret = sort {$a->ID cmp $b->ID} @ret;
#   return \@ret;
# }

# sub Choose {
#   my ($self,%args) = @_;
#   $systemmapping = {};
#   foreach my $sys
#     (sort @{$self->SearchSources
# 	      (Criteria => $self->GetSearchCriteria,
# 	       Sources => $args{Sources})}) {
#       $systemmapping->{$sys->SPrint} = $sys;
#     }
#   my @chosen = SubsetSelect
#     (Set => \@set,
#      Selection => {});
#   my @ret;
#   foreach my $name (@chosen) {
#     push @ret, $systemmapping->{$name};
#   }
#   return \@ret;
# }

# sub SearchSources {
#   my ($self,%args) = @_;
#   Message(Message => "Searching sources...");
#   my @keys;
#   if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
#     @keys = @{$args{Sources}};
#   }
#   if (!@keys) {
#     @keys = $self->MySources->Keys;
#   }
#   my @matches;
#   foreach my $key (@keys) {
#     my $source = $self->MySources->Contents->{$key};
#     if (! $source->Loaded) {
#       Message(Message => "Loading $key...");
#       $source->MyProducts->Load;
#       Message(Message => "Loaded ".$source->MyProducts->Count." products.");
#       $source->Loaded(1);
#     }
#     if (! $source->MyProducts->IsEmpty) {
#       Message(Message => "Searching $key...");
#       foreach my $product ($source->MyProducts->Values) {
# 	if ($args{Criteria}) {
# 	  if ($product->Matches(Criteria => $args{Criteria})) {
# 	    push @matches, $product;
# 	  }
# 	}
# 	if ($args{Filter}) {
# 	  if ($product->Matches(Filter => $args{Filter})) {
# 	    push @matches, $product;
# 	  }
# 	}
#       }
#     }
#   }
#   return \@matches;
# }

# sub GetSearchCriteria {
#   my ($self,%args) = @_;
#   my %criteria;
#   my $conf = $UNIVERSAL::broker->Config->CLIConfig;
#   if (exists $conf->{-n}) {
#     $criteria{Name} = $conf->{-n};
#   }
#   if (exists $conf->{-d}) {
#     $criteria{ShortDesc} = $conf->{-d};
#   }
#   if (exists $conf->{-D}) {
#     $criteria{LongDesc} = $conf->{-D};
#   }
#   if (exists $conf->{-p}) {
#     $criteria{Price} = $conf->{-p};
#   }
#   if (! %criteria) {
#     foreach my $field 
#       # (qw (Name ShortDesc LongDesc Tags Dependencies Categories Source)) {
#       (qw (Name Cost)) {
# 	Message(Message => "$field?: ");
# 	my $res = <STDIN>;
# 	chomp $res;
# 	if ($res) {
# 	  $criteria{$field} = $res;
# 	}
#       }
#   }
#   return \%criteria;
# }

1;
