generateStatusBriefingOfType(Agent,whenAsked) :-
	true.

generateStatusBriefingOfType(Agent,afterWakingUp) :-
	true.

generateStatusBriefingOfType(Agent,beforeBedtime) :-
	true.

generateStatusBriefingOfType(Agent,beforeBedtime) :-
	true.

generateStatusBriefingForTopic(finances,Type) :-
	true.

generateStatusBriefingForTopic(banking,Type) :-
	true.

generateStatusBriefingForTopic(billPayment,Type) :-
	true.

generateStatusBriefingForTopic(scheduling,Type) :-
	true.

generateStatusBriefingForTopic(appointments,Type) :-
	true.

generateStatusBriefingForTopic(calendar,Type) :-
	true.

generateStatusBriefingForTopic(food,Type) :-
	true.

generateStatusBriefingForTopic(questionAnswering,Type) :-
	true.

generateStatusBriefingForTopic(desiredFood,Type) :-
	true.

generateStatusBriefingForTopic(individualNeeds,Type) :-
	true.

generateStatusBriefingForTopic(statusBriefingConfiguration,Type) :-
	true.

generateStatusBriefingForTopic(statusBriefingConfiguration,Type) :-
	true.

generateStatusBriefingForTopic(jobSearch,Type) :-
	true.


%% (status briefing
%%  (when asked
%%   (finances
%%    (banking
%%     (what balances are in each account)
%%     )
%%    )
%%   (scheduling
%%    (what appointments later today, tonight or tomorrow)
%%    (what is going on this week)
%%    )
%%   (food
%%    (what are the recommended things to eat today)
%%    )
%%   (question answering
%%    )
%%   )
%%  (after waking up
%%   (finances
%%    (banking
%%     (what balances are in each account)
%%     )
%%    (bill payment, any upcoming bilsl)
%%    )
%%   (scheduling
%%    (what appointments later today, tonight or tomorrow)
%%    (what is going on this week)
%%    )
%%   (food
%%    (what are the recommended things to eat today)
%%    )
%%   (question answering
%%    )
%%   )
%%  (before expected bed time
%%   (finances
%%    (banking
%%     (what balances are in each account)
%%     )
%%    (bill payment, any upcoming bilsl)
%%    )
%%   (scheduling
%%    (what appointments are tonight or tomorrow)
%%    (what is going on this week)
%%    )
%%   (job search
%%    )
%%   (question answering
%%    )
%%   )
%%  )
