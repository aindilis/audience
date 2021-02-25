ask(oneOf(frdcsaAgentFn(akahige),Patient),Doctor,Communication) :-
	tellDoctor(Patient,Doctor,List),
	member(Communication,List).

ask(frdcsaAgentFn(freeLifePlanner),andrewDougherty,hasEffects(task(TaskID,Desc,Importance),obtainAnswerOfType(effectsOfContingency))) :-
	task(TaskID,Desc,Importance).

ask(frdcsaAgentFn(resourceManager),andrewDougherty,hasSource(Item,obtainAnswerOfType(sourceOfItem))) :-
	hasShoppingListItem(Person,Item),
	\+ hasSource(Item,_).

ask(frdcsaAgentFn(resourceManager),Person,decideTruthValue(hasShoppingListItem(andrewDougherty,Item),obtainAnswerOfType(boolean))) :-
	desires(Person,Item),
	\+ hasShoppingListItem(Person,Item).

ask(frdcsaAgentFn(freeWOPR),andrewDougherty,possibleResponse(Contingency,obtainAnswerOfType(responseToContingency))) :-
	unpreparedForContingency(Contingency).

ask(frdcsaAgentFn(freeWOPR),andrewDougherty,hasEffects(Contingency,obtainAnswerOfType(effectsOfContingency))) :-
	unpreparedForContingency(Contingency).

