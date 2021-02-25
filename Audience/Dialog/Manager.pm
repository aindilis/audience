package Audience::Dialog::Manager;

# a drop in replacement of Manager::Dialog for UniLang agents

use UniLang::Agent::Agent;
use UniLang::Util::Message;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (QueryUser Verify Approve ApproveCommand Choose ChooseSpecial
                 EasyQueryUser PrintList Message ApproveCommands
                 ChooseHybrid ChooseOrCreateNew SubsetSelect );

# A disciplined approach to dialog management with the user.

sub EasyQueryUser {
  my $entry;
  chomp ($entry = <STDIN>);
  return $entry;
}

sub QueryUser {
  my ($contents) = (shift || "");
  if (! defined $UNIVERSAL::agent) {
    print "$contents\n> ";
    my $result = <STDIN>;
    while ($result =~ /^$/) {
      $result = <STDIN>;
    }
    chomp $result;
    return $result;
  } else {
    $UNIVERSAL::agent->SendContents
      (Contents => "$contents\n> ");

    # now wait for the item
    my $result = $UNIVERSAL::agent->WaitForResponse
      (Sender => "UniLang");
    while ($result =~ /^$/) {
      my $result = $UNIVERSAL::agent->WaitForResponse
	(Sender => "UniLang");
    }
    chomp $result;
    return $result;
  }
}

sub Verify {
  my ($contents) = (shift || "Is this correct?");
  my $result = QueryUser($contents);
  while ($result !~ /^[yY|nN]$/) {
    $result = QueryUser("Please respond: [yYnN]");
  }
  return ($result =~ /^[yY]$/);
}

sub ApproveCommand {
  my $command = shift;
  print "$command\n";
  if (Approve("Execute this command? ")) {
    system $command;
    return 1;
  }
  return;
}

sub ApproveCommands {
  my %args = @_;
  if ((defined $args{Method}) && ($args{Method} =~ /parallel/i)) {
    foreach $command (@{$args{Commands}}) {
      Message(Message => $command);
    }
    # bug: use proof theoretic fail conditions here instead
    if (Approve("Execute these commands? ")) {
      foreach my $command (@{$args{Commands}}) {
	system $command;
      }
      return 1;
    } else {
      return 0;
    }
  } else {
    my $outcome = 0;
    foreach $command (@{$args{Commands}}) {
      if (ApproveCommand($command)) {
	++$outcome;
      }
    }
    return $outcome;
  }
}

sub Approve {
  my $message = shift || "Is this correct? ([yY]|[nN])\n";
  $message =~ s/((\?)?)[\s]*$/$1: /;
  print $message;
  my $antwort = <STDIN>;
  chomp $antwort;
  if ($antwort =~ /^[yY]([eE][sS])?$/) {
    return 1;
  }
  return 0;
}

sub Choose {
  my @list = @_;
  my $i = 0;
  if (!@list) {
    return;
  } elsif (@list == 1) {
    print "<Chose:".$list[0].">\n";
    return $list[0];
  } else {
    foreach my $item (@list) {
      print "$i) $item\n";
      ++$i;
    }
    my $response;
    while (defined ($response = <STDIN>) and ($response !~ /^\d+$/)) {
    }
    chomp $response;
    return $list[$response];
  }
}

sub ChooseSpecial {
  my %args = @_;
  my @list = @{$args{List}};
  if (!@list) {
    return;
  } elsif (@list == 1) {
    print "<Chose:".$list[0].">\n";
    return $list[0];
  } else {
    print PrintList(List => \@list,
		    Format => $args{Format});
    my $response;
    while (defined ($response = <STDIN>) and ($response !~ /^\d+$/)) {
    }
    chomp $response;
    return $list[$response];
  }
}

sub ChooseHybrid {
  my %args = @_;
  my @list = @{$args{List}};
  if (!@list) {
    return;
  } else {
    print PrintList(List => \@list,
		    Format => $args{Format});
    my $response;
    while (defined ($response = <STDIN>) and ($response =~ /^$/)) {
    }
    chomp $response;
    if ($response =~ /^\d+$/) {
      return ($list[$response],"match");
    } else {
      return ($response,"new");
    }
  }
}

sub ChooseReadkey {
  use Term::ReadKey;
  ReadMode('cbreak');
  if (defined ($char = ReadKey(-1)) ) {
    return $char;
  }
  ReadMode('normal');
}

sub PrintList {
  my %args = @_;
  my @list = @{$args{List}};
  my $format = $args{Format};
  my $result = "";
  my $i = 0;
  foreach my $item (@list) {
    if ($format eq "multiple") {
      $result .= "$i) $item\n";
    } elsif ($format eq "single") {
      $result .= "<$i:$item> ";
    } elsif ($format eq "simple") {
      $result .= "$item ";
    }
    ++$i;
  }
  return $result;
}

