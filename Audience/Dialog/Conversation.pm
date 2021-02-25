package Audience::Dialog::Conversation;
use File::Temp qw ( mktemp );
use Manager::Dialog qw ( ChooseHybrid Choose QueryUser );
use Data::Dumper;

$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Models Player Players History File Method EditMode / ];

sub init {
  my ($self, %args) = @_;
  if ($args{File}) {
    $self->File($args{File});
  } else {
    $self->File(mktemp("conversation.XXXX"));
  }
  if (-f $args{File}) {
    my $command = "cat ".$self->File;
    $self->Models(eval `$command`);
  } else {
    $self->Method(Choose(("Human Computer", "Computer Human", "Computer-0 Computer-1", "Human-0 Human-1")));
    my @players = split /\s+/,$self->Method;
    $self->Models
      ({
	$players[0] =>
	{
	 "start" => [
		     {
		      State => "end",
		      Act => "Hello!"
		     },
		    ],
	 "end" => [
		   {
		    State => "start",
		    Act => "Goodbye!"
		   }
		  ],
	},
	$players[1] =>
	{
	 "start" => [
		     {
		      State => "end",
		      Act => "Hello!"
		     },
		    ],
	 "end" => [
		   {
		    State => "start",
		    Act => "Goodbye!"
		   }
		  ],
	}
       });
  }
  my @playerslist = keys %{$self->Models};
  $self->Players(\@playerslist);
  $self->Player($playerslist[0]);
  if (defined $args{Type}) {
    if ($args{Type} eq "game") {
      $self->Train(State => "start",
		   History => []);
    }
  } else {
    $self->Converse(State => "start",
		    History => []);
  }
}

sub Converse {
  my ($self, %args) = @_;
  $self->History($args{History} || []);
  if ($self->EditMode) {
    print "*" x 40 . "\n";
    print "<history>\n";
    foreach my $act (@{$self->History}) {
      print "\t".$act->{Player}."\t".$act->{Act}."\n";
    }
    print "</history>\n";
  }
  my $currentplayer = $self->Player;
  print "Player: ".$currentplayer."\n";
  if ($currentplayer =~ /computer/i) {
    $self->ChooseComputer;
    $self->TradePlayers;
    $self->Converse(State => $args{State},
		    History => $self->History);
  } elsif ($currentplayer =~ /human/i) {
    if ($self->EditMode) {
      print "State: ". $args{State} . "\n";
    }
    my @choices;
    if ($self->EditMode) {
      push @choices, qw ( <Toggle> <Quit> <Delete> <Edit> <Add-Transposition> <Backup> );
    } else {
      push @choices, qw ( <Toggle> );
    }
    if (! exists $self->Models->{$self->Player}->{$args{State}}) {
      $self->Models->{$self->Player}->{$args{State}} = [];
    }
    push @choices, map {$_->{Act}} @{$self->Models->{$self->Player}->{$args{State}}};
    my ($act,$type) = ChooseHybrid(List => \@choices, Format => "multiple");
    my $state;
    if ($type eq "match") {
      if ($act =~ /^<Quit>$/) {
	$self->Save;
	exit (0);
      } elsif ($act =~ /^<Backup>$/) {
	my @history = @{$self->History};
	my $his = pop @history;
	print Dumper($his);
	$self->TradePlayers;
	$self->Converse(State => $his->{FromState},
			History => \@history);
      } elsif ($act =~ /^<Delete>$/) {
	my @newchoices = map {$_->{Act}} @{$self->Models->{$self->Player}->{$args{State}}};
	my $act2 = Choose(@newchoices);
	my @list = @{$self->Models->{$self->Player}->{$args{State}}};
	my $i = 0;
	foreach my $hash (@list) {
	  if ($hash->{Act} eq $act2) {
	    splice @list, $i, 1;
	  } else {
	    ++$i;
	  }
	}
	$self->Models->{$self->Player}->{$args{State}} = \@list;
	$self->Converse(State => $args{State},
			History => $self->History);
      } elsif ($act =~ /^<Edit>$/) {
	my @newchoices = map {$_->{Act}} @{$self->Models->{$self->Player}->{$args{State}}};
	my $act2 = Choose(@newchoices);
	foreach my $hash (@{$self->Models->{$self->Player}->{$args{State}}}) {
	  if ($hash->{Act} eq $act2) {
	    my $response = QueryUser("Replace with?");
	    chomp $response;
	    $hash->{Act} = $response;
	  }
	}
	$self->Converse(State => $args{State},
			History => $self->History);
      } elsif ($act =~ /^<Toggle>$/) {
	$self->EditMode(!$self->EditMode);
	$self->Converse(State => $args{State},
			History => $self->History);
      } elsif ($act =~ /^<Add-Transposition>$/) {
	foreach my $key (keys %{$self->Models->{$self->Player}}) {
	  push @newchoices, map {$_->{Act}} @{$self->Models->{$self->Player}->{$key}};
	}
	$act2 = Choose(@newchoices);
	foreach my $key (keys %{$self->Models->{$self->Player}}) {
	  foreach my $hash (@{$self->Models->{$self->Player}->{$key}}) {
	    if ($hash->{Act} eq $act2) {
	      $state = $hash->{State};
	    }
	  }
	}
	# add this state to this location and go on
	push @{$self->Models->{$self->Player}->{$args{State}}},{State => $state,
								Act => $act2};
	push @{$self->History}, {FromState => $args{State},
				 ToState => $state,
				 Act => $act2,
				 Player => $self->Player};
	if ($self->EditMode) {
	  print "**** $state\n";
	}
	$self->TradePlayers;
	$self->Converse(State => $state,
			History => $self->History);
      } else {
	foreach my $hash (@{$self->Models->{$self->Player}->{$args{State}}}) {
	  if ($hash->{Act} eq $act) {
	    $state = $hash->{State};
	  }
	}
	push @{$self->History}, {FromState => $args{State},
				 ToState => $state,
				 Act => $act,
				 Player => $self->Player};
	if ($self->EditMode) {
	  print "**** $state\n";
	}
	$self->TradePlayers;
	$self->Converse(State => $state,
			History => $self->History);
      }
    } else {
      $state = $self->ActToState($act);
      push @{$self->Models->{$self->Player}->{$args{State}}},{State => $state,
							      Act => $act};
      push @{$self->History}, {FromState => $args{State},
			       ToState => $state,
			       Act => $act,
			       Player => $self->Player};
      print "**** $state\n";
      $self->TradePlayers;
      $self->Converse(State => $state,
		      History => $self->History);
    }
  }
}

