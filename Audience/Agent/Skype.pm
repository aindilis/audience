# Net::DBus::Skype

# http://forum.skype.com/topic/92761-callto-skype-links-for-phone-numbers-with-ubuntu-and-firefox/page__s__59afadaa108921521296dc66dea59cf0
# https://developer.skype.com/Docs/ApiDoc/Skype_API_on_Linux


# http://search.cpan.org/~mncoppola/Win32-Skype-0.01/lib/Win32/Skype.pm

use Net::DBus::Skype;

my $s = Net::DBus::Skype->new;
my $s = Net::DBus::Skype->new({ debug => 1 });

$s->action('skype:echo123?call');
# -or-
$s->action('skype:echo123');
# -or-
$s->action('skype://echo123');
# -or-
$s->raw_skype('CALL echo123');
