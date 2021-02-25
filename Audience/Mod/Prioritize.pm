package Prioritize;

# Use the %action and %saved-messages folder to train a mail priority classifier.

# integrate into this system the critic email classification stuff

# also classify RSS feeds

# integrate Text::Analysis of messages

# topic detection and tracking

# Client  emails must be  responded to  almost instantly  if possible,
# even if it is  simply to let them know that we  are looking into it.
# They should include an estimation of the amount of time it will take
# to analyze and debug the problem.

# include other email sources like GMail and Yahoo

# include IRC


# try to analyze how messages relate to goals in the goal system

use ASConsole::Corpus::Message;
use Prioritize::Classifier;
use Prioritize::Contact;
use BOSS::Config;
use Manager::Dialog qw(ApproveCommands Choose QueryUser);
use MyFRDCSA;

use Data::Dumper;
use Date::Manip;
use Email::Simple;
use Mail::Address;
use Net::IMAP::Client;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config CurrentFolder Folders MyIMAP MyIterator SentMailFiles
   SentMailDir Contacts Last MyClassifier /

  ];

sub init {
  print("Initializing Prioritize\n");
  my ($self,%args) = @_;
  my $specification = "
	-d <depth>		Reply only to a depth of this many messages

	-u [<host> <port>]	Run as a UniLang agent
";

  # $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"audience","scripts","prioritize");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    #     $UNIVERSAL::agent->Register
    #       (Host => defined $conf->{-u}->{'<host>'} ?
    #        $conf->{-u}->{'<host>'} : "localhost",
    #        Port => defined $conf->{-u}->{'<port>'} ?
    #        $conf->{-u}->{'<port>'} : "9000");
  }
  $self->MyIterator({});
  $self->SentMailDir("/home/andrewdo/Mail/backup");
  $self->Contacts({});
  $self->Last({});
  $self->MyClassifier(Prioritize::Classifier->new);
}

sub Connect {
  my ($self,%args) = @_;
  return if $self->MyIMAP;

  #   $args{Host} = QueryUser("Host?") unless $args{Host};
  #   $args{Username} = QueryUser("Username?") unless $args{Username};
  #   $args{Password} = QueryUser("Password?") unless $args{Password};

  $args{Host} = "localhost";
  $args{Username} = "andrewdo";
  $args{Password} = `cat <REDACTED>`;
  chomp $args{Password};
  $self->Folders({
 		  "INBOX" => 1,
  		  "saved-messages" => 1,
  		  "action" => 1,
		  "work" => 1,
		  "posi" => 1,
		 });
  my $imap = Net::IMAP::Client->new(

				    server => $args{Host},
				    user   => $args{Username},
				    pass   => $args{Password},
				    ssl    => 1, # (use SSL? default no)
				    port   => 993 # (but defaults are sane)

				   ) or die "Could not connect to IMAP server";

  if (! $imap->login()) {
    print STDERR "Login failed: " . $imap->last_error . "\n";
    exit(0);
  }
  $self->MyIMAP
    ($imap);

  # $self->Iterator($self->GetEarliestUnseen);
  # # print Dumper($self->MyIMAP->mailboxes());
  foreach my $folder (keys %{$self->Folders}) {
    $self->SetCurrentFolder(Folder => $folder);
    $self->resetIterator;
    # set the iterator to the last message
  }
  print("Done initializing Prioritize\n");
}

sub Iterator {
  my ($self,$item) = @_;
  if (defined $item) {
    # set the iterator
    $self->MyIterator->{$self->CurrentFolder} = $item;
  } else {
    return $self->MyIterator->{$self->CurrentFolder};
  }
}

sub GetIMAPLast {
  my ($self,%args) = @_;
  if (! exists $self->Last->{$self->CurrentFolder}) {
    $self->Last->{$self->CurrentFolder} = $self->MyIMAP->search('ALL')->[-1];
  }
  return $self->Last->{$self->CurrentFolder};
}

sub resetIterator {
  my ($self,%args) = @_;
  $self->MyIterator->{$self->CurrentFolder} = $self->GetIMAPLast;
}

sub hasID {
  my ($self,%args) = @_;
  # print "LAST IS: ".$self->MyIMAP->last."\n";
  if ($self->CurrentFolder) {
    if ($self->GetIMAPLast >= $args{ID} and $args{ID} >= 0) {
      return 1;
    } else {
      # fix this code to handle deleted/ moved items
      $self->MyIMAP->select($self->CurrentFolder);
      if ($self->{FOLDERS}{$self->CurrentFolder}{messages} >= $args{ID} and $args{ID} >= 0) { # try updating it
	return 1;
      }
    }
  }
}

