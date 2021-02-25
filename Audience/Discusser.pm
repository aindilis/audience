package Audience::Discusser;

# system for propogating events

use MyFRDCSA;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

sub Discuss {
  my ($self,%args) = @_;
  my $contact = $args{Contact};
  return unless $contact;
  $self->Message(Message => "You have queued messages.");
  if ($self->Approve(Request => "Would like to see them now?")) {

    # now  foreach message,  classify it  as  either a  question or  a
    # statement, if it is a question, record the response.

    # perhaps in the  future do more cool task  context stuff here, to
    # ensure proper interpretation of messages

    # you could also  do cool things like determine  whether the agent
    # is  likely to  remember the  context of  each  discussion thread
    # based on how long ago and  how much information flux she has had
    # of late.

    my $queue = $contact->{Contact}->IncomingQueue->Queue;
    my $log = $contact->{Contact}->LogQueue->Queue;
    my @messages;
    my @queries;
    while ($queue->Count) {
      my $message = $queue->Shift;
      my $time = $message->Date;
      my $sender = $message->Sender;
      my $receiver = $message->Receiver;
      my $contents = $message->Contents;
      $self->Message(Message => "at <$time>, <$sender> wrote to <$receiver>:");
      my $type = $self->ClassifyMessageContents(Contents => $contents);
      if ($type eq "question") {
	my $response = $self->Query(Query => "\" $contents \" ???");
	push @queries, $message;
      } elsif ($type eq "statement") {
	$self->Message(Message => "\" $contents \"");
	push @messages, $message;
      }
      $message->Status->{Sent} = 1;
    }
    $log->Unshift(Messages => @queries);
    my @conj;
    push @conj, (scalar @queries)." queries" if @queries;
    push @conj, (scalar @messages)." messages" if @messages;
    my $request = "Do you acknowledge receipt of these ".join(" and ",@conj)."?";
    if ($self->Approve(Request => $request)) {
      foreach my $message (@messages) {
	$message->Status->{Acknowledged} = 1;
      }
    } else {
      $queue->Unshift(Messages => \@messages);
    }
    $queue->Save;
    $log->Save;
  }
}

sub ClassifyMessageContents {
  my ($self,%args) = @_;
  # obviously this could stand to be better implemented
  my $c = $args{Contents};
  if ($c =~ /\?$/) {
    # its a question
    return "question";
  } else {
    return "statement";
  }
}

sub Message {
  my ($self,%args) = @_;
  my $m = $args{Message};
  $message = Audience::Proxy::Message->new
    (Sender => "",
     Receiver => "",
     Date => undef,
     Contents => "");
}

sub Query {
  my ($self,%args) = @_;
  $self->Message(Message => $args{Query});
  # now is the difficult part, waiting for the input
  return $res;
}

sub Approve {
  my ($self,%args) = @_;
  my $res = $self->Query(Query => $args{Request});
  return 1 if $res =~ /[yY]([eE][sS])?/;
}

1;
