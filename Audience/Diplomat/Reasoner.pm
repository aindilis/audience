package Audience::Diplomat::Reasoner;

# ISN'T IT OBVIOUS?  Use that stuff from Y2 Challenge problem here

# or maybe use CELT, etc.

# could also use Corpus here for some things



use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / PendingMessages / ];

sub init {
  my ($self,%args) = @_;
  $self->PendingMessages($args{PendingMessages} || []);
}

sub InterpretCommunications {
  my ($self,%args) = @_;
  foreach my $message (@{$self->PendingMessages}) {
    # use tabari to code events
    $self->CodeMessageWithTabari(Message => $message);
  }
}

sub CodeMessageWithTabari {
  my ($self,%args) = @_;
  # this is perhaps more appropriate to get data from event-log, but I
  # guess  various  modules have  to  report  to event-log,  including
  # audience, and then this could respond.

  # for now, just have the user select
  if ($args{Manual} || 1) {
    Message(Message => "Please code this message:\n".
	    $message->Sender."\n".$message->Contents);
    my @codes = SubsetSelect
      (Set => ,
       Selection => {});
    $message->TabariCode(\@codes);
  } else {
    # # Write file containing message
    # WriteFile("/tmp/tabari",$message->Sender."\n".$message->Contents);
    # my $res = `tabari /tmp/tabari`;
    # # Process the results
    # $message->TabariCode([$res]);
  }
}

sub DoPlanning {
  my ($self,%args) = @_;
  $self->DoSimplisticPlanning;

}

sub DoSimplisticPlanning {
  my ($self,%args) = @_;
  # this is  just a simply state  transition based on  make a directed
  # graph, which consists  of moves that two or  more players can play
  # and  simply  walk  through  this  graph.   perhaps  in  this  case
  # reinforcement learning is appropriate.
}

sub GenerateResponse {
  my ($self,%args) = @_;
  # use templates to generate a valid response.
}

sub ConsultWithBardToEvaluateMeaningOfStatement {
  my ($self,%args) = @_;
}

1;