sub MyIMAPSeen {
  my ($self,$message) = @_;
  # fix this later
  return 1;
}

sub GetEarliestUnseen {
  my ($self,%args) = @_;
  my $i = 1;
  while ($self->MyIMAPSeen($i)) {
    ++$i;
  }
  return $i;
}

sub hasNext {
  my ($self,%args) = @_;
  # return true if there are more messages
  # print "Earliest unseen is: ".$self->GetEarliestUnseen()."\n";
  return $self->hasID(ID => $self->Iterator + 1);
}

sub getNext {
  my ($self,%args) = @_;
  # the way to reverse things is to use the - $self->Iterator as below

  # return true if there are more messages
  $self->Iterator($self->Iterator + 1);
  my $contents = NetIMAPClientMsgSummaryAsString($self->MyIMAP->get_summaries([ $self->Iterator ])->[0]);
  return ASConsole::Corpus::Message->new
    (Contents => $contents);
}

sub hasPrevious {
  my ($self,%args) = @_;
  # return true if there are more messages
  # print "Earliest unseen is: ".$self->GetEarliestUnseen()."\n";
  return $self->hasID(ID => $self->Iterator - 1);
}

sub getPrevious {
  my ($self,%args) = @_;
  # the way to reverse things is to use the - $self->Iterator as below

  # return true if there are more messages
  $self->Iterator($self->Iterator - 1);
  #   print Dumper({
  # 		IMAP => $self->MyIMAP,
  # 		Iterator => $self->Iterator,
  # 	       });
  my $summaries = $self->MyIMAP->get_summaries([ $self->Iterator ]);
  my $contents = NetIMAPClientMsgSummaryAsString($summaries->[0]);
  return {
	  Message => ASConsole::Corpus::Message->new
	  (Contents => $contents),
	  ID => {
		 Iterator => $self->Iterator,
		},
	 };
}

sub DESTROY {
  my ($self,%args) = @_;
  $self->MyIMAP->quit;
}

sub LoadReceivedMail {
  my ($self,%args) = @_;
  $self->Connect;
}

sub LoadSentMail {
  my ($self,%args) = @_;
  my $sentmaildir = $self->SentMailDir;
  my @messages = split /\n/, `ls -1 $sentmaildir | sort -n | tac`;
  $self->SentMailFiles(\@messages);
}

sub SetCurrentFolder {
  my ($self,%args) = @_;
  my $folder = $args{Folder};
  return if (defined $self->CurrentFolder and $self->CurrentFolder eq $folder);
  $self->MyIMAP->select($folder);
  $self->CurrentFolder($folder);
}

sub PreviousMail {
  my ($self,%args) = @_;
  my $sentmaildir = $self->SentMailDir;
  if ($args{Folder} eq "Sent") {
    if (scalar @{$self->SentMailFiles}) {
      my $pmessage;
      do {
	my $message = shift @{$self->SentMailFiles};
	my $c = `cat "$sentmaildir/$message"`;
	my $email = Email::Simple->new($c);
	$pmessage = $self->ProcessMessage
	  (
	   Folder => $args{Folder},
	   Type => "Sent",
	   Email => $email,
	   ID => {
		  File => "$sentmaildir/$message",
		 },
	  );
      } while (scalar @{$self->SentMailFiles} and ! $pmessage->{Date});
      return $pmessage;
    } else {
      print "Nope!\n";
    }
  } else {
    $self->SetCurrentFolder(Folder => $args{Folder});
    if ($self->hasPrevious) {
      my $pmessage;
      do {
	my $ret = $self->getPrevious;
	my $message = $ret->{Message};
	$pmessage = $self->ProcessMessage
	  (
	   Folder => $args{Folder},
	   Type => "Received",
	   Email => $message->MyEmailSimple,
	   ID => $ret->{ID},
	  );
      } while ($self->hasPrevious and ! $pmessage->{Date});
      return $pmessage;
    } else {
      print "Nope!\n";
    }
  }
  return;
}