sub Message {
  my %args = @_;
  chomp $args{Message};
  print $args{Message}."\n";
}

sub ChooseOrCreateNew {
  my %args = @_;
  my @list = @{$args{List}};
  unshift @list, "<Other>";
  unshift @list, "<Cancel>";
  my $result = Choose(@list);
  if ($result =~ /^<Cancel>$/) {
    return;
  } elsif ($result =~ /^<Other>$/) {
    return QueryUser("Please enter your choice");
  } else {
    return $result;
  }
}

sub SubsetSelect {
  my (%args) = (@_);
  my @options = @{$args{Set}};
  my %selection = ();
  if ($args{Selection}) {
    %selection = %{$args{Selection}};
  }
  my $type = $args{Type};
  my $prompt = $args{Prompt} || "> ";
  unshift @options, "Finished";
  if (scalar @options > 0) {
    while (1) {
      my $i = $args{MenuOffset} || 0;
      foreach my $option (@options) {
	chomp $option;
	if (defined $selection{$options[$i]}) {
	  print "* ";
	} else {
	  print "  ";
	}
	print "$i) ".$option."\n";
	$i = $i + 1;
      }
      print $prompt;
      my $ans = <STDIN>;
      chomp $ans;
      if ($ans ne "") {
	if ($ans) {
	  # go ahead and parse the language
	  foreach my $a (split /\s*,\s*/, $ans) {
	    my $method = "toggle";
	    if ($a =~ /^s(.*)/) {
	      $a = $1;
	      $method = "select";
	    } elsif ($a =~ /^d(.*)/) {
	      $a = $1;
	      $method = "deselect";
	    }
	    my $start = $a;
	    my $end = $a;
	    if ($a =~ /^\s*(\d+)\s*-\s*(\d+)\s*$/) {
	      $start = $1;
	      $end = $2;
	    }
	    for (my $i = $start; $i <= $end; ++$i) {
	      print "($i)\n";
	      if ($method eq "toggle") {
		if (defined $selection{$options[$i]}) {
		  delete $selection{$options[$i]};
		} else {
		  $selection{$options[$i]} = 1;
		}
	      } elsif ($method eq "deselect") {
		if (defined $selection{$options[$i]}) {
		  delete $selection{$options[$i]};
		}
	      } elsif ($method eq "select") {
		$selection{$options[$i]} = 1;
	      }
	    }
	  }
	} else {
	  if (defined $type and $type eq "int") {
	    my @retvals;
	    my $i = $args{MenuOffset} || 0;
	    foreach my $option (@options) {
	      if ($selection{$option}) {
		push @retvals, $i - 1;
	      }
	      ++$i;
	    }
	    return @retvals;
	  } else {
	    return keys %selection;
	  }
	}
      }
    }
  } else {
    return;
  }
}

1;

# package Survivor::Dialog;

# # Depends: festival sphinx2-bin libclass-methodmaker-perl

# use Class::MethodMaker
#   new_with_init => 'new',
#   get_set       => [ qw / STTEngine TTSEngine / ];

# sub init {
#   my ($self,%ARGS) = (shift,@_);

#   # init STT engine
#   my $sstengine;
#   open($sttengine,"/usr/bin/sphinx2-demo |") or
#     die "Can't open Speech-To-Text engine.\n";
#   $self->STTEngine($sttengine);

#   # init TTS engine
#   my $ttsengine;
#   open($ttsengine,"| festival --pipe") or
#     die "Can't open Text-To-Speech engine.\n";
#   $self->TTSEngine($ttsengine);
# }

# my $state = 0;
# my $pass;
# print "[initializing]\n";
# sleep 20;
# system "festival ";
# while ($line = <FILE>) {
#   chomp $line;
#   if ($line =~ /\[initializing\]/) {
#     $state = 1;
#     print "[initialized]\n";
#   } elsif ($state == 1) {
#     if ($line =~ /(one|what)/) {
#       SayText("Roger, affirmative.");
#     } elsif ($line =~ /(two|do)/) {
#       SayText("Roger, negative.");
#     }
#     print "$line\n";
#   }
# }

# sub YesNoQuestion {
#   my ($self,$text) = (shift,shift);
#   my $response = $self->Ask($text);
#   if ($response =~ /yes/i) {
#     $self->Say("Roger, affirmative");
#     return 1;
#   } elsif ($response =~ /no/i) {
#     $self->Say("Roger, negative");
#     return 0;
#   }
# }

# sub Question {
#   my ($self,$text) = (shift,shift);
#   $self->Say($text);
#   return $self->Hear();
# }

# sub Say {
#   my ($self,$text) = (shift,shift);
#   print $self->TTSEngine $text;
# }

# sub Hear {

# }

# 1;
