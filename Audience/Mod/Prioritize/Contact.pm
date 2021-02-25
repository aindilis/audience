package Audience::Mod::Prioritize::Contact;

use Data::Dumper;
use Text::Wrap;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Messages Monitor /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name});
  $self->Messages([]);
  $self->Monitor(0);
}

sub AddEmail {
  my ($self,%args) = @_;
  # $self->Name($args{Name});
  my $m = $args{Message};
  push @{$self->Messages}, $m;
  if ($m->{Type} eq "Sent") {
    if (! $self->Monitor) {
      my $id;
      if (exists $m->{ID}->{File}) {
	$id = $m->{ID}->{File};
      } elsif (exists $m->{ID}->{Iterator}) {
	$id = $m->{ID}->{Iterator};
      }
      my $id2;
      if (exists $self->Messages->[0]->{ID}->{File}) {
	$id2 = $self->Messages->[0]->{ID}->{File};
      } elsif (exists $self->Messages->[0]->{ID}->{Iterator}) {
	$id2 = $self->Messages->[0]->{ID}->{Iterator};
      }

      if ($self->Messages->[0]->{Type} eq "Sent") {
	print $self->Name." needs to contact us\n";
	print "\tregarding ".$m->{Subject}."\t---\t".$id."\n";
      } elsif ($self->Messages->[0]->{Type} eq "Received") {
	print "We need to contact ".$self->Name."\n";
	print "\tregarding ".$self->Messages->[0]->{Subject}."\t---\t".$id2."\n";
      }

    }
    $self->Monitor(1);
    # check to see whether we need to contact them or they need to contact us
    # simply look at the first email, if it was a Sent, that means they need to contact us
    # if it was a received, that means we need to contact them
  }
}

1;

