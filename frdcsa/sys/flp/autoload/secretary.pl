sendEmail([FromEmailAddress,ToEmailAddress,Cc,Bcc,Subject,Body,Attachments,Signature],Result) :-
	(   (	length(Attachments,0)) ->
	    (	AttachmentsArgument = '') ;
	    (	atomic_list_concat(Attachments,' ',AttachmentsList),
		concat_atom(['-a ',ArgumentsList],AttachmentsArgument) )  ),
	(   var(Subject) -> SubjectArgument = '' ; (view([subject,Subject]),atom_concat('-s ',Subject,SubjectArgument))),
	BodyFile = '/tmp/flp-email.txt',
	open(BodyFile,write,Out),
	write(Out,Body),
	close(Out),
	atomic_list_concat(['env EMAIL="', FromEmailAddress, '" mutt -e "set crypt_use_gpgme=no" ',SubjectArgument,' ',AttachmentsArgument,' -- ',ToEmailAddress,' < ',BodyFile],'',ShellCommand),
	view([emailCommand,ShellCommand]),
	(   shell(ShellCommand,Result),view(Result)),
	true.

hasCarrier(phoneNumberFn('<REDACTED>'),'<REDACTED>').

%% https://www.textmagic.com/free-tools/carrier-lookup

map1(PhoneNumber,SMSEmailTemplate) :-
	hasCarrier(phoneNumberFn(PhoneNumber),Carrier),
	map0(Carrier,CarrierProperName),
	map2(CarrierProperName,SMSEmailTemplate).

map0(tMobile,'T-Mobile').
map0(verizon,'Verizon').
map0(allTell,'All Tell').
map0(boost,'Boost').
map0(cellularSouth,'Cellular South').
map0(centennialWireless,'Centennial Wireless').
map0(cincinnatiBell,'Cincinnati Bell').
map0(cricketWireless,'Cricket Wireless').
map0(metroPcs,'Metro PCS').
map0(powertel,'Powertel').
map0(qwest,'Qwest').
map0(rogers,'Rogers').
map0(suncom,'Suncom').
map0(telus,'Telus').
map0(usCellular,'U.S. Cellular').
map0(virginMobileUsa,'Virgin Mobile USA').

map2('T-Mobile','cell-phone-number@tmomail.net').
map2('Verizon','cell-phone-number@vtext.com').
map2('All Tell','cell-phone-number@@message.alltel.com').
map2('Boost','cell-phone-number@myboostmobile.com').
map2('Cellular South','cell-phone-number@csouth1.com').
map2('Centennial Wireless','cell-phone-number@cwemail.com').
map2('Cincinnati Bell','cell-phone-number@gocbw.com').
map2('Cricket Wireless','cell-phone-number@sms.mycricket.com').
map2('Metro PCS','cell-phone-number@mymetropcs.com').
map2('Powertel','cell-phone-number@ptel.net').
map2('Qwest','cell-phone-number@qwestmp.com').
map2('Rogers','cell-phone-number@pcs.rogers.com').
map2('Suncom','cell-phone-number@tms.suncom.com').
map2('Telus','cell-phone-number@msg.telus.com').
map2('U.S. Cellular','cell-phone-number@email.uscc.net').
map2('Virgin Mobile USA','cell-phone-number@vmobl.com').

sendEmailMessage(ToEmailAddresses,Subject,Body,Result) :-
	sendEmail(['<REDACTED>',ToEmailAddresses,[],[],Subject,Body,[],''],Result).

sendTextMessage(PhoneNumbers,Text,Result) :-
	sendTextMessageViaTextBelt(PhoneNumbers,Text,Result).

getEmailForTextMessageRecipientPhoneNumber(PhoneNumber,ToEmailAddress) :-
	isa(PhoneNumber,phoneNumber),
	map1(PhoneNumber,SMSEmailTemplate),
	regex_replace(SMSEmailTemplate,'(cell-phone-number)',PhoneNumber,[],ToEmailAddress),
	view([toEmailAddress,ToEmailAddress]).

