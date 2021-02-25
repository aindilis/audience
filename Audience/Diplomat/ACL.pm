package Audience::Diplomat::ACL;

use Manager::Dialog qw(Message SubsetSelect Choose Approve);

use Data::Dumper;
use Decision::ACL;
use Decision::ACL::Rule;
use Decision::ACL::Constants qw(:rule);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Medium Events Responses ACL / ];

sub init {
  my ($self,%args) = @_;
  $self->ACL(Decision::ACL->new());
  $self->Medium($args{Medium});
  $self->Events($args{Events});
  $self->Responses($args{Actions});

}

sub CheckPermissions {
  my ($self,%args) = @_;
  # Check the ACL permissions
  my $return_status = $self->ACL->RunACL
    ({
      Contact => $args{Contact},
      Medium => $args{Medium} || "",
      Event => $args{Event} || "",
      Response => $args{Response} || "",
     });
  return $return_status;
}

sub SPrintRules {
  my ($self,%args) = @_;
  my $retval;
  foreach my $rule (@{$self->ACL->Rules()}) {
    $retval .= Dumper($rule);
  }
  return $retval;
}

sub AddRule {
  my ($self,%args) = @_;
  # Create a Decision::ACL::Rule object
  my $rule = new Decision::ACL::Rule
    ({
      now => $args{Now} || 0,
      action => $args{Action} || "deny",
      fields =>
      {
       Contact => $args{Contact},
       Medium => $args{Medium} || "",
       Event => $args{Event} || "",
       Response => $args{Response} || "",
      }
     });
  # Push that rule onto the ACL.
  print "AddingRule<".$args{Action}."><".$args{Contact}."><".$args{Medium}.
    "><".$args{Event}."><".$args{Response}.">\n";
  $self->ACL->PushRule($rule);
}

sub RemoveRule {
  my ($self,%args) = @_;
  # Create a Decision::ACL::Rule object
  my $rule = new Decision::ACL::Rule
    ({
      now => $args{Now} || 0,
      action => $args{Action} || "deny",
      fields =>
      {
       Contact => $args{Contact},
       Medium => $args{Medium} || "",
       Event => $args{Event} || "",
       Response => $args{Response} || "",
      }
     });
  # Push that rule onto the ACL.
  # $self->ACL->PushRule($rule);
  Message(Message => "Not yet implemented");
}

sub AddRuleClass {
  my ($self,%args) = @_;
  my $hash = {};
  Message(Message => "Select Contact");
  $hash->{Contact} = [SubsetSelect
		      (Set => [sort $UNIVERSAL::audience->MyContactManager->Contacts->Keys],
		       Selection => {})];
  Message(Message => "Select Medium");
  $hash->{Medium} = [SubsetSelect
		     (Set => $self->Medium,
		      Selection => {})];
  Message(Message => "Select Events");
  $hash->{Event} = [SubsetSelect
		    (Set => $self->Events,
		     Selection => {})];
  Message(Message => "Select Responses");
  $hash->{Response} = [SubsetSelect
		       (Set => $self->Responses,
			Selection => {})];
  $hash->{Action} = Choose("allow","deny");
  # if a thing is left blank, mark all
  foreach my $s (qw(Contact Medium Event Response)) {
    if (!@{$hash->{$s}}) {
      $hash->{$s} = ["ALL"];
    }
  }
  if (Approve("Add rule class:\n".Dumper($hash))) {
    foreach my $contact (@{$hash->{Contact}}) {
      foreach my $medium (@{$hash->{Medium}}) {
	foreach my $event (@{$hash->{Event}}) {
	  foreach my $response (@{$hash->{Response}}) {
	    $self->AddRule
	      (
	       Contact => $contact,
	       Medium => $medium,
	       Event => $event,
	       Response => $response,
	       Action => $hash->{Action},
	      );
	  }
	}
      }
    }
  }
}

sub RemoveRuleClass {
  my ($self,%args) = @_;
  my $hash = {};
  Message(Message => "Select Contact");
  $hash->{Contact} = [$self->SubsetSelect
		      (Set => [sort $UNIVERSAL::audience->MyContactManager->Contacts->Keys],
		       Selection => {})];
  Message(Message => "Select Medium");
  $hash->{Medium} = [$self->SubsetSelect
		     (Set => $self->Medium,
		      Selection => {})];
  Message(Message => "Select Events");
  $hash->{Event} = [$self->SubsetSelect
		    (Set => $self->Events,
		     Selection => {})];
  Message(Message => "Select Responses");
  $hash->{Response} = [$self->SubsetSelect
		       (Set => $self->Responses,
			Selection => {})];
  $hash->{Action} = Choose("allow","deny");
  if (Approve("Remove rule class:\n".Dumper($hash))) {
    foreach my $contact (@{$hash->{Contact}} || "") {
      foreach my $medium (@{$hash->{Medium}} || "") {
	foreach my $event (@{$hash->{Event}} || "") {
	  foreach my $response (@{$hash->{Response}} || "") {
	    $self->RemoveRule
	      (
	       Contact => $contact,
	       Medium => $medium,
	       Event => $event,
	       Response => $response,
	       Action => $hash->{Action},
	      );
	  }
	}
      }
    }
  }
}

1;

# use Mach::People;

# Since mach is in sort of  disarray, and it will not do for us
# to use it, shall just use the people directory for now.

# Since interaction will happen, we  need to recognize in which cases it
# is permissible and  in which cases it is not.   Exceptions may be made
# in emergency situations where animosity or physical harm to self would
# result but must be reported.

# Pretty obvious that in  addition to Actions/Permission,etc, we ought
# to have Diplomat come up with responses.
