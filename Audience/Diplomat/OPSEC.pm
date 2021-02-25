package Audience::Diplomat::OPSEC;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [

		    qw / /

		   ];

sub init {
  my ($self,%args) = @_;
}

sub CountInformationExchange {
  my ($self,%args) = @_;
}

sub ConsiderInformationContent {
  my ($self,%args) = @_;
}

sub LodgeComplaints {
  my ($self,%args) = @_;
  # any outgoing message that is analyzed, complaints will be lodged
  # against the message object.  before sending it out,
  # Diplomat/Reasoner must consider these complaints.  If a message is
  # sent with active complaints, all complaints must have an
  # abrogating justification, and RSR gets wind.

}

1;