sendTextMessageViaEmail(PhoneNumbers,Text,Result) :-
	%% ensure types on all items
	%% ensure the mutt command exists
	member(PhoneNumber,PhoneNumbers),
	getEmailForTextMessageRecipientPhoneNumber(PhoneNumber,ToEmailAddress),
	sendEmail(['<REDACTED>',ToEmailAddress,[],[],'test',Text,[],''],EmailResult),
	%% Result = [emailResult,EmailResult].
	true.

sendTextMessageViaTextBelt(PhoneNumbers,Text,Result) :-
	member(PhoneNumber,PhoneNumbers),
	atomic_list_concat([
			    'curl -X POST http://textbelt.com/text -d number=',PhoneNumber,' -d ''message=',
			   Text,''''
			   ],'',ShellCommand),
	view(ShellCommand),
	(   shell(ShellCommand,Result), view([result,Result])),
	true.

%% duckTypeRegex(phoneNumber). - use that phone number parsing stuff I wrote
%% duckTypeRegex(emailAddress).

isa(PhoneNumber,phoneNumber) :-
	member(PhoneNumber,[]).

isa(EmailAddress,emailAddress) :-
	member(EmailAddress,[]).

%% how to reach someone: by phone call, by text message, by email.
%% over the headset, over speakers.  By displaying something.  By
%% displaying something on their screen.  By locking their phone.  By
%% playing audio on their phone.

%% alexaPushNotification(Arguments) :-
%% 	argt(Arguments,[notification(Notification),alexaDevice(AlexaDevice)]),
%% 	%% try to push to alexa, if we can't, try to push to a
%% 	%% computer in the vicinity, but log that it is less certain
%% 	(   alexaPushNotificationHelper(Arguments) ->
%% 	    true ;
%% 	    pushNotificationToNearestComputer(Arguments)).

%% alexaPushNotificationHelper(Arguments) :-
%% 	argt(Arguments,[notification(Notification),alexaDevice(AlexaDevice)]).

%% pushNotificationToNearestComputer(Arguments) :-
%% 	argt(Arguments,[notification(Notification),alexaDevice(AlexaDevice)]),
%% 	nearestComputersToDevice(AlexaDevice,Computers),
%% 	member(Computer,Computers),
%% 	(   hasSpeakers(Computer),
%% 	    audioVolumeLevel(Computer, VolumeLevel) ),
%% 	pushNotificationToComputer([computer(Computer),notification(Notification)]).
%% 	%% checkForResponseIfTimeAvailable.

%% pushNotificationToComputer(Arguments) :-
%% 	argt(Arguments,[computer(Computer),notification(Notification)]),
%% 	prologAgent(executeCommandOnComputer([computer(Computer),command(Command)])).

sendInstantMessage(IMScreenName,Text,Result) :-
	(   getOption(useAudience,true) -> 
	    %% sendContents('Agent1','Yaswi1','Audience','',[...],Result),
	    queryAgentPerl('Agent1','Yaswi1','Audience','',
			   [
			    '_perl_hash',
			    'IM',[
				  '_perl_hash',
				  'SendMessage',[
						 '_perl_hash',
						 'Recipient',IMScreenName,
						 'Subject','FLP',
						 'Body',Text,
						 'Thread','test',
						 'Priority',10
						]
				 ],
			    '_DoNotLog',1
			   ],
			   Result) ; true).

hasFLPInstantMessageScreenName('<REDACTED>','<REDACTED>').

hasLocation('<REDACTED>','<REDACTED>').

tell(Agent,TmpStatement) :-
	view([1]),
	%% sendInstantMessageToAgent(Agent,TmpStatement),
	view([2]),
	atomic_list_concat(TmpStatement,' ',Statement),
	view([3]),
	hasLocation(Agent,Location),
	view([4]),
	hasLocation(loginFn(UserName,System),Location),
	view([5]),
	view([command,[alexaPushNotification(loginFn(UserName,System),Statement)]]),
	view([6]),
	speak(loginFn(UserName,System),Statement).

speak(loginFn(UserName,System),Statement) :-
	(   getOption(useAlexaPushNotifications,true) ->
	    alexaPushNotification(loginFn(UserName,System),Statement) ;
	    espeakSayText(Statement)).

espeakSayText(Statement) :-
	shell_quote_term(Statement,QStatement),
	atomic_list_concat(['espeak -v mb-en1',QStatement],' ',Command),
	shell_command_async(Command).

sendInstantMessageToAgent(Agent,TmpStatement) :-
	view([1]),
	hasFLPInstantMessageScreenName(Agent,IMScreenName),
	view([2]),
	atomic_list_concat(TmpStatement,' ',Statement),
	%% FIXME: use try here, to avoid stopping if one fails
	view([3]),
	sendInstantMessage(IMScreenName,Statement,Result).

tellAndSendInstantMessageToAgent(Agent,TmpStatement,[Result1,Result2]) :-
	(   tell(Agent,TmpStatement) -> Result1 = true ; Result1 = fail),
	(   sendInstantMessageToAgent(Agent,TmpStatement) -> Result2 = true ; Result2 = fail).

%% wsmHoldsNow(location(Agent,Location))),
%% hasSpeaker(Location,Speaker),
%% hasBluetoothSpeaker(loginFn(UserName,System),Speaker),
%% alexaPushNotification(loginFn(UserName,System),Statement),

%% if she does not respond, try to locate her

isWithinNormalAudibleRange('<REDACTED>','<REDACTED>').

hasPercentage(volumeLevel(loginFn(andrewdo,aiFrdcsaOrg),'analog-stereo'),100.0).
hasPercentage(volumeLevel(loginFn(andrewdo,aiFrdcsaOrg),'blue'),100.0).

hasPercentage(volumeLevel(possessionFn(andrewDougherty,bluetoothSpeaker)),100.0).

amazonEchoDotHasPushNotificationBluetoothSpeaker(andrewDoughertysAmazonEchoDot,andrewDoughertysPushNotificationBluetoothSpeaker).

isConnectedViaBluetooth(aiFrdcsaOrg,andrewDoughertysPushNotificationBluetoothSpeaker).

hasIPAddress(aiFrdcsaOrg,'<REDACTED>').

hasUserNameOnSystem('<REDACTED>',andrewDougherty,andrewdo).


%% try to contact the user, ask them to perform a verification action

hasPercentage(chargeLevel(possessionFn(andrewDougherty,cellPhone)),100.0).

%% if the user hasn't taken the action, either they are unable or
%% unwilling.

%% if unable, perhaps they didn't hear the message

%% if they didn't hear the message, perhaps the remote machines are
%% unable to play it, or perhaps it was played but they were unable to
%% hear it

%% if they were unable to hear it, perhaps there were other noises,
%% perhaps they were not close enough, perhaps they had hearing
%% difficulties, perhaps they were not listening (i.e. asleep,
%% unconscious), perhaps they were away

%% if the machine was unable to play it, perhaps any of the machines
%% in the system were inoperational for whatever reason (for instance,
%% perhaps the )

%% continue this

%% have the capability to ask the user a question and get a verified
%% response

%% FIXME: try adding a feature to call their phone somehow, in an
%% emergency, if they can't be gotten a hold of.

%% always allow for more explanations.  look into model based fault
%% diagnostic system for this.

%% pactl set-sink-mute 0 toggle # to toggle mute



muteDevice(loginFn(UserName,System),AudioSourcePattern) :-
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				'pactl list short sinks | grep ',
				AudioSourcePattern,
				' | awk \'{print \\$1}\' | xargs -I  \'{}\' -s 1000 pactl set-sink-mute \'{}\' 1'
			       ]).

unmuteDevice(loginFn(UserName,System),AudioSourcePattern) :-
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				'pactl list short sinks | grep ',
				AudioSourcePattern,
				' | awk \'{print \\$1}\' | xargs -I  \'{}\' -s 1000 pactl set-sink-mute \'{}\' 0'
			       ]).

setLevel(hasPercentage(volumeLevel(loginFn(UserName,System),AudioSourcePattern),Percentage)) :-
	floor(Percentage,FloorPercentage),
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				'pactl list short sinks | grep ',
				AudioSourcePattern,
				' | awk \'{print \\$1}\' | xargs -I  \'{}\' -s 1000 pactl set-sink-volume \'{}\' ',
				FloorPercentage,
				'%'
			       ]).

mountRemoteFilesystems(loginFn(UserName,System)) :-
	hasIPAddress(System,IP),
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				'echo Rayrocajrad4 | sshfs -o password_stdin andrewdo@173.165.36.101:/ /game -o allow_other'
			       ]).

setLevel(hasPercentage(volumeLevel(loginFn(UserName,System),AudioSourcePattern),Percentage)) :-
	floor(Percentage,FloorPercentage),
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				'pactl list short sinks | grep ',
				AudioSourcePattern,
				' | awk \'{print \\$1}\' | xargs -I  \'{}\' -s 1000 pactl set-sink-volume \'{}\' ',
				FloorPercentage,
				'%'
			       ]).

%% go ahead and have the ability to get the battery level

%% before sending a message to the bluetooth speaker set the volume as
%% needed

%% have it work for aiFrdcsaOrg as well


%% Allow the user to acknowledge when possible through the alexa tts
%% interface.


%% sometimes a person can't talk out loud cause they'd wake someone.
%% Have an interval after which you are increasingly sure the user has
%% not responded.

%% use microphone to determine sound level, like if TV running.

streamAudioFromRemoteMicrophone(loginFn(UserName,System),AudioInputPattern) :-
	maximizeVolumeOnDevice(loginFn(UserName,System),AudioInputPattern),
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				%% 'vlc ...'
				]),
	%% delayed_shell_command_async(5,['mplayer ...']),
	true.

sendFilesViaEmail(Sender,Files,Recipients) :-
	%% figure out how to pack file files into emails
	true,
	%% iterate over recipients, find their emails, and send
	true.

%% hasLogin

micCheck(Login) :-
	maximizeVolumeOnDevice(loginFn(UserName,System),AudioInputPattern),

	%% play a sound on the device, using Alexa, like a bs

	%% notification, and then transcribe the audio recording, or
	%% so some volume detection, or something

	true.

startRecordingAudio(Room) :-
	currentUser(CurrentUser),
	hasLocation(loginFn(UserName,System),Room),
	hasLogin(CurrentUser,loginFn(UserName,System)),
	atomic_list_concat(['/home/',UserName,'/rec-voice-activated.sh'],Command),
	view([command,Command]),
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				Command
			       ]).
	
stopRecordingAudio(Room) :-
	currentUser(CurrentUser),
	hasLocation(loginFn(UserName,System),Room),
	hasLogin(CurrentUser,loginFn(UserName,System)),
	atomic_list_concat(['/home/',UserName,'/stop-rec-voice-activated.sh'],Command),
	view([command,Command]),
	executeCommandOnSystem(loginFn(UserName,System),
			       [
				Command
			       ]).


contactList(andrewDougherty,[]).

maintainCommunicationWithFriends(andrewDougherty) :-
	contactList(andrewDougherty,ContactList),
	member(Contact,ContactList),
	member(Type,[email,instantMessage]),
	%% member(Type,[email,instantMessage(possessionFn(andrewDougherty,cellPhone)),instantMessage(aiFrdcsaOrg),instantMessage(possessionFn(andrewDougherty,tablet))]),
	sendMessageOfType(Type,andrewDougherty,contact(andrewDougherty,Contact)).

sendMessageOfType(instantMessage,Agent,Message) :-
	true.

sendMessageOfType(email,Agent,Message) :-
	hasPrimaryEmailAddress(Agent,Email),
	sendEmail([FromEmailAddress,Email,Cc,Bcc,'incoming message',Message,Attachments,Signature],Result).

tellAgent(CurrentAgent,Agent,TmpStatement) :-
	isa(Agent,doctor),
	currentWSMContext(WSMContext),
	getContextFromWSMContext(WSMContext,Context),
	fassert_argt('Agent1','Yaswi1',[term(tellDoctor(CurrentAgent,Agent,TmpStatement)),context(Context)]).

askAgent(CurrentAgent,Agent,TmpStatement) :-
	isa(Agent,doctor),
	currentWSMContext(WSMContext),
	getContextFromWSMContext(WSMContext,Context),
	fassert_argt('Agent1','Yaswi1',[term(askDoctor(CurrentAgent,Agent,TmpStatement)),context(Context)]).
