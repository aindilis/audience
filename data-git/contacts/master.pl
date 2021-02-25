persons([andrewDougherty]).

hasRelatives(andrewDougherty,[]).
hasFriends(andrewDougherty,[]).

%% FIXME: replace this with a proper generalization, with regards to
%% the repeated structure of lists and plurals

hasRelative(PersonA,PersonB) :-
	hasRelatives(PersonA,List),
	member(PersonB,List).

hasFriend(PersonA,PersonB) :-
	hasFriends(PersonA,List),
	member(PersonB,List).

person(Person) :-
	persons(List),
	member(Person,List).

hasAnniversary(Person,birthday,[_-Month-Day],N) :-
	isa(Person,person),
	not(hasAnniversary1(Person,birthday,_)),
	dateOfEvent(birthdayOf(Person),[Year-Month-Day]),
	getCurrentDateTime([Y-M-D,H:Mi:S]),
	N is Y - Year.
hasAnniversary(Person,Topic,[_-Month-Day],_) :-
	hasAnniversary1(Person,Topic,[_-Month-Day]).

hasAnniversary1('<REDACTED>',birthday,[Year-'<REDACTED>'-'<REDACTED>']).

dateOfEvent(birthdayOf('<REDACTED>'),['<REDACTED>'-'<REDACTED>'-'<REDACTED>']).

are([],person).

%% 2019-02-26 11:23:32 <aindilis> anyone know of an industrial strength prolog
%% genealogy database that captures all the nuances of gender, marital and
%% family relationships, etc?  looking to add into Free Life Planner for
%% handling familial relations and reminders of things like birthdays and
%% such.
%% 2019-02-26 11:23:52 *** pie__ (~pie_@unaffiliated/pie-/x-0787662) has quit:
%% Ping timeout: 272 seconds
%% 2019-02-26 11:27:36 <aindilis> also, suppose you have something like
%% "hasAnniversary(Person,Type,[Month-Day])" and also
%% "hasBirthday(Person,[Year-Month-Day])", and you want to have it so that
%% there are both source code entries for hasAnniversary/3, but also you
%% can infer hasAnniversary/3 from hasBirthday/2.  How do you infer it
%% without causing an infinite loop such as if you said
%% hasAnniversary(Person,birthday,[Month-Day]) :-
%% 2019-02-26 11:27:36 <aindilis>
%% isa(Person,person),not(hasAnniversary(Person,birthday,_)),hasBirthday(Person,[_-Month-Day]). <-
%% ?
%% 2019-02-26 11:28:42 <aindilis> the way I've done it is to have the source code
%% entries for hasAnniversary/3 be hasAnniversary1/3.  like
%% hasAnniversary1(andrewDougherty,birthday,[year-month-day]).
%% 2019-02-26 11:29:35 <aindilis> as for the genealogy database, all things like
%% half-siblings, step-parents, marriage, divorce, annulment, etc
%% 2019-02-26 11:30:22 <aindilis> if there is no such resource, does anyone want
%% to write one?  should work with GEDCOM for instance
%% 2019-02-26 11:30:44 <aindilis> *write one with me and add to SWIPL packs
%% 2019-02-26 11:32:28 <aindilis> maybe there is a book with the definitions that
%% someone could point to?
%% ##prolog>
