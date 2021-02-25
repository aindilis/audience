package Audience;

use Audience::AgentManager;
use Audience::ContactManager;
use Audience::ContactManager2;
use Audience::IdentityManager;
use Audience::Diplomat;
use Audience::Proxy;
use BOSS::Config;
use Manager::Dialog qw(Message);
use MyFRDCSA;
use PerlLib::UI;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config MyAgentManager MyContactManager MyContactManager2
   MyIdentityManager MyProxy MyDiplomat MyUI DefaultTimeOut /

  ];

sub init {
  my ($self,%args) = (shift,@_);
  $specification = "
	-a <agents>...		Run agents (im, email, phone, wearable, etc

	-c			Console interface (i.e. without UniLang)
	-d			Debugging mode

        --list-sources		Display a list of all sources

        -U [<sources>...]       Update contact sources
        -l [<sources>...]	Load contact sources
        -p [<sources>...]	Load contact sources and process axioms from sources
        -s [<sources>...]	Sync contact sources

	-u [<host> <port>]	Run as a UniLang agent
";
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"audience");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->DoNotDaemonize(1);
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->DefaultTimeOut(0.05);
}

sub LoadAgents {
  my ($self,%args) = (shift,@_);
  my $conf = $self->Config->CLIConfig;
  my @agents = ();
  if (exists $conf->{'-a'}) {
    push @agents, @{$conf->{'-a'}};
  }
  if (exists $conf->{'-u'}) {
    push @agents, "UniLang";
  }
  $self->MyAgentManager
    (Audience::AgentManager->new
     (
      Agents => \@agents,
      Timeout => $self->DefaultTimeOut,
     ));
}

sub Execute {
  my ($self,%args) = (shift,@_);
  my $conf = $self->Config->CLIConfig;
  $self->MyProxy(Audience::Proxy->new());
  $self->MyDiplomat(Audience::Diplomat->new());
  $self->MyContactManager
    (Audience::ContactManager->new());
  $self->MyIdentityManager
    (Audience::IdentityManager->new());
  $self->MyContactManager->LoadContacts;
  $self->MyContactManager2
    (Audience::ContactManager2->new());
  $self->LoadAgents;
  if (exists $conf->{'-u'}) {
    $self->MyAgentManager->StartAgents;
    $self->MyAgentManager->Execute;
  }
  if (exists $conf->{'--list-sources'}) {
    $self->MyContactManager2->MySourceManager->ListSources;
  }
  if (exists $conf->{'-U'}) {
    $self->MyContactManager2->MySourceManager->UpdateSources
      (
       Sources => $conf->{'-U'},
      );
  }
  if (exists $conf->{'-l'}) {
    $self->MyContactManager2->MySourceManager->LoadSources
      (
       Sources => $conf->{'-l'},
      );
  }
  if (exists $conf->{'-p'}) {
    $self->MyContactManager2->MySourceManager->LoadSources
      (
       Sources => $conf->{'-p'},
      );
    $self->MyContactManager2->MySourceManager->ProcessAxioms
      (
       Sources => $conf->{'-p'},
      );
  }
  if (exists $conf->{'-s'}) {
    $self->MyContactManager2->SyncContacts
      (
       Sources => $conf->{'-s'},
      );
  }
  if (exists $conf->{'-c'}) {
    $self->MyUI
      (PerlLib::UI->new
       (Menu => [
		 "Main Menu", [
			       "ACLs", "ACLs",
			      ],
		 "ACLs", [
			  "Show Rules",
			  sub {print "".$self->MyDiplomat->MyACL->SPrintRules},
			  "Add Rule",
			  sub {$self->MyDiplomat->MyACL->AddRuleClass},
			  "Remove Rule",
			  sub {$self->MyDiplomat->MyACL->RemoveRuleClass},
			 ],
		],
	CurrentMenu => "Main Menu"));
    Message(Message => "Starting Event Loop...");
    if ($conf->{'-u'}) {
      $self->Listen(TimeOut => $self->DefaultTimeOut);
    } else {
      $self->MyUI->BeginEventLoop;
    }
  }
}

sub Listen {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (defined $self->MyAgentManager) {
    $self->MyAgentManager->Listen
      (
       TimeOut => $args{TimeOut},
      );
  }
  if (exists $conf->{-u}) {
    $UNIVERSAL::agent->Listen
      (
       TimeOut => $args{TimeOut},
      );
  }
}

1;
