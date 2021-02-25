package Audience::ContactManager::Source::BBDB;

use BBDB;
use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Loaded MyBBDB Axioms /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyBBDB(BBDB->new);
  $self->Axioms([]);
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = @_;

}

sub LoadSource {
  my ($self,%args) = @_;
  # first of all, load some bbdb specific axioms
  $self->AddAxioms
    (
     Axioms => [
		["implies", ["bbdb-record", "first", \*{'::?ENTRY'}, \*{'::?FIRSTNAME'}], ["has-firstname", \*{'::?ENTRY'}, \*{'::?FIRSTNAME'}]],
		["implies", ["bbdb-record", "last", \*{'::?ENTRY'}, \*{'::?SURNAME'}], ["has-surname", \*{'::?ENTRY'}, \*{'::?SURNAME'}]],
		["implies", ["bbdb-record", "email", \*{'::?ENTRY'}, \*{'::?EMAILADDRESS'}], ["has-email-address", \*{'::?ENTRY'}, \*{'::?EMAILADDRESS'}]],
		["implies", ["and", ["bbdb-record", "first", \*{'::?ENTRY'}, \*{'::?FIRSTNAME'}], ["bbdb-record", "last", \*{'::?ENTRY'}, \*{'::?LASTNAME'}]], ["has-fullname", \*{'::?ENTRY'}, ["concat", \*{'::?FIRSTNAME'}, \*{'::?LASTNAME'}]]],
	       ],
    );
  my $partslist = [qw(first last aka company phone address net notes)];
  my $parts = {
	       first => sub {
		 my (%args) = @_;
		 $self->AddAxioms
		   (
		    Axioms => [
			       ["bbdb-record", "first", $args{EntryFn}, $args{Value}],
			      ],
		   );
	       },
	       last => sub {
		 my (%args) = @_;
		 $self->AddAxioms
		   (
		    Axioms => [
			       ["bbdb-record", "last", $args{EntryFn}, $args{Value}],
			      ],
		   );
	       },
	       # 	       aka => sub {
	       # 		 my (%args) = @_;

	       # 	       },
	       # 	       company => sub {
	       # 		 my (%args) = @_;

	       # 	       },
	       phone => sub {
		 my (%args) = @_;
		 my @axioms;
		 my $phoneid = 0;
		 foreach my $entry (@{$args{Value}}) {
		   push @axioms, ["bbdb-record", ["phone-fn",$phoneid,"phone-type"], $args{EntryFn}, $entry->[0]];
		   my $indicies = ["area-code","local-code","last-four-digits","unknown"];
		   foreach my $index (@$indicies) {
		     my $value = shift @{$entry->[1]};
		     push @axioms, ["bbdb-record", ["phone-fn",$phoneid,$index], $args{EntryFn}, $value];
		   }
		   ++$phoneid;
		 }
		 $self->AddAxioms
		   (
		    Axioms => \@axioms,
		   );
	       },
	       address => sub {
		 my (%args) = @_;
		 my @axioms;
		 my $addressid = 0;
		 foreach my $entry (@{$args{Value}}) {
		   my $indicies = ["address-type","street-address","city","state","zipcode","country"];
		   foreach my $index (@$indicies) {
		     my $value = shift @$entry;
		     if ($index eq "street-address") {
		       unshift @$value, "street-address";
		     }
		     push @axioms, ["bbdb-record", ["address-fn",$addressid,$index], $args{EntryFn}, $value];
		   }
		   ++$addressid;
		 }
		 $self->AddAxioms
		   (
		    Axioms => \@axioms,
		   );
	       },
	       net => sub {
		 my (%args) = @_;
		 # ("bbdb-email" ("entry-fn" 135) "krackykracky\@yahoo.com")
		 my @axioms;
		 foreach my $entry (@{$args{Value}}) {
		   push @axioms, ["bbdb-record", "net", $args{EntryFn}, $entry];
		 }
		 $self->AddAxioms
		   (
		    Axioms => \@axioms,
		   );
	       },
	       notes => sub {
		 my (%args) = @_;
		 my @axioms;
		 foreach my $entry (@{$args{Value}}) {
		   push @axioms, ["bbdb-record", ["note-fn", $entry->[0]], $args{EntryFn}, $entry->[1]];
		 }
		 $self->AddAxioms
		   (
		    Axioms => \@axioms,
		   );
	       },
	      };

  # for now, just process the local copy
  my $bbdbfile = "/home/andrewdo/.bbdb";
  my $allR = BBDB::simple($bbdbfile);
  my $entryid = 0;
  my $missing = {};
  foreach my $bbdbentry (@$allR) {
    my $entryfn = ["bbdb", "file", "date", $entryid];
    $self->AddAxioms
      (
       Axioms => [
		  ["has-source", $entryfn, "BBDB"],
		  ["has-source-source", $entryfn, "/home/andrewdo/.bbdb"],
		 ],
      );
    foreach my $part (@$partslist) {
      if (exists $parts->{$part}) {
	$parts->{$part}->
	  (
	   Value => $bbdbentry->part($part),
	   EntryFn => $entryfn,
	  );
      } else {
	my $res = $bbdbentry->part($part);
	if (scalar @$res) {
	  if (! exists $missing->{$part}) {
	    print "$part\n";
	    $missing->{$part} = [];
	  }
	  push @{$missing->{$part}}, $res;
	}
      }
    }
    ++$entryid;
  }
  $self->Loaded(1);
}

sub AddAxioms {
  my ($self,%args) = @_;
  my @axioms;
  foreach my $axiom (@{$args{Axioms}}) {
    push @axioms, $axiom;
  }
  push @{$self->Axioms}, @axioms;
}

1;
