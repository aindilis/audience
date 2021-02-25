package Audience::Proxy::MessageQueue;

use Audience::Proxy::Message;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / StorageFile Queue /

  ];

sub init {
  my ($self,%args) = @_;
  $self->StorageFile($args{StorageFile});
  $self->Queue($args{Queue} || []);
}

sub Count {
  my ($self,%args) = @_;
  return scalar @{$self->Queue};
}

sub IsEmpty {
  my ($self,%args) = @_;
  return ! (scalar @{$self->Queue});
}

sub Push {
  my ($self,%args) = @_;
  push @{$self->Queue}, @{$args{Messages}};
}

sub Pop {
  my ($self,%args) = @_;
  pop @{$self->Queue};
}

sub Shift {
  my ($self,%args) = @_;
  shift @{$self->Queue};
}

sub Unshift {
  my ($self,%args) = @_;
  unshift @{$self->Queue}, @{$args{Messages}};
}

sub Save {
  my ($self,%args) = @_;
  my $OUT;
  if (open(OUT,">".$self->StorageFile)) {
    print OUT Dumper($self->Queue);
    close(OUT);
  } else {
    print "cannot open ".$self->StorageFile."\n";
  }
}

sub Load {
  my ($self,%args) = @_;
  my $f = $self->StorageFile;
  if (-f $f) {
    my $c = `cat "$f"`;
    $self->Queue(eval $c);
  } else {
    $self->Queue([]);
  }
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper($self->Queue);
}

1;
