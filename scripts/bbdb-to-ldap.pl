#!/usr/bin/perl -w

use lib "/var/lib/myfrdcsa/codebases/internal/audience/scripts";
use BBDB::Export;
use BBDB::Export::LDIF;
use BBDB::Export::LDAP;

# sync with ldap via ldapadd and ldapdelete
my $exporter = BBDB::Export::LDIF->new(
				       {
					bbdb_file   => "/home/andrewdo/.bbdb",
					output_file => "export.ldif",
					dc          => "dc=frdcsa, dc=org",
				       }
				      );

# my $exporter = BBDB::Export::LDAP->new(
# 				       {
# 					bbdb_file   => "/home/andrewdo/.bbdb",
# 					output_file => "/tmp/output",
# 					dc          => "dc=frdcsa, dc=org",
# 					ldappass    => "<REDACTED>",
# 				       }
# 				      );
$exporter->export();
