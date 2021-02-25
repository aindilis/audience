package Audience::Proxy::Message;

use UniLang::Util::Message;;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ID Sender Receiver Contents Date TranslatedContents Medium
   Classification TabariCode Formalization Meaning HiddenMeaning
   Complaints Status /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ID($args{ID});
  $self->Sender($args{Sender});
  $self->Receiver($args{Receiver});
  $self->Contents($args{Contents});
  $self->Date($args{Date});
  $self->TranslatedContents($args{TranslatedContents});
  $self->Medium($args{Medium});
  $self->Classification($args{Classification});
  $self->TabariCode($args{TabariCode});
  $self->Formalization($args{Formalization});
  $self->Meaning($args{Meaning});
  $self->HiddenMeaning($args{HiddenMeaning});
  $self->Complaints($args{Complaints} || []);
  $self->Status($args{Status} || {});
}

sub TranslateToUniLangMessage {
  my ($self,%args) = @_;
  my $um = UniLang::Util::Message->new
    (Sender => $self->Sender,
     Receiver => $self->Receiver,
     Date => $self->Date,
     Contents => $self->Contents);
  return $um;
}

sub TranslateFromUniLangMessage {
  my ($self,%args) = @_;
  my $um = $args{UniLangMessage};
  $self->Sender($um->Sender);
  $self->Receiver($um->Receiver);
  $self->Date($um->Date);
  $self->Contents($um->Contents);
  return;
}

sub SPrint {
  my ($self,%args) = @_;
  return "<S:".$self->Sender."><R:".$self->Receiver."><C:".$self->Contents.">";
}

1;
