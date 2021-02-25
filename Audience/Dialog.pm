package Audience::Dialog;

# system handles real time dialog

use Audience::Dialog::Conversation;
use BOSS::Config;

$VERSION = '1.00';
use strict;
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Conf File Parties Conversations / ];

sub init {
  my ($self, %args) = @_;
  my $specification = "
	-g		Game conversation
	-i <file>	Input file
";
  $self->Conf(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Conf->CLIConfig;
  $self->File($args{File} || $conf->{'-i'} || "/tmp/conversation.aud");
  $self->Conversations($args{Conversations} || []);
  $self->Parties($args{Parties} || "");
}

sub Start {
  my ($self, %args) = @_;
  my $conf = $self->Conf->CLIConfig;
  if (exists $conf->{'-g'}) {
    push @{$self->Conversations}, Audience::Dialog::Conversation->new
      (File => $self->File,
       Type => "game");
  } else {
    push @{$self->Conversations}, Audience::Dialog::Conversation->new
      (File => $self->File);
  }
}

1;
