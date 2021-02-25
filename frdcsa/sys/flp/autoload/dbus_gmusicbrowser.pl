gmusicBrowserCommand(playPause,loginFn(UserName,System)) :-
	dbusSend('--dest=org.gmusicbrowser /org/gmusicbrowser org.gmusicbrowser.RunCommand string:PlayPause',Result).

gmusicBrowserCommand(currentSong,loginFn(UserName,System)) :-
	dbusSend('--print-reply --dest=org.gmusicbrowser /org/gmusicbrowser org.gmusicbrowser.CurrentSong',Result).

gmusicBrowserCommand(getPosition,loginFn(UserName,System)) :-
	dbusSend('--print-reply --dest=org.gmusicbrowser /org/gmusicbrowser org.gmusicbrowser.GetPosition',Result).

%% Functions
%% RunCommand

%% Takes a string as argument, this string is the name of a command with optional arguments.

%% See the output of ”gmusicbrowser -listcmd” for a list of comands and their arguments.

%% No return value
%% CurrentSong

%% no arguments

%% returns a hash/dictionary containing info on the current song. Currently the hash contains these fields : title, album, artist, length, track, disc.

%% More fields may be added in future versions.
%% GetPosition

%% no arguments

%% returns the position in the current song in seconds
%% Playing

%% no arguments

%% returns a boolean, true if playing, false if stopped/paused.
%% Set

%% Takes 3 strings as arguments:

%% path/filename of song OR numeric ID of the song
%% field to change
%% new value

%% returns true if succeeded, false if failed (in particular if the song couldn't be found in the library)

%% Be careful with this function, the new value is not checked for validity as much as it should be.
%% Get

%% Takes 2 strings as argument:

%%     path/filename of song OR numeric ID of the song
%%         field

%% 	returns the value of the field
%% 	GetLibrary

%% 	no arguments

%% 	returns the list of songs ID in the library
%% 	GetAlbumCover

%% 	takes a string as argument

%% 	returns the filename of the cover if the string match an album name that has a cover

%% 	Note that the filename of the cover may be a mp3 file with an embedded cover.

%% 	May change in future versions with the support of multiple albums with the same name.
%% 	Signals
%% 	SongChanged

%% 	Emitted when the current song changes with the song ID of the new song as argument.