sub ActToState {
  my ($self, $act) = (shift,shift);
  $act =~ s/\W+//g;
  $act =~ s/^(.{40}).*/$1/;
  $act .= int rand(1000);
  return $act;
}

sub Match {
  my ($self, $regex, $list) = @_;
  return scalar (grep eval "/^$regex\$/", @$list);
}

sub ChooseComputer {
  my ($self, %args) = @_;
  push @{$self->History}, {Act => "hi",
			   State => "start",
			   Player => $self->Player};
  print "**** hi\n";
}

sub TradePlayers {
  my ($self, %args) = @_;
  my @playerslist = @{$self->Players};
  while (@playerslist) {
    my $player = shift @playerslist;
    if ($player ne $self->Player) {
      $self->Player($player);
      @playerslist = ();
    }
  }
}

sub Save {
  my ($self, %args) = @_;
  my $OUT;
  open(OUT,">".$self->File) or
    die "Cannot open ".$self->File;
  print OUT Dumper($self->Models);
  close(OUT);
}

sub Train {
  my ($self, %args) = @_;
  $self->History($args{History} || []);
  if ($self->EditMode) {
    print "*" x 40 . "\n";
    print "<history>\n";
    foreach my $act (@{$self->History}) {
      print "\t".$act->{Player}."\t".$act->{Act}."\n";
    }
    print "</history>\n";
  }
  my $currentplayer = $self->Player;
  print "Player: ".$currentplayer."\n";
  if ($currentplayer =~ /computer/i) {
    $self->ChooseComputer;
    $self->TradePlayers;
    $self->Converse(State => $args{State},
		    History => $self->History);
  } elsif ($currentplayer =~ /human/i) {
    if ($self->EditMode) {
      print "State: ". $args{State} . "\n";
    }
    my @choices;
    if ($self->EditMode) {
      push @choices, qw ( <Toggle> <Quit> <Delete> <Edit> <Add-Transposition> <Backup> );
    } else {
      push @choices, qw ( <Toggle> );
    }
    if (! exists $self->Models->{$self->Player}->{$args{State}}) {
      $self->Models->{$self->Player}->{$args{State}} = [];
    }
    push @choices, map {$_->{Act}} @{$self->Models->{$self->Player}->{$args{State}}};
    my ($act,$type) = ChooseHybrid(List => \@choices, Format => "multiple");
    my $state;
    if ($type eq "match") {
      if ($act =~ /^<Quit>$/) {
	$self->Save;
	exit (0);
      } elsif ($act =~ /^<Backup>$/) {
	my @history = @{$self->History};
	my $his = pop @history;
	print Dumper($his);
	$self->TradePlayers;
	$self->Converse(State => $his->{FromState},
			History => \@history);
      } elsif ($act =~ /^<Delete>$/) {
	my @newchoices = map {$_->{Act}} @{$self->Models->{$self->Player}->{$args{State}}};
	my $act2 = Choose(@newchoices);
	my @list = @{$self->Models->{$self->Player}->{$args{State}}};
	my $i = 0;
	foreach my $hash (@list) {
	  if ($hash->{Act} eq $act2) {
	    splice @list, $i, 1;
	  } else {
	    ++$i;
	  }
	}
	$self->Models->{$self->Player}->{$args{State}} = \@list;
	$self->Converse(State => $args{State},
			History => $self->History);
      } elsif ($act =~ /^<Edit>$/) {
	my @newchoices = map {$_->{Act}} @{$self->Models->{$self->Player}->{$args{State}}};
	my $act2 = Choose(@newchoices);
	foreach my $hash (@{$self->Models->{$self->Player}->{$args{State}}}) {
	  if ($hash->{Act} eq $act2) {
	    my $response = QueryUser("Replace with?");
	    chomp $response;
	    $hash->{Act} = $response;
	  }
	}
	$self->Converse(State => $args{State},
			History => $self->History);
      } elsif ($act =~ /^<Toggle>$/) {
	$self->EditMode(!$self->EditMode);
	$self->Converse(State => $args{State},
			History => $self->History);
      } elsif ($act =~ /^<Add-Transposition>$/) {
	foreach my $key (keys %{$self->Models->{$self->Player}}) {
	  push @newchoices, map {$_->{Act}} @{$self->Models->{$self->Player}->{$key}};
	}
	$act2 = Choose(@newchoices);
	foreach my $key (keys %{$self->Models->{$self->Player}}) {
	  foreach my $hash (@{$self->Models->{$self->Player}->{$key}}) {
	    if ($hash->{Act} eq $act2) {
	      $state = $hash->{State};
	    }
	  }
	}
	# add this state to this location and go on
	push @{$self->Models->{$self->Player}->{$args{State}}},{State => $state,
								Act => $act2};
	push @{$self->History}, {FromState => $args{State},
				 ToState => $state,
				 Act => $act2,
				 Player => $self->Player};
	if ($self->EditMode) {
	  print "**** $state\n";
	}
	$self->TradePlayers;
	$self->Converse(State => $state,
			History => $self->History);
      } else {
	foreach my $hash (@{$self->Models->{$self->Player}->{$args{State}}}) {
	  if ($hash->{Act} eq $act) {
	    $state = $hash->{State};
	  }
	}
	push @{$self->History}, {FromState => $args{State},
				 ToState => $state,
				 Act => $act,
				 Player => $self->Player};
	if ($self->EditMode) {
	  print "**** $state\n";
	}
	$self->TradePlayers;
	$self->Converse(State => $state,
			History => $self->History);
      }
    } else {
      $state = $self->ActToState($act);
      push @{$self->Models->{$self->Player}->{$args{State}}},{State => $state,
							      Act => $act};
      push @{$self->History}, {FromState => $args{State},
			       ToState => $state,
			       Act => $act,
			       Player => $self->Player};
      print "**** $state\n";
      $self->TradePlayers;
      $self->Converse(State => $state,
		      History => $self->History);
    }
  }
}

1;