sub NetIMAPClientMsgSummaryAsString {
  my $msg = shift;
  if (defined $msg) {
    my $to = "";
    if (defined $msg->to) {
      my $ref = ref $msg->to;
      if ($ref eq "ARRAY") {
	$to = join(", ",map {GetString($_)} @{$msg->to});
      }
    }
    my $subject = "";
    if (defined $msg->subject) {
      $subject = $msg->subject;
    }
    my $date = "";
    if (defined $msg->date) {
      $date = $msg->date;
    }
    return join("\n",
		"Subject: ".$subject,
		"From: ".join(", ",map {GetString($_)} @{$msg->from}),
		"To: ". $to,
		"Date: ".$date,
		"text",
	       );
  }
}

sub GetString {
  my $email = shift;
  if (defined $email) {
    if (defined $email->mailbox and defined $email->host) {
      return $email->as_string;
    }
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $email = $args{Email};
  my ($subject,$date,$party);
  if ($email) {
    $subject = $email->header("Subject");
    $date = ParseDate($email->header("Date"));
    if ($args{Type} eq "Sent") {
      $party = $email->header("To");
    } else {
      $party = $email->header("From");
    }
  }
  return {
	  Email => $email,
	  Folder => $args{Folder},
	  Party =>  $party,
	  Date => $date,,
	  Subject => $subject,
	  Type => $args{Type},
	  ID => $args{ID},
	 };
}

sub TrainClassifier {
  my ($self,%args) = @_;
  # we want to iterate over the different folders and add to the classifier
  
}

sub ClassifyIncomingMessages {
  my ($self,%args) = @_;
}



sub AnalyzeMail {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  $self->LoadSentMail;
  $self->LoadReceivedMail;
  # okay
  # now what we want to do is this
  # first, get the next message from each source
  my $queuedepth = 30;
  my $folders = {map {$_ => 1} ("Sent",keys %{$self->Folders})};
  my $queuehasnext = {%$folders};
  my $queue = {};
  foreach my $folder (keys %$folders) {
    foreach my $i (1..$queuedepth) {
      if (exists $queuehasnext->{$folder}) {
	my $previousmail = $self->PreviousMail(Folder => $folder);
	if (! defined $previousmail) {
	  delete $queuehasnext->{$folder};
	} else {
	  if (! defined $queue->{$folder}) {
	    $queue->{$folder} = [];
	  }
	  push @{$queue->{$folder}}, $previousmail;
	}
      }
    }
    # now sort the queue
  }

  # then, choose which one is the latest based on date
  # process that for all the details
  while (scalar keys %$folders) {
    my @best;
    foreach my $folder (keys %$folders) {
      if (scalar @{$queue->{$folder}}) {
	$queue->{$folder} = [sort {Date_Cmp($b->{Date},$a->{Date})} @{$queue->{$folder}}];
	push @best, $queue->{$folder}->[0];
      }
    }
    my $message = [sort {Date_Cmp($b->{Date},$a->{Date})} @best]->[0];
    # here is where we do the analysis
    # $self->PrintMessage(Message => $message);
    $self->AddMessage(Message => $message);
    if (defined $conf->{'-d'}) {
      ++$count;
      if ($count > $conf->{'-d'}) {
	print "Count exhausted!\n";
	return;
      }
    }
    my $folder = $message->{Folder};
    shift @{$queue->{$folder}};
    my $previousmail = $self->PreviousMail(Folder => $folder);
    if (! defined $previousmail) {
      delete $queuehasnext->{$folder};
    } else {
      push @{$queue->{$folder}}, $previousmail;
    }
  }
}

sub PrintMessage {
  my ($self,%args) = @_;
  my $message = $args{Message};
  print join("\t",map {"<$_>"} $message->{Folder},$message->{Date},$message->{Party},$message->{Subject})."\n";
}

sub AddMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  # okay here is what we want to do if the message is sent, that adds
  # the recipients to our list of tracks to monitor.  but since we
  # store a graph of all communications anyway
  foreach my $addr (Mail::Address->parse($m->{Party})) {
    # add a contact lookup here
    my $contact = $self->GetContactFromAddress(Address => $addr->address);
    if (! exists $self->Contacts->{$contact}) {
      $self->Contacts->{$contact} = Prioritize::Contact->new(Name => $contact);
    }
    $self->Contacts->{$contact}->AddEmail
      (Message => $m);
  }
  #   if ($m->{Type} eq "Sent") {
  #     # get the addresses to those
  #     # print Dumper(["Sent",$m->{Party}]);
  #   } elsif ($m->{Type} eq "Received") {
  #     print Dumper(["Received",$m->{Party}]);
  #   } else {
  #     print "Type error ".$m->{Type}."\n";
  #   }
}

sub GetContactFromAddress {
  my ($self,%args) = @_;
  return lc($args{Address});
}

1;

