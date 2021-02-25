generatePageFor(audience,UserName,[userActualNameAsks,UserActualNameAsks,userActualNameIsAsked,UserActualNameIsAsked,userActualNameIsAssigned,UserActualNameIsAssigned,userActualNameAssigns,UserActualNameAssigns]) :-
	catalystUserNameResolvesToAgent(UserName,UserActualName),
	scryList(ask(UserActualName,Agent,Question),UserActualNameAsks),
	%% scryList(ask(Agent,UserActualName,Question),UserActualNameIsAsked),
	setof([Agent,Result],setof(Question,UserActualName^ask(Agent,UserActualName,Question),Result),UserActualNameIsAsked),
	scryList(taskAssignedByTo(Task,Desc,UserActualName,Agent),UserActualNameAssigns),
	scryList(taskAssignedByTo(Task,Desc,Agent,UserActualName),UserActualNameIsAssigned).

% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/master.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/master.pl').

% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/snail-mail.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/snail-mail.pl').

% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/phone.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/phone.pl').

% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/email.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/email.pl').

% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/in-person.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent/in-person.pl').


% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/contacts/master.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/contacts/master.pl').

% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/contacts/irc_channels.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/contacts/irc_channels.pl').

% :- include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/contacts/bbdb.pl').
% :- prolog_include('/var/lib/myfrdcsa/codebases/internal/audience/data-git/contacts/bbdb.pl').
	
:- load_all_prolog_files_in_directory('/var/lib/myfrdcsa/codebases/internal/audience/data-git/agent').
:- load_all_prolog_files_in_directory('/var/lib/myfrdcsa/codebases/internal/audience/data-git/contacts').

addFeature('have something for audience that catches communications.  for instance, intercept posts about promises to do something or to become more active and caution the user not to make those promises because we always seem to get sidetracked with some new concern').

hasEmail(Agent,Email) :-
	hasPrimaryEmail(Agent,Email).