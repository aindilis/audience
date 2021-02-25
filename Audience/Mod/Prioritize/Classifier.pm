package Audience::Mod::Prioritize::Classifier;

use Data::Dumper;
use BOSS::Config;
use MyFRDCSA;

use AI::Categorizer;
use AI::Categorizer::Category;
use AI::Categorizer::Learner::NaiveBayes;
use Algorithm::NaiveBayes::Model::Frequency;
use AI::Categorizer::Learner::SVM;
use Data::Dumper;
use IO::File;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw /  /

  ];

sub init {
  my ($self,%args) = @_;

$UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"audience","scripts","email-priority-classifier");
my $dir = "$UNIVERSAL::systemdir/data/classification/bootstrap/classes";

$statepath = "$UNIVERSAL::systemdir/data/classification/model";

# Create the Learner, and restore state if need be
$conf->{'--learner'} = "NaiveBayes";

my $learner;
my $needstraining;
if (exists $conf->{'--learner'}) {
  if ($conf->{'--learner'} eq "SVM") {
    if (-d $statepath) {
      print "Restoring state\n";
      $learner = AI::Categorizer::Learner::SVM->restore_state($statepath);
    } else {
      $learner = AI::Categorizer::Learner::SVM->new();
      $needstraining = 1;
    }
  } elsif ($conf->{'--learner'} eq "NaiveBayes") {
    if (-d $statepath) {
      print "Restoring state\n";
      $learner = AI::Categorizer::Learner::NaiveBayes->restore_state($statepath);
    } else {
      $learner = AI::Categorizer::Learner::NaiveBayes->new();
      $needstraining = 1;
    }
  } else {
    die "Learner ".$conf->{'--learner'}." not found\n";
  }
}

if ($needstraining) {
  # LOAD THE SOURCE DATA
  my @categories;
  my %mycategories;
  my @cats = split /\n/, `ls $dir`;
  @cats = splice @cats,-30;
  foreach my $categoryname (@cats) {
    my $cat = AI::Categorizer::Category->by_name(name => $categoryname);
    $mycategories{$categoryname} = $cat;
    push @categories, $cat;
  }

  my @test;
  my @train;

  my $traincutoff;
  if (exists $conf->{'--traintest'}) {
    print "Doing a train test\n";
    $percentage = $conf->{'--traintest'};
    die "Invalid percentage: $percentage\n" unless ($percentage >= 0 and $percentage <= 100);
  }

  foreach my $categoryname (@cats) {
    my $c = $mycategories{$categoryname};
    print "<$categoryname>\n";
    foreach my $file (split /\n/,`find $dir/$categoryname`) {
      if (-f $file) {
	my $filecontents = `cat $file`;
	if (defined $percentage and int(rand(100)) > $percentage) {
	  my $d = AI::Categorizer::Document->new
	    (name => $file,
	     content => $filecontents);
	  push @test, $d;
	} else {
	  if (UNIVERSAL::isa($c,'AI::Categorizer::Category')) {
	    my $d = AI::Categorizer::Document->new
	      (name => $file,
	       content => $filecontents,
	       categories => [$c]);
	    $c->add_document($d);
	    if (UNIVERSAL::isa($d,'AI::Categorizer::Document')) {
	      push @train, $d;
	    }
	  }
	}
      }
    }
  }

  # create a knowledge set
  my $k = new AI::Categorizer::KnowledgeSet
    (
     categories => \@categories,
     documents => \@train,
    );

  print "Training, this could take some time...\n";
  $learner->train(knowledge_set => $k);
  $learner->save_state($statepath) if $statepath;
}

my $targetcontents = `cat /var/lib/myfrdcsa/codebases/minor/paperless-office/first-scan/out.txt`;

my $d = AI::Categorizer::Document->new
  (name => "target",
   content => $targetcontents);

my $hypothesis = $learner->categorize($d);
foreach my $key (sort {$hypothesis->{scores}->{$b} <=> $hypothesis->{scores}->{$a}} keys %{$hypothesis->{scores}}) {
  print "$key\t\t".$hypothesis->{scores}->{$key}."\n";
}

1;

