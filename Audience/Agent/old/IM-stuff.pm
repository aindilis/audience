
# sub ProcessCommand {
#   my ($self,%args) = @_;
#   # Audience::Proxy

#   my $c = $args{Command};
#   my $m = $args{Message};

#   print "\tSignOffOfNetXMPPClient\n";
#   chomp $c;
#   if ($c) {
#     if ($c =~ /^IM (.+)$/) {
#       $self->LastReceiver($1);
#       print "Setting LastReceiver to <$1>\n";
#     } elsif ($c =~ /^(quit|exit)$/) {
#       $self->SignOffOfNetXMPPClient;
#     } elsif ($c =~ /^list$/) {

#     } else {
#       push @{$self->Conversations->{$self->LastReceiver || $self->LastSender}}, [$self->ScreenName,$contents];

#       # $self->SendMessage
#       #   (
#       #    Recipient => '<REDACTED>',
#       #    Subject => '',
#       #    Body => '',
#       #    Thread => '',
#       #    Priority => 10,
#       #   );

#       $self->SendMessage
#         (
#          Recipient => ($self->LastReceiver || $self->LastSender),
#          Subject => '',
#          Body => $c,
#          Thread => '',
#          Priority => 10,
#         );
#     }
#   }
# }

# sub Handler {
#   my ($self,@args) = @_;
#   # print Dumper(@args);
#   my ($aim,$messageobject,$sender,$receive) = @args;
#   $self->LastSender($sender);
#   my $contents = $messageobject->{args}->[2];
#   push @{$self->Conversations->{$sender}}, [$sender,$contents];
#   my $new = UniLang::Util::Message->new
#     (Sender => "Audience",
#      Receiver => "UniLang-Client",
#      Date => $UNIVERSAL::agent->GetDate,
#      Contents => "UniLang-Client, <$sender>:<$contents>");
#   $UNIVERSAL::agent->Send
#     (Handle => $UNIVERSAL::agent->Client,
#      Message => $new);
# }

# sub Stop {
#   my ($self,%args) = @_;
#   $self->SignOffOfNetXMPPClient;
# }

# sub Stop {
#   print "Exiting...\n";
#   $self->NetXMPPClient->Disconnect();
#   exit(0);
# }

# while(defined($self->Execute())) { }
