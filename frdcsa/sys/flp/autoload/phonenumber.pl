numberingPlanAreaCode(A) :-
	parsedPhoneNumberFn(A,_,_).
centralOfficeExchangeCode(B) :-
	parsedPhoneNumberFn(_,B,_).
subscriberNumber(C) :-
	parsedPhoneNumberFn(_,_,C).

parsePhoneNumber(Input,parsedPhoneNumberFn(type(northAmerican),[numberingPlanAreaCode(A),centralOfficeExchangeCode(B),subscriberNumber(C)])) :-
	((integer(Input)) -> (atom_number(PhoneNumber,Input)) ; (PhoneNumber = Input)),
	(split_string(PhoneNumber, '-', '', [A,B,C]) ;
	 split_string(PhoneNumber, ' ', '', [A,B,C]) ;
	 split_string(PhoneNumber, ['-',' '], ['(',')'], [A,B,C]) ;
	 (string_length(PhoneNumber,10),
	  sub_string(PhoneNumber,0,3,_,A),
	  sub_string(PhoneNumber,3,3,_,B),
	  sub_string(PhoneNumber,6,4,_,C))),
	string_length(A,3),
	string_length(B,3),
	string_length(C,4).

%% parsePhoneNumber([A,B,C],parsedPhoneNumberFn(type(northAmerican),[numberingPlanAreaCode(A),centralOfficeExchangeCode(B),subscriberNumber(C)])) :-
%% 	length(A,3),
%% 	length(B,3),
%% 	length(C,4).

parsePhoneNumbers :-
	findall([phoneNumberFn(Y),phoneNumberFn(Sequence)],(get_all_subterms_with_leading_predicate(phoneNumberFn,Matches),member(phoneNumberFn(Y),Matches),nonvar(Y),parsePhoneNumber(Y,ParsedPhoneNumber),getPhoneNumberSequence(ParsedPhoneNumber,Sequence)),Result),
	write_list(Result).

hasParsedPhoneNumber(Agent,ParsedPhoneNumber) :-
	hasPhoneNumber(Agent,phoneNumberFn(PhoneNumber)),
	parsePhoneNumber(PhoneNumber,ParsedPhoneNumber).

getPhoneNumberSequence(ParsedPhoneNumber,Sequence) :-
	ParsedPhoneNumber = parsedPhoneNumberFn(type(northAmerican),[numberingPlanAreaCode(A),centralOfficeExchangeCode(B),subscriberNumber(C)]),
	atomic_list_concat([A,B,C],'',Sequence).

hasPhoneNumberSequence(Agent,Sequence) :-
	hasParsedPhoneNumber(Agent,ParsedPhoneNumber),
	getPhoneNumberSequence(ParsedPhoneNumber,Sequence).