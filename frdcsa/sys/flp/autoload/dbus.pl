dbusSend(TmpCommand) :-
	atomic_list_concat(['dbus-send',TmpCommand],' ',Command),
	shell_command_async(Command).

dbusSend(TmpCommand,Result) :-
	atomic_list_concat(['dbus-send',TmpCommand],' ',Command),
	shell_command_to_String(Command,Result).

%% #!/usr/bin/perl
%% use warnings;
%% use strict;
%% use Net::DBus;

%% my $bus = Net::DBus->session;
%% my $service = $bus->get_service('org.gmusicbrowser');
%% my $object = $service->get_object('/org/gmusicbrowser', 'org.gmusicbrowser');

%% my $info= $object->CurrentSong;
%% print "$_ : $info->{$_}\n" for sort keys %$info;
%% print "position : ".$object->GetPosition."\n";