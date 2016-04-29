"Threediopolis" by Andrew Schultz

[Note : to compile this into something that will not cause a buffer overflow, Emily Short's Basic Screen Effects should change
			VM_PrintToBuffer(printed_text, 64, str);
to
			VM_PrintToBuffer(printed_text, 70, str);]

[Stuff to search for:

(BR)major, for list manipulation and header stuff
(BR)tof findies (regular mode)
(BR)top scenery progress
(BR)tos scenery
(BR)too table of observies
(BR)tsc table of score comments
(BR)tse table of sad endings
(BR)the table of happy endings
(BR)tol table of lookbys
]

volume 1

the story headline is "A Futuristic Word-Play Gofering"

the story description is "The big city is griddy and gritty. Can you navigate it?"

the release number is 3.

release along with cover art.

[release along with an interpreter.]

Use maximum indexed text length of at least 3000.

Use dynamic memory allocation of at least 16384.

book extensions

include Basic Screen Effects by Emily Short.

include Conditional Undo by Jesse McGrew.

section debug stub

to debug-say (tt - text):
	if debug-state is true:
		say "DEBUG: [tt][line break]";

section get rid of default verbs

understand the command "rub" as something new.
understand the command "burn" as something new.
understand the command "stand" as something new.
understand the command "wave" as something new.

does the player mean drinking the package: it is likely.

instead of drinking:
	say "There are hydration stations all around Threediopolis. You just take them for granted, now."

the block attacking rule is not listed in any rulebook.

check attacking:
	if noun is package:
		say "It's probably got an alarm or something if you get violent." instead;
	if noun is bracelet:
		say "No, it's kind of cool in an ironic sort of way." instead;
	if player carries the noun:
		if noun is availableometer or noun is adrift-a-tron:
			if charges of noun is 0:
				say "You should recycle it later. Or get it recycled." instead;
		say "No, it should be useful. Sorry if you're a bit frustrated!" instead;
	if noun is a quasi-entry:
		say "Force is neither necessary nor appreciated." instead;
	say "Vandalism is an easy crime to detect and prosecute. Camera technology, etc." instead;

section debug extensions - not for release

[include object response tests by Juhana Leinonen. [makes sure certain actions work as intended, checks default]

include property checking by Emily Short. [make sure descriptions are implemented] [commented out for debug-zblorbability]]

section debug-start - not for release

when play begins:
	now debug-state is true;
	say "There is a total of [maximum score] possible things to do. Guess you better get on it!"

every turn (this is the debug-tracking rule):
	[say "[thestring]";]
	do nothing.
	[say "[your-tally].";]

Include (- Switches z; -) after "ICL Commands" in "Output.i6t".

book i6 cool stuff

[thanks to climbingstars for the main code behind the yes/no example. I tweaked some trivial stuff. If you want to change the yes/no defaults, this is a good start. It even tells you if you are using no words or too many. Snaz-zee!]

To set the/-- pronoun it to (O - an object): (- LanguagePronouns-->3 = {O}; -).

chapter allow o

Include (-

[ Keyboard  a_buffer a_table  nw i w w2 x1 x2;
	sline1 = score; sline2 = turns;

	while (true) {
		! Save the start of the buffer, in case "oops" needs to restore it
		for (i=0 : i<64 : i++) oops_workspace->i = a_buffer->i;

		! In case of an array entry corruption that shouldn't happen, but would be
		! disastrous if it did:
		#Ifdef TARGET_ZCODE;
		a_buffer->0 = INPUT_BUFFER_LEN;
		a_table->0 = 15;  ! Allow to split input into this many words
		#Endif; ! TARGET_

		! Print the prompt, and read in the words and dictionary addresses
		PrintPrompt();
		DrawStatusLine();
		KeyboardPrimitive(a_buffer, a_table);

		! Set nw to the number of words
		#Ifdef TARGET_ZCODE; nw = a_table->1; #Ifnot; nw = a_table-->0; #Endif;

		! If the line was blank, get a fresh line
		if (nw == 0) {
			@push etype; etype = BLANKLINE_PE;
			players_command = 100;
			BeginActivity(PRINTING_A_PARSER_ERROR_ACT);
			if (ForActivity(PRINTING_A_PARSER_ERROR_ACT) == false) L__M(##Miscellany,10);
			EndActivity(PRINTING_A_PARSER_ERROR_ACT);
			@pull etype;
			continue;
		}

		! Unless the opening word was OOPS, return
		! Conveniently, a_table-->1 is the first word on both the Z-machine and Glulx

		w = a_table-->1;
		! Undo handling

		if ((w == UNDO1__WD or UNDO3__WD) && (nw==1)) {
			Perform_Undo();
			continue;
		}
		i = VM_Save_Undo();
		#ifdef PREVENT_UNDO; undo_flag = 0; #endif;
		#ifndef PREVENT_UNDO; undo_flag = 2; #endif;
		if (i == -1) undo_flag = 0;
		if (i == 0) undo_flag = 1;
		if (i == 2) {
			VM_RestoreWindowColours();
			VM_Style(SUBHEADER_VMSTY);
			SL_Location(); print "^";
			! print (name) location, "^";
			VM_Style(NORMAL_VMSTY);
			L__M(##Miscellany, 13);
			continue;
		}
		return nw;
	}
];

-) instead of "Reading the Command" in "Parser.i6t"

chapter Ed's question

to decide what number is Ed-blab:
	(- EdBlab() -)

Include (-

Array edMad --> 4 "'Yes or no. Not rocket science.' Whew. He's a bit...direct." "'C'mon, kid, you can't answer an easy yes-no question...'" "'Last chance. No wrong answers. Only two possible.' He's a little upset, but a simple yes/no will probably make him happy." "'Okay, you asked for it. Or you didn't.'";
Array edSilent --> 4 "'Yeah, yeah. Doer not a talker. But I need a simple yes or no.'" "Ed out-silences you into feeling you really should answer yes or no." "With a quizzical frown, Ed moves a hand up, then down. He's a little ticked, but a simple yes/no will change that." "Ed shrugs.";

[ EdBlab i j k;
   k = 0;
   for (::) {
      if (location ~= nothing && parent(player) ~= nothing) DrawStatusLine();
      KeyboardPrimitive(buffer, parse);
      #Ifdef TARGET_ZCODE;
      j = parse->1;
      #Ifnot; ! TARGET_GLULX;
      j = parse-->0;
      #Endif; ! TARGET_
      k++;
      if (j) { ! at least one word entered
         i = parse-->1;
         if (i == YES1__WD or YES2__WD) rtrue;
         if (i == NO1__WD or NO2__WD) rfalse;
		 if (j > 1) { print "'No biographies. Yes or no.'"; }
		 else { print (string) edMad-->k; }
      } else { print (string) edSilent-->k; }
      if (k == 4) return 2;
   }
];

-)

tt is a table name that varies.

chapter transcripting stub

Include (-
[ CheckTranscriptStatus;
#ifdef TARGET_ZCODE;
return ((0-->8) & 1);
#ifnot;
return (gg_scriptstr ~= 0);
#endif;
];
-).

To decide whether currently transcripting: (- CheckTranscriptStatus() -)

ignore-transcript-nag is a truth state that varies.

after reading a command:
	let locom be the player's command in lower case;
	if the player's command matches the regular expression "^\p" or the player's command matches the regular expression "^\*":
		if character number 1 in the player's command is "[bracket]":
			say "Did you mean to hit P?";
			if the player consents:
				try pushing the button instead;
			else:
				say "Ok, you don't need to use brackets, though.";
				reject the player's command;
		if currently transcripting:
			say "Noted.";
			reject the player's command;
		otherwise:
			if ignore-transcript-nag is false:
				say "You've made a comment-style command, but Transcript is off. Type TRANSCRIPT to turn it on, if you wish to make notes. Or if you want to eliminate this nag, for instance if you have an interpreter that does so independently, say yes now.";
				if the player consents:
					now ignore-transcript-nag is true;
				reject the player's command;
	if alpha-look-mode is true or scen-look-mode is true:
		if character number 1 in locom is "x":
			say "You turn away.";
			now saw-see is true;
			now command prompt is ">";
			now alpha-look-mode is false;
			consider the notify score changes rule;
			reject the player's command;
		unless locom matches the regular expression "^<densuw>":
			say "That's not a direction you can move the scope in.";
			reject the player's command;
		eval-dir "[character number 1 in the player's command in upper case]" instead;
	if scen-look-mode is true or look-mode is true or bm-mode is true:
		if locom matches the regular expression "<a-z>":
			say "You need to input a number[if scen-look-mode is true] or direction[end if]--0 will [if bm-mode is true]list your conversation options[else]decline help[end if].";
			reject the player's command;
[	if look-mode is false:
		if the player's command matches the regular expression "^<0-9><0-9>*$":
			if number of characters in locom is 3:
				say "You need to try to walk to that location.";
			else if number of characters in locom < 3:
				say "Too few numbers in that to be a Threediopolis address. Which you should specify how to walk to, anyway.";
			else:
				say "That is outside Threediopolis City Bounds. Fourth-dimensional travel is for spaceports only.";
			reject the player's command;]
	if fast-run is false:
		if number of characters in locom is 2 or number of characters in locom is 3:
			now reserve-command is locom;
			let HH be hash of locom;
			if HH is 108 or HH is 105 or HH is 103 or HH is 8:
				say "[if HH is 108]That's a pretty crazy diagonal direction. You'd crash into something, even with a jetpack[else if HH is 8]It would be more efficient if you could walk through buildings, but they're private property[else]Upward-diagonal directions are possible, but even with a jetpack, you could get ticketed for them[end if]. Did you mean to run these directions in order?";
				if the player consents:
					say "[italic type][bracket]NOTE: you can [one of]always[or]still[stopping] remove this command check for good with J (for jump through diagonals--no argument.[close bracket][roman type][line break]";
					dirparse reserve-command;
				else:
					say "Ok--you can always bypass the two-to-three-letter-command check with J (for jumping.)";
				the rule succeeds;
	now ignore-remaining-dirs is false;
	if the number of characters in locom > 1:
		if locom matches the regular expression "^<ewnsud \.>*$":
			if the player's command matches "see new seens":
				if player has the book:
					say "You don't need this command, since you already have the book.";
					the rule succeeds;
				carry out the newseensing activity;
				if number of characters in your-tally >= 1:
					say "[italic type][bracket]NOTE: I kicked you back to the start[if number of visible quasi-entries > 0] and also removed the place you could've entered. They're all gone now[end if].[close bracket][roman type][line break]";
				now my-table is table of scenery;
				now list-in-status is false;
				reset-game;
				the rule succeeds;
			dirparse locom;
			the rule succeeds;
	let w1 be word number 1 in locom;
	if the w1 is "g" or w1 is "again":
		say "That would actually make getting around in Threediopolis more complex. Because you can't really move from there to here, again, or not that way[if edtasks + pals < 3]. You'll understand once you find a few things--it'd just allow all kinds of extra crazy [italic type]guesses[roman type][else]. Most of the fun stuff would begin with G, though EGGS and DUNG would be left, which is not so fun[end if]. Using one-word directions should be quick enough.";
		reject the player's command;
	if locom matches the regular expression "<\d>+<\p\s>+<\d>+":
		if spacedashwarn is false:
			say "[italic type][bracket]NOTE: instead of typing in two separate numbers, you can just lump them together, in the future.[close bracket][roman type][line break]";
			now spacedashwarn is true;
		replace the regular expression "(<\d>+)<\p\s>+(<\d>+)" in locom with "\1\2";
		change the text of the player's command to locom;

spacedashwarn is a truth state that varies.

section debug variables i still need in release

debug-state is a truth state that varies.

superuser is a truth state that varies.

book undoing

understand the command "undo" as something new.

oopsy-daisy is a number that varies.

rule for deciding whether to allow undo:
	if oopsy-daisy > 0 and oopsy-daisy <= number of rows in table of undo-msgs:
		choose row oopsy-daisy in table of undo-msgs;
		say "[ok-all-right entry][line break]";
		if can-undo entry is true:
			allow undo;
		else:
			deny undo;
	otherwise:
		say "Undeeds won't get you back to where you were. In fact, that's sort of why Ed Dunn hired you[one of]. [italic type][bracket]Fourth wall note: you can undo if you get killed, or you make a truly drastic decision to change cheat devices, but otherwise, you can't. Just push the button on your device to reset your wanderings instead[roman type].[close bracket][roman type][line break][or].[stopping]";
		deny undo;

table of undo-msgs
ok-all-right	can-undo
"Okay, I'll pretend you didn't wait around too long." [zzz]
"Okay, I'll pretend you didn't want to complete the game just yet." [win the game]
"Okay, I'll let you back away from the egress." [END]
"Okay, I'll let you undo the cheat and choose something else." [get availableometer/adrift-a-tron]
"It's a pretty cool cheat-tool, but it's not THAT cool."	false	[backtracking for availableometer/adrift-a-tron]
"Okay, the Sneeds will be glad to wait for you. Even if they caught you lurking around (and they won't,) they'd chalk it up to shyness or whatever!" [Sneeds]
"OK, this gets rid of the book of secrets til later." [undo getting book of secrets]

book when play begins

dee-male is a truth state that varies. dee-male is false.

friends-found is a number that varies. friends-found is 0.

edtasks is a number that varies. edtasks is 0.
pals is a number that varies. pals is 0.
maxedtasks is a number that varies. maxedtasks is 0.
maxpals is a number that varies. maxpals is 0.

secs is a number that varies.

quality is a kind of value. the qualities are chums, biz, party, relax, stuffly, or youish.

begin-rows is a number that varies. end-rows is a number that varies.

salty is a truth state that varies.

to say rhsl:
	if score < maximum score:
		say "[score]/[maximum score] task[if score is not 1]s[end if] done";
	else:
		say "All done, yay"

when play begins (this is the let's get it started rule):
	now my-table is table of findies;
	now maximum score is number of rows in table of findies;
	now right hand status line is "[rhsl]";
	now tt is table of findies;
	repeat through table of findies:
		unless there is a findtype entry:
			now findtype entry is biz;
		if findtype entry is chums:
			increment maxpals;
		else:
			increment maxedtasks;
		now found entry is 0;
		if there is no searchedfor entry:
			now searchedfor entry is 1;
		if there is no breakbefore entry:
			now breakbefore entry is 0;
		if there is no unlist entry:
			now unlist entry is false;
		if there is no descrip entry:
			say "BUG [tally entry] needs descrip.";
	repeat through table of scenery:
		if there is no found entry:
			now found entry is 0;
		if there is no descrip entry:
			say "BUG [tally entry] needs descrip.";
	repeat through table of nearlies:
		if there is no found-yet entry:
			now found-yet entry is false;
		if there is no descrip entry:
			say "BUG [tally entry] needs descrip.";
	repeat through table of undo-msgs:
		if there is no can-undo entry:
			now can-undo entry is true;
	if a random chance of 1 in 2 succeeds:
		now dee-male is true;
	assign-plurals;
	repeat through table of findies:
		now twistiness entry is letfound of tally entry;
	repeat through table of scenery:
		now twistiness entry is letfound of tally entry;
	choose-next-zag;
	now secs is number of rows in table of scenery;
	calibrate-scenery-progress;
	sort table of observies in random order;
	now opposite-direction is southwest;
	now begin-rows is 1;
	now end-rows is 3;
	if a random chance of 1 in 2 succeeds:
		now salty is true;

to choose-next-zag:
	let A be (next-zag + 9) / 10;
	now next-zag is A * 10;
	increase next-zag by a random number from 2 to 10;

to decide which number is letfound of (myt - text):
	let temp be 0;
	let zzz be indexed text;
	now zzz is "[myt]";
	if zzz matches the text "e", case insensitively:
		increment temp;
	if zzz matches the text "u", case insensitively:
		increment temp;
	if zzz matches the text "s", case insensitively:
		increment temp;
	if zzz matches the text "n", case insensitively:
		increment temp;
	if zzz matches the text "w", case insensitively:
		increment temp;
	if zzz matches the text "d", case insensitively:
		increment temp;
	decide on temp;

book stubs and location globals

[I would REALLY like to use ital-say here, but that causes the game to need Glulx.]

your-tally is indexed text that varies.

ns is a number that varies. ew is a number that varies. ud is a number that varies.

to endgame-process:
	let donesies be pals + edtasks;
	choose row with tally of "Deedee" in table of findies;
	say "[if found entry is 0]Ed seems quite upset you weren't able to find Deedee. He knows it was a ways away, but still--well, she will hear of the party[else]Ed nods to you and to Deedee[end if]. ";
	if pals < (maxpals - 1) - found entry:
		say "Then Ed grumbles a bit that you didn't find enough of his friends. The party should still be happening enough. ";
	else if pals is maxpals - 1 - found entry:
		repeat through table of findies:
			if findtype entry is chums and found entry is 0:
				say "'Nice job finding my other friends. Too bad you couldn't find [tally entry in upper case], but they won't be burned out next time.' ";
	else:
		say "'These other friends of mine can keep a party exciting on their own.' ";
	say "[paragraph break]";
	repeat through table of sad endings:
		if stuff-i-did entry >= pals + edtasks:
			now oopsy-daisy is 2;
			say "[eval entry][line break]";
			end the story;
			continue the action;
	say "'[if county of youish is maxy of youish]It's good to see you did all the fun stuff I put in there. I like fun[else]You could've done a little more fun stuff, no guilt[end if].'[paragraph break]Ed hands you some stuff: ";
	say "[if 3 * county of stuffly >= 2 * maxy of stuffly]a Yankees world champs t-shirt from before their 90-year drought[else]an antique zip drive[end if], ";
	say "[if 3 * county of party >= 2 * maxy of party]a big block of dehydrated beer[else]a canister of your least favorite flavor of powdered fruit punch[end if], ";
	say "[if 3 * county of biz >= 2 * maxy of biz]a little extra for helping his business run smoothly[else]a Round Tuit to help you be a bit more business-minded[end if], and a ";
	say "[if 3 * county of relax >= 2 * maxy of relax]CD--yes, a CD--of games Ed assures you are awesome, by some Andrew Schultz guy[else]download code for game 14 in a series that's been stale since #2[end if]. ";
	repeat through the table of happy endings:
		if donesies <= stuff-i-did entry:
			say "[eval entry]";
			now oopsy-daisy is 2;
			if donesies > 20:
				end the story finally;
			else:
				end the story;
			the rule succeeds;
	say "Oops. You scored too high. This is a BUG.";

scenery-sorted is a truth state that varies.

rule for amusing a victorious player:
	say "Have you tried:[line break]";
	repeat through table of stupid jokes:
		say "--[nyuk entry][line break]";
	if eggsfound is secs:
		continue the action;
	let A be 0;
	let left-to-find be 2;
	if secs - eggsfound < 2:
		now left-to-find is secs - eggsfound;
	let word-length be 3;
	while left-to-find > 0 and word-length < 11:
		repeat through table of scenery:
			if number of characters in tally entry is word-length:
				if left-to-find > 0:
					decrement left-to-find;
					say "--[tally entry in upper case]?";
		increment word-length;

to say door-warn:
	choose row with tally of "End" in table of findies;
	if found entry is not 0:
		say " (you will have to restart to see this)";

table of stupid jokes
nyuk
"swearing?"
"Entering the ominous door and ignoring the warning[door-warn]?"
"Z 3 times in a row? Then trying it again?"
"Standard commands like jump/sing (before and after solving a few puzzles)/wave? Oh, XYZZY, too."
"Not answering YES or NO to Ed Dunn four times in a row? (He reacts differently to multi-, one- and zero- word responses.)"
"Visiting Ed Dunn with no tasks done? 1, 4, 7, 10, then every 4 give different responses."
"Just searching through the source code for the table of scenery (for to[if 1 is 1][end if]ss) and table of nearlies (source available on ifarchive.org) to learn all the 'funny' hidden places at once?"

to decide what number is eggsfound:
	let ef be 0;
	repeat through table of scenery:
		if found entry > 0:
			increment ef;
	decide on ef.

zero-ticker is a number that varies. zero-ticker is 0.
plus-ticker is a number that varies. plus-ticker is 0.
base-hint-count is a number that varies. base-hint-count is 0.
hint-iter is a number that varies. hint-iter is 0.

ed-happy-test is a truth state that varies.

to decide what number is force-ed-point:
	choose row with tally of "EdDunn" in table of findies;
	if found entry is 0:
		decide on 1;
	decide on 0;

hint-ever-block is a truth state that varies.

opposite-direction is a direction that varies.

hint-oppo is a truth state that varies.

ignore-susp is a truth state that varies.

just-found is a truth state that varies.

mb-mb-not is a number that varies.

to reset-game:
	now opposite-direction is southwest;
	now ns is 4;
	now ew is 4;
	now ud is 4;
	now drift-this-trip is false;
	let add-to be number of characters in your-tally;
	if add-to >= 8:
		if player does not have book of top secret things:
			if pals + edtasks < 4:
				increment mb-mb-not;
				if mb-mb-not is 2:
					say "Hmm. Maybe you didn't need to walk around so much, or so long. Ed Dunn was brief with you, but he didn't seem cruel. Shorter walks and using the teleport could be better.";
					now mb-mb-not is 0;
	if add-to > 7:
		now add-to is 7;
	if pals + edtasks >= 3 or player has book of top secret things:
		increase plus-ticker by add-to;
	now your-tally is "";
	now all visible quasi-entries are off-stage;
	now ignore-susp is false;
	if door to ed is visible:
		now door to ed is off-stage;
	move player to outside-area;
	if hint-block is false and just-found is false:
		consider the try-a-hint rule;
		if the rule succeeded:
			if hint-ever-block is false:
				now hint-ever-block is true;
				say "[line break]";
				say "[italic type][bracket]NOTE: you can toggle hints like this by typing hh.[close bracket][roman type][line break]";
	now just-found is false;
	if pals + edtasks is 19 + force-ed-point:
		if ed-happy-test is false:
			say "Hmm. You think Ed would be relatively happy enough with what you've done. He mentioned he didn't need perfection. You could probably go see him [if ed-happy-test is false]again [end if]any time, now.[line break]";
			now ed-happy-test is true;
			continue the action;
	if pals + edtasks is 45 - force-ed-point:
		say "Hmm. You've got 90% done. That should be enough for Ed. You hope. There may be some obscure tasks (err, 'stretch goals') in there. You could probably go see him [if ed-happy-test is false]again [end if]any time, now.[if force-ed-point is 1][paragraph break][end if]";

this is the plural-almost rule:
	let needplurals be 0; [I can make this a function, I know]
	repeat through table of plurals:
		if found entry is 1:
			if found corresponding to a tally of mult entry in table of findies is 0:
				increment needplurals;
	if needplurals is 0:
		the rule fails;
	say "You wonder if you didn't almost make it somewhere but you just didn't go far enough...you searched for one instead of many[if needplurals > 1], maybe more than once[end if].";
	the rule succeeds;

table of plurals
sing	mult	found
"dud"	"Duds"	0
"ewe"	"Ewes"	0
"nun"	--	--
"sud"	--	--
"deed"	--	--
"dude"	--	--
"dune"	--	--
"nude"	--	--
"seed"	--	--
"weed"	--	--
"sense"	--	--
"wuss"	"Wusses"	--
"newdud"	--	--
"weenee"	--	--
"useddud"	--	--

to assign-plurals:
	let L be indexed text;
	repeat through table of plurals:
		if there is no found entry:
			now found entry is 0;
		now L is "[sing entry]";
		now mult entry is "[L]s";

this is the try-a-hint rule:
	if player has book of top secret things:
		consider the try-scen-hint rule;
	else:
		consider the try-ed-hint rule;
	if the rule succeeded:
		the rule succeeds;
	the rule fails.

sneed-count is a number that varies.

cheat-ticker is a truth state that varies.

this is the try-scen-hint rule:
	unless cheat-ticker is true:
		if plus-ticker >= 15:
			now plus-ticker is 0;
			now base-hint-count is 0;
		else:
			the rule fails;
	let temp be 0;
	increment sneed-count;
	if sneed-count is 4:
		say "You briefly wonder if you should just call it a day and go take up the Sneeds['] invitation. But, hmm, maybe one more try.";
		now sneed-count is 0;
	repeat through table of scenery:
		if found entry is 0 and twistiness entry < 3:
			increment temp;
	if temp > 0:
		say "Feeling a bit stuck, you consider finding the least twisty place[if temp > 1]s[end if] remaining[if temp > 1], or close to it. You count [temp] total[end if].";
		if temp is 1:
			repeat through table of scenery:
				if twistiness entry < 3 and found entry is 0:
					say "[line break]That place is at [sector-num of tally entry], written up as [descrip entry].";
		the rule succeeds;
	repeat through table of scenery:
		if found entry is 0 and diffic entry is alfhint:
			if temp is 0:
				say "[if temp is 0]You look at the list and see something where you could probably figure out directions to go, if not the order: [else], [end if][descrip entry]";
			increment temp;
	if temp > 0:
		if temp is 1 and found corresponding to a tally of "wenewenew" in table of scenery is 0:
			now hint-long is 1 - hint-long;
			if hint-long is 1:
				say ", which looks long, but the clue [one of]may help[or]looks symmetrical, hmm[stopping].";
				the rule succeeds;
		else:
			say "[if temp > 1]. This is one of [temp in words] such left[end if].";
		the rule succeeds;
	let temp be found corresponding to a tally of "dense" in table of scenery;
	if temp is 0:
		say "You feel a bit less foggy--thick--realizing you could figure the directions to the overpopulated area. The order...it can't be TOO hard.";
		the rule succeeds;
	let temp be found corresponding to a tally of "dunse" in table of scenery + found corresponding to a tally of "swune" in table of scenery;
	if temp < 2:
		say "Hm. There's [if temp is 0]those[else]that[end if] stupid misspelled very twisty one[if temp is 2]s[end if], near. But--you can work out what direction you don't have to go. That must be a help.";
		the rule succeeds;
	let temp be found corresponding to a tally of "seduse" in table of scenery;
	if temp is 0:
		say "That red light district entry is alluring--no, not that way, just--you think you see which way you'd need to double back.";
		the rule succeeds;
	let temp be found corresponding to a tally of "ensue" in table of scenery;
	if temp is 0:
		say "You just sort of let it happen, and you think you see the ways to get to the kinda near place at 546. The order...it can't be TOO hard.";
		the rule succeeds;
	let temp be (4 * found corresponding to a tally of "sweenee" in table of scenery) + (2 * found corresponding to a tally of "sweenee" in table of scenery) + found corresponding to a tally of "sweenee" in table of scenery;
	if temp is 0:
		say "You recall the hot dog stand[if temp > 3] and the guy's name. He'd just moved[else if temp is 3] and its imitators but not its original location[else if temp is 0] and are sure it's had imitators and it also had to move[else] and guess there's probably one more imitator[end if].";
		the rule succeeds;
	let temp be found corresponding to a tally of "sundew" in table of scenery;
	if temp is 0:
		say "Hmm. The plant. Six twisty, six places to go. It'll be a tangle to get there, having to go every which way--but that cuts down the possibilities. You think.";
		the rule succeeds;
	let temp be found corresponding to a tally of "sudden" in table of scenery;
	if temp is 0:
		say "Hm, the BANG is kind of like the Scandinavian vacation, but probably not the same letters. Maybe you can work it out.";
		the rule succeeds;
	let temp be found corresponding to a tally of "deseesed" in table of scenery;
	if temp is 0:
		say "You reflect on the symmetry of life, how you arrive and leave helpless--if you are lucky--despite all medical advances.";
		the rule succeeds;
	let temp be found corresponding to a tally of "dedududu" in table of scenery;
	if temp is 0:
		say "You whistle four notes as you think about what that police clue could possibly mean.";
		the rule succeeds;
	let temp be found corresponding to a tally of "newwessewn" in table of scenery;
	if temp is 0:
		say "You remember some sort of weird suburb that sounded posh, back when you were working through your tasks for Ed. What was it? It's--well, it's not too twisty to get there. You probably can figure how to start. Maybe you should [if set to abbreviated room descriptions]de-zone-out[else]listen a bit more to[end if] the announcements.";
		the rule succeeds;
	let temp be found corresponding to a tally of "senessense" in table of scenery;
	if temp is 0:
		say "You feel you must be going senile, not knowing how those three letters misspell an old folks['] home.";
		the rule succeeds;
	say "Well, this kind of stinks. You're on a real cold streak. Maybe you can figure what to do by looking at your list. Maybe somewhere will make sense that didn't before you found a few other places. The list's getting pretty alphabetized.";
	the rule fails;

hint-long is a number that varies.

this is the try-ed-hint rule:
	let bool be false;
	let found-this-time be 0;
	unless cheat-ticker is true:
		if pals + edtasks < 3:
			increment zero-ticker;
			if zero-ticker is 3:
				say "[one of]You flash back to Ed Dunn's voice booming through your head: 'It's not just where you go but how you get there!' Maybe you can try hitting some of the nearer locations until something turns up[or]You remember nightmares, from when you were a kid, of going one way then back to somewhere totally different[cycling].";
				now zero-ticker is 0;
				the rule succeeds;
			the rule fails;
		if plus-ticker >= 15:
			now plus-ticker is 0;
			now base-hint-count is 0;
		else:
			the rule fails;
	if pals + edtasks < 7:
		say "Frustrating. Maybe if you can pick off some of the nearer tasks in the same location, others will open up[one of][or]. Come to thik of it, you COULD brute force it. But that'd be a lot of walking[stopping].";
		the rule succeeds;
	if edtasks + pals + force-ed-point is number of rows in table of findies:
		say "You're not sure what you're flailing around for. Time to see Ed Dunn.";
		the rule succeeds;
	let acro be found corresponding to a tally of "Edu" in table of findies + found corresponding to a tally of "Dns" in table of findies + found corresponding to a tally of "Nes" in table of findies;
	if acro < 3:
		say "You pick up some static from the teleport device. Ed Dunn is babbling [if acro is 2]a[else]some[end if] three-letter acronym[unless acro is 2]s[end if] you feel half guilty for not understanding. Or not liking and not using. You know you've heard [if acro is 2]it[else]them[end if] before, though.";
		the rule succeeds;
	let sewing be found corresponding to a tally of "Sew" in table of findies + found corresponding to a tally of "Sewn" in table of findies + found corresponding to a tally of "Sewed" in table of findies;
	if sewing < 3:
		say "You wonder if you can thread the needle [if sewing is 2]once more[else if sewing is 1]again[else]somehow[end if] through the streets to mark off a quick task of Ed's.";
		the rule succeeds;
	consider the plural-almost rule;
	if the rule succeeded:
		the rule succeeds;
	let eeds be found corresponding to a tally of "Seeds" in table of findies + found corresponding to a tally of "Deeds" in table of findies + found corresponding to a tally of "Weeds" in table of findies;
	if eeds < 3:
		say "Needs, needs, needs, you mumble to yourself, wondering if there are any you could pick off relatively easily.";
		the rule succeeds;
	repeat through table of findies:
		if diffic entry is deduc and found entry is 0:
			if found-this-time > 0:
				say ", ";
			else:
				say "You note you could figure out the directions to take, here: ";
			say "[descrip entry]@[sector-num of tally entry]";
			increment found-this-time;
	if found-this-time > 0:
		say ".";
		the rule succeeds;
	if found corresponding to a tally of "Wendee" in table of findies is 0:
		if found corresponding to a tally of "Uwe" in table of findies is 1 or task-list is super-alpha:
			now bool is true;
		say "You [if bool is true]are[else]can be pretty[end if] sure of the first letter of that frieend far away";
		if found corresponding to a tally of "Uwe" in table of findies is 0 and task-list is not super-alpha:
			say "--but the friend at 544 may help narrow things down";
		say ".";
		the rule succeeds;
	if task-list is super-alpha:
		repeat through table of findies:
			if diffic entry is alfhint and found entry is 0:
				if found-this-time > 0:
					say ", ";
				else if found-this-time < 6:
					say "You note you could figure out the directions to take, here, now that the list was reorganized: ";
				increment found-this-time;
				say "[descrip entry]@[sector-num of tally entry]";
		if found-this-time > 0:
			say ".";
			the rule succeeds;
	let nunes be found corresponding to a tally of "Nudes" in table of findies + found corresponding to a tally of "Dunes" in table of findies + found corresponding to a tally of "Dudes" in table of findies;
	if nunes < 3:
		say "[one of]Static from the teleport device: Ed Dunn rants against his rival. Nunes, Nunes, Nunes[or]You wonder why Ed Dunn hated Nunes so much[stopping].";
		the rule succeeds;
	let uns be found corresponding to a tally of "Unused" in table of findies + found corresponding to a tally of "Unwed" in table of findies + found corresponding to a tally of "Unseen" in table of findies;
	if uns < 3:
		say "Static from the teleport device has Ed ranting. ";
		if found corresponding to a tally of "Unused" in table of findies is 0:
			say "Being worn out. ";
		if found corresponding to a tally of "Unseen" in table of findies is 0:
			say "Being overexposed. ";
		if found corresponding to a tally of "Unwed" in table of findies is 0:
			say "Being married. ";
		say "[if uns is 1]V[else if uns is 2]Both v[else]All v[end if]ery un-Ed.";
		the rule succeeds;
	if found corresponding to a tally of "Senses" in table of findies is 0:
		say "You overhear some motivational-speak about how some people are more receptive to hearing, some to seeing, some to feeling.";
		the rule succeeds;
	if found corresponding to a tally of "Wedded" in table of findies is 0:
		say "[one of]A very ecological limo tied with balloons and recyclable tin cans rattles by just as you pop back[or]You cringe, hoping that that limo won't reappear[stopping].";
		the rule succeeds;
	let dudsy be found corresponding to a tally of "UsedDuds" in table of findies + found corresponding to a tally of "NewDuds" in table of findies;
	if dudsy < 2:
		say "Interference from the teleport device has Ed talking about building on [if dudsy is 1]one more thing[else]a couple things[end if] you previously [dudsdid] to do something bigger.";
		the rule succeeds;
	if found corresponding to a tally of "Seeweed" in table of findies is 0:
		say "You overhear, over static from your transporter, Ed Dunn claiming [one of]Deedee likes the healthy stuff and the fried stuff. Gee[or]the green food he wants for his party is very un-, un-, hmm, no, that's not it. It's--organic, an extension of one concept, or a useful combination of two others[or]that DeWeese fellow is a culinary genius[cycling].";
		the rule succeeds;
	if found corresponding to a tally of "Weenees" in table of findies is 0:
		say "You overhear Ed Dunn claiming a that hot dog hut owner is really on the level. His prices don't fluctuate up and down. Apparently the guy overuses apostrophe's as well as vowels.";
		the rule succeeds;
	say "Well, this kind of stinks. You're on a real cold streak. Maybe you can figure what to do by looking at your list. Maybe somewhere will make sense that didn't before you found a few other places[random-hint].";
	the rule fails;

to say dudsdid:
	if found corresponding to a tally of "Duds" in table of findies is 0:
		say "could've done";
	else:
		say "did"

to say random-hint:
	increment hint-iter;
	if task-list is alpha and hint-iter is 3:
		now hint-iter is 0;
		say ". Or maybe you could take Ed Dunn up on his offer of help";

to decide which number is the sector-num of (i - indexed text):
	let q be i in lower case;
	let z be 444;
	increase z by number of times q matches the text "e" - number of times q matches the text "w";
	increase z by 10 * (number of times q matches the text "n" - number of times q matches the text "s");
	increase z by 100 * (number of times q matches the text "u" - number of times q matches the text "d");
	decide on z;

chapter transport tubes

the transport tubes are a backdrop. the transport tubes are everywhere. "It's rude to stare while people zoom up and down."

instead of doing something other than examining transport tubes:
	if current action is entering:
		say "But which way? Up or down?" instead;
	say "The tubes aren't worth thinking much about. You just need to get places."

chapter going

instead of exiting:
	say "Out? Of Threediopolis? You would be arrested for absconding with that package sooner or later.";

to dirsmack:
	say "In these efficient days, people find using more than one letter for a direction too flowery.[line break]";

before going (this is the don't waste my time with all those extra letters already now rule):
	if word number 1 in the player's command in lower case is "go":
		say "In these sped-up days, the word 'go' is superfluous. Unless you are in charge, like Ed Dunn.'" instead;
	if the player's command matches the text "north", case insensitively:
		dirsmack instead;
	if the player's command matches the text "south", case insensitively:
		dirsmack instead;
	if the player's command matches the text "east", case insensitively:
		dirsmack instead;
	if the player's command matches the text "west", case insensitively:
		dirsmack instead;
	if the player's command matches the text "up", case insensitively:
		dirsmack instead;
	if the player's command matches the text "down", case insensitively:
		dirsmack instead;

chapter no noun needed

Rule for printing a parser error when the latest parser error is the only understood as far as error: [I can't do better as "[word number 1]" comes up blank]
	say "That command doesn't need more than one letter. You may wish to retry without the second word.";

chapter blank parser

Rule for printing a parser error when the latest parser error is the can't see any such thing error:
	repeat through table of scenery:
		if your-tally is tally entry:
			say "Whatever you just saw is gone now--thankfully, it wasn't critical, even though it was kind of interesting.";
			the rule succeeds;
	say "Nothing like that is here[one of]. If you just saw something in the background, it was there for local flavor[or][stopping][if player has book][one of]. Plus, your score goes up when you find scenery, now[or][stopping][end if].";
	the rule succeeds;

hint-index is a number that varies.

max-skips is a number that varies. max-skips is 4.

skip-index is a number that varies. skip-index is 1.

to decide which number is ronum of (iitt - indexed text):
	let locom be iitt in lower case;
	if character number 1 in locom is "d", decide on 1;
	if character number 1 in locom is "e", decide on 2;
	if character number 1 in locom is "n", decide on 3;
	if player has task-list and task-list is super-alpha:
		if character number 1 in locom is "u", decide on 6;
		if character number 1 in locom is "w", decide on 7;
		if character number 2 in locom is "e", decide on 4;
		decide on 5; [SE = 4, S* = 5]
	if character number 1 in locom is "s", decide on 4;
	if character number 1 in locom is "u", decide on 5;
	if character number 1 in locom is "w", decide on 6;
	decide on 0;

Rule for printing a parser error when the latest parser error is the I beg your pardon error:
	let cur-row be 0;
	let cur-row-2 be 0;
	let skips-so-far be 0;
	let poss-skips be max-skips;
	let remainin be number of rows in table of findies - (edtasks + pals + force-ed-point);
	if bm-mode is true:
		say "It's hard to plan ahead with the suspicious guy all in your personal space. Type 0 to see a list of conversation choices." instead;
	if player has book:
		now remainin is secs - eggsfound;
	if poss-skips > remainin:
		now poss-skips is remainin;
	if poss-skips is 0:
		if the door to the sneed house is visible or door to ed is visible:
			say "You've got nothing else to do. You really should walk in." instead;
		say "You hesitate, noting you have nothing left to do on your list. You probably want to go [if player has book]visit the Sneeds[else]back to Ed Dunn[end if] now." instead;
	if scen-look-mode is true or look-mode is true:
		say "The telescope is too distracting! It's so much higher-tech than your list, but you can leave by typing 0." instead;
	if there is a visible quasi-entry:
		if your-tally is not "see" and your-tally is not "eddunn" and your-tally is not "sneeds":
			say "Something's right here! You can just [if front door is visible]knock[else]enter[end if]." instead;
		say "There's something nearby, but you still pick something at random from your notes.";
	increment skip-index;
	if skip-index > poss-skips:
		now skip-index is 1;
		debug-say "Note: wrapping.";
	if debug-state is true:
		say "DEBUG: [skip-index] index, [poss-skips] possible skips, [max-skips] max skips, [remainin] remaining.";
	if player has book:
		repeat with disnum running from 3 to 10:
			repeat through table of scenery:
				increment cur-row;
				if number of characters in tally entry is disnum and found entry is 0:
					increment skips-so-far;
					if skips-so-far is skip-index:
						say "[what-next]. Hmm... '[descrip entry] at [sector-num of tally entry]' in row [ronum of tally entry] looks (relatively) not too bad. ";
		if twistx is false:
			say "[line break]" instead;
		now skips-so-far is 0;
		repeat with twi running from 1 to 6:
			repeat through table of scenery:
				increment cur-row-2;
				if twistiness entry is twi and found entry is 0:
					increment skips-so-far;
					if skips-so-far is skip-index:
						say "[if cur-row-2 is cur-row]It also looks not-too-twisty[else]Also, '[descrip entry]' at [sector-num of tally entry] is not too twisty[end if].";
		the rule succeeds;
	if task-list is not super-alpha:
		repeat through table of findies:
			if found entry is 0:
				increment skips-so-far;
				if skips-so-far is skip-index:
					say "[what-next]. Hmm... '[descrip entry] at [sector-num of tally entry]' is as good as any. It is [nearness of tally entry]." instead;
	repeat with disnum running from 3 to 8:
		repeat through table of findies:
			if number of characters in tally entry is disnum and found entry is 0:
				increment skips-so-far;
				if skips-so-far is skip-index:
					say "[what-next]. Hmm... '[descrip entry] at [sector-num of tally entry]' in row [ronum of tally entry] is as good as any. It is [nearness of tally entry]." instead;
	say "You plot which direction to go next. Some bug behind the fourth wall, sadly, prevents you from having any concrete ideas." instead;

to say what-next: [?! this is a disaster if the player trolls and finds the tough ones first]
	say "[if player has book and eggsfound < 40]Okay. Still near stuff to pick off[else if player has book]Hmm, maybe you've narrowed down the way to places you left til later[else if edtasks + pals < 25]Still got a good bit of nearby tasks[else]Some toughies left[end if]"

boxed-showed is a truth state that varies.

Rule for printing a parser error when the latest parser error is the didn't understand error:
	say "[reject]";
	if boxed-showed is false and list-in-status is true::
		now boxed-showed is true;
		display the boxed quotation "
		'I've always enjoyed going north. Of course,
		south-west is a fine direction, too.'

		-- E. B. White, Stuart Little";

to say reject:
	say "Being a messenger, you don't have much more to do than go in the six basic directions (transport tubes make going up and down easy.) Or enter places. Maybe knock. Nothing fancy. Type C to see everything you can do."

chapter cing

cing is an action out of world.

understand the command "c" as something new.

understand "c" as cing.

to say my-thing:
	if player has availableometer:
		say "availableometer";
	else:
		say "adrift-a-tron";

carry out cing:
	say "[bracket]All commands are case insensitive[close bracket][paragraph break]The six directions, abbreviated: N, S, E, W, U, D. K knocks. I/IN goes in (inventory doesn't change much so I trumps INVENTORY when you can enter.)[line break][if player has availableometer or player has adrift-a-tron]A=use your [my-thing][line break][end if]B=brief V=verbose C=this command[line break][if pals < 9 and player does not have book]F=friends left FF=friends in header [end if]I=inventory [if player does not have book]O=one line of by-length list OO=one line in header [end if][if task-list is super-alpha and player does not have book]M=move to line (1-7) MM new list[end if] X=all the list[line break]H=hint, HH=hint toggle[line break]P pushes the panic button to send you to sector 444. [if player has book of top secret things]PP makes this the default when finding scenery.[line break]R shows the nearest, first-in-alphabet unvisited place, R # (up to 9) shows the next 9. XX makes twistiness for solved items disappear.[run paragraph on][end if][line break]J=jump mode to toggle diagonal warning.[line break][if player does not have book]T toggles big long listing in the status bar. [end if]X (#) reads one line, X (24) reads (for example) lines 2-4.[line break]Z waits.[line break]Typing no command circles through some of the nearer places you still need to visit.[line break]";
	the rule succeeds;

book list in status

list-in-status is a truth state that varies.

hpos is a number that varies.

rule for constructing the status line when task-list is detail-header:
	deepen the status line to expected-depth + 1 rows;
	center "Threediopolis, Sector [ud][ns][ew]: [scoreboard]" at row 1;
	if player has book of top secret things:
		write-scen-details;
	else:
		write-details;

to write-scen-details:
	let Q2 be 0;
	let startstring be "a";
	let listed-last be true;
	let sz be 3;
	let rowlist be { 0 };
	let inlist be 0;
	let cur-row be 1;
	remove entry 1 from rowlist;
	move the cursor to 2;
	while sz <= 10 and inlist < expected-depth:
		now cur-row is 1;
		repeat through table of scenery:
			if found entry is 0 and number of characters in tally entry is sz and inlist < expected-depth:
				add cur-row to rowlist;
				increment inlist;
			increment cur-row;
		increment sz;
	now Q2 is 1;
	repeat with myvar running through rowlist:
		choose row myvar in table of scenery;
		say "[if Q2 > 1 or expected-depth > 1][Q2]. [end if][prev-string of myvar] < [descrip entry]@[sector-num of tally entry][twistrate of twistiness entry] ([nearness of tally entry]) < [post-string of myvar][line break]";
		increment Q2;
[	repeat through table of scenery:
		if found entry is 0:
			increment Q2;
			if Q2 > 1:
				say "[line break]";
			say "[if Q2 > 1 or expected-depth >= 2][Q2]. [end if] [startstring] < @[sector-num of tally entry]: [descrip entry], [nearness of tally entry]";
			now listed-last is true;
			if Q2 is expected-depth:
				continue the action;
		else:
			if listed-last is true:
				say " < [tally entry]";
			now startstring is tally entry;
			now listed-last is false;]

to say prev-string of (n - a number):
	let y be n - 1;
	let aa be indexed text;
	choose row n in the table of scenery;
	now aa is "[character number 1 in tally entry]";
	while y > 0:
		choose row y in the table of scenery;
		if character number 1 in tally entry is not aa:
			say "[aa]";
			continue the action;
		if found entry is 1:
			say "[tally entry]";
			continue the action;
		decrement y;
	say "[aa]";

to say post-string of (n - a number):
	let y be n + 1;
	let aa be indexed text;
	choose row n in the table of scenery;
	now aa is "[character number 1 in tally entry]";
	while y <= number of rows in the table of scenery:
		choose row y in the table of scenery;
		if character number 1 in tally entry is not aa:
			say "[aa]z";
			continue the action;
		if found entry is 1:
			say "[tally entry]";
			continue the action;
		increment y;
	say "[aa]z";

to write-details:
	let Q2 be 0;
	move the cursor to 2;
	repeat through table of findies:
		if found entry is 0 and findtype entry is not chums and Q2 < expected-depth and tally entry is not "EdDunn":
			increment Q2;
			say "[if Q2 > 1 or expected-depth >= 2][Q2]. [end if]@[sector-num of tally entry]: [descrip entry], [nearness of tally entry]";
			if Q2 is expected-depth:
				continue the action;
			else:
				say "[line break]";
	say "(Oh, man! You are getting close.)";

rule for constructing the status line when task-list is byrow-header:
	if list-in-status is true:
		deepen the status line to 1 rows;
	center "@[sector-num of your-tally]|[thisrow of cur-byrow]" at row 1;
	the rule succeeds;

rule for constructing the status line when task-list is friend-header:
	if list-in-status is true:
		deepen the status line to 1 rows;
	center "@[sector-num of your-tally]|[pal-list]" at row 1;
	the rule succeeds;

to say one-list:
	let myt be my-chars;
	let count be 0;
	if myt is 0:
		say "You got everything!";
		continue the action;
	say "[entry myt of farsies]: ";
	repeat through table of findies:
		if number of characters in tally entry is myt and findtype entry is not chums:
			if count > 0:
				say "/";
			increment count;
			say "[if found entry is not 0][tally entry][else][sector-num of tally entry][end if]";

rule for constructing the status line when task-list is oneline-header:
	center "@[sector-num of your-tally]|[one-list]" at row 1;
	the rule succeeds;

rule for constructing the status line when list-in-status is false:
	if player does not have task-list and player does not have book:
		center "See Ed Dunn!";
		the rule succeeds;
	deepen the status line to 1 rows;
	center "Threediopolis, Sector [ud][ns][ew]: [scoreboard]" at row 1;
	the rule succeeds;

maxhrows is a number that varies. maxhrows is 18.
maxalphrows is a number that varies. maxalphrows is 18.
maxrrows is a number that varies. maxrrows is 18.

thisheaderbreak is a number that varies. thisheaderbreak is 0.

rule for constructing the status line when list-in-status is true (this is the major header wrangling rule):
	now in-header is true;
	if task-list is super-alpha or player has book of top secret things:
		deepen the status line to maxalphrows rows;
	else:
		deepen the status line to maxrrows rows;
	center "[if player has book of top]SEENS SEEN/UNSEEN[else]ED DUNN'S NEEDS[end if] [bracket][scoreboard][close bracket]" at row 1;
	if task-list is super-alpha or player has book of top secret things:
		now hpos is 0;
		super-alpha-it;
		now in-header is false;
		the rule succeeds;
	else:
		now hpos is 0;
		unalpha-it;
		now in-header is false;
		the rule succeeds;

to say scoreboard:
	if player has book of top secret things:
		say "[if eggsfound is secs]You found all the secrets![run paragraph on][else][eggsfound]/[secs] secrets found[end if]";
	else:
		if pals is maxpals and edtasks is maxedtasks:
			say "All friends found, all tasks done!";
		else:
			say "[pals]/[maxpals] pals found, [edtasks]/[maxedtasks] tasks done";

book silly defaults

instead of singing:
	say "[if player has book or pals + edtasks > 2]Dee dee dee, dee dee dee[else]You try, but you only hear two notes in your head[end if]."

instead of swearing obscenely or swearing mildly:
	say "Dude! Eww."

book dropping

instead of dropping:
	if noun is task-list:
		say "Drop the task list? But it has all the clues of what you need to do!";
	else if noun is device:
		say "No way! Those things are valuable.";
	else if noun is mysterious package:
		say "You'd be flaking out at your job, doing that. No way!";
	else if noun is the player:
		say "Hmm, no.";
	else if noun is carried or noun is held:
		say "Littering is no good.";
	else:
		say "You probably can't take that, much less drop it."

does the player mean dropping the task-list: it is very likely.

book verbose-brief

Understand "v" as preferring unabbreviated room descriptions.

Understand "b" as preferring abbreviated room descriptions.

book restart-quit

understand "q" as quitting the game.

check quitting the game:
	if player has book:
		say "Maybe, instead of quitting, you should go back and see Deedee and Sed Sneed?";
		if the player consents:
			say "Ok, shouldn't be too hard to walk there." instead;
	else:
		continue the action;
	if pals + edtasks is 0:
		say "Well, this stinks. You just couldn't figure out how to wander about to find anything for Ed Dunn. Maybe he will find someone else. Maybe you've been missing something.";
	else if pals + edtasks > 5:
		say "Before quitting, would you like a list of everything you've found so far, in case you want to change difficulty level?";
		if the player consents:
			print-so-far;

check restarting the game:
	if pals + edtasks > 5:
		if player does not have book:
			say "Before restarting, would you like a list of everything you've found so far, in case you are restarting to change difficulty level?";
			if the player consents:
				print-so-far;

to print-so-far:
	repeat through table of findies:
		if found entry is 1:
			say "[one of][or], [stopping][tally entry]";
	say ".";

book items

chapter task-list

the task-list is a privately-named thing. the printed name of task-list is "list of needs". understand "list/needs" and "list of needs" as the task-list.

the verso is part of the task-list. description is "[bug]"

verso-examine is a truth state that varies.

check examining verso:
	if task-list is not super-alpha:
		say "There's nothing on the back of the list, yet." instead;
	if player has book:
		say "The book is more important now.";
	now verso-examine is true;
	try examining task-list;
	now verso-examine is false instead;

instead of doing something other than examining the verso:
	say "There's really nothing else to do with the verso besides examining it."

task-list can be twisty. task-list is not twisty.

task-list can be super-alpha, alpha or kinda-random. task-list is super-alpha.

task-list can be reg-header, friend-header, byrow-header, detail-header or oneline-header.

description of task-list is "BUG should be kicked elsewhere."

does the player mean opening the task-list: it is very unlikely.

instead of doing anything other than examining or dropping task-list:
	say "It's just a list. No need to do anything exotic.";

list-note is a truth state that varies.

check examining the task-list when list-note is false:
	if the player's command matches the regular expression "list", case insensitively:
		now list-note is true;
		say "[italic type][bracket]NOTE: you can just type X to re-examine the list.[close bracket][roman type][line break]";

task-x is a truth state that varies.

after examining the task-list for the first time:
	now task-x is true;
	if score is 0:
		say "You think a moment. Some of these locations listed twice, there has to be something if you just walk right there. Especially the ones nearby.";
	continue the action.

does the player mean examining the task-list: it is likely.

does the player mean examining the book of secret: it is very likely.

chapter x0ing

x0ing is an action applying to one number.

understand "x [number]" as x0ing.

to say x0in:
	say "You need to specify a one- or two-digit number with digits between 1 and [listrows].";

carry out x0ing:
	let a be the number understood / 10;
	let b be the remainder after dividing number understood by 10;
	let ot1 be 0;
	let ot2 be 0;
	if number understood < 1 or number understood > 100:
		say "You need to specify a one- or two-digit number with digits between 1 and [listrows]." instead;
	if a is 0:
		if b < 1 or a > listrows:
			say "You can read rows 1-[listrows]." instead;
		now ot1 is begin-rows;
		now ot2 is end-rows;
		now begin-rows is b;
		now end-rows is b;
		say "(temporarily reading just row [b])";
	else:
		if a > listrows or b > listrows or b is 0:
			say "[x0in]" instead;
		if a > b:
			say "The start row, [a], is larger than the end row, [b]. Did you intend to look from row [b] to [a]?";
			if the player consents:
				say "Okay, reading rows [b] to [a].";
				now begin-rows is b;
				now end-rows is a;
			else:
				say "Okay. Doing nothing." instead;
		else if a is b:
			say "Fixing row [a] next time you examine. Note that x [a] is as effective as x [a][a] if you want to see that row once.";
			now begin-rows is b;
			now end-rows is a;
		else:
			now begin-rows is a;
			now end-rows is b;
	if player has book:
		if dont-examine is false:
			try examining book;
		if list-in-status is true:
			now maxalphrows is 18;
	else if player has task-list:
		if dont-examine is false:
			try examining task-list;
	else:
		say "BUG! You have neither book nor task list." instead;
	if b is 0:
		now begin-rows is ot1;
		now end-rows is ot2;

to decide what number is listrows:
	if player has book:
		decide on 6;
	decide on 7;

chapter button

description of the pocket teleporter device is "It's got a button you can push. You're reminded how, with so many buttons to push in Threediopolis, the letter 'p' is a verb meaning 'push the button.'";

the button is part of the pocket teleporter device.

description of the button is "It looks as pushable as any other button, you'd guess."

check pushing the button:
	if ns is 4 and ew is 4 and ud is 4:
		if your-tally is "":
			say "Pushing the button would be kind of pointless here. Well, technically, here and now." instead;
		say "You feel a bit disoriented. You're in the same place, and yet you're not. But you feel refreshed and ready for your next journey.";
		reset-game instead;
	if number of characters in your-tally < 2:
		say "You have heard about teleporter overheat. It's quite a way to go. Maybe you should walk around a bit[if number of characters in your-tally is 1] more[end if]." instead;
	if there is a visible quasi-entry:
		if sneed house is not visible:
			say "Are you sure? You found a place to visit!";
			if the player consents:
				do nothing;
			else:
				say "OK.";
				the rule succeeds;
	say "[one of]Teleporting technology, apparently only for the very richest people,[or]Your trusty teleporter[stopping] kicks you back to the [one of][or]not-quite-[stopping]center of the city[one of]--well, it used to be, til it expanded north, east and up back in 2140. [italic type]YOU[roman type] still think of it that way.[paragraph break]Your employer must really be loaded, especially since your gadget doesn't have or need a full/empty gauge on it[or][stopping].";
	reset-game instead;

instead of switching on teleporter device:
	try pushing the button instead;

instead of pushing teleporter device:
	try pushing the button instead;

chapter ping

ping is an action applying to nothing.

understand the command "p" as something new.

understand "p" as ping.

carry out ping:
	try pushing the button instead;

chapter teleporter device

chapter mysterious package

the mysterious package is a thing. description of mysterious package is "You see nothing special about the mysterious package. But you bet there's something special under that newfangled top-open-secret material that can hold things several times its size if necessary. Quantum physics is crazy."

instead of opening mysterious package:
	say "It's mysterious enough you're worried something bad will happen before you take it where you need to go."

instead of searching mysterious package:
	say "That'd be rude."

book when play begins

to first-status: (- DrawStatusLine(); -);

when play begins (this is the employer-intro rule):
	change the prevent undo flag to true;
	first-status;
	say "Threediopolis was the first city to have different sidewalk levels, one above another, back in 2050. It's pretty normal now in 2100, but they didn't plan everything right back then, so Threediopolis is still a bit quirky.[paragraph break]You still get lost some days, like today--while remembering a traumatic episode from your youth (adults yelling at you for somehow getting lost on a simple errand) you run across a building you've never seen. You enter and are whisked to a penthouse office. A fellow wearing a fractal power-tie and a white button-down shirt with elbow patches jumps up.[paragraph break]'Ah! You answered my online ad! What? No? You didn't? Even better! You're a natural! Unpoisoned by GPS! Just what I need! It's not anyone can find here. I'm Ed Dunn. You are? ...'[wfak]";
	say "[paragraph break]Before you can answer, Ed hands you a list of tasks, an equally mysterious package you're told not to open, and a pocket teleporter device, for getting back if you get even more lost than you need to.[paragraph break]'Getting here was the hard part, kid. Some places, like here, UncountableCo doesn't track. And if you don't get everything on this list done before you get back here, that's okay.'[paragraph break]Before you can ask what list, Ed makes a hush-hush gesture. 'It's organized by travel time, kid. Or it should be, once you find how to use it. Don't worry, just--don't lose it.'[paragraph break]He explains how some things just don't need to be traced electronically, and how there's lots of weird scenery to see if you're interested in that sort of thing, and since you got here without knowing, you couldn't get anywhere on the list WITH knowing.[paragraph break]'Knowing what...?'[paragraph break]'One other thing, kid. You might want to use that teleporter pretty quickly if you don't see anything to start. Say, no further than five blocks. Til you get your bearings.'[paragraph break]Ed stares at his computer, then snaps his fingers. 'Oh, hey, I should push this button. Alphabetize this whole list, sort of. Make things easier for the rookie. What do you say?' ";
	say "[italic type][bracket]NOTE: if you haven't played before, I strongly recommend you take the hints by saying YES.[close bracket][roman type][line break]";
	let qq be Ed-Blab;
	if qq is 1:
		now task-list is alpha;
	else if qq is 0:
		now task-list is kinda-random;
	else:
		say "[paragraph break]'You'll never know what you missed out on, kid. Not even answering a simple yes/no question.' Ed Dunn is a busy man, but he has time to chew you out. He complains how you just aren't the sort of flaky and whimsical he needs for the job until he finds someone else to order around. You are escorted out.";
		end the story;
		consider the shutdown rules;
	say "'Got it. You look smart enough to [if task-list is kinda-random]take the extra challenge.[no line break][else]know the value of a little organization. Now they're in order, you don't NEED to do [']em in order, cuz if you know the ones you don't know are in order, that's a hint. Hey, stop on back if you need an extra hint, eh?[no line break][end if]'[paragraph break]Pep talk time. 'You got potential. You seem like someone who knows it's not just getting there, but HOW you get there.' You've heard that truism before...but does it mean anything? You have no time to ask. Security whisks you away as Ed booms 'And keep with it. Note what you found. Don't worry about the order, either!'[paragraph break]It's not a huge list. You even have addresses of where to go. It can't be too hard, can it?";
	now ns is 4;
	now ew is 4;
	now ud is 4;
	now the player has the task-list;
	now the player has the pocket teleporter device;
	now the player has the mysterious package;
	pause the game;
	now left hand status line is "[location of the player]"

to re-randomize:
	repeat through table of findies:
		if there is a rand-score entry:
			if rand-score entry is 0:
				now rand-score entry is a random number between 0 and 99;
		else:
			let Q be a random number between 0 and 99;
			increase  Q by 100 * number of characters in tally entry;
			now rand-score entry is Q;
	let R be -1;
	sort table of findies in rand-score order;
	repeat through table of findies:
		let Q be rand-score entry / 100;
		if Q > R:
			now R is Q;
			now breakbefore entry is 1;
		else:
			now breakbefore entry is 0;

description of player is "You are dressed in clothes similar in style to one hundred years ago, except for their name brand and their biodegradability. I mean, they don't degrade while you wear them. There are special enzymes. At a garbage plant."

book outside area

outside-area is a privately-named room. Printed name of outside-area is "Threediopolis, Sector [ud][ns][ew]"

after printing the locale description of outside-area when outside-area is unvisited:
	say "You glance quickly at Ed Dunn's list: some things are in sector 444, but you can't see anything resembling them. ";
	say "[italic type][bracket]NOTE: the room descriptions are random and for amusement only. Type B to get rid of them or V to have them appear again. A different note will appear once you've seen them all.[close bracket][roman type][line break]";

description of outside-area is "[if number of characters in your-tally is 0]Everything here sort of looks like everything else and doesn't at the same time. Going one direction seems as good as going any other.[otherwise][blahdeblah][run paragraph on][end if]"


the block waking up rule is not listed in any rulebook.

the block listening rule is not listed in any rulebook.

the block jumping rule is not listed in any rulebook.

check waking up:
	say "But you have not been sleeping on the job." instead;

check listening:
	say "The sounds of Threediopolis are always changing. But you don't want them distracting you from your job." instead;

instead of eating:
	say "Are you hungry for a meal, or a job that'll buy several of them? Get back to wandering.";

the block kissing rule is not listed in any rulebook.

instead of kissing:
	say "You aren't looking for romance, here.";

instead of climbing:
	say "Why climb when there are transport tubes?"

to say blahdeblah:
	if a random chance of 1 in 2 succeeds:
		increment losties-count;
		if losties-count > number of rows in table of losties:
			now losties-count is 1;
			now losties-flip is true;
		choose row losties-count in table of losties;
		say "[blurb entry]";
	else:
		increment observies-count;
		if observies-count > number of rows in table of observies:
			if observies-flip is false:
				say "A jetskateboarder blasting Dude U Need by Eddee Dee pulls up. It fades out, and Sue's Dude by Sunnee and Dussdee Dessens starts. Ouch. Double Whammy. ";
				say "[italic type][bracket]NOTE: you've seen all the random stuff Threediopolis has to offer, so you may want to request (B)rief if you want to. I won't, like, deduct a sneaky point or anything.[close bracket][roman type][line break]";
				now observies-flip is true;
				now observies-count is 0;
				continue the action;
			now observies-count is 1;
		choose row observies-count in table of observies;
		say "[blurb entry]";

allthru-warn is a truth state that varies.

table of losties
blurb
"You may or may not have wandered down this block before."
"You note a three-way street sign: Avenue [dig of ud][ns], Street [dig of ud][ew], Updownway [dig of ns][ew]."
"You're lost, or maybe you're not. It's so hard to know, for sure. Everything looks the same as elsewhere, yet different at the same time."
"You're unable to tell if this is a neighborhood you really should avoid or one you should know back and forth."

losties-flip is a truth state that varies.

losties-count is a number that varies.

table of observies [too]
blurb
"An ad hoc politician discusses the proposed 'stupid tax,' and if it should apply to people who don't use their smarts for social good like clever conversations, too."
"An ambulance flashes by. Seconds later, you hear 'Learning pills!' 'Overdose? Or mixed with memory pills?' then a side argument whether those things work."
"An argument between freelance grammar and pronunciation police includes constant interruptions."
"'Attention citizens! Public transport to the New Wessewn sector has been discontinued until further notice.'"
"'Attention Threediopolis walkers! Would you like to afford a car to tune out announcements like these? The Department of Commerce can help...'"
"A cheery voice announces: 'Attention potential scofflaws! One-way sidewalks delegitimize jaywalking, except in extreme emergencies!'"
"A computer executive recalls how he hazed a new worker over dire threats of Y2K1 bugs. Hilarious stuff!"
"'Dad, was Grampa more annoying than you when he said you kids don't know how easy you have it?'"
"A Department of Revenue camera flashes--prima facie evidence a pedestrian finished crossing the street too late--and an audio-ad gives financial service advice for people with trouble paying tickets."
"A dork is beaten up for insisting on 2050[']s spelling and pronunciation and grammar. He protests at least he's not 20th century, but it does no good."
"Dork-on-dork crime! A kid who can memorize fifteen-digit IDs is verbally abused by those who use their memory for more research-worthy things."
"A driver shows a police officer his u-turn permit and goes on his way."
"A drug addict and computer addict argue over gets to blame society more for their habits."
"Fans of opposing Intellectual Bowl teams--the Acronyms and the Emoticons--gather around, discussing their favorite Nitpicker, Generalist, Logic Basher and Contrarian, hoping nobody goes on the DL with depression. They pause to laugh at someone wearing a baseball cap."
"'Grampa, when you were a kid, did your grandparents moan more or less about when they were kids?'"
"A group of short kids threatens to ruin a group of jocks['] test scores and future bank credit."
"A hipster starts bragging on this obscure game he's been enjoying--it's just under 1GB to install, but it actually has CONTENT, man!"
"Homosexual teens insult a peer for not being flamboyant enough (Don't worry, heterosexuals still pick on other heterosexuals over stereotypes, too. Yay, equality!)"
"'I'm not a math person, but...' / 'I'm not a psychologist, but...' / 'I'm not a nice person, but you both sound pretty annoying!'"
"It seems like you've both been here too often before and yet have never seen this area."
"Light music nobody hates enough to complain about pipes out from behind artificial plants."
"A little smart-aleck discusses how to organize the ramps up to the higher levels of Threediopolis more efficiently. You hate to say it, but he sounds right."
"A man walking by waves his ultrasound shaver, and two days of scuzz fall. It's not litter if you're a productive member of society."
"A musical purist argues passionately for old-school auto tuning."
"A nonagenarian whines how songs pining for simpler, more thoughtful times were...well, simpler and more thoughtful."
"A normal-IQ person is given a police warning for wearing a Harvard t-shirt without proper disclaimers."
"People arguing whether partisan disconnect is at an all-time high pass by you on either side, debating which of them is really in the middle of the spectrum."
"People squabble over which Mark R. Smith contributed more to history."
"Police corner a suspected handicap permit fraud! He had claimed social phobia disability, but whether or not he can answer the charges, that will dig him deeper."
"A public transport train pauses here and gives three contradictory delay apologies. Someone nearby breaks it down far too melodramatically."
"A rant you overhear about Big Pharma, while correct, leaves you craving something more than just plain aspirin."
"A recently boarded up 'adult' shop. Your naive pre-teen self actually thought people BOUGHT stuff there, despite the Internet."
"A sappy autotuned song from a public speaker delivers a [one of]common-sense-reductionist[or]horrendously pedantic[at random] PSA."
"A sectarian atheist fight breaks out over the best reason religion is stupid and how the afterlife should be, if it existed."
"Several assembly coders shove a script programmer into an alley and gaffle him for selling out. You...you saw NOTHIN['], man."
"A sociological argument! Is it time to add a 'fifth world' to the existing tier of four?"
"Some rich showoff with a jetpack flies dangerously close overhead."
"Some way-old-skool fool brags about a dope song that samples only *one* song that samples something actually original."
"Someone annoyed with political filibusters changes the subject to keep their listeners excited, I guess."
"Someone argues in favor of redistribution of income without being quite so sharing about the metaphorical talking stick."
"Someone bemoans how reality TV stars had class back a century ago, but now it's quantity and not quality."
"Someone blasting electronic music with a proper permit is left alone, though a whistler is arrested for busking. Best not to loiter, or you might be next."
"Someone coughs violently as another person walks by with an electronic cigarette."
"Someone cracks a 'classic' joke about GUI that, really,...it's just overplayed."
"Someone discusses a report proving people say 'In these troubled economic times' too much regardless of the economy."
"Someone heading to atheist confessional for stupid things done this week mutters 'Forgive my stupidity as I forgive others...'"
"Someone insults innumerate people than exaggerates what a loser the listener is--for their own good."
"Someone is cut down for taking public transport to a farmer's market. Real purists walk!"
"Someone laughs at an idiot who doesn't understand the one-page proof of Fermat's Last Theorem that was found way back in 2075."
"Someone mentions lots and lots of sexualities are still really repressed out there, and if you don't think so, you need to shut up."
"Someone mentions the unfairness of sneaky tax loopholes like that Ed Dunn might find."
"Someone on their way to a sensory deprivation tank laughs at paper books when you can have online multimedia."
"Someone playing a popular logic game on his NetFone whines it's just crunching numbers. Someone else playing the same game bemoans a quirky lateral-thinking solution."
"Someone rails against a puzzle in a silly logic game that can be solved by cultural knowledge or brute force. Each solution is stupid! Plus, it's also all too meta."
"Someone rants on many ways stupid people could have avoided being stupid by noticing obv--'OW! who put that bike meter there?'"
"Someone recalls the good old days when phones and IDs had one less digit."
"Someone walking the wrong way on a sidewalk to no good purpose is given a ticket."
"Someone without proper clearance for a vertical transport tube is pulled away and arrested."
"Someone wonders why, with all the balding and grey hair cures, some people are still slobs enough not to bother."
"Someone yacking into a NetFone bumps you as he passes ahead, but hey, more silence now."
"Someone yells about how he won't ever-no-never hang out with stupid people like religious fundamentalists."
"Techies discuss developing GUIs that make it nearly impossible for a customer to log out—but are still legal."
"'That book really makes you think about thought control.' / 'I've seen better.' / 'WHAT? YOU OBVIOUSLY DIDN'T PAY ATTENTION!'"
"Two ads in quick succession on a building videoscreen, one for a talk show and one for screen watching addiction."
"Two dorks wearing Science Tech letterman jackets (math team, blitz chess team) recite the well-worn reasons smart people are still underdogs to jocks. They argue over changes to the Optimal Tax Rate Algorithm. "
"Two equally annoying people describe how you gotta hate BOTH political parties in charge here."
"Two groups of young punks, in Steve Jobs and Bill Gates t-shirts, exchange harsh words over kernel architecture. You move on to avoid a 'situation.'"
"Two high-rolling humanist quasi-clergy discuss the next candidates for Smarthood."
"Two hipsters who never tried the real thing (too anti-environment) argue over the best coffee substitute."
"Two kids agree: anyone who hasn't taken and passed the Self Referential Aptitude Test by age 12 is just not one of the cool nerds."
"Two know-it-alls discuss the latest artificial-artificial fat and sugar substitutes, their risks, benefits and sustainability. You resolve to drink more water."
"Two little smart-alecks wonder if grandparents whined nostalgically so much back in the good old days."
"Two music critics discuss the relative merits of songs that almost rhyme and songs that rhyme words with themselves."
"Two NetPhoners crash into each other [one of]in the middle of a crosswalk[or]where two sidewalks meet[at random]."
"Two particularly annoying foodies berate, equally, an Escherville style restaurant in Threediopolis and a Threediopolis style restaurant in Escherville."
"Two people argue over whether 2100 is the 21st or 22nd century, but they do agree they're sick of politicians and salesmen talking of the new century and beyond, already."
"Two people debate the science of stretching out before a long walk or lots of exercise, or the latest diet. Then they dismiss the stock market as pure luck."
"Two smart kids wonder why ANYONE would root for a sports team not owned by sabermetrically-inclined techsters."
"Two ten year olds discuss the big sudoku quiz in tomorrow's math class and how losers who brute force it will fail."
"Two women discuss how the creaky old Bechdel test isn't nearly adequate enough any more for gender fairness in games, especially if the games are kind of meta."
"A voice advertises match-3 game addiction treatment sponsored by a shoot-em-up company, then for fairness and balance, a shoot-em-up addiction treatment sponsored by a match-3 company. Ha! YOU'd never stoop to playing silly games like that."
"You almost bump into someone reading [italic type]Moron Shaming and Logically Valid Namecalling for Fun and Profit[roman type]. They try to practice on you but fail."
"You pass a public library with the standard door-disclaimer: requests for old-style physical books require legitimate written reasons. You walk on, forgetting where it is."
"You pass by an annoyingly detailed conversation about long-term and short-term weather[if ud < 9] (not that it matters much below the top)[end if], smack into a clueless one."
"You pass some kid being bullied for his lame 1-GB internet connection and 32-megapixel phone. Eh, not your business."
"You pass someone holding a STATE CERTIFIED NICE BEGGAR sign. But you know those are easy to forge!"
"You pass two oldsters violently arguing WHY the good old days were better."
"You quickly run past someone with a monotonous-looking 'SLEEP: THE TAX OF LIFE' pamphlet. Then someone with a new-age dream-control book."
"You reflect on studies showing how much of your life advertising eats, and you wonder if that accounts for people complaining about or repeating particularly memorable ads, too."
"You run away from an annoying unfair conversation about why smart people suck--straight into one about how dumb people suck."
"You see a penny. No, it's a gag penny, since the date's after 2080."
"You walk by opposing heated demonstrations of corporate versus charity shills, then of two antiviolence factions."
"You're stuck behind someone babbling into their NetFone for a bit--moving ahead of them, you'd hear the conversation worse."

observies-flip is a truth state that varies.

observies-count is a number that varies.

to say dig of (dd - a number):
	if dd > 0:
		say "[dd]";

book waiting

every turn:
	if the current action is not waiting:
		now waits-in-a-row is 0;

waits-in-a-row is a number that varies. already-slept is a truth state that varies.

zwait is a truth state that varies.

s-z is a truth state that varies.

check waiting:
	if the player's command matches the text "wait", case insensitively:
		say "What a quaintly verbose way to wait! Four whole letters!" instead;
	increment waits-in-a-row;
	if zwait is false:
		now zwait is true;
		say "You reflect briefly that Z is the end of the alphabet, and people who Z too much may run afoul of efficiency laws[if s-z is false and player has book]. You read in the book that if you're Z'ing around, just try going south instead[end if].";
		if s-z is false and player has book:
			now s-z is true;
		the rule succeeds;
	if waits-in-a-row is 3:
		if already-slept is false:
			say "You fall asleep on your journey. You are awakened by whirring and clacking. Droids pick you up and give you an infra-red marking that identifies you as a potential leech on society--and juice and cookies, this time, since your possessions label you as moderately wealthy. They remind you the marking will fade in a year.[line break]";
			now waits-in-a-row is 0;
			reset-game instead;
		say "The anti-vagrant/loiterer droids are rougher with you this time. You barely manage to chuck Ed Dunn's paper down a garbage vaporizer before you are locked in a poor house cell for a month. (Fourth wall time: on the bright side, this is about the only chance you get to UNDO.)";
		now oopsy-daisy is 1;
		end the story instead;
	if waits-in-a-row is 2:
		say "You hear a [if already-slept is true]familiar [end if]buzzing of droids in the distance." instead;
	if s-z is false and player has book:
		now s-z is true;
		say "You have a strange urge to go south. You can't think why. As if going south and waiting are very similar." instead;

instead of sleeping:
	say "There are laws against that in any civilized city these days. Plus, that's an invitation to get robbed.";

book verbs

chapter thinking

instead of thinking:
	if thinked is false:
		say "If you were able to do one thing, you're pretty sure you'd know how to get back to Ed Dunn's secret hideout. You just remember it's been hidden." instead;
	if door to ed is visible:
		say "You think about whether or not you should call it a day[if score is maximum score]. You've done everything, so probably, yeah[end if]." instead;
	say "You take a moment to orient yourself, calculate a bit, and then walk back and forth til you arrive at outside Ed Dunn's secret hideout.";
	now your-tally is "eddunn";
	now ud is 3;
	now ns is 6;
	now ew is 5;
	move Ed Dunn's secret hideout to location of player;
	try looking instead;

chapter yessage

instead of saying yes:
	if word number 1 in the player's command in lower case is "yes":
		say "Without Ed Dunn around, being a yes-man won't do much good. Especially not such a verbose one. Three whole letters! ";
	else:
		say "The y-axis is north or south. I mean, N or S. ";
	rhet instead;

to rhet:
	say "[italic type][bracket]NOTE: any rhetorical questions in this game can be ignored. Explicit yes/no questions will have a special prompt.[close bracket][roman type][line break]";

chapter noage

instead of saying no:
	say "You shake your head, but nothing appreciably changes. ";
	rhet instead;

chapter going

section directions

bounds-warn is a truth state that varies.

to say losted:
	say "You're lost. You have strayed beyond the city bounds. A border droid takes your ID and whisks you back to the center[if posschars > number of characters in your-tally], and you decide to cancel the rest of your walking plans[end if].";
	if bounds-warn is false:
		if player does not have book:
			if pals + edtasks < 5:
				say "You look at your list, and many of the locations are relatively close to the center. Maybe you don't need to venture near the edges that much.";
				now bounds-warn is true;
	now ignore-remaining-dirs is true;

check going south:
	now your-tally is "[your-tally]s";
	if ns is 0:
		say "[losted]";
		reset-game instead;
	decrement ns;

check going north:
	now your-tally is "[your-tally]n";
	increment ns;
	if ns is 10:
		say "[losted]";
		reset-game instead;

check going west:
	now your-tally is "[your-tally]w";
	if ew is 0:
		say "[losted]";
		reset-game instead;
	decrement ew;

check going east:
	now your-tally is "[your-tally]e";
	increment ew;
	if ew is 10:
		say "[losted]";
		reset-game instead;

gone-up-or-down is a truth state that varies.

to say up-down-cool:
	say "Boy, it's cool to have unlimited passes through the vertical tubes! Ordinary citizens would get flagged for wasting city energy. Not that one level of the city is [italic type]better[roman type] than another, just, wow, Ed Dunn must Be Somebody";
	now gone-up-or-down is true;

check going up:
	if gone-up-or-down is false:
		say "[up-down-cool].";
	if stairway to heaven is visible:
		say "Did you mean to go up the stairway? Just checking.";
		if the player consents:
			try entering stairway instead;
	now your-tally is "[your-tally]u";
	increment ud;
	if ud is 10:
		say "[losted]";
		reset-game instead;

check going down:
	if gone-up-or-down is false:
		say "[up-down-cool].";
	now your-tally is "[your-tally]d";
	if ud is 0:
		say "[losted]";
		reset-game instead;
	decrement ud;

section generics

check going:
	if number of characters in your-tally > 10:
		say "You've been wandering for too long. You get tired, and you figure it's probably best to start over with a clean look on things. You push the button on your teleporter device[if posschars > 11], cancelling the rest of your planned journey[end if], and [if sector-num of your-tally is 444]everything looks a bit different[else]back you go to the center[end if].";
		now ignore-remaining-dirs is true;
		reset-game instead;
	tally-and-place;
	if hint-oppo is false and player does not have book and edtasks is 0:
		if opposite of opposite-direction is noun:
			say "Things look a little different now that you came back. All those side streets you take.";
			now hint-oppo is true;

book-clued is a truth state that varies.

to tally-and-place:
	let A be indexed text;
	now A is your-tally;
	repeat with Q running through things in outside-area:
		if Q is not player:
			now Q is off-stage;
	if player does not have book of top secret:
		repeat through table of findies:
			if A is tally entry in lower case:
				if note-found is false:
					if found entry is 1:
						say "Hm, that place you found before--it's somewhere around here, but you're focused on what to find next.";
						now note-found is true;
				if found entry is not 1 and location of what-drops entry is not outside-area:
					move what-drops entry to outside-area;
					if what-drops entry is door to Ed Dunn's secret hideout:
						now thinked is true;
					if the current action is waiting:
						say "[line break]You see something you didn't before--[what-drops entry].";
		repeat through table of findies:
			if A is tally entry in lower case:
				if found entry is not 1 and location of what-drops entry is not outside-area:
					move what-drops entry to outside-area;
	else:
		if your-tally is "see":
			move secret entry to outside-area;
		repeat through table of findies:
			if A is tally entry in lower case:
				if what-drops entry is front door:
					move what-drops entry to outside-area;
				else if book-clued is false:
					say "You remember something being here for Ed Dunn's tasks, but you don't want to pay attention, now. You're exploring the city.";
					now book-clued is true;

note-found is a truth state that varies.

section diagonals

going southwest is diaging.
going northwest is diaging.
going southeast is diaging.
going northeast is diaging.

outside-area is west of outside-area.
outside-area is north of outside-area.
outside-area is up of outside-area.

instead of diaging:
	say "You can't cut through buildings. Even with a teleporter device. Well, apparently you could cut through some lobbies years ago, but surveillance and keycard-doors have taken care of that.";

check opening front door:
	say "That would be rude. Try knocking instead." instead;

book entering

instead of entering front door: try opening front door instead;

book knocking

knocking is an action applying to nothing.

understand the commands "k" and "knock" as something new.

understand "k" and "knock" as knocking.

knock-warn is a truth state that varies.

carry out knocking:
	if knock-warn is false:
		if number of characters in the player's command > 4:
			say "[italic type][bracket]NOTE: in the future you can type K for knock.[close bracket][roman type][line break]";
			now knock-warn is true;
	if ominous is visible:
		try processing instead;
	if front door is visible:
		if player has book of top secret:
			say "You already invited them, and they're probably busy.";
			try examining front door instead;
		try processing instead;
	if sneed is visible:
		now oopsy-daisy is 6;
		let sneedrows be 0;
		repeat through table of scenery progress:
			if eggsfound >= need-to-get entry:
				increment sneedrows;
		choose row sneedrows in table of scenery progress;
		say "[sneed-talk entry]";
		end the story finally instead;
	otherwise if there is a visible quasi-entry:
		say "No need to be so formal. Walk on in.";
	otherwise:
		say "Nothing familiar enough to knock at.";

knock1ing is an action applying to one thing.

understand the command "knock on [something]" as something new.

understand "knock on [something]" as knock1ing.

carry out knock1ing:
	if noun is front door:
		try knocking instead;
	if noun is the player:
		say "That's just silly." instead;
	say "No need to be so formal[if noun is stained-glass], even at a place of religion[end if]. Walk on in.";

does the player mean knock1ing the player: it is unlikely.

book processing

thinked is a truth state that varies.

en-notify is a truth state that varies.

processing is an action applying to nothing.

helpitems is a number that varies. nonhelpitems is a number that varies.

to give-a-plus:
	if task-list is super-alpha:
		increment helpitems;
		if helpitems + nohelpitems is 14:
			say "You have enough evidence now to determine the list is organized fully alphabetically, by first letter--though S is broken in two parts. Though, of course, you might want to visit places you can guess out of order. To narrow down possibilities for the others[if pals < maxpals and fffwarn is false]. Also, you can try FFF to see friends sorted a bit more clearly[end if].[paragraph break]";
			if pals < maxpals:
				now fffwarn is true;
	else:
		increment nohelpitems;

to decide which number is mymin:
	if task-list is not byrow-header:
		decide on 0;
	decide on entry cur-byrow of rowstart;

to decide which number is mymax:
	if task-list is not byrow-header:
		decide on 0;
	decide on (entry (cur-byrow + 1) of rowstart) - 1;

carry out processing:
	let A be indexed text;
	now A is your-tally;
	repeat through table of findies:
		if A is tally entry in lower case and what-drops entry is visible:
			now plus-ticker is base-hint-count;
			give-a-plus;
			if there is a foundit entry:
				say "[foundit entry][line break]";
				if what-drops entry is front door:
					increment friends-found;
					if friends-found is maxpals:
						say "[line break]Excellent. You got all Ed's friends. That should keep him pretty happy.";
						if task-list is friend-header:
							say "[line break]It also means you don't need the friends header any more. Perhaps oo would be a useful command now.[paragraph break]";
							now task-list is reg-header;
						else:
							say "[line break]";
			otherwise:
				say "Aha! You've found [tally entry].";
			if what-drops entry is Ed Dunn's secret hideout:
				endgame-process instead;
			if found entry is not 2 and found entry is not 3:
				if ever-fast is false and what-drops entry is not door to ed:
					if score > 2 or number of characters in tally entry > 3:
						say "[italic type][bracket]NOTE: it looks like you've roughly figured your way around. If you haven't tried yet, you don't need to type periods or enter between moves to get places, so SSSS is the same as S.S.S.S.[close bracket][roman type][line break]";
						now ever-fast is true;
				give-a-point;
				now hint-iter is 0;
			repeat with en running through visible quasi-entries:
				now en is off-stage;
			if tally entry is "See" or tally entry is "Suss":
				now found entry is 3;
			otherwise:
				now found entry is 1;
			if task-list is byrow-header:
				let openyet be false;
				repeat with TEMPVAR running from mymin to mymax:
					choose row TEMPVAR in table of findies;
					if found entry is 0:
						now openyet is true;
				if openyet is false and edtasks < maxedtasks:
					say "You've cleared everything in your current row![paragraph break]";
					choose-new-row;
			if en-notify is false:
				say "[italic type][bracket]NOTE: from now on you can type IN once you see a place to enter or, if there's a door to knock on, K. On which to knock.[close bracket][roman type][line break]";
				now en-notify is true;
			if task-list is detail-header:
				[say "[edtasks]/[maxedtasks] tasks row subtracted if Ed not seen yet? [force-ed-point] Depth = [expected-depth].";]
				if edtasks is maxedtasks:
					say "You've found all the non-friend tasks[if maxpals is pals], and the friends too. Time to see Ed Dunn[else], but you have some friends left to find, so maybe ff will be useful[end if].";
					now task-list is reg-header;
				else if (maxedtasks - edtasks) - force-ed-point < expected-depth:
					now expected-depth is (maxedtasks - edtasks) - force-ed-point;
					if expected-depth is 1:
						say "You've found everything, [if pals < maxpals]except[else]including[end if] Ed's friends. So I'll be changing the header[if pals < maxpals] to friends[end if].";
						if pals < maxpals:
							now task-list is friend-header;
						else:
							now task-list is reg-header;
					if shrink-notify is false:
						say "[italic type][bracket]NOTE: you're getting close to doing everything for Ed before returning to him, so I shrank the list to [expected-depth] rows...and I'll continue to [']til you are done. You're doing great![close bracket][roman type][line break]";
						now shrink-notify is true;
			if look-mode is false and alpha-look-mode is false:
				reset-game;
				check-for-blather;
			the rule succeeds;
	say "Nothing to knock on here.";
	the rule succeeds;

shrink-notify is a truth state that varies.

to check-for-blather:
	repeat through table of score-comments:
		if pals + edtasks is sco entry:
			say "[comm entry][line break]";

table of score-comments [tsc]
sco	comm
4	"You think back to the times Internet route planners gave you wrong or slow directions and feel slightly superior."
6	"You hear Ed Dunn discussed in hushed tones--that he is not that smart but hires people much smarter to work for him. A smart voice and dumb voice agree there's a racket--but they'd work for him, all the same."
8	"It's a good thing the moving walkways--the ones you take for granted--are helping you along, or you'd be more tired than you are."
10	"You think back to the slider puzzles and even the peg solitaire game you never quite figured out. You bet they'll be easier to figure once you're done here. But Rubik's Cubes? Still, no way. Maybe you could work your way up, though."
12	"You remember walking into dead ends as a kid trying to take shortcuts to school. But you are avoiding them now."
14	"You remember overhearing coworkers telling you you need to get out more and see the city. Man, if they only knew."
16	"You reflect back to an unfortunate school incident where you solved a logic-box puzzle and people said that sort of thing would never be handy in real life."
18	"You're almost hit by a bicycle messenger who claims to be delivering something REALLY important."
20	"You've lost 5 pounds since you started walking around. You'd wanted to for months. And you're still going strong."
22	"You're in the zone, zigzagging about. This whole getting lost without getting lost thing feels intuitive once you get used to it. But what if you get too used to it? Will you lose the magic?"
24	"You think you remember getting lost where you just were--years ago, though. But now, of COURSE the buildings and streets connect like so!"
26	"Man, this reminds you of the crossword puzzles in the Brand New York Times. How the middle bits seem pretty cool because you have just enough hints, and something impossible to start now seems doable, and how the last clues were annoying until you got them."
28	"You momentarily have one of those 'I'm doing all the work and what am I paid' fits, but then you realize lots of people would pay to see this much of Threediopolis."
30	"You remember abstract problems you wanted to solve but never had the mental endurance to."
32	"You recall being made fun of for not wanting to learn how to order a taxicab around--or drive a car."
34	"Two joggers run by, sniffing at how you don't get THAT in shape just walking."
36	"Seeing so much of the city has reminded you of other areas you wanted to visit, like New Wessewn."
38	"You become a bit worried you won't be able to come back to any of these neat exotic sounding places now you've uncovered them and your time helping Ed is through."
40	"You remember how having a nice long walk helped you figure out that last something--maybe it will, here, too[if hint-block is true], if you type HH to get hints back[end if], even if it doesn't lead anywhere."
42	"You hear someone moaning 'I didn't want to go there, anyway,' and feel slightly superior--remembering how you walked there for Ed just a bit ago."
44	"You think about how the tough classes in school gave you an A at 80% and you wondered why and then you found out why. Maybe this is like it. Maybe just one more..."
46	"Man, you're totally in shape after all that walking. In shape enough to impress at a ritzy party like Ed Dunn's. Maybe you will even get invited!"
48	"You realize it's up to you, whether you want to achieve perfection for your own sake. [if force-ed-point is 1]That last one[else]Those last two[end if] could be tough. A big picture thinker like Ed Dunn will probably be happy with most everything. You think back to an evil teacher who deducted spite points for a few grammar slip-ups in an awesome story you wrote and realize what a bum they were. You could totally dis them in your mind by either seeing Ed now or getting that final point."

section score-ranks

table of sad endings [tse]
stuff-i-did	eval
1	"'Not up to it, eh? Geez, you found me, but some of these others woulda been easier to find. Well, I'll find else who else'll turn up.'"
5	"'Bare minimum, eh? Well, here's a bare-minimum payment. Actually, pennies are kind of valuable, since we haven't made any new ones for a while.'"
10	"'Hmph. Probably took more time coming here to quit than actually doing the tasks. Eh, well. Here, have an antique zip drive.'"
15	"Ed Dunn hands you a bogus ID with high-level clearance. 'Don't worry, it's airtight. No way you can get busted. Look, if you are out of a job, this'll give you a little extra unemployment pay. Maybe even some disability pay. I mean, we have a lot of lazy people, but with computers being as important as they are these days, people who are able to game the system are more likely to be able to learn a computer job eventually. I don't know how you are with them, but I like you, kid, so I'm giving you this. It's got black market value, too.'"
20	"He hands you an envelope. 'Pretty good, kid. I have made it worth your time. If you know anyone even more efficient than you, let me know, and I'll give you a referral fee.' When you get outside, you realize he is right. There is about a year's worth of pay at your regular job here."
25	"'Almost good enough for a full-time job, kid! tell you what, I'll recommend you to someone almost as important as me for these sorts of tasks. Maybe you'll make it back some day.' He hands you a wad of bills you're instructed not to count until you get outside. In them, you see the letter of recommendation. It's got a few backhanded compliments, but for even a fraction of this pay rate, you can deal."

table of happy endings [the]
stuff-i-did	eval
30	"'Not bad, kid! Not bad at all! But--not quite terrific.'"
35	"'Say! You've got hustle and sticktoitiveness. I--I'll call you if I don't find anyone even better next time. You might make it into my inner circle pretty quickly with a bit of work.'"
39	"'You've been wasting your life, kid. I'm glad you stumbled on this place. You aren't going to be a messenger forever, that's for sure. Here's a pass to a social club for clever people who can't quite trust or satisfy rich people. You'll make connections there.'"
43	"'Wow! Almost perfect. If you were perfect, I'd be worried you wasted your life fetching stuff for me. I'd like to keep you around. You almost deserve to come to my party! Maybe next time!'"
50	"Ed praises you as a new go-getter in the organization. [ed-praise][paragraph break]In fact, he is so pleased, he invites you to his party! He even manages to impress the duende-endued DeeDee Sneed, who's engaged (strictly convenience, Ed's sure) to old-money Sundude Senese. Ed calls you as 'Old sport' as he related how Sundude called him 'Ed Dung' once (and you can see why it hurts.) He is sure he will get her one day![paragraph break][wfak]But he also introduces you to another messenger he has hired. Denese (or Sed. I forgot to ask your romantic preference) Sneed and their brother/sister, Sed/Denese. You two talk about--well, all kinds of things that will be so fun to learn, the next time you work for Ed, the side streets of Threediopolis will lose SSDD and gain, not unfamiliarity, but what's the word...[paragraph break][wfak]...NEWNESS."
100	"'Wow! You did everything and more! This should be impossible, but congratulations, like.'"

to say wfak:
	if debug-state is false:
		wait for any key;

to say ed-praise:
	let mypct be (nohelpitems * 100) / (helpitems + nohelpitems);
	repeat through table of helppct:
		if mypct <= pct entry:
			say "[eval entry]";

table of helppct
pct	eval
5	"'Ya didn't hesitate to go for help. Some ivory tower types might. Good work.'"
20	"'Some people gave up when they were just getting started. But you persevered. Took up my offer of hints.'"
40	"'A good combination of doing it yourself and using your resources to figure everything out.'"
60	"'Boy. You got a lot done before you needed help. You're going places, kid.'"
80	"'Did it almost all on your own. Good job.'"
100	"'Didn't even need my help! Kid, I wish I had some extra hard deliveries to make. You'd pick them off, easy.'"

book looking

check looking:
	if the player's command matches the regular expression "^(l|look)\b":
		say "[one of]Looking around won't be enough to get you lost the way you need to get lost. It seems it might even add one more variable, or layer of complexity, beyond just waiting.[paragraph break]You could say doing so in the middle of a journey is [italic type]useless[roman type].[or][run paragraph on][stopping]";

after choosing notable locale objects:
	set the locale priority of sneed house to 0;

suspicious-guy-help is a truth state that varies.

suspicious-seen is a truth state that varies.

scenery-found-yet is a truth state that varies.

to check-cur-done:
	let cur-alf-row be 0;
	let a be "a";
	let b be indexed text;
	let any-blank be false;
	if begin-rows is 1 and end-rows is 6: [choosing all the rows, covered elsewhere]
		continue the action;
	repeat through my-table:
		let b be character number 1 in tally entry;
		if b is not a:
			increment cur-alf-row;
			if cur-alf-row is inline:
				if found entry is 0:
					continue the action; [we found a non-clue]
	say "There are no clues left in the rows you've chosen.";

misp-found is a truth state that varies.

after looking (this is the place ed's tasks rule) :
	if your-tally is "suss" and player does not have book of secret and ignore-susp is false:
		if suspicious-guy-help is false:
			choose row with tally of "Suss" in table of findies;
			if found entry is 0:
				give-a-plus;
			now found entry is 3;
			if score is maximum score - 2 and suspicious-seen is false:
				say "A suspicious guy walks up to you, says 'Psst!' and then, before you can respond, says, 'Never mind. I can't help you.' before running away." instead;
			if score is maximum score - 1 and suspicious-seen is true:
				say "A suspicious guy walks up to you, says 'Psst!' and then, before you can respond, says, 'Never mind. I can't help you.' before running away." instead;
			say "[one of]A suspicious guy[or]That suspicious guy (again)[stopping] sidles up and says, 'Psst! Pal! Got a hint. Or even better. Contraband. What d'you say?'[paragraph break][recap]";
			now bm-mode is true;
		if suspicious-seen is false:
			now suspicious-seen is true;
			give-a-point;
		now plus-ticker is 0;
		now hint-iter is 0;
		consider the notify score changes rule;
	let A be indexed text;
	now A is your-tally;
	repeat through table of preclues:
		if found entry is 0 and A is tally entry:
			now found entry is 1;
	repeat through table of scenery:
		if A is tally entry:
			if found entry is 2 or A is "sneeds":
				if player has book:
					move Sneed house to outside-area;
			if found entry is 0:
				now plus-ticker is 0;
				if A is "sneeds":
					now found entry is 2;
				else:
					now found entry is 1;
				increase base-hint-count by 2;
				if player does not have book of top secret things:
					say "[foundit entry][one of][paragraph break]But what you noticed doesn't seem practical, so you put it out of your mind as you continue pacing. Places you can't enter won't help you help Ed Dunn.[line break][or][line break][stopping]";
				else:
					say "[foundit entry][if scenery-found-yet is false][paragraph break][first-sc].[else][line break]";
					now scenery-found-yet is true;
					if misp-found is false and player has book of top secret:
						say "You pat yourself on the back for finding this and mentally stick your tongue out at the person who beat you in a spelling bee years ago.";
						now misp-found is true;
					if expected-depth > secs - eggsfound:
						now expected-depth is secs - eggsfound;
					if center-warn is false:
						say "[italic type][bracket]NOTE: you can hit PP to zap back to the center automatically after finding scenery.[close bracket][roman type][line break]";
						now center-warn is true;
					else if found entry is not 2 and center-on-scene is true: [stay around the sneeds']
						say "[line break]You zap back to the almost-center[if posschars > number of characters in your-tally], cancelling the rest of your plans[end if].";
						now ignore-remaining-dirs is true;
						reset-game;
					check-cur-done;
				continue the action;
			if found entry is -1 or found entry is 2:
				now plus-ticker is 0;
				if found entry is -1:
					now found entry is 2;
				say "Oh man. It's the Sneeds['], again! Should you stop in?";
				if the player consents:
					let count be 0;
					repeat through the table of scenery progress:
						if eggsfound >= need-to-get entry:
							increment count;
					choose row count in the table of scenery progress;
					say "[sneed-talk entry]";
					end the story;
					consider the shutdown rules instead;
				else:
					say "Okay. You drift on, walking away.";
	repeat through table of nearlies:
		if A is tally entry:
			if there is a rule-to-reveal entry:
				consider the rule-to-reveal entry;
				if the rule succeeded:
					say "[descrip entry][line break]";
				the rule succeeds;
			if found-yet entry is false:
				now found-yet entry is true;
				say "[descrip entry][line break]";
				the rule succeeds;
	continue the action;

to say first-sc:
	say "[if sneed house is visible]You might want to poke around elsewhere, though, but you're glad you found them[else]Well, hey, that's first piece of scenery found with the book handy! You make a note and move on[end if]";

table of preclues
tally	found
"dune"	0
"nude"	0

section after-look start hints

init-clues is a number that varies.

after looking (this is the early hints rule) :
	if init-clues < 2 and player has task-list:
		if task-x is true:
			if pals + edtasks < 3:
				if number of characters in your-tally is 1:
					repeat through table of initclues:
						if hintyet entry is false:
							if character number 1 in your-tally is "[firstlet entry]":
								if character number 1 in your-tally is not "w":
									increment init-clues;
								say "[myclue entry][line break]";
		else if number of characters in your-tally is 1 and pals + edtasks < 5:
			say "You consider[one of][or], again,[stopping] you should maybe read the task list Ed gave you before starting any treks[if pals + edtasks > 0], though you've already done a bit[end if].";
	continue the action;

table of initclues
firstlet	hintyet	myclue
"u"	false	"Hmm, well, nothing here right away, [if-sun]."
"d"	false	"Apparently one task far away is here, along with two near ones[if-dsolve]. What's up with that?"
"n"	false	"[if-unwed]."
"s"	false	"One store on the list should be near, [if-wes]."
"e"	false	"Four places on the list, [if-e]."
"w"	false	"You didn't expect to find any places here. But maybe there are a few a couple blocks down."

to say if-e:
	let myi be 0;
	choose row with tally of "Nes" in table of findies;
	if found entry is 1:
		say "and you got one of them. Maybe the other is not so bad";
		continue the action;
	choose row with tally of "Nudes" in table of findies;
	increase myi by found entry;
	choose row with tally of "Dunes" in table of findies;
	increase myi by found entry;
	say "[if myi is 0]with two being really near and two being less near. All in the same place. Odd[else]and you picked off something harder already[end if]"

to say if-dsolve:
	let myi be 0;
	choose row with tally of "Dns" in table of findies;
	increase myi by found entry;
	choose row with tally of "Dew" in table of findies;
	increase myi by found entry;
	if myi is 0:
		continue the action;
	say "[if myi is 1], including the one you solved[else], both of which you got[end if]"

to say if-unwed:
	choose row with tally of "Unwed" in table of findies;
	say "[if found entry is 1]You found Ed's only task here rather early, but there's no more in this sector. That doesn't mean you won't find something this trip[else]Eh, only one place on the list, so maybe you just got lost on the way. Or perhaps you need to get sort of lost, somehow. Maybe put it off until later[end if]"

to say if-sun:
	choose row with tally of "Sun" in table of findies;
	say "[if found entry is 1]but Ed's friend can't be far[else]though two tasks are near[end if]"

to say if-wes:
	choose row with tally of "Wes" in table of findies;
	say "[if found entry is 1]and you found Wes. The other can't be that bad[else]and so's a friend of Ed's, but you see nothing[end if]";

chapter pping

pping is an action out of world.

understand the command "pp" as something new.

understand "pp" as pping when player has book of top secret things.

center-warn is a truth state that varies.

center-on-scene is a truth state that varies.

carry out pping:
	if center-on-scene is false:
		now center-on-scene is true;
		now center-warn is true;
	else:
		now center-on-scene is false;
	say "Now you [if center-on-scene is false]won't[else]will[end if] zap to the center after seeing scenery[if center-on-scene is true]. Though if you've just done so, you'll still need to type P to go back to the center right now. Busy work hasn't been [italic type]completely[roman type] abolished yet[end if].";
	the rule succeeds.

book xyzzying

xyzzying is an action applying to nothing.

understand the command "xyzzy" as something new.

understand "xyzzy" as xyzzying.

carry out xyzzying:
	say "Yes, indeed, the game map has 3 axes--x, y and z.";
	the rule succeeds;

book hinting

hinting is an action out of world.

understand the command "h/hint/help" as something new.

understand "h" and "hint" and "help" as hinting.

to say dds-dnd:
	choose row with tally of "dds" in table of scenery;
	say "[if found entry is 1]the dental pain at 234 has an S and 2 D's[else]you found DDS at 234[end if], and ";
	choose row with tally of "dnd" in table of scenery;
	say "[if found entry is 1]the chaot. gam. soc. at 254 has an N and 2 D's[else]you found DND (D and D) at 254[end if]. The second is an example of the pronunciation munging you'll need to find the tougher scenery";

carry out hinting:
	if player has book of top secret things:
		say "[one of]The book of top secret things is totally alphabetized from the start (the rows are locations starting with D, E, N, S, U and W,) but you can and probably should also keep a chunk of it on top with R (1-9). HINT again to find about the shortest places to go for hints. They can clue farther-away places.[or]Twistiness is also a big help, if you understand what it is. You may wish to take time to figure twistiness from the clues you saw when helping Ed Dunn. If you can pick off a few other clues, it may help, too. Twistiness is not intended to be complex, so don't overthink it.[or]Try to focus on items with negative twistiness at first--even if you haven't figured what it is, yet! For instance, [dds-dnd]. These are a lot like the original game.[or]You can also see Ed's old friends for less regimented hints. HINT again for twistiness.[or]Twistiness is just the number of unique directions you need to go to find the location, though not the actual bends. So EEW and EWE would have the same twistiness. HINT again tells about spelling.[or]Some names are misspelled, here. You may need to pronounce them and slightly de-misspell, and they won't be as transparent as WEENEES and SEEWEED, but once you pick off the less difficult scenery, the more difficult ones must be in a certain alphabetical range, which will help you.[or]That's all the hints. HINT will cycle through again.[cycling]" instead;
	if edtasks + pals is 0:
		say "[one of]You may notice that traveling to some areas that have a task shows nothing. Maybe it is how you get there that is important. [italic type][bracket]Note--there'll be a few more hints. But it'll be more fun if you figure it out. Hopefully.[close bracket][roman type][line break][or]Try for the least difficult tasks first. Remember, you always push the button to get back into the center.[or]You may want to consider your employer's name, Ed Dunn. It's a potential clue.[or]Or his clue that it's how you get there that matters, too.[or]You may want to focus on addresses with more than one entry--in particular, addresses the same distance away.[or]355 is the best one, with everyone so near.[or]There are six ways to get there in three moves.[or]Last clue before spoiler: your friends['] names are Dee, Des, Ewen, Ned, Sue, Swen, Wendee, Wes and Uwe. These names have something in common with Ed Dunn.[or]They all contain the letters NSEWUD and no others.[or]Which are one-letter directions.[or]The way to get to them is how you spell them.[or]If you're really stumped on individual puzzles, [3d-logic] provides the logic. The source code should be released post-comp.[stopping]" instead;
	say "Every few fruitless explorations should give you a hint. You can toggle these progressive in-game hints with the HH command.[paragraph break]The logic file with this game or at [3d-logic] is probably better for that list should tell you the easiest, or shortest, remaining task, and also, two of the places have hints on the side[news-hint]." instead;
	the rule succeeds;

to say 3d-logic:
	say "http://www.ifarchive.org/if-archive/games/competition2013/zcode/threediopolis/logic.txt (or google threediopolis logic sheet if the archive is down)".

to say news-hint:
	choose row with a tally of "Suss" in table of findies;
	if found entry is 1:
		say ", and you've been to the random one. Just don't enter, and you'll get some real news";

chapter hhing

hhing is an action out of world.

understand the command "hh" as something new.

understand "hh" as hhing.

hint-block is a truth state that varies.

carry out hhing:
	if hint-block is true:
		say "Hints restored.";
		now hint-block is false;
	else:
		say "Hints removed. Restore with hh, again.";
		now hint-block is true;
	the rule succeeds;

chapter walkthroughing

walkthroughing is an action applying to nothing.

understand the command "walkthrough" as something new.

understand "walkthrough" as walkthroughing.

carry out walkthroughing:
	say "In lieu of a walkthrough, you should look to either the logic document included with the story file, or the Table of Findies in the source code. It can be searched easiest with [bracket]t[if 1 is 1][end if]of[close bracket]. With or without brackets.";
	the rule succeeds;

book creditsing

creditsing is an action out of world.
abouting is an action out of world.

understand the command "credits" as something new.

understand "credits" as creditsing.

understand the command "about" as something new.

understand "about" as abouting.

carry out abouting:
	say "This game wasn't intended to be huge on plot, but rather, I saw a way to do things, and I figured why not. I put the skeleton on the shelf after starting it in May 2012, toyed with it for a post-IFComp 2012 release, then got so lazy I saw I could submit it in time for IFComp 2013![paragraph break]Type CREDITS for testers and such.[paragraph break][if score < 2]A previous IFComp game that might spoil this game's mechanic[else]Brian Rapp's [italic type]Under, In Erebus[roman type][end if] also probably had considerable influence on this game, though it does have a lot more plot and cool locations.[paragraph break]I hope you enjoy this. I recognize some people won't, and that's cool, and I don't want to play the 'I know some philistines may hate it' card. However, if it helps someone who doesn't like it try their [italic type]own[roman type] thing, that'd be way cool.[paragraph break]Also, remember to track back to puzzles you couldn't solve after getting a few others. They may be easier. And don't feel you have to do things in any particular order!";
	say "As of release 4, Threediopolis is relatively stable. I don't plan to make any huge changes, but if you want, you can report bugs/feature requests at [repo].";
	the rule succeeds;

carry out creditsing:
	say "Thanks to (alphabetized by first name) DJ Hastings, Geoff Moore, Jim Warrenfeltz, Kevin Jackson-Mead, Melvin Rangasamy (who also provided I6 coding help), and Wade Clarke, who also designed the cover art that gave me a few extra ideas.[paragraph break]Heartless Zombie provided hash code for A Roiling Original, which, simplified, facilitated the user input here.[paragraph break]Olivia Pourzia, Hugo Labrande, Stephen Watson and Toby Ott provided advice for inter-comp releases. Runnerchild's review pointed out inconsistent hints. The people at ClubFloyd (12/29/13) made some wonderful observations of all kinds to help with this game's polish, and Emily Boegheim and Paul Lee sent transcripts and encouragement mid-IFComp 2013. Gráinne Ryan, Jason Lautzenheiser and Sean M. Shore helped with release 3m as did Jenni Polodna and Jimmy Maher's xyzzyreviews.org essays.[paragraph break]Tangential thanks to PERL creators/maintainers and more importantly the people who created and maintained Inform.[paragraph break]By the way, the source code and a logical walkthrough should be readily available if you want to get all the points for both regular and extended mode. I hope nothing is too obscure or unfair.";
	the rule succeeds;

book quasi-entry list

a quasi-entry is a kind of thing.

the nodoor is privately-named scenery. description of nodoor is "[bug-rep]"

to say bug-rep:
	say "BUG please let me know how this happened at blurglecruncheon@gmail.com, or report an issue at [repo].";

to say repo:
	say "http://github.com/andrewschultz/threediopolis"

a quasi-entry is usually fixed in place.

a quasi-entry can be openable. a quasi-entry is usually not openable.

instead of taking a quasi-entry:
	say "That'd be vandalism. Probably [if noun is front door]KNOCK[else if noun is openable]OPEN or ENTER it or go IN[otherwise]ENTER it or go IN[end if], instead.";

the blurry doors that seem only half there are a plural-named quasi-entry.

description of blurry doors that seem only half there is "The more you try to make out details, the less they seem there. However, they seem more likely to fade away then to solidify into a wall, though, so you might as well risk entering them."

the front door is a quasi-entry. "Man! Someone's front door! With the secret detail Ed Dunn showed you that's obvious once you know it!"

description of front door is "It looks familiar, slightly different from all the identical ones."

check examining front door when player has book of secret things:
	repeat through table of findies:
		if your-tally is tally entry in lower case:
			say "[if there is no palhint entry]Though the front door has no specific reason why, still, you probably shouldn't.[else][palhint entry][line break][end if]" instead;
	say "Oops! Somehow, I didn't account for this friend. [bug]" instead;

the odd grassy door is a quasi-entry.

description of odd grassy door is "It's greenish-brown, and you're tempted to pick at it to see how naturesome it is, but you'd better not."

the extremely ominous door is a quasi-entry.

description of ominous door is "It says VOLUNTARY POPULATION CONTROL CLINIC."

the stained-glass entryway is a quasi-entry.

understand "door" and "entry" and "glass" as entryway.

description of stained-glass entryway is "It is impressive. It would make you believe in religion, if you hadn't convinced yourself long ago you'd probably pick the wrong one."

the hinged wooden gate is a quasi-entry.

description of hinged wooden gate is "It may be more for show and seems woefully out of place here."

the door shaped like a champagne bottle is a quasi-entry.

description of champagne bottle is "It's a bit tacky, but it gets the point across. You will learn something about partying if you go through it."

the restaurant door is a quasi-entry.

description of restaurant door is "Seen one, seen them all."

the cobblestone archway is a quasi-entry.

description of cobblestone archway is "Fully designed for maximum old-world charm without looking decrepit."

the stairway to heaven is a quasi-entry.

the printed name of the stairway to heaven is "a stairway to heaven, or, more likely these days, the humanist daydreamer's equivalent"

description of stairway to heaven is "It gets bright near the top--an illusion every grade-school kid knows, but it's still awe-inspiring in person."

instead of climbing stairway to heaven:
	try entering stairway instead;

the clothing store is a quasi-entry.

description of clothing store is "You'll have to walk in to see what's so special. Nothing in the windows outside really captures you."

understand "door" as clothing store.

the loading dock is a quasi-entry.

description of loading dock is "The loading dock is neither exciting nor forbidding. You can probably just ENTER it."

the md is a privately-named quasi-entry. understand "metal" and "door" and "metal door" as md. the printed name of md is "metal door with a one-way peephole".

the peephole is part of the md. description of peephole is "It's for looking out, not looking in."

instead of searching peephole:
	say "Just walk in, geez. You're an employed ADULT.";

description of md is "It's plain, and the builders planned it that way."

the surprising new store is a quasi-entry. description of surprising new store is "You can tell it's clean and cheery and, looking inside, you see welcome signs."

the welcome signs are part of the surprising new store. description of welcome signs is "They're inviting you to come in."

instead of doing something other than examining the signs:
	say "They're only for looking at."

the barely detectable gladed trail is a quasi-entry.

description of the barely detectable gladed trail is "It's kept up well. But it's also narrow enough that if you weren't looking for it, you'd miss it."

dunes are a quasi-entry.

description of dunes is "Very sandy but off-limits to those without a reservation. You assume one is in your mysterious package."

the door to Ed Dunn's secret hideout is a quasi-entry.

initial appearance of the door to Ed Dunn's secret hideout is "[one of]Hey, here's the door to Ed Dunn's secret hideout! Makes sense[or]Ed Dunn's secret hideout door is just where you remember it. You can enter it to report to your employer[stopping]."

description of door to Ed Dunn's secret hideout is "It's surprisingly ordinary, and it doesn't even have Ed's name on it."

opening a quasi-entry is pointscoring.

entering a quasi-entry is pointscoring.

[instead of examining a quasi-entry:
	say "Stop staring and walk inside!"]

the intimidating 15-foot revolving door is a quasi-entry.

description of the intimidating 15-foot revolving door is "Fortunately, the door handle is a more reasonable three feet above."

the door handle is part of the 15-foot revolving door.

instead of doing something with the door handle:
	say "It's the door itself you want to mess with.";

description of door handle is "BUG";

instead of doing something with the intimidating 15-foot revolving door:
	try processing instead;

the clothing store is a quasi-entry.

the tiny yet inviting door is a quasi-entry.

description of the tiny yet inviting door is "It's meant to radiate charm and a simpler life. More practically, it stands out from the cookie-cutter doors around it, so you know you've found the right place."

the big glass doors are a quasi-entry. the big glass doors are plural-named.

understand "door" as big glass doors.

description of big glass doors is "They help the business inside look important."

the door to the Sneed house is a quasi-entry. description is "This door was made for knockin[']!"

instead of going inside:
	let Q be a random visible quasi-entry;
	if Q is nothing:
		say "Nothing to enter. It's all so unfamiliar.";
	otherwise:
		try entering Q instead;

rule for supplying a missing noun when the current action is entering:
	if there is a visible quasi-entry:
		now noun is a random visible quasi-entry.

does the player mean opening a quasi-entry: it is likely.

instead of opening a quasi-entry:
	if sneed house is visible:
		say "You don't want to seem TOO eager to visit Denese and Sed, so you knock instead.";
		try knocking instead;
	if front door is visible:
		say "That front door is someone's home. You should really knock instead." instead;
	if noun is trail or noun is dock:
		say "You can't. It's open as is. So you walk down it.";
	try processing instead;

seen-ed is a truth state that varies.

next-zag is a number that varies.

to give-a-point:
	now just-found is true;
	let before-chars be my-chars;
	if front door is in outside-area or front door was in outside-area:
		increment pals;
		if pals is maxpals:
			say "Obviously, there'll be random people to make up the numbers, but Ed's best pals are the ones who will keep the party moving.";
			continue the action;
		repeat through table of palstuff:
			if numpals entry is pals:
				say "[line break][paltext entry]";
				if en-notify is false:
					say "[line break]";
		if pals is not a numpals listed in the table of palstuff:
			say "[line break][one of]Well[or]Hooray[or]Awesome[or]Woohoo[or]Hot dang[or]Yippee[or]Hoowah[or]Bada-bing[in random order], that's another friend found! Back to the center.";
		continue the action;
	else:
		increment edtasks;
		if edtasks + pals is next-zag:
			continue the action;

table of palstuff
numpals	paltext
1	"Well, Ed won't be alone now. Or, rather, he'll have one of his best pals to talk to."
3	"You've found some pretty swank areas of Threediopolis you'd have missed otherwise. It looks like there are more."
5	"Just over halfway there, well, with the friends. You are getting the hang of whom to find, where."
7	"Man! None of Ed's pals have insulted you heinously yet. You already feel a bit more posh."

instead of entering a quasi-entry:
	if noun is front door or noun is sneed house:
		try opening noun instead;
	if noun is ominous door:
		say "From the list, it looks like Ed wants you to punk them instead. Plus, you think you know what 'Voluntary Population Control' might mean. So, it'd be better to knock instead, wouldn't it?";
		unless the player consents:
			say "You walk into the population control clinic. Inside is a Death Panel. No, silly, not the health care type. Those're even more secretive! (IF they exist, of course. There's still no proof.) You're briefly thanked for doing your small part to alleviate overpopulation and given forms to sign.[paragraph break]As you are strapped into the lethal comfy chair with all these needles, they discuss whether you were destined to be useless to society or too lazy to contribute any more, then evaluate your contributions relative to your beliefs and where you started in life. It's emotionally, if not physically, painful.[paragraph break]Oh, yes. they confiscate your package, since you probably stole it, and there's illegal stuff in it anyway. It's useful when establishing trumped-up charges against Ed Dunn to confiscate his vast possessions five years later.";
			now oopsy-daisy is 3;
			end the story instead;
	if quick-i is false:
		say "[italic type][bracket]NOTE: you can type i instead of enter/in in the future. It trumps the default command for I, taking inventory, which has limited use in this game.[close bracket][roman type][line break]";
		now quick-i is true;
	if noun is door to ed:
		choose row with what-drops of door to ed in table of findies;
		if found entry is not 2:
			increment nohelpitems;
		now found entry is 2;
		if seen-ed is false:
			increment edtasks;
			now seen-ed is true;
		unless pals + edtasks + 1 < maxpals + maxedtasks:
			say "You're confident you smoked this challenge. You blow past the guard at the front door, waving the task list to silence their protests!";
			try processing instead;
		if task-list is alpha:
			say "As you approach the door, a guard asks your business. You recall Ed Dunn's offer of help. Are you looking for help?";
			if the player consents:
				say "You explain your situation, and the guard takes your list, fiddles with it and hands it back! It's even better organized than before! There are list items, though one of them takes up two rows. You can't wait to give things another crack, so you push the device button.[paragraph break]";
				say "[italic type][bracket]NOTE: you unlocked a new header/view. Type mm for a jazzy new header, or m (1-7) to see the respective row--plain m cycles through the rows.[close bracket][roman type][line break]";
				now plus-ticker is 0;
				now task-list is super-alpha;
				sort the table of findies in tally order;
				define-row-starts;
				reset-game instead;
		say "You loaf around a bit, worried about facing Ed Dunn, but the guard at the door doesn't seem to want you to hang around. Go in?";
		unless the player consents:
			say "The guard mumbles, 'I'm a busy man. Don't waste my time!' and turns away. Slightly ashamed, you push the transporter device button to escape the awkwardness.";
			reset-game instead;
		say "Evaluation time!";
	try processing instead;

rowstart is a list of number variable.

to define-row-starts:
	let count be 1;
	let X be indexed text;
	now X is "";
	repeat through table of findies:
		if character number 1 in tally entry is not X:
			add count to rowstart;
			now X is "[character number 1 in tally entry]";
		if character number 1 in tally entry is "S":
			if character number 2 in tally entry is "n":
				add count to rowstart;	[SE->SN merge. Even if I add something, it can't get closer.]
		increment count;
	add 1 + (number of rows in table of findies) to rowstart;
	[repeat with Q running through rowstart:
		choose row Q in table of findies;
		say "[Q] [tally entry].";]


a library entrance is a quasi-entry.

description of library entrance is "It's barred, almost like a jail, which scares away the dumber people. That's a good thing, because dummies often tie up books that could be used by someone smarter."

instead of entering library:
	try processing instead;

a vacant lot is a quasi-entry.

description of vacant lot is "It's for loafing around in, not loafing around around. So you may just want to enter it."

instead of entering vacant lot:
	try processing instead;

the shiny new store door is a quasi-entry.

description of the shiny new store door is "Okay, it's not super shiny, but it feels and looks shiny, as something new should."

the secret entry is a quasi-entry. description of secret entry is "A door that blends in nicely with the building facade. But not quite well enough, now you know what to look for."

understand "door" as secret entry.

friends-printed is a truth state that varies.

carry out examining the task-list:
	if list-in-status is true:
		say "This should be in the status box. If it is not, or the status box looks bad, type t to remove it.";
	let Z be a list of numbers;
	let temp be 0;
	say "[bold type]**************ED DUNN'S NEEDS**************[roman type] ([row-blab])[if edtasks < 10][paragraph break]LOOKING IN MIDDLE OF JOURNEY IS USELESS.[end if][run paragraph on]";
	if task-list is not super-alpha or verso-examine is true:
		unalpha-it;
	else:
		super-alpha-it;
	if  task-list is not kinda-random and score < 4:
		say "[one of][paragraph break]Hm, he said it was alphabetized, but you aren't sure yet what he was talking about.[or][line break][stopping]";
	if score > 18 and ok-now is false:
		say "You figure Ed Dunn would be pretty happy with how you've done so far. But maybe you can do better.";
		now ok-now is true;
	if list-in-status is false and toggle-suppress is false:
		say "[line break]";
		say "[italic type][bracket]NOTE: You can put this in the header with t, though it is not recommended with Parchment, or you can toggle this warning with tt. You can also track just friends with f (ff puts this in the header), you can see the topmost line with o (oo puts it in the header) or push r (number) to put the first (#) clues in the header--rr or r displays just #1. X (#) or (##) shows one line or a series--you're currently seeing [begin-rows] to [end-rows].[close bracket][roman type][line break]";
	the rule succeeds;

thestring is indexed text that varies.

to decide what number is listwidth:
	if screen width > 150:
		decide on 150;
	decide on screen width;

to unalpha-it:
	let curlines be 0;
	now thisheaderbreak is 0;
	let localrow be 0;
	repeat through table of findies:
		if in-header is true:
			if breakbefore entry is 1:
				increment curlines;
				if curlines is 17:
					say "[lb]  (worry about the rest later--easy stuff first.)";
					the rule succeeds;
				say "[lb]--[nearness of tally entry]: ";
				now hpos is number of characters in "[nearness of tally entry]";
				now hpos is 4 + hpos;
			else if breakbefore entry is 2:
				increment curlines;
				say "[lb]--friends: ";
				now hpos is 11 + hpos;
			else:
				say ", ";
				now hpos is 2 + hpos;
		else:
			if breakbefore entry > 0:
				increment localrow;
			if in-header is true or localrow is inline:
				if breakbefore entry is 2:
					say "[lb]--friends: ";
				else:
					say "[if breakbefore entry is 1][lb]--[nearness of tally entry]: [else], [end if]";
		if found entry is 1 and unlist entry is false:
			if in-header is true:
				increase hpos by number of characters in tally entry;
				if hpos >= listwidth:
					increment curlines;
					if curlines is 17:
						say "[line break]  ([later].)";
						the rule succeeds;
					say "[lb]  ";
					now hpos is 2;
					increase hpos by number of characters in tally entry;
			if in-header is true or localrow is inline:
				say "[italic type][tally entry][noital]";
		else if unlist entry is false:
			increase hpos by 4 + number of characters in descrip entry;
			if in-header is true:
				if hpos >= listwidth:
					increment curlines;
					if curlines is 17:
						say "[line break]  ([later].)";
						the rule succeeds;
					say "[lb]  ";
					now hpos is 2;
					increase hpos by 4 + number of characters in descrip entry;
			if in-header is true or localrow is inline:
				say "[descrip entry]@[sector-num of tally entry][if in-header is false and task-list is twisty][twistrate of twistiness entry][end if]";
		else:
			now hpos is 0;
			if in-header is true or localrow is inline:
				say "[lb]";
	if in-header is true:
		if thisheaderbreak + 1 < maxrrows:
			now maxrrows is thisheaderbreak + 1;
			rejig the status line to maxrrows rows;

to rejig the status line to (depth - a number) rows:
	(- VM_StatusLineHeight({depth}); -);

to say lb:
	say "[line break]";
	increment thisheaderbreak;

to decide whether (mynum - a number) is inline:
	if mynum > end-rows:
		decide no;
	if mynum < begin-rows:
		decide no;
	decide yes;

to decide whether print-this-clue of (lr - a number):
	unless lr is inline:
		if in-header is true and player does not have top secret:
			decide yes;
		decide no;
	decide yes;

to decide what number is opsize of (x - a number):
	if x < 7 and x > 3, decide on 7 - x;
	if x > 0 and x < 4, decide on x;
	decide on 0; [this should never happen]

to decide whether you-can-twist:
	if player has book of top secret:
		if twistx is false:
			decide yes;
	else:
		if task-list is twisty:
			decide yes;
	decide no;

to super-alpha-it: [major list manipulation]
	now thestring is "[listwidth]";
	let curlines be 0;
	let a be indexed text;
	let alpha-row be 0; [1=d 2=e 3=n 4=s 5=u 6=w]
	now thisheaderbreak is 0;
	now hpos is 0;
	now a is "a";
	let localrow be 0;
	repeat through my-table:
[		if in-header is true:
			now thestring is "[thestring] before = [tally entry] [hpos]";]
		let b be character number 1 in "[tally entry]" in lower case;
		if a is not b:
			increment localrow;
			if print-this-clue of localrow:
				if in-header is true:
					increment curlines;
					if curlines is maxhrows - 1:
						say "[line break]  ([later].)";
						the rule succeeds;
					say "[lb]--";
					now hpos is 2;
				else:
					increment localrow;
					if localrow is inline or in-header is true:
						say "[paragraph break]--";
			now a is b;
		else:
			if print-this-clue of localrow:
				say ", ";
				now hpos is hpos + 2;
		if print-this-clue of localrow:
			if there is no unlist entry or unlist entry is false:
				if found entry is 1:
					now hpos is hpos + number of characters in tally entry;
					if hpos >= listwidth:
						if in-header is true:
							increment curlines;
							if curlines is maxhrows - 1:
								say "[lb]  ([later].)";
								the rule succeeds;
							say "[lb]  ";
						now hpos is 2 + number of characters in tally entry;
					if in-header is true or localrow is inline:
						say "[italic type][tally entry][noital]";
				else:
					now hpos is hpos + number of characters in descrip entry + 7 + number of characters in "[nearness of tally entry]";
					if you-can-twist:
						increase hpos by opsize of twistiness entry;
					if hpos >= listwidth:
						if in-header is true:
							increment curlines;
							if curlines is 17:
								say "[lb]  ([later].)";
								the rule succeeds;
							say "[lb]  ";
						now hpos is number of characters in descrip entry + 9 + number of characters in "[nearness of tally entry]";
					if in-header is true or localrow is inline:
						say "[descrip entry]@[sector-num of tally entry] ([nearness of tally entry][twistrate of twistiness entry])";
	if in-header is true:
		if thisheaderbreak + 1 < maxalphrows:
			now maxalphrows is thisheaderbreak + 1;
			rejig the status line to maxalphrows rows;
[		if in-header is true:
			now thestring is "[thestring] after=[hpos][line break]";]

to say later:
	say "there's more, but that's enough for now"

in-header is a truth state that varies.

to say noital:
	say "[if in-header is true][roman type][revsty][else][roman type][end if]";

to say revsty:
	(- style reverse; -)

farsies is a list of text variable. farsies is { "buggily near", "buggily near", "extra near", "near", "kinda near", "kinda far", "far", "extra far", "extra extra far", "farthest" }

to say nearness of ( xxxx - indexed text ):
	let ch be the number of characters in xxxx;
	if ch > 10:
		say "buggily far";
	else if ch < 3:
		say "buggily near";
	else:
		say "[entry ch of farsies]";

ok-now is a truth state that varies. ok-now is false.

chapter ting

toggle-suppress is a truth state that varies.

ting is an action out of world.

understand the command "t" as something new.

understand "t" as ting.

understand "t [number]" as xpreing when scenes-in-header.

to decide whether scenes-in-header:
	if player does not have book of secret, decide no;
	decide yes;

xpreing is an action applying to one number.

dont-examine is a truth state that varies;

carry out xpreing:
	follow the screen-size-check rule;
	let q be whether or not list-in-status is true;
	if the rule succeeded:
		now list-in-status is true;
		now dont-examine is true;
		try x0ing the number understood;
		now dont-examine is false;
		say "[if q is false]Updated the rows to see[else][alpha-header-note][end if].";

To decide what number is screenh:
	(- VM_ScreenHeight() -);

t-warn-slow is a truth state that varies.

screen-nag is a truth state that varies;

this is the screen-size-check rule:
	if t-warn-slow is false:
		now t-warn-slow is true;
		say "[italic type][bracket]NOTE: there is currently a slowdown problem with web-based interpreters.[close bracket][roman type][line break]";
	if screenh < 20:
		say "The interpreter screen height of [screenh] is too small for Ed's big list. The minimum needed is 20, and 25+ is preferred.";
		the rule fails;
	if screen width < 85 and superuser is true:
		say "The interpreter screen width of [screen width] is too small for Ed's big list. The minimum needed is 85, and 105+ is preferred.";
		the rule fails;
	if screen width < 105 or screenh < 25:
		if screen-nag is false:
			say "The screen dimensions are [screen width] x [screenh]. Dimensions of at least 105x25 are recommended to be able to see all entries at once but not necessary. You can resize later. Do you still wish to toggle the list inventory to the status bar?";
			unless the player consents:
				say "Ok. You can change your mind later.";
				the rule fails;
		say "[italic type][bracket]NOTE: if you resize to <25 height or <105 width, it is at your own risk.[close bracket][roman type][line break]";
	the rule succeeds;

to say alpha-header-note:
	say "Ok, the list is in the status bar, now[if screen width > 150], though it's trimmed to 150 wide[end if]"

carry out ting:
	if list-in-status is false:
		follow the screen-size-check rule;
		if the rule succeeded:
			now list-in-status is true;
			now task-x is true;
			now task-list is reg-header;
			say "[alpha-header-note].";
		else:
			say "Header list failed.";
	else:
		say "List toggled from status bar.";
		now list-in-status is false;
	the rule succeeds;

chapter tting

tting is an action out of world.

understand the command "tt" as something new.

understand "tt" as tting.

carry out tting:
	if toggle-suppress is false:
		say "Suppressed toggle warning in inventory.";
		now toggle-suppress is true;
	else:
		say "Unsuppressed toggle warning in inventory.";
		now toggle-suppress is false;
	the rule succeeds;

book examining

carry out examining a direction:
	if noun is northwest or noun is northeast or noun is southeast or noun is southwest:
		say "Hey! Looking at street names on signposts is cheating!" instead;
	say "You didn't get your job with Ed Dunn by paying careful attention to where you were going. Or where you came from.";
	the rule succeeds;

book inventory stub

quick-i is a truth state that varies.

check taking inventory:
	if number of visible quasi-entries is 1:
		if quick-i is false:
			now quick-i is true;
			say "You [if front door is visible or sneeds is visible]almost [end if]take a quick step in. ";
			say "[italic type][bracket]NOTE: there's no need to take inventory when you're by something you can enter, so I'm changing 'I' to 'IN.'[close bracket][roman type][line break]";
		try entering a random visible quasi-entry instead;

After printing the name of the book of top secret things while taking inventory:
	say " (can be examined with just X)";

After printing the name of the task-list while taking inventory:
	say " ([if player has book of top secret things]happily obsolete[else]can be examined with just X[end if])";

book ening

ening is an action applying to nothing.

understand the command "en" as something new.

understand "en" as ening.

carry out ening:
	if number of visible quasi-entries is 0:
		say "Nowhere to enter." instead;
	try processing instead;

book blackmarketing

to say recap:
	say "The options are:[line break]1. Hint[line break]2. Adrift-a-tron (tells when things are hopeless)[line break]3. Availableometer (tells what you can do)[line break]4. Twist-o-scope[line break]5. Leave, no teleport[line break]6. Leave and teleport back[paragraph break]";

bm-mode is a truth state that varies.

blackmarketing is an action applying to one number.

understand "[number]" as blackmarketing when bm-mode is true.

carry out blackmarketing:
	if number understood > 6 or number understood < 0:
		say "You need to type a number from 1 to 6, or 0 to recap." instead;
	if number understood is 4:
		say "You accept the twist-o-scope, which hooks up to your list and adds some new information to it. Then the guy mumbles something about proprietary copyrights, and he hides the scope and runs away.";
		now task-list is twisty;
		now suspicious-guy-help is true;
	if number understood is 6:
		say "You zap back to the center before he can say anything. He looks slightly dismayed. But he probably has nowhere better to hang around, if you want to go back.";
	if number understood is 5:
		say "You take your leave, but not before he assures you that way you want to go is nowhere, and oh yeah, talk to him if you change your mind. But you'll probably have to leave and come back.";
		now ignore-susp is true;
	else if number understood is 3:
		say "'Here's your availableometer. It'll tell you how much you can still find as you wander.' ";
		say "[italic type][bracket]NOTE: you can X IT right now, or X METER.[close bracket][roman type][line break]";
		now player has availableometer;
		set the pronoun it to availableometer;
		now suspicious-guy-help is true;
		now oopsy-daisy is 4;
	else if number understood is 2:
		say "'Here's your adrift-a-tron. It'll tell you when you're hopelessly wandering.' ";
		say "[italic type][bracket]NOTE: you can X IT right now, or X TRON.[close bracket][roman type][line break]";
		now player has adrift-a-tron;
		set the pronoun it to adrift-a-tron;
		now suspicious-guy-help is true;
		now oopsy-daisy is 4;
	else if number understood is 1:
		if score < 10:
			say "'Y'might want to wait a bit for just a hint. I can only give one. Sure?'";
			unless the player consents:
				say "'You know where to find me, champ.'";
				now bm-mode is false instead;
		choose a random row in the table of findies;
		while tally entry is "Suss" or found entry > 0 or searchedfor entry is 0 or what-drops entry is front door:
			choose a random row in the table of findies;
		say "He whispers '[tally entry]' in your ear and disappears.";
		now suspicious-guy-help is true;
	else if number understood is 0:
		say "[recap]" instead;
	now bm-mode is false;
	now shiny new store door is off-stage;
	if number understood is 6:
		reset-game instead;

the book of top secret things is a thing. description is "[bug]".

the WWEDD bracelet is a thing. description is "'What would Ed Dunn do?' Ed passed them out at the party. He talked about not being limited by stuffy proper spelling and that sort of thing when thinking big."

check taking off WWEDD bracelet:
	say "Certainly not. It's a gift from Ed. Plus it might have a tracking device." instead;

to say bug:
	say "BUG. You should not have seen this. Contact schultz.andrew@sbcglobal.net with a transcript, or what you were doing, and I'll try to fix that."

the invitation from the Sneeds is a thing. description is "It's a nice handwritten note to stop by any time once you're sick of looking at Threediopolis scenery."

r-noted is a truth state that varies.

ever-twisted is a truth state that varies.

to say row-blab:
		say "[if begin-rows is end-rows]row [begin-rows][else]rows [begin-rows] to [end-rows]";

check examining book of top secret things:
	say "It's divided into six sections[one of], which you can probably guess[or][stopping], and rather flimsy. You count [eggsfound] weird secrets found, of [number of rows in table of scenery]. Below are [row-blab], but you can change which you view with x ##. You don't need spaces.";
	let firstletter be indexed text;
	now firstletter is "a";
	let temp2 be 0;
	let current-rows be 0;
	repeat through table of scenery:
		if character number 1 in tally entry is not firstletter:
			now firstletter is character number 1 in tally entry;
			increment current-rows;
			if current-rows >= begin-rows and current-rows <= end-rows:
				say "[line break]--";
		else:
			if current-rows >= begin-rows and current-rows <= end-rows:
				say ", ";
		now temp2 is number of characters in tally entry;
		if current-rows >= begin-rows and current-rows <= end-rows:
			say "[if found entry is 0][descrip entry] ([entry temp2 in farsies]@[sector-num of tally entry][twistrate of twistiness entry])[else][bold type][tally entry in upper case][roman type][condtwist of twistiness entry][end if]";
	say "[paragraph break]";
	if ever-twisted is false:
		say "You can[one of][or] still[stopping], when you're ready, type XX to eliminate the +/- from places you've seen. The +/- determines twistiness.";
	if r-noted is false:
		say "[italic type][bracket]NOTE: you can, and you probably want to, type R to display the first task (by distance and then alphabetically) or, for more hints, R 9 to show the first nine hints.[close bracket][roman type][line break]";
		now r-noted is true;
	the rule succeeds;

to say condtwist of (nu - a number):
	unless twistx is true:
		say "[twistrate of nu]";

to say twistrate of (nu - a number):
	unless twistx is true:
		say "[if nu < 4]-[end if][if nu < 3]-[end if][if nu < 2]-[end if][if nu > 3]+[end if][if nu > 4]+[end if][if nu > 5]+[end if]";

the availableometer is a thing. the availableometer has a number called charges. charges of availableometer is 10. description is "It is lightweight, totally inexplicable to someone from 20 years ago much less 87 (technology, BOY,) and indicates it has [charges of availableometer] charges left. [italic type][bracket]FOURTH WALL NOTE: the command A activates it.[close bracket][roman type]"

understand "meter" as availableometer.

After printing the name of the adrift-a-tron while taking inventory:
	say " (METER)";

the adrift-a-tron is a thing. the adrift-a-tron has a number called charges. charges of adrift-a-tron is 10. description is "It is lightweight, totally inexplicable to someone from 20 years ago much less 87 (technology, boy,) and indicates it has [charges of adrift-a-tron] charges left. [italic type][bracket]FOURTH WALL NOTE: the command A is shorthand to activate it.[close bracket][roman type]"

understand "tron" as adrift-a-tron.

After printing the name of the adrift-a-tron while taking inventory:
	say " (TRON)";

adrift-on is a truth state that varies.

drift-this-trip is a truth state that varies.

check switching on adrift-a-tron:
	if adrift-on is true:
		say "It already is." instead;
	if drift-this-trip is true:
		say "You already know you're lost." instead;
	say "It's on now.";
	now adrift-on is true instead;

check switching off adrift-a-tron:
	if adrift-on is false:
		say "It already is." instead;
	say "It's off now.";
	now adrift-on is false instead;

every turn when adrift-on is true:
	let a-so-far be 0;
	let mytab be table of findies;
	if pals + edtasks + force-ed-point is number of rows in table of findies:
		now mytab is table of scenery;
	repeat through mytab:
		if tally entry in lower case matches the regular expression "^[your-tally]":
			increment a-so-far;
	if a-so-far is 0:
		say "The adrift-a-tron shrieks as if to say you did something very wrong, then [if charges of adrift-a-tron is 0]goes FOOMP[else]notes it has [charges of adrift-a-tron] charges left. You turn it off[end if].";
		now oopsy-daisy is 5;
		now drift-this-trip is true;
		now adrift-on is false instead;
	if charges of adrift-a-tron is 0:
		now adrift-a-tron is off-stage;

chapter xxing

twistx is a truth state that varies. twistx is usually false.

xxing is an action out of world.

understand the command "xx" as something new.

understand "xx" as xxing when player has book of top secret things or task-list is super-alpha.

carry out xxing:
	now ever-twisted is true;
	if player has book of top secret things:
		say "You [if twistx is false]blot out[else]recall[end if] the depictions of twistiness for scenery you've found.";
		now twistx is whether or not twistx is false;
		the rule succeeds;
	try examining verso instead;

chapter aing

aing is an action out of world.

understand the command "a" as something new.

understand "a" as aing.

carry out aing:
	let mytab be table of findies;
	if pals + edtasks + force-ed-point is number of rows in table of findies:
		now mytab is table of scenery;
	let a-so-far be 0;
	if player does not have availableometer and player does not have adrift-a-tron:
		say "[reject]" instead;
	if player has adrift-a-tron:
		if adrift-on is true:
			try switching off adrift-a-tron instead;
		else:
			try switching on adrift-a-tron instead;
	if number of characters in your-tally is 0:
		say "Best to go somewhere first." instead;
	repeat through table of findies:
		if tally entry in lower case matches the regular expression "^[your-tally]":
			increment a-so-far;
	if a-so-far is 0:
		say "The availableometer registers nothing. But at least you don't lose a charge." instead;
	now oopsy-daisy is 5;
	decrement charges of availableometer;
	say "[if charges of availableometer is 0]Just before your availableometer makes a FOOMP, it shows[else]Your availableometer shows, next to '[charges of availableometer] charges left,'[end if] the number [a-so-far]. [if a-so-far is 1]Guess there's only one path[else]That's how many paths are[end if] ahead from here.";
	if charges of availableometer is 0:
		now availableometer is off-stage;
	the rule succeeds;

chapter newseensing

table of stumblies
tally
"dude"
"new"
"sen"
"sued"
"used"
"weed"
"wend"

newseensing is an activity.

to fake-find (ww - text):
	choose row with tally of ww in table of scenery;
	now found entry is 1;

to decide whether still-there of (ww - text):
	choose row with tally of ww in table of scenery;
	if found entry is 0, decide yes;
	decide no;

rule for newseensing:
	let any-scen-left be false;
	now tt is table of scenery;
	if player has book of top secret things:
		say "You don't need this command, since you already have the book." instead;
	now player has book of top secret things;
	choose row with final response activity of seeing unseen in Table of Final Question Options;
	blank out the whole row;
	now player has the invitation;
	now task-list is off-stage;
	now player wears the WWEDD bracelet;
	repeat through table of stumblies:
		if still-there of tally entry:
			now any-scen-left is true;
	if any-scen-left is true and debug-state is false:
		say "Getting the book this way may opt you out of several bits of scenery you'd have found through solving the game. If you've seen them, or you don't mind them being spoiled, type Y or YES. Otherwise, type N or NO.";
		if the player consents:
			repeat through table of stumblies:
				fake-find tally entry;
		else:
			say "OK.";
	else:
		repeat through table of stumblies:
			fake-find tally entry;
	say "You blink a bit. No, you're off the clock. That's not Ed Dunn's list you're holding. It's a book (well, more like a pamphlet, but don't tell Ed that) of secret places to see in Threediopolis! Of course, you're not told how to get there, or they wouldn't be secret. You've already seen a few of them, doing Ed's tasks.[paragraph break]You also remember your friends the Sneeds would let you crash at any time to wrap up your travels. They'll be nonjudgmental, no matter how much or little you've looked around. A small bracelet falls out as you flip through the pamphlet. You put it on.";
	now package is off-stage;
	now all visible quasi-entries are off-stage;
	now oopsy-daisy is 7;
	now begin-rows is 1;
	now end-rows is 3;
	the rule succeeds;

book cheatlooking

table of hashes
Letter (indexed text)	Code
"e"	5
"w"	5
"n"	3
"s"	3
"u"	100
"d"	100

look-mode is a truth state that varies.

understand "[number]" as cheatlooking when look-mode is true.

to decide what indexed text is the filtered name of (t - a value of kind K):
	let s be t in lower case;
	replace the regular expression "<^abcdefghijklmnopqrstuvwxyz>" in s with "";	[ a-z would include accented characters]
	decide on s;

to decide what number is the hash of (t - a value of kind K):
	let s be the filtered name of t;
	let hash be 0;
	repeat with c running from 1 to the number of characters in s:
		if there is a letter of character number c in s in the table of hashes:
			increase hash by the Code corresponding to a Letter of character number c in s in the table of hashes;
		else:
			decide on 500;
	decide on hash;

dirparsing is a truth state that varies.

posschars is a number that varies.

ignore-remaining-dirs is a truth state that varies.

looks-by is a number that varies.

table of lookbys [tol]
looky
"You plan ahead, yet don't plan at all at the same time, as you zigzag through Threediopolis"
"You put your head down and power-walk, only looking up for 3-d traffic lights"
"You walk by several identical twenty-story buildings owned by Tiny-Rise Condos"
"You find a cool shortcut with moving walkways that you soon forget"
"It's a quick journey. The lines for the vertical transport tubes are short, so no people-phalanxes block the sidewalks"
"You careen past police robots gaffling a fellow walker for aggravated wrong-way walking. Hey, the algorithms are proven to be fair"

to dirparse (dirlump - indexed text):
	if number of characters in dirlump > 2 and number of characters in your-tally > 0:
		say "You aren't starting from the center. Do you still wish to turbo ahead?";
		if the player consents:
			say "Ok.";
		else:
			say "Just type p to go to the center and try again.";
			continue the action;
	if number of characters in dirlump > 13:
		say "That is way too long a trip to even think about.";
		continue the action;
	let allchar be number of characters in dirlump;
	let ef be ever-fast;
	if ever-fast is false:
		say "You pick up the pace of your wandering, there, planning a few blocks ahead.";
		now ever-fast is true;
	else:
		unless set to abbreviated room descriptions:
			increment looks-by;
			if looks-by > number of rows in table of lookbys:
				now looks-by is 1;
			choose row looks-by in table of lookbys;
			say "[looky entry].";
	now dirparsing is true;
	now posschars is number of characters in your-tally + allchar;
	repeat with charnum running from 1 to allchar:
		if bm-mode is true:
			continue the action;
		unless ignore-remaining-dirs is true:
			if character number charnum in dirlump is "w":
				try going west;
			if character number charnum in dirlump is "e":
				try going east;
			if character number charnum in dirlump is "n":
				try going north;
			if character number charnum in dirlump is "s":
				try going south;
			if character number charnum in dirlump is "u":
				try going up;
			if character number charnum in dirlump is "d":
				try going down;
			if character number charnum in dirlump is ".":
				say "[italic type][bracket]NOTE: ignoring period.[close bracket][roman type][line break]";
	now ignore-remaining-dirs is false;
	now dirparsing is false;
	now posschars is 0;

brief-warn is truth state that varies;

ever-fast is a truth state that varies.
fast-run is a truth state that varies.

reserve-command is indexed text that varies.

to eval-dir (firstlet - text):
	let foundany be false;
	let whatever be indexed text;
	let foundsofar be 0;
	let mytab be table of findies;
	if player has book:
		now mytab is table of scenery;
	repeat through mytab:
		if character number 1 in tally entry in upper case is firstlet and found entry is 0:
			increment foundsofar;
			if a random chance of 1 in foundsofar succeeds: [silly code but 1/1 chance we choose 1st, 1/2 we choose 2nd, 1/3 we choose 3rd, and choices overwritten]
				now whatever is "[tally entry]";
			now foundany is true;
	if foundany is false:
		say "The scope doesn't budge that way. Maybe that's a good thing--you don't need it to.";
		continue the action;
	else:
		[say "Found [foundsofar], [foundany], [whatever].";]
		give-clue whatever;
	now the command prompt is ">";
	now alpha-look-mode is false;

cheatlooking is an action applying to one number.

saw-see is a truth state that varies.

carry out cheatlooking:
	let found-one be false;
	let temp be 0;
	let temp2 be 0;
	let start-number be 0;
	let end-number be 0;
	now saw-see is true;
	if the number understood is 0:
		say "You decline hints for now. You decide to hit the teleporter button, too.";
		now look-mode is false;
		now the command prompt is ">";
		reset-game instead;
	if the number understood is 1 or the number understood is 2 or the number understood is 9:
		say "Nothing's quite that [if the number understood is 9]far[else]near[end if]." instead;
	if the number understood > 10:
		say "Even if something were there, it'd be too far to walk without getting tired." instead;
	if the number understood is not listed in L:
		say "Bad news: that isn't available as an option. Good news: it's because you've gotten everything like that." instead;
	now look-mode is false;
	now the command prompt is ">";
	let LN be a list of numbers;
	repeat through table of findies:
		increment temp;
		if number of characters in tally entry is the number understood:
			now end-number is temp;
			if found-one is false:
				now start-number is temp;
				now found-one is true;
			if found entry is 0:
				add temp to LN;
	sort LN in random order;
	now temp is entry 1 of LN;
	choose row temp in table of findies;
	give-clue tally entry;

to give-clue (walkclued - indexed text):
	increment num-hints-given;
	say "[line break]You see a graphical depiction of someone walking [dir-go of walkclued], but then your vision loses focus.[paragraph break]You're informed you have [3 - num-hints-given] hint[if num-hints-given is not 2]s[end if] left. Then you push the teleporter device button to get back to where it'll be easier to follow that person.";
	reset-game;

to say dir-go of (t - indexed text):
	let tt be indexed text;
	now tt is "[t in lower case]";
	repeat with X running from 1 to the number of characters in tt:
		if X > 1:
			say ", ";
		if X is the number of characters in tt:
			say "then finally ";
		if character number X in tt is "e":
			say "east";
		if character number X in tt is "w":
			say "west";
		if character number X in tt is "n":
			say "north";
		if character number X in tt is "s":
			say "south";
		if character number X in tt is "u":
			say "up";
		if character number X in tt is "d":
			say "down";

chapter ring

r1ing is an action out of world.

understand the command "r/rr" as something new.

understand "r" and "rr" as r1ing.

ring is an action applying to one number.

understand the command "r/rr [number]" as something new.

understand "r [number]" and "rr [number]" as ring.

carry out r1ing:
	if task-list is detail-header:
		say "First task list element is now not in header.";
		now task-list is reg-header instead;
	try ring 1 instead;

expected-depth is a number that varies.

carry out ring:
	let other-num be 0;
	if number understood < 1:
		try r1ing instead;
	now expected-depth is the number understood;
	if player does not have book of top secret things:
		now other-num is (maxedtasks - edtasks) - force-ed-point;
	else:
		now other-num is number of rows in table of scenery - eggsfound;
	[say "[maxedtasks]  - [edtasks] - [force-ed-point]  = [other-num].";]
	[say "Exp [expected-depth] vs other # [other-num] vs left [maxedtasks] max ed [edtasks] force [force-ed-point].";]
	if expected-depth > 9:
		now expected-depth is 9;
	if other-num is 0:
		if pals < maxpals:
			now task-list is friend-header;
		say "You've found all the non-friend tasks[if maxpals is pals], and the friends too. Time to see Ed Dunn[else], but you have some friends left to find, so I'm switching you to the friends header[end if]." instead;
	if expected-depth > other-num:
		now expected-depth is other-num;
	if expected-depth < number understood:
		say "[italic type][bracket]NOTE: cutting down to [expected-depth] rows.[close bracket][roman type][line break]";
	say "Header now shows first [if expected-depth > 1][expected-depth] task list elements[else]task list element[end if].";
	now task-list is detail-header;
	now list-in-status is false;
	the rule succeeds;

chapter friending

friending is an action out of world.

understand the command "f" as something new.

understand "f" as friending.

to say pal-list:
	let yet be 0;
	say "Pals: ";
	repeat through table of findies:
		if findtype entry is chums:
			increment yet;
			say "[if found entry is 1][tally entry][else][friend-first of tally entry][sector-num of tally entry][end if]";
			if number of characters in tally entry > 3 and found entry is 0:
				repeat with counter running from 4 to number of characters in tally entry:
					say "*";
			if yet < maxpals:
				say "/";

to say friend-first of (te - indexed text):
	if friendfirst is false:
		continue the action;
	say "[character number 1 in te in upper case]";

friendfirst is a truth state that varies.

friend-warn is a truth state that varies;

to say allpals:
	say "You remember Ed's friends: Dee, Deedee, Des, Ewen, Ned, Sue, Swen, Uwe, Wendee and Wes. They sure knew their way around Threediopolis. You guess you could stop by and maybe there'd be a hint";

carry out friending:
	if player has book:
		say "[allpals]." instead;
	if friends-found is maxpals:
		say "You already found everyone.";
		continue the action;
	say "[pal-list].";
	unless task-list is friend-header:
		if friend-warn is false:
			now friend-warn is true;
			say "[line break]";
			say "[italic type][bracket]NOTE: while friends are still left, you can focus on them in the status bar with ff.[close bracket][roman type]";
	the rule succeeds.

chapter friendtoping

chapter ffing

ffing is an action applying to nothing.

understand the command "ff" as something new.

understand "ff" as ffing.

carry out ffing:
	if player has book:
		say "[allpals]." instead;
	if friends-found is maxpals:
		if edtasks + pals is number of rows in table of findies:
			say "Neither the friend list nor task list is helpful now, because you solved everything. Go, you!" instead;
		say "You've found all Ed's friends, so that part of the list isn't so helpful now. Go, you! You may wish to try oo[if task-list is super-alpha] or mm[end if] instead." instead;
	if task-list is not friend-header:
		say "Friends are now in header[ast-long].";
		now list-in-status is false;
		now task-list is friend-header;
	else:
		say "Friends are now not in header.";
		now task-list is reg-header;
	the rule succeeds.

to say ast-long:
	let aster be found corresponding to a tally of "Ewen" in table of findies + found corresponding to a tally of "Swen" in table of findies + found corresponding to a tally of "Wendee" in table of findies;
	say "[if aster is 0]. More asterisks = further distance[end if]";

chapter ffing

fffwarn is a truth state that varies.

fffing is an action applying to nothing.

understand the command "fff" as something new.

understand "fff" as fffing.

carry out fffing:
	if player has book:
		say "[allpals]." instead;
	now fffwarn is true;
	if friends-found is maxpals:
		if edtasks + pals is number of rows in table of findies:
			say "Neither the friend list nor task list is helpful now, because you solved everything. Go, you!" instead;
		say "You've found all Ed's friends, so that part of the list isn't so helpful now. Go, you! You may wish to try oo[if task-list is super-alpha] or mm[end if] instead." instead;
	if task-list is not friend-header:
		say "Friends are now in header[ast-long].";
		now task-list is friend-header;
	if friendfirst is false:
		say "Adding first letter to friends.";
		now friendfirst is true;
	else:
		say "Removing first letter from friends.";
		now friendfirst is false;
	the rule succeeds;

chapter mming

mming is an action out of world.

understand the command "mm" as something new.

understand "mm" as mming when task-list is super-alpha and player does not have book.

carry out mming:
	if player has book of top secret things:
		say "This doesn't work now that you don't need Ed's list." instead;
	if task-list is byrow-header:
		choose-new-row;
		say "You flip [if cur-byrow is 1]back to the top[else]to the next[end if] row.";
	else:
		say "Placing one row of tasks at the top.";
		now task-list is byrow-header;
	the rule succeeds;

to choose-new-row:
	if edtasks is maxedtasks:
		say "You don't need to browse, since you have all the points.";
	let search-row be cur-byrow + 1;
	if search-row > 7:
		now search-row is 1;
	let morethanone be 0;
	while cur-byrow is not search-row:
		let adjmin be entry search-row in rowstart;
		let adjmax be (entry (search-row + 1) in rowstart) - 1;
		repeat with Q running from adjmin to adjmax - 1:
			choose row Q in table of findies;
			if found entry is 0:
				say "You flip [if cur-byrow > search-row]up[else]down[end if] the list[if morethanone is 1]--skipping a row you completed[else if morethanone > 1]--skipping rows you completed[end if].";
				now cur-byrow is search-row;
				continue the action;
		increment morethanone;
		increment search-row;
		if search-row > 7:
			now search-row is 1;
	say "Something happened. I wasn't able to find a row, and I should have. Let me know what you have left and what you just found or tried and I'll fix this. [bug].";

chapter ming

ming is an action applying to one number.

mnexting is an action out of world.

understand the command "m" as something new.

understand "m [number]" as ming when task-list is super-alpha and player does not have book.

understand "m" as mnexting when task-list is super-alpha and player does not have book.

dirs is a list of text variable. dirs is { "D", "E", "N", "SE", "S", "U", "W" }

to say extras of (XTR - text):
	let asts be number of characters in XTR - 3;
	repeat with temp running from 1 to asts:
		say "*";

cur-byrow is a number that varies. cur-byrow is 2.

carry out mnexting:
	if task-list is not byrow-header:
		say "Changing task list in header to rows.";
		now task-list is byrow-header;
	choose-new-row;

carry out ming:
	if player has book of top secret things:
		say "This doesn't work now that you don't need Ed's list." instead;
	if task-list is not super-alpha and debug-state is false:
		say "You can't shift the list this way until you have accepted a certain bit of help." instead;
	if number understood < 1 or number understood > 7:
		say "You can only pick from rows 1-7." instead;
	if list-in-status is true:
		deepen the status line to 1 rows;
	now cur-byrow is number understood;
	if task-list is byrow-header:
		say "Row [number understood] is now at the top";
		let search-row be cur-byrow + 1;
		if search-row > 7:
			now search-row is 1;
		let hasempty be false;
		let adjmin be entry search-row in rowstart;
		let adjmax be (entry (search-row + 1) in rowstart) - 1;
		repeat with Q running from adjmin to adjmax - 1:
			choose row Q in table of findies;
			if found entry is 0:
				now hasempty is true;
		say "[unless hasempty is true], though you've found everything in it[end if].";
	else:
		say "You glance at row [number understood], and it says [thisrow of number understood][line break]";

to say thisrow of (YZ - number):
	let new-row be false;
	let count be 0;
	say "[rowprint of entry YZ of dirs]";

to say rowprint of (YY - text):
	let count be 0;
	if pals + edtasks > 14:
		say "[YY]:";
	repeat through table of findies:
		if YY is "SE":
			if character number 1 in tally entry is "S" and character number 2 in tally entry is "e":
				if count > 0:
					say "/";
				increment count;
				if found entry is 0:
					say "[sector-num of tally entry][extras of tally entry]";
				else:
					say "[tally entry]";
		else:
			if character number 1 in tally entry is YY:
				unless YY is "S" and character number 2 in tally entry is "e":
					if count > 0:
						say "/";
					increment count;
					if found entry is 0:
						say "[sector-num of tally entry][extras of tally entry]";
					else:
						say "[tally entry]";

chapter oing

oing is an action out of world.

understand the command "o" as something new.

understand "o" as oing.

to decide which number is my-chars:
	let temp be 9;
	if task-list is super-alpha:
		repeat through table of findies:
			if findtype entry is not chums and found entry is 0:
				if number of characters in tally entry < temp:
					now temp is number of characters in tally entry;
					if temp is 3:
						decide on 3;
		if temp is 9:
			decide on 0;
		decide on temp;
	repeat through table of findies:
		if findtype entry is not chums and found entry is 0:
			decide on number of characters in tally entry;
	decide on 0;

last-far is a number that varies.

oo-warn is a truth state that varies.

carry out oing:
	if player has book:
		say "With the book, by-distance hinting won't fit in the header. You can use R 9, which works, instead." instead;
	let myt be my-chars;
	let commas be false;
	if myt is 0:
		say "Hmm, you don't have anything left!" instead;
	if last-far > 0 and myt > last-far:
		let myt2 be myt - 1;
		say "You click your tongue now you've solved everything up to [entry myt2 in farsies]. Next![paragraph break]";
	say "You glance at the [entry myt in farsies] line.[paragraph break]";
	now last-far is myt;
	repeat through table of findies:
		if number of characters in tally entry is myt and findtype entry is not chums:
			if commas is false:
				now commas is true;
			else:
				say ", ";
			say "[if found entry is not 0][tally entry][else][descrip entry]@[sector-num of tally entry]";
	say ".";
	if oo-warn is false:
		now oo-warn is true;
		say "[italic type][bracket]NOTE: you can put a list of numbers and found tasks in the status line with oo.[close bracket][roman type][line break]";
	the rule succeeds;

chapter ooing

ooing is an action out of world.

understand the command "oo" as something new.

understand "oo" as ooing.

carry out ooing:
	if player has book:
		say "The command you want now is probably R, since the scenery clues are a bit more intricate." instead;
	if edtasks + maxpals is number of rows in table of findies:
		say "You're all done." instead;
	if edtasks is maxedtasks:
		say "You've done all the tasks but haven't gotten all Ed's friends. Maybe try FF instead." instead;
	if task-list is oneline-header:
		now task-list is reg-header;
		say "Regular header." instead;
	else:
		say "Top line is now in header.";
		now list-in-status is false;
		now task-list is oneline-header;
	the rule succeeds;

chapter fasting

fasting is an action out of world.

understand the command "j/jump" as something new.

understand "j" and "jump" as fasting.

carry out fasting:
	now ever-fast is true;
	if fast-run is false:
		say "Jump mode is on, e.g. NWU or NW diagonals are no longer questioned.";
		now fast-run is true;
	else:
		say "Jump mode is off, e.g. NWU or NW diagonals are now questioned.";
		now fast-run is false;
	the rule succeeds;

chapter default

check waking up:
	say "You had your vitamin mush this morning. You're wide awake." instead;

check waving:
	say "If Ed Dunn is watching, he may want you to get on with it. If the government is watching, they aren't amused." instead;

check jumping:
	say "No reason to, with vertical transport tubes to go up and down." instead;

check smelling:
	if your-tally is "weed":
		say "Smells like someone's having a mellow time." instead;
	say "Pollution is 96% less stinky than a hundred years ago. Which isn't all good. Now, you can't tell if it's killing you." instead;

book scoring

to decide what number is county of (qua - a quality):
	let A be 0;
	repeat through table of findies:
		if findtype entry is qua and found entry is not 0:
			increment A;
	decide on A.

to decide what number is maxy of (qua - a quality):
	let A be 0;
	repeat through table of findies:
		if findtype entry is qua:
			increment A;
	decide on A.

nohelpitems is a number that varies. helpitems is a number that varies.

carry out requesting the score:
	if player has book:
		say "You've completed all of Ed's tasks, and now you're looking for scenery from the book. So far, you've got [eggsfound] of [number of rows in table of scenery] of them." instead;
	say "Overview: you have completed [pals + edtasks] of Ed's [maxedtasks + maxpals] tasks, [nohelpitems] on your own and [helpitems] with his revised lists. You can look [if list-in-status is true]in the header, too[else]at your list (just type X) for what's left[end if]. More details are below.[paragraph break]--[county of chums] of Ed's [maxpals] friends found[line break]--[county of stuffly] of [maxy of stuffly] places that give Ed more stuff[line break]--[county of biz] of [maxy of biz] ways to help Ed's business[line break]--[county of relax] of [maxy of relax] tasks that will help Ed relax[line break]--[county of party] of [maxy of party] ways to help Ed with his upcoming party[line break]--[county of youish] of [maxy of youish] recommended things for your own amusement and enlightenment.";
	let my-eggs be eggsfound;
	if my-eggs > 0 and pals + edtasks > 0:
		say "[line break]You have also found [my-eggs] of [number of rows in table of scenery] unusual landmarks/incidents that give color to Threediopolis.";
	the rule succeeds;

Procedural rule: ignore the print final score rule.

book disambiguation

Rule for clarifying the parser's choice of book of top secret things: do nothing.
Rule for clarifying the parser's choice of task-list: do nothing.

book stupid scenery

table of scenery [tos]
tally (text)	descrip (text)	foundit (text)	found	twistiness	diffic
"dds"	"toothy"	"You feel a toothache. You think[if player has book]. And just like that, someone offers to send you a free voucher for an ergonomic toothbrush. Dental replacements are cheap in 2100, but prevention is still cheaper[end if]. "	0	2	alfhint
"dedend"	"kuldissakk"	"You can just hear the misspelling in the people saying nuthing that way dood."	0	3	alfhint
"dedsune"	"deth neer"	"This feels like one of those seedy areas you were warned about, where a pack of bad-spelling thugs might jump out and kill you."	0	5	tough
"dedududu"	"police zigzag here"	"A song from the 80s--thankfully not the too-cheesy 2080s--echoes through your head. The chorus, anyway. A policeman stands too close to you, tracking every breath you take."	0	3	tough
"deduse"	"git cloos then figger"	"Dudes see u, essess your list, call it trivial, and move on to more properly brain-bending things. You realize you've encountered a special task force encouraged to ignore spelling so they can focus on deeper things. (Ironically, they're often great grammar cops.)"	0	4	misp
"deesensee"	"Morrul Peepul"	"People who can't spell worth a dang weigh in on complex ethical questions with impressive oversimplification. It's good practice to refute them scientifically in your head, but bad policy to actually debate."	0	4	misp
"deneennunn"	"author of Unended"	"A security guard backs you off. 'No fans. This is Deneen Nunn's mansion. she is a busy woman, what with the sequel to Unended she's writing.'[paragraph break]'What's it called?' 'Denuded. Don't ask what happens to Neenu Unwen.' You're whisked away, but not before you catch a glimpse of next book's title: NEW ENDS."	0	4	alfhint
"dense"	"lots of people"	"You're in an unusually overpopulated area of Threediopolis. And yet, nothing seems worth visiting."	0	4	tough
"denude"	"get pranked"	"Some weirdo runs by and tries to pull your pants down. You swat him away. He won't try again!"	0	4	tough
"desdenee"	"see fyootyer thingees"	"Someone tells you you will finish your journey when you are good and ready, whether or not you've found everything you wanted to. They offer a fortune with actual details for the low price of...[paragraph break]You turn away before they finish their pitch."	0	4	misp
"deseesed"	"symmetrik funeril hom 4 long tyme sikk"	"People sob here, in their own way, over loss. The sentiments are hackneyed and in bad grammar. But you feel guilty for nitpicks. You move on."	0	3	misp
"desended"	"ancestur trakker"	"A man offers to figure your 'real' nationality and famous ancestors--none of these rigged DNA tests--for free. But halfway through he says he needs to look further back, and it will require money. You run away."	0	4	misp
"deweese"	"Seeweed HQ"	"Here's where DeWeese Seeweed makes their food. It's lovely and salty and just like the actual sea except less stinky."	0	4	tough
"dnd"	"chaot. gam. soc."	"You feel temporarily devoid of dexterity and wisdom as you step on a discarded 20-sided die. Well, it could've been a 4-sider. You look around, but it's a really do-not-disturb area."	0	3	alfhint
"dude"	"lebowskiosity"	"There's an argument in the distance about whether someone crossed a foul line while bowling. Someone out of his element with no frame of reference shouts 'Well, that's just your opinion, man!' Silence abides."	0	3	tough
"dues"	"yearly fee"	"You overhear 'Come on, it's less than a tithe--and we're more likely to exist than an Invisible Cloud Being.' You actually learn a lot of scam techniques and ways to outsmart or reject them."	0	4	alfhint
"dundee"	"no wildlife or Australians"	"You hear vague Scottish accents around. People talk about how that's not a knife, THAT's a knife."	0	4	tough
"dunse"	"speling leson, dum dum"	"You listen to some loud idiot who can't pronounce or spell anything for a bit."	0	5	misp
"duses"	"dyse n kards"	"All sorts of street gambling occurs here. Casinos are required to have odds warnings labeled prominently on all machines, which hasn't hurt business, but it's more fun and lively out here."	0	4	misp
"eden"	"before history"	"You think back to how humanity started, for some reason. This place was probably innocent, long ago."	0	3	alfhint
"eeee"	"a scream"	"You hear a piercing scream! Well, it's not the first you've heard. And you didn't, like, hear any violence either. In city life, you learn to deal."	0	1	alfhint
"eesus"	"blassfeemer"	"A man with slicked-back hair, in a purple shirt and pants, holding a purple bowling ball, cooly rails off threats of cap-busting, whatever that is, before glide-walking away. Odd. That was completely frivolous yet profound in its own way!"	0	3	alfhint
"endeed"	"genrul enkurijment/agremeent"	"You're waylaid by happy-idiotic conversation from various street preachers. At first, you listen to be polite, but you get sucked in, and you find yourself hearing, and saying, 'Indeed! Indeed!' You're not sure why that helped you feel more confident, but you remember studies proving this sort of thing works at a molecular level--provided the person doesn't expect it to. So you probably can't come back for seconds."	0	3	alfhint
"ennuee"	"fake ty-urd fillosoferz"	"A bunch of poseurs in berets discuss the most exciting reason to feel bored. They ask you for one, and when you mumble, they ditch you as uninteresting."	0	3	alfhint
"ensue"	"let stuff happen here"	"Time seems to pass and things seem to cause each other to happen here."	0	4	tough
"essen"	"german eateries"	"You smell sauerkraut and bratwurst, briefly. But that passes. No time for food, anyway."	0	3	tough
"esses"	"squiggly area"	"You walk by a rare curving side street. Walking down it would be too dangerous if a car came the other way."	0	2	alfhint
"euwe"	"chess champs['] park"	"People play chess here--pfft, the simple version solved as a draw in 2037, not even the Fischer 960 version dissected twenty years later--and yell in Dutch as you walk by."	0	3	tough
"eww"	"messy area"	"You just stepped in something disgusting. You shuffle your shoe to scrape it off and move on."	0	2	alfhint
"nene"	"Hawaiian geese/zoo"	"The local zoo gives priority to kids and families, but you still look in. Hawaiian animals are special. All but Oahu went underwater after global warming, and only now is the whole archipelago making a slow comeback. "	0	2	alfhint
"ness"	"mystic animal, no lake"	"You suddenly worry a mythical water beast is around, though there's no lake for miles. But it's just the world's most believable dinosaur statue. Pfft. You move on."	0	3	alfhint
"new"	"not old"	"A construction site you pass by--and promptly forget about--promises state of the art homes for sale soon."	0	3	tough
"newdude"	"help recent resident"	"Someone looks confused, and you're surprised you're able to give good directions, just by thinking logically about where things must be. or not."	0	5	tough
"newwessewn"	"Area you remembered scoring 36 points"	"You pass by a gated community full of mansions. Maybe one day you'll deserve to live there."	0	4	tough
"nusense"	"fresh wiizdum frum yuneekly un-noying gy"	"Some fellow on a soapbox brings up obvious counters to conventional wisdom--it's not really *new* sense, though. After a while, he becomes...un-nu. A nuisance. You move on."	0	4	misp
"sed"	"learn about string replacement"	"You stumble by a bunch of techies discussing awk and grep and discussing how it's all more fun and interesting than silly puzzle boxes with no purpose. Not that the guy who just passed would be good at either."	0	3	alfhint
"seduse"	"riskay nite klub 1"	"A louche woman in a DUENDE ENDUED tank top futzes with her Vita-Vape electronic-cigarette replacement (outside the sleazy club, by law) and says you look like you have been thinking too hard but fails to eduse any desire. She's no Neenu Weeden or Susee Nen. You quickly hustle away, more sure than ever that figuring things out beats more primal urges."	0	4	misp
"seedee"	"tuff nite klub 2"	"Outside a nightclub, people beatbox incessantly to blasted rhymes (and almost-rhymes and words that rhyme with themselves) so old they're cool again, or so old-cool again they're just way too old, now. The portmanteaus 'Seediopolis' and 'Greediopolis' pop up every other verse. You were already going to run away when the next song, the groanworthy 'classic' 'Dees Nuds,' starts."	0	3	alfhint
"seen"	"surveillance"	"You hear the whirr of a hidden security camera. Ooh! Here's where the Guinness 'Most Surveilled Suburb' is!"	0	3	alfhint
"seesuns"	"6-12 munths at wunse. Enlitening!"	"You find a free museum exhibit that lets you experience the whole year in four minutes. It's illuminating, like looking right into a binary star."	0	4	misp
"seeus"	"attention hogs"	"You ignore people waving and yelling for attention for its own sake."	0	3	alfhint
"sen"	"Pol., not quite rep. or gov."	"You are redirected around a political rally where people chant 'We need Wu!' then 'Wu needs us!'"	0	3	alfhint
"senessense"	"Ol['] fokes hom"	"A retirement home that is trying to be hip with a few 'cool' misspellings there. You can't--you won't look--you just move on. Not something to think about. What with the population retracting and not enough people staffing and science not able to stave off old age much longer than eighty years ago. Nevertheless, it motivates you to Do Stuff Now."	0	3	misp
"sensen"	"Confections! Confections!"	"Someone hands you a free packet of breath mints. you're not sure if this means you deserve fresh breath or you have really bad breath. it's nice and licorice-y."	0	3	tough
"sensus"	"Make yurself count"	"You find a building where you fill out personal details--nothing too detailed--but you are denied a free sticker for your troubles because you didn't produce ID readily enough. You did your civic duty, I guess."	0	4	tough
"sesede"	"freedum diskushin kunfedrasee"	"A bunch of idiots wearing colonial costumes complain they pay too much in taxes and want out of Threediopolis. You've seen studies saying the reverse is true, but other studies show these people can't be argued with."	0	3	alfhint
"seuss"	"oh, a thing you'll see"	"A fuzzy something-or-other in a star-bellied t-shirt stops ranting about trees and how to butter bread to ask directions to somewhere called Solla Sollew. Seeing your list, he remarks 'Oh, the places you'll go,' before running off."	0	3	alfhint
"sewnsew"	"feel silly [']n silly"	"Your clothes suddenly feel like a schlumpf or a bum or something or other."	0	4	tough
"sneeds"	"Denese and/or Sed"	"[if player does not have book]You see someone you don't know who looks really nice, then reflexively give a wave but forget what they look like[else][one of]It's the Sneeds[']![or]The Sneeds['], again.[stopping] You can enter if you've done all you want to. They'll be glad to see you no matter how much scenery you've found.[end if]"	0	4	tough
"sneese"	"Pepperee sinus freeing"	"You--whew--well, you were worried your sinuses were clogging up, but the air here did you a power of good."	0	3	misp
"snes"	"retro comp. pt. 2"	"An area much like the retro competition you saw earlier! It seems more colorful, but maybe it's lost a bit of soul. You catch a glimpse of a classic you always meant to play, then move on."	0	3	tough
"sudden"	"bang"	"A loud noise from nowhere surprises you."	0	5	tough
"sued"	"legal trouble"	"Someone moans about his trouble with lawyers. You tune that whining out."	0	4	tough
"sundew"	"plant not shiny or wet"	"You pass by a warning for a carnivorous plant."	0	6	tough
"suns"	"get blinded"	"As you walk by, the sun manages to bounce off two buildings curved so that the sun hits your eyes--twice. You blink and can't recognize anything[if-snus]."	0	3	tough
"sununu"	"political name"	"A political rally. 'Wu! Unneeded dud!' a man shouts as he advocates education in stilted sentences. Stuff like that might pass in New Hampshire, but not here."	0	3	alfhint
"sussud"	"phi colli fa clu"	"A song from the 80s--the 1980s--echoes through your head. You remember about three-quarters of it."	0	3	tough
"swedes"	"little Scandinavia"	"You're in an ethnic residential district. [biz-dist]."	0	4	tough
"sweenee"	"where the hot dog hut was"	"A big sign says Sweenee Weenee's has moved[swee-try]."	0	4	tough
"swune"	"c sumwun handsum n faymus"	"Oh my god--it's--it's--EEEEE! Suddenly, you care little for spelling or logic or anything. You just saw...[paragraph break]...and you realize you'll only see someone THAT famous up-close WUNSE."	0	5	misp
"unded"	"hontid howse: zombees, gools"	"You haven't been to one of these in a while. It's really cute by the entry, with kids trying to be scary, until you remember that it may just be adults coaching kids to be pseudo-cute and overdo the youthfully earnest bit. It's down to a science these days, the buttons you can push. You move on and decide not to get fleeced."	0	4	misp
"undees"	"boxee breefs"	"You didn't want to admit you needed a few new pairs, but you did. You go in for a nice geometric pattern. From your own pocket, of course. Not Ed Dunn's."	0	5	misp
"undue"	"criticism to ignore"	"Someone walks by and gives you an insult you didn't deserve. It has a bit of truth, but that was probably by accident."	0	4	tough
"unneeded"	"to feel emo"	"You suddenly feel as if nobody, not even Ed Dunn, cares about you."	0	4	alfhint
"unseeded"	"underdogs in knockout tourney"	"You hear a pep rally for the local underdog team who's gone rather far in some tournament in some sport or other."	0	5	tough
"unsewn"	"threadbareness"	"A button falls off your outfit and rolls where you can't find it. Well, it's biodegradable enough."	0	5	tough
"unsunned"	"dark gothy neighborhood"	"You walk by some people with remarkably pale skin. Tanning parlors are TOTALLY safe these days, but some people just don't trust the government."	0	5	tough
"used"	"well worn"	"You feel beaten-down and second-hand all of a sudden. Maybe even wondering if you'll always be a gofer to Ed Dunn types. But maybe you are halfway to somewhere Ed needs you to go."	0	4	alfhint
"wednesd"	"18 2/3 hours"	"You temporarily forget what day it is. Wait, it's on the tip of your tongue."	0	5	tough
"weed"	"the good herb"	"Based on the smell, maybe there are private gardens behind some walls here, maybe not. Some people just won't pay the exorbitant taxes for growing...that."	0	3	alfhint
"weeeeee"	"amusement park"	"You walk past a big amusement park. People are screaming. You'd probably have to give up your cool high-tech stuff if you stopped in, but you can imagine the feeling, and that's enough."	0	2	alfhint
"weeuns"	"tinykids compound"	"You get in touch with your inner child, including the one that was kinda jealous of what other people have. All the progress in child care since when...then you're waylaid to tell a story about the old days and it's kind of fun, really. Some stuffy bureaucrat stamps your monthly Generational Relations file with a 'satisfactory.'"	0	5	tough
"weewee"	"public nuisance"	"You just stepped in a puddle, though it hasn't rained much lately. Whoever, uh, made that puddle is really juvenile."	0	2	tough
"wend"	"contorted traveling"	"Your most recent turning and twisting around seems like it should've led somewhere. But it did not. Yet."	0	4	alfhint
"wenewenew"	"symmet. statue 2 insite, lurning, NOWLEDGE"	"You pass by a large statue that reminds you of times the penny--well, it's the dime these days, the penny being devalued--dropped. It felt good then and feels good now."	0	3	alfhint
"wenus"	"LOVVELY plannetorryum"	"The knowledge and ideas passed along here is very colloquial but nonetheless useful. Some cranks are disappointed nobody's really started on space travel, and despite their political views, you leave thinking, if only you'd been taught this way in school, instead of all that memorization!"	0	5	misp
"wewun"	"histery/viktery monyumint"	"You pass by a large monument commemorating some war or other that may not have ended as successfully as the government says it did. A victory over eggheadedness, grammar policing, general old-school stuffiness, and so forth. It's guarded by video cameras, and you hope they didn't catch you frowning as you walked past."	0	4	misp
"wudden"	"hand karved krafts"	"Everything's overpriced in an outdoor market here, since cutting down trees is regulated now--but it needs to be. Still, you love browsing and seeing the texture metal and synthetics can't provide."	0	5	misp
"wuwu"	"peppy radio station"	"Yes--it is--offices for a radio station, with all the old gear and stuff, before podcasts. How quaint!"	0	2	alfhint
"www"	"internet presence"	"A really cool idea for a website pops into your head. Then you forget it."	0	1	alfhint

table of nearlies [ton]
tally (text)	just-miss (text)	found-yet	descrip (text)	rule-to-reveal
"deesended"	"desended"	false	"[kids-desend]."
"deesendens"	"desended"	false	"[kids-desend]."
"deesseed"	--	false	"You pass by a flower place that caters to [flowery], but the store doesn't really count as scenery, [if player does not have book]and Ed doesn't need flowers, [end if]so you move along."
"desendens"	"desended"	false	"[kids-desend]."
"eddunn"	--	false	"You don't want or need to go back to Ed Dunn's right now. Maybe you could visit the Sneeds, instead."	has-book rule
"ende"	--	false	"You suddenly have an urge to read a children's book, the sort that goes on and on and you're just glad it does, and you're ready to read from the start again when it's over."
"newness"	--	false	"You feel slightly refreshed, but you don't actually SEE anything. Plus, you remember how just going around Threediopolis will give Ed's tasks newness."
"newsense"	"nusense"	false	"You pass by someone who is promoting some up-to-date thinking, but he's not quite annoying or ludicrous enough to be memorable. Maybe there is someone close to just above."
"sedsneed"	"sneeds"	false	"Perhaps Sed Sneed comes here some time, but he's usually at his familial residence."	unfound-sneed rule
"seeewed"	"seeweed"	false	"You pass by a health food restaurant trying to capitalize on the latest craze--an obvious ripoff of [seew]."
"senesense"	"senessense"	false	"You must be getting old--you feel like you've forgotten something, or you'd have wound up somewhere."
"seweeed"	"seeweed"	false	"You pass by a health food restaurant trying to capitalize on the latest craze--an obvious ripoff of [seew]."
"sneee"	"sneese"	false	"You feel a tingle in your nose, one you just want to get rid of. Perhaps something to the south--nah, not right now, maybe retrace and try again."	unfound-sneeze rule
"suee"	--	false	"[sooee]" 	soee rule
"suue"	--	false	"[sooee]" 	soee rule
"suuue"	--	false	"[sooee]" 	soee rule
"suuuue"	--	false	"[sooee]" 	soee rule
"unended"	--	false	"This was the area [one of]what's her name Nunn[or]Deneen what's her name[in random order] wrote about in that book Ewen was reading."	unfound-deneen rule
"unsewed"	"unsewn"	false	"You hear whispers of a nudist colony nearby, but not quite here."
"weeenes"	"weenees"	false	"You pass by a disreputable hot dog hut, an obvious ripoff of [wees]."
"weneees"	"weenees"	false	"You pass by a disreputable hot dog hut, an obvious ripoff of [wees]."
"wwedd"	--	false	"The What Would Ed Dunn Do bracelet fails to glow or do anything magical or even remotely technological."

this is the has-book rule:
	if player has book:
		the rule succeeds;
	the rule fails;

to say sooee:
	say "Someone offers you a flier for a hog calling competition next weekend. You don't even want to know where it is, and you flash a look of such disgust, you imagine they'll tell their cohorts not to bug you.";
	now sooeed is true;

sooeed is a truth state that varies.

this is the soee rule:
	if sooeed is true:
		the rule fails;
	the rule succeeds;

to say kids-desend:
	say "[if ew is 7]Kids here discuss describing a parity problem to their great-grandparents (one doesn't have any, which makes him the odd kid out,) about how if you walk an even number of blocks from an even sector, you always wind up in another even sector[else]Kids wind up stringing out their e's a bit too long here, something I'm sure their great-grandparents wouldn't have the heart tell them they shouldn't[end if]."

to say flowery:
	choose row with tally of "deseesed" in table of scenery;
	say "[if found entry is 1]that nearby funeral home you found[else]a nearby funeral home[end if]";

this is the unfound-sneed rule:
	choose row with tally of "sedsneed" in table of scenery;
	if found entry is 1:
		the rule fails;
	the rule succeeds;

this is the unfound-sneeze rule:
	choose row with tally of "sneese" in table of scenery;
	if found entry is 1:
		the rule fails;
	the rule succeeds;

this is the unfound-deneen rule:
	choose row with tally of "deneennunn" in table of scenery;
	if found entry is 1:
		the rule fails;
	the rule succeeds;

to say seew:
	if found corresponding to a tally of "weenees" in the table of findies is 0:
		say "somewhere more reputable";
	else:
		say "DeWeese Seeweed";

to say wees:
	if found corresponding to a tally of "weenees" in the table of findies is 0:
		say "a much better establishment that's probably nearby";
	else:
		say "Sweenee Weenees";

to say if-snus:
	choose row with a tally of "Snus" in table of findies;
	if found entry is 0:
		say ", though you figure you must've been close, somehow, some way"; [this was a weird one according to testers]

to say biz-dist:
	choose row with a tally of "Sweden" in table of findies;
	say "The business district is[if found entry is 0] probably[else], as you know,[end if] a left/right turn away";

to say swee-try:
	choose row with a tally of "Weenees" in table of findies;
	say "[if found entry is 0]. Probably far away and near at the same time[else]. The new place seems nicer[end if]"

table of scenery progress [top]
sneed-talk	findy-talk	need-to-get	nailed-yet
"You really couldn't find any scenery."	"You mark down your first bit of crazy Threediopolis scenery since you got your notebook. Yay!"	1	false
"You didn't feel like seeing much scenery, but you saw enough. Maybe talking it over with the Sneeds will leave you recharged. It does. The talk about how, after all, you don't want to get burned out. You're not sure if they actually mean it, or if they're just being nice, but either way, it feels okay. At home, later, you blow through a crossword--you've never solved one this late in the week."	"You suddenly realize you know more about the REAL Threediopolis than idiots who babble about all the cool restaurants they've been to."
"The Threediopolis scenery is tougher to find than the chores--that makes a certain amount of sense. Business gets all the visible locations, because money talks. You have to search to find artsiness and culture. You've done enough walking for a good long while, and you think you know enough to look forward to maybe seeing more scenery after your next chores from Ed Dunn. It's meant to be taken in slowly. Why go in for it all at once?"	"Your head is spinning less over local neighborhoods people rattled on about when you were younger. Of COURSE that is THERE, and so forth."
"Hm, yeah, you have a good balance of stuff you've done and stuff to look forward to. The Sneeds agree. People feel like they have to do everything these days, since computers do. You've sort of forgotten a lot of the ways you got to Ed's business partners or whatever. That'll keep it fun."	"Ed's tasks have helped you find so much quirky neat stuff on your own, and hey, he said you could take whatever time you needed. You feel more accomplished than finding a national landmark or trendy club."
"You feel a bit above average for your job, even though there aren't many people to compare yourself to, and they're mostly the ones you're talking to right now. There are plenty less obscure areas of Threediopolis you've never seen, which are simpler than what you just found right now. Maybe you'll visit them. It'll be nice to know where things are."	"Someone tells you you're headed for a bad end, wandering around like that, probably not using your full government-judged aptitudes to do a job you're paid to. Your disinterested smile convinces them further they're is right."
"You find yourself discussing diminishing returns to scale and discussing not letting small things getting you down and planning for later. You compare notes with the Sneeds, who also missed a few things to see. You're unsure whether Ed Dunn's big thinking has rubbed off on you, but either way, you are relieved he--and the notebook--aren't like those teachers who claim you need to get everything right."	"Some idiot tells you you look like you need to get out more. If he only knew."
"Turns out the Sneeds missed a few clues too. You missed just enough to be able to snicker about crazy people who managed to visit ALL these places and yet see how they figured it out."	"You're sure you've forgotten the places where Ed asked you to go, which will help you have fun finding them again later."
"The Sneeds note the place or two they missed. They're really impressed. You sit around and talk of that new proposed mega-city, Fourdiopolis. It's got hexidecimal addresses. And teleport chambers. But they can only displace you a constant amount--from and to? Ana and kata? The government hasn't decided on the right terms. But you spend several fun evenings speculating where its secrets could be."	"That's it! You're pretty sure you've found everything."

to calibrate-scenery-progress:
	let count be 0;
	let found-in-game be number of rows in table of stumblies;
	if eggsfound > 8:
		now found-in-game is eggsfound;
	if eggsfound + number of rows in table of scenery progress > secs:
		repeat through table of scenery progress:
			if eggsfound + number of rows in table of scenery progress > secs + count:
				increment count;
				now nailed-yet entry is true;
		say "[italic type][bracket]NOTE: you've already found so much scenery, you'll miss [count] of the silly 'you found this' wisecracks. You can SEE NEW SEENS at the start to read them all. Or just read the source code.[close bracket][roman type][line break]";
	let ro be number of rows in table of scenery progress;
	repeat through table of scenery progress:
		increment count;
		if there is no nailed-yet entry:
			now nailed-yet entry is false;
		if there is no need-to-get entry or need-to-get entry is not 1:
			now need-to-get entry is ((count - 2) * (secs - found-in-game)) / (ro - 2);
			increase need-to-get entry by found-in-game;
			if debug-state is true: [can't debug-say as indexed text threw me a curveball]
				say "DEBUG: Row [count] has find-value of [need-to-get entry].";

book finding table

diflev is a kind of value. the diflevs are deduc, alfhint, tough and misp.

table of findies [tof]
tally (text)	descrip (text)	foundit (text)	what-drops	found	searchedfor	breakbefore	unlist	rand-score	findtype	diffic	twistiness	palhint
"Dee"	"pal"	"You are surprised to see a [if dee-male is true]man[else]woman[end if] answer the door, but you're not sure why. 'Ed Dunn, eh? My [if dee-male is true]wife[else]husband[end if] will be glad to drop by. [if dee-male is true]Her[else]His[end if] name's Dee, too. Well, the abbreviation. We both laughed too hard at it when we first met.'"	front door	0	1	2	false	0	chums	deduc	--	"Dee and Dee are off for some surprising and unexpected stuff beyond their house."
"Deedee"	"twice as fun pal"	"A slightly snooty looking woman answers the door. 'WHAT ARE YOU...oh! Ed Dunn?' she says, sounding a bit too happy. 'Sundude! Another party of Ed's!' She thanks you very much and gives you a tip which would be insulting if you asked for it."	front door	0	1	--	false	0	chums	alfhint	--	"You remember Deedee and Sundude arguing about their getaway home in--where was it? New Wesseewn?"
"Des"	"English pal ponds make sad"	"'An Ed Dunn party, eh? His are worth the walk. But boy, I tell you, the guy who sold me this place cheated me. Said I'd be down the street from Ed's. Never said how far.'"	front door	--	--	--	false	0	chums	deduc	--	"Off to the future, my past or maybe a funeral."
"Ewen"	"[if task-list is not super-alpha]near [end if]pal (Scottish-Canadian)"	"A man holding [italic type]Unended[roman type], the award-winning book by Deneen Nunn, answers the door. 'Sometimes I wonder if Ed Dunn only invites me to feel multicultural. Eh, well, free food, how can I say no?'"	front door	--	--	--	false	0	chums	tough	--	"You don't want to disturb Ewen reading what's-her-name. [one of]Deneen what's-it[or]Who's-it Nunn[in random order]."
"Ned"	"pal"	"Ned compliments you on not getting lost getting here--there are other tempting and even dangerous places in the nearby area. He suspects and hopes that that's why he didn't get the last invite. Well, he hopes it was more temptation than danger."	front door	--	--	--	false	0	chums	deduc	--	"Ned is writing scripts. One is labeled [italic type]type words.txt | grep '^(n|s|e|w|u|d|oo|y|z|c)*$'[roman type]--it's unclear if he's just showing off, or what."
"Sue"	"pal"	"'Ah, yes,' says the lady answering the door, 'You messengers always find me early, don't you? Must be my personality. Oh, and don't go up-east when you leave. There's hog-calling competitions all over. Or is that next weekend?'"	front door	--	--	--	false	0	chums	deduc	--	"Karaoke for me, me, me, d'oh."
"Swen"	"[if task-list is not super-alpha]near [end if]pal"	"'You look dizzy! You been walking around in circles?' asks Ed's latest invitee. He mentions that old puzzle about someone going south, east and north to arrive where he started, and how there's more than one point, before making some desultory joke about remembering to forget the lutefisk. He explains it's funnier once you know Ed Dunn."	front door	--	--	--	false	0	chums	tough	--	"Swen is off for a cultural event."
"Uwe"	"Freund"	"'Ah, Ed always appreciates my European viewpoint. Even if he and other guests forget if I'm from France or Germany.'"	front door	--	--	--	false	0	chums	tough	--	"Uwe is studying chess. A former world champ who doesn't know how to pronounce his name."
"Wendee"	"[if task-list is not super-alpha]far [end if]frieeend"	"'Oh! You're with Ed Dunn? Let me see the list he gave you,' says the woman answering. She nods approvingly. 'He said he only invited Nene because she was closer. I'm glad he meant it this time. I hope he has those awesome hot dogs this party!'"	front door	--	--	--	false	0	chums	alfhint
"Wes"	"awesome pal"	"'Nice of Ed to think of me even though I'm so far away. I hope it wasn't too far for you.'"	front door	--	--	--	false	0	chums	alfhint
"Den"	"Visit total party-cave"	"You realize that Ed Dunn has done you a favor by allowing you to view this. You take extra careful notes on how the party is, what's being served, what a party should be, and the general atmosphere and how people are acting. Alas, you can't partake of some amenities while on the job, but you can't complain."	a door shaped like a champagne bottle	--	--	1	false	--	party	deduc
"Dew"	"Wet grass"	"A kid on a lonely park bench. 'So you're the one my uncle got to play with me today. You'll do, I guess.' It's actually rather fun, and the kid gets bored first."	gladed trail	--	--	--	--	--	relax	tough
"Dns"	"Chat w/web srvr"	"You probably took less time to walk there than it would've taken to stay on hold if you called in. Or get an email response. Internet customer service was so much better a hundred years ago! You straighten out a few things about your employer's websites, both the ones people know he owns and the one they don't[acro-thick]."	big glass doors	--	--	--	--	--	biz	tough
"Edu"	"Visit online univ. HQ"	"While you're not sure what business Ed Dunn has here, the secretaries there recognize it immediately. Apparently, Ed Dunn has a .EDU domain offering real-world business advice, and one of the main projects is getting people to do busy work for you, whether you really need it done or not[acro-thick]."	big glass doors	--	--	--	--	--	biz	tough
"End"	"Help Stop Something"	"Hmmm... the door says 'Voluntary Population Control.' Kind of a dirty little secret. Not strictly condemned by the government, but they can't brag about it, either.[paragraph break]You reach into the mysterious package and pull out a stink-bomb, then knock and run away. Since you didn't light it INSIDE the clinic, there's nothing they can do to you. There's legal precedent--plus if they prosecuted you, they'd have to reveal the address in court, which would mean more annoying protestors. You're glad your benefactor has a conscience!"	the extremely ominous door	--	--	--	--	--	youish	deduc
"Nes"	"Retro gm comp"	"Oh man! There's people playing, not just emulated NES games, but the real thing! With a power glove, too! One competitor, you went to school with. He is impressed you work for Ed Dunn. He knew a guy who almost got to but wasn't up to it! You give a few invites for the winners. Ed likes the nerd street cred."	big glass doors	--	--	--	--	--	party	alfhint
"See"	"[if saw-see is true][bold type][see-3][noital][else]A powerful hinty spying telescope[end if]"	"[see-hints]"	secret entry	--	--	--	--	--	youish	deduc
"Sew"	"Fix holes in my clothes"	"Most people just have to dispose of clothes and get new recyclable ones, but Ed Dunn can afford more expensive stuff. You dump out the clothes that need repairing and get a receipt with the ready date. Technology hasn't managed to speed up clothes mending."	tiny yet inviting door	--	--	--	--	--	stuffly	tough
"Sun"	"Soak Up Vitamin D"	"It's so rare to get natural sun. Usually the heat lamps are enough. Someone punches your ration card and you return to your home, cheerier. You're given a dark bottle of instant sunlight for your employer, too. He seems to be on the monthly plan, and it's too fragile to mail to him."	big glass doors	--	--	--	--	--	youish	alfhint
"Deus"	"Latin Mass"	"What with the brutal unholy war over atheists['] best reasons to disbelieve in God, religion has made a comeback. The priests here acknowledge you've traveled long and hard and far. You're not sure if you've gone anywhere. But they mention the journey is important, and the cliche provides comfort. There's a weird coin in the package, with which you buy a candle to light. Perhaps it is pre-penance for the party."	a stained-glass entryway	--	--	1	--	--	relax	alfhint
"Duds"	"New&used Clothes"	"You walk into the store and realize you don't know what you should buy. A sales associate dubiously asks if he can help you, and when you mention it's not quite you but Ed Dunn, he whistles and hands you some clothes, with obsequious gratitude to be one of several suppliers to Ed Dunn."	clothing store	--	--	--	--	--	stuffly	tough
"Ewes"	"Sheep's milk"	"Sheep's milk? Well, you've heard of worse stuff at rich people's parties. You guess. You'd never have noticed this mini-farm if you hadn't been told where to locate it. You'd never been to a farm before."	hinged wooden gate	--	--	--	--	--	party	tough
"News"	"TV Info show"	"There is a setup for an old-fashioned newscast. People still watch them, especially in the morning, mostly because the anchors are attractive and perky, and none of the reported news is too jarringly thoughtful. However, your package is frisked, and when one of the guards alerts one of the news station big-shots about whom you work for, the big shot schmoozes a bit, gives you a few presents and secret after-party invitations to pass on, and asks for a few favors."	big glass doors	--	--	--	--	--	biz	tough
"Nuns"	"A conventional convent"	"You hand the nuns a folded sheet marked 'Ed Dunn's Undue Deeds.' Apparently Ed Dunn is enough of a benefactor that the nuns forgive all his sins--and yours--after you say his penance for him!"	a stained-glass entryway	--	--	--	--	--	relax	tough
"Send"	"Deploy package"	"A combination DMV, post office and virtual jury duty fulfillment center. You write down your employer's name, location, and reason for having to send something physical--and you're promised the package-inside-Ed's-package will be sent off."	loading dock	--	--	--	--	--	biz	alfhint
"Sewn"	"Handmade clothes with love in every stitch-1"	"[ed-sew]."	clothing store	--	--	--	--	--	stuffly	tough
"Snus"	"Smokeless tobacco"	"Of course, the smokable kind's been illegal a while, smoking outdoors being proved worse than smoking indoors being proved worse than smoking outdoors. But this stuff is there, if people MUST. It's been genetically engineered to be okay to snort but very toxic to smoke--just in case people get ideas. The clerk nods as you say it's for someone else. He's heard that one before."	big glass doors	--	--	--	--	--	party	tough
"Suds"	"Root Beer &/or Cream Soda"	"You've never been a Coke or Pepsi person, particularly after they aligned themselves with opposing political parties. Other soft drinks are taxed at a higher rate except for the bootleg stuff. Like what's here. Your employer apparently Knows People. Because he is such a good customer, you even get some illicit phosphate-filled laundry detergent."	restaurant door	--	--	--	--	--	party	tough
"Suse"	"New Linux system--boo Windows 27"	"If only the people extolling Linux weren't so annoying, you'd have fallen in line with them sooner once you saw why. You suspect your employer felt the same. You pick up a lightweight custom computer for your employer."	shiny new store door	--	--	--	--	--	biz	deduc
"Suss"	"[if suspicious-seen is true][can-i-suss][else]Get a free hint[end if]"	"Well, I guess your employer knows that he can't expect utter perfection. But you can't imagine you get more than one thing."	nodoor	--	--	0	--	--	youish	deduc
"Deeds"	"pay property tax"	"People seem surprised to see you. You don't look like a property owner. But once they see your list, they realize who you are working for. You paying in person has saved him $500 (exorbitant, even with inflation) in electronic handling fees. He can afford it, but why support the racket?"	intimidating 15-foot revolving door	--	--	1	--	--	biz	deduc
"Dudes"	"cowboy hat & boots"	"You reflect that, ironically, you didn't have to go west once to enter here. You buy a fold-up cowboy hat that fits nicely into your big mysterious package."	clothing store	--	--	--	--	--	stuffly	tough
"Dunes"	"sandy beaches"	"It's not fully a natural beach, and you can't go in the water, but people shouldn't have to drive to a less wired area just to see the dunes. You are able to reserve the dunes for a weekend for Ed Dunn at a nice discount. The agents like that, because people who reserve on-line cancel more frequently."	dunes	--	--	--	--	--	relax	tough
"Nudes"	"ART not porn"	"Obviously there needs to be a crackdown on sicko-porn masquerading as art, but this has been certified by the Ministry of Art as relatively intellectual stuff. It will provoke dynamic conversation at Ed Dunn's party, too, for sure. You pick out a sculpture from the No-Photograph Zone for later delivery to your benefactor."	md	--	--	--	--	--	party	tough
"Seeds"	"garden startup materials"	"Genetic engineering advances have made it so most people, even if they get seeds, can only grow plants for one year. A power grab by agribusiness? Perhaps. But nobody much goes hungry, so nobody can complain. You pay for and take the valuable seed packets."	odd grassy door	--	--	--	--	--	relax	deduc
"Sewed"	"handmade clothes with love in every stitch-2"	"[ed-sew]."	clothing store	--	--	--	--	--	stuffly	tough
"Suede"	"softish leathery clothes"	"Real leather's a bit scarce, even for rich people, but suede still costs about the same, adjusted for inflation. Anyway, it's just like artificial flavors in food--you get used to it, with all the other advances."	clothing store	--	--	--	--	--	stuffly	tough
"Unwed"	"Matchmaker for singles"	"You walk in. 'Are you searching for that special someone...?' a clerk asks.[paragraph break]You mumble 'Um...not for me, this, um, guy needs it.' You hand over the package with a list of names.[paragraph break]'Ah, quite so. Mr. Dunn offers our services as a surprise gift to people who have impressed him. I am not surprised you have not.' Whoa!"	secret entry	--	--	--	--	--	party	tough
"Weeds"	"visit that vacant lot I loved as a kid"	"Vacant lots are making a comeback of sorts since the world reached its critical-peak population. Eventually they'll be phased out above the concerns of environmentalists, once people figure even more efficient methods of production and the population can go up again, but this one's still here. You take a few phone-pictures for Ed Dunn to remember, and you take time to remember your own vacant lot. You also spend time cleaning it up, to fulfill both your and Ed's monthly community service quotas."	vacant lot	--	--	--	--	--	relax	alfhint
"EdDunn"	"[ed-blah]"	"You return, with a list of what you've done.[line break]"	door to Ed Dunn's secret hideout	--	--	1	--	--	youish	tough
"Senses"	"Smell/taste test"	"You are evaluated on various senses, and surprisingly, you are graded high on a sixth sense. You don't know what it is, but you're afraid asking will forfeit your score. You're given a certificate of senseness, which goes in the mysterious package. This will please Ed...I think?"	secret entry	--	--	--	--	--	relax	tough
"Sweden"	"book Scandinavian vacation"	"Well, I guess Ed Dunn wants to have a few 24 hour days of sunlight. You place the reservation for a summer vacation with an agent named Enes Sund."	big glass doors	--	--	--	--	--	relax	tough
"Unseen"	"Invisible Institute docs"	"Knowledge is power is money. You aren't allowed to see what Ed needs, but whatever it is, it's too important to keep online. You hand over a piece of paper, and you get back a booby trapped bag someone makes sure you slip in the package. You're not sure what the Invisible Institute is for, and you still aren't sure you want to find out."	blurry doors that seem only half there	--	--	--	--	--	biz	tough
"Unused"	"brand new stuff-in-general"	"Ed Dunn deserves this new stuff, you imagine. You get a free new spatula for visiting in-person. You get some new pocket-sized technology for Ed Dunn. It all goes back in your package. It will trickle down to the less fortunate when he gets bored. You think."	shiny new store door	--	--	--	--	--	stuffly	tough
"Wedded"	"new bride/groom stuff"	"Expensive wedding presents have been discouraged by the government ever since the population was deemed unsustainable. But people now get married and divorced much more frequently, so non-loners still have that racket going. Well, it's your benefactor's money, not yours. He probably needs to do this to keep up business relations."	shiny new store door	--	--	--	--	--	biz	alfhint
"Wusses"	"anti-athletic club"	"People might not run here, but they sure run their mouths. A gay couple bashes a male author for only writing about male characters, a lesbian couple does the same to a female author, and a heterosexual couple laments the lack of homosexual couples in a third author's oeuvre. They also trash a teen angst novel about a kid who's good at math and finds peace without becoming talkative and social because, BORING. You take notes, to help Ed sound clever at his party.[paragraph break]In fact, someone with an EDU'D DUDE t-shirt hands you a manuscript of other Exciting New Ideas people forgot ten years ago. It is sealed so Ed will know if you looked at it. But you're given an overview."	library	--	--	--	--	--	party	alfhint
"NewDuds"	"unworn clothes boutique"	"You wouldn't wear any clothes like this year's fashions, with or without the wearble technology, but you're not paying. You put the clothes in the mysterious package."	clothing store	--	--	1	--	--	stuffly	tough
"Seeweed"	"[saltren]ee greens"	"You stop by a new restaurant, whose proprietor, Mr. DeWeese (of course,) gives you a free sample of the envorinmentally replenishable kelp-based lollipops and after-dinner mint substitutes in addition to the more nutritional party fare. It'll...it'll hit the spot when you're hungrier."	restaurant door	--	--	--	--	--	party	tough
"Weenees"	"improperly voweeled hut of hot dog's"	"Man, you have heard a lot of reasons why this place or that place is good for comfort food, but one thing you can always rely on: owners misspell, grub will excel. The [']S on the sign triggers another rule: apostrophe botch, the sauce is top notch. The proprietor, Mr. Sweenee (of course,) gives you few free samples for such a bulk order--and because you look like you've come a ways--and man, you eat them so fast, you already wish you'd got more."	restaurant door	--	--	--	--	--	party	tough
"UsedDuds"	"2nd-hand clothing boutique"	"Arriving in the used clothes store, you suddenly realize that there are probably used clothes in the mysterious package. You take them out and give them to the clerk, who credits your employer's account. They're a little garish, but the concealed wearble technology is still worth something."	clothing store	--	--	1	--	--	stuffly	tough

to say ed-sew:
	say "[one of]Nobody really cares about fashion any more, but there are still clothes to wear to show you don't. Ed Dunn needs a lot of them[or]Ed Dunn apparently needs an extra shipment of clothes-to-show-he-doesn't-care-about-clothes. Well, YOU'RE not paying for them[stopping]"

to say saltren:
	say "[if salty is true]salt[else]trend[end if]";

to say ed-blah:
	choose row with tally of "EdDunn" in table of findies;
	say "[if found entry is 2]Ed Dunn again[else]See Ed Dunn for evaluation/hint[end if]";

to say see-3:
	say "See ([3 - num-hints-given] left)";

to say acro-thick:
	say "[one of]. The acronyms are flying around, here. You hope you don't have to put up with much more of this[or]. This has to be all the acronymage you can put up with for today[stopping]";

to say can-i-suss:
	say "[if suspicious-guy-help is false][bold type]Can still SUSS[else]SUSS[end if][noital]"

my-table is a table-name that varies.

book see-hints

num-hints-given is a number that varies.

L is a list of numbers that varies.

L2 is a list of indexed text variable.

alpha-look-mode is a truth state that varies.

scen-look-mode is a truth state that varies.

to say see-hints:
	if num-hints-given > 2:
		say "You are turned away. You've already used enough hints.";
		continue the action;
	now L is { 0 };
	now L2 is { };
	let C be text;
	if player does not have book:
		choose row with tally of "See" in table of findies;
		if found entry is 0:
			increment edtasks;
			now found entry is 3;
	repeat through tt:
		let A be the number of characters in "[tally entry]";
		if A is not listed in L:
			if found entry is 0:
				if there is no what-drops entry or what-drops entry is not front door:
					add A to L;
		let B be character number 1 in "[tally entry]" in upper case;
		if B is not listed in L2:
			add B to L2;
	sort L;
	if player has book:
		say "You approach a telescope that can be tilted or extended. It's got tracking technology. How to move it?";
		now scen-look-mode is true;
		now command prompt is "[L] or [L2]:";
	else if task-list is super-alpha:
		if number of entries in L2 is 0:
			say "Unfortunately, the telescope doesn't seem to be active. Maybe that's a good sign, and you don't need it.";
			continue the action;
		say "You approach a scope that can be tilted in the six directions. It's got that tracking technology that will follow people around. How will you move it?[no line break]";
		now alpha-look-mode is true;
		now saw-see is true;
		now command prompt is "[ways-to-tap]";
	else:
		if number of entries in L is 1:
			say "Unfortunately, the telescope doesn't seem to be active. Maybe that's a good sign, and you don't need it.";
			continue the action;
		say "You're given a scope to look through--you can follow someone as they make their way to one of your locations. You notice it has settings at [L], where 0 means you'll do nothing. What do you choose?[no line break]";
		now look-mode is true;
		now command prompt is "Choose one of [L]:";

to say ways-to-tap:
	let a be indexed text;
	let b be indexed text;
	say "Here are the ways you can tap the telescope: ";
	repeat through table of findies:
		if found entry is 0:
			now a is character number 1 in tally entry;
			if a is not b:
				say "[a], ";
				now b is a;
	say "or X to exit:";

Table of Final Question Options (continued)
final question wording	only if victorious	topic		final response rule		final response activity
"see MECHANICS (M/MECH)"	true	"m/mech/mechanics"	--	showing mechanics
"go look for scenery (SEE NEW SEENS)"	true	"see new seens" or "see/new/seens" or "see/new seens" or "see new"	--	seeing unseen

seeing unseen is an activity.

rule for seeing unseen:
	if player has book:
		say "You already have. You can UNDO, if you want[if eggsfound is secs], though you have found everything[end if].";
	now my-table is table of scenery;
	fully resume the story;
	say "Maybe wandering around looking for noncritical stuff will make Threediopolis feel un-new.[paragraph break]Note 1: if you lose this save file, you can activate the scenery-hunt mode with SEE NEW SEENS if you restart the game.[paragraph break]Note 2: the scenery is significantly more difficult to find than Ed's tasks. This is intentional, as are the clues that look weird.";
	carry out the newseensing activity;
	try ring 9;
	now ud is 4;
	now ew is 4;
	now ns is 4;
	calibrate-scenery-progress;
	now your-tally is "";

showing mechanics is an activity.

rule for showing mechanics:
	let A be ((maxpals + maxedtasks) * 9) / 10;
	say "The game gives pre-ordered messages for every other successful finds.[paragraph break]Ed gives you something special if you hit 90% rounded down, or [A]/[maxpals + maxedtasks].[paragraph break]The separate subtasks give a different response from Ed depending on whether you do 2/3 of them. They are lumped as follows: [paragraph break]";
	repeat with Q running through qualities:
		say "--[Q]: ";
		let needcomma be 0;
		repeat through table of findies:
			if findtype entry is Q:
				if needcomma is 1:
					say ", ";
				else:
					now needcomma is 1;
				say "[if found entry is 0 and player does not have book][descrip entry]@[sector-num of tally entry][else][tally entry][end if]";
		say "[line break]";


Include (-

[ ASK_FINAL_QUESTION_R;
	print "^";
	(+ escape mode +) = false;
	while ((+ escape mode +) == false) {
		CarryOutActivity(DEALING_WITH_FINAL_QUESTION_ACT);
		DivideParagraphPoint();
	}
];

-) instead of "Ask The Final Question Rule" in "OrderOfPlay.i6t".

The escape mode is a truth state that varies.

To fully resume the story:
	resume the story;
	now escape mode is true;

chapter superuser - not for release

suping is an action out of world.

understand the command "sup" as something new.

understand "sup" as suping.

carry out suping:
	now superuser is true;
	say "[italic type][bracket]NOTE: this command should not be in the release version.[close bracket][roman type][line break]";
	the rule succeeds;

volume beta testing - not for release

when play begins (this is the beta instructions rule) :
	say "[italic type][bracket]NOTE: Beta testers who want to try Advanced Mode should type SEE NEW SEENS. Also, this line should not be in the final release.[close bracket][roman type][line break]Other commands include CT to toggle forced cheat on return to the almost-center, or HME to hint you once with what that cheat would be.[line break]RNEAR resets the table of nearlies (see source code) and FINDEM 'finds' everything except the final places.";

chapter findeming

[* report everything as found except final location]

findeming is an action out of world.

understand the command "findem" as something new.

understand "findem" as findeming.

carry out findeming:
	repeat through table of scenery:
		if tally entry is not "sneeds":
			now found entry is 1;
	repeat through table of findies:
		if tally entry is not "eddunn":
			now found entry is 1;
	the rule succeeds;

chapter rnearing

[* reset table of nearlies]

rnearing is an action out of world.

understand the command "rnear" as something new.

understand "rnear" as rnearing.

carry out rnearing:
	repeat through table of nearlies:
		now found-yet entry is false;
	say "Table of Nearlies is reset.";
	the rule succeeds;

chapter cting

[* toggles cheat-ticker]

cting is an action out of world.

understand the command "ct" as something new.

understand "ct" as cting.

carry out cting:
	now cheat-ticker is whether or not cheat-ticker is true;
	say "Now cheat on return is [cheat-ticker].";
	the rule succeeds;

chapter hmeing

[* HME displays the immediate hint]

hmeing is an action out of world.

understand the command "hme" as something new.

understand "hme" as hmeing.

carry out hmeing:
	consider the try-a-hint rule instead;
	the rule succeeds;

volume testing - not for release

chapter aling

[* force task list to super-alpha]

aling is an action out of world.

understand the command "al" as something new.

understand "al" as aling.

carry out aling:
	now task-list is super-alpha;
	sort the table of findies in tally order;
	the rule succeeds.

chapter lling

[* display how you could tap the telescope if you were near it]

lling is an action out of world.

understand the command "ll" as something new.

understand "ll" as lling.

carry out lling:
	say "[ways-to-tap][line break]";
	the rule succeeds;

chapter staing

[* this toggles the list being in the status line]

staing is an action out of world.

understand the command "sta" as something new.

understand "sta" as staing.

carry out staing:
	now list-in-status is true;
	the rule succeeds;

book tests

[* all kinds of tests here. By letter, with churn, without churn]

[test resets with "eggs/pp/nsnsnsnsnsns/wwwwww/weeweee"

test d with "dee/k/deeds/in/den/in/des/k/deus/in/dew/in/dns/in/dudes/in/duds/in/dunes/in"

test e with "edu/in/end/k/ewen/k/ewes/in/eddunn/n"

test n with "ned/newduds/nudes/news/nuns"

test s with "seeds/in/send/in/senses/in/sew/in/sewed/in/sewn/in/snus/in/suds/in/sue/k/suede/in/sun/k/suse/in/suss/n/sweden/in/swen/k/see/in/"

test u with "unseen/in/unused/in/unwed/in/usedduds/in/uwe/k"

test w with "wedded/in/weeds/in/weenees/in/wendee/k/wes/k/wusses/in"

test q with "f/b/eddunn/in/y"

test fiddly with "x list/x/x button/x device/x package/open package/drop package/drop device/drop list/xyzzy"

test errthru with "d/d/d/d/d/u/u/u/u/u/u/w/w/w/w/w/e/e/e/e/e/e/s/s/s/s/s/n/n/n/n/n/n/s/w/e/d/u/n/s/w/e/d/u/n"

test garbage with "123/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"

test h with "s/s/s/e/e/e/p/s/s/s/e/e/e/p/s/s/s/e/e/e/p"]

[test 28 with "j/r 9/den/i/dew/i/dns/i/edu/i/end/k/nes/i/see/i/0/sew/i/sun/i/deus/i/duds/i/ewes/i/news/i/nuns/i/send/i/sewn/i/snus/i/suds/i/suse/i/suss/4/deeds/i/dudes/i/dunes/i/nudes/i/seeds/i/sewed/i/suede/i/unwed/i/weeds/i"

test wchurn with "d/e/e/p/d/e/s/p/e/w/e/n/p/n/e/d/p/s/u/e/p/s/w/e/n/p/u/w/e/p/w/e/n/d/e/e/p/w/e/s/p/d/e/n/p/d/e/w/p/d/n/s/p/e/d/u/p/e/n/d//k/s/e/e/p/0/p/s/e/w/p/s/u/n/p/d/e/u/s/p/d/u/d/s/p/e/w/e/s/p/n/e/w/s/p/n/u/n/s/p/s/e/n/d/p/s/e/w/n/p/s/n/u/s/p/s/u/d/s/p/s/u/s/e/p/s/u/s/s/4/n/p/d/e/e/d/s/p/d/u/d/e/s/p/d/u/n/e/s/p/n/u/d/e/s/p/s/e/e/d/s/p/s/e/w/e/d/p/s/u/e/d/e/p/u/n/w/e/d/p/w/e/e/d/s/p/p/s/e/n/s/e/s/p/s/w/e/d/e/n/p/u/n/s/e/e/n/p/u/n/u/s/e/d/p/w/e/d/d/e/d/p/w/u/s/s/e/s/p/n/e/w/d/u/d/s/p/w/e/e/n/e/e/s/p/u/s/e/d/d/u/d/s/p/e/d/d/u/n/n/in"

test wnochurn with "dee/p/des/y/f/p/ewen/p/ned/p/sue/p/swen/p/uwe/p/wendee/p/wes/p/den/p/dew/p/dns/p/edu/p/end/k/see/i/0/p/sew/p/sun/p/deus/p/duds/p/ewes/p/news/p/nuns/p/send/p/sewn/p/snus/p/suds/p/suse/p/suss/4/p/deeds/p/dudes/p/dunes/p/nudes/p/seeds/p/sewed/p/suede/p/unwed/p/weeds/p//p/senses/p/sweden/p/unseen/p/unused/p/wedded/p/wusses/p/newduds/p/weenees/p/usedduds/p/eddunn/in"

test wslash with "j/b/d/e/e/k/d/e/e/d/e/e/i/d/e/s/k/e/w/e/n/k/n/e/d/k/s/u/e/k/s/w/e/n/k/u/w/e/k/w/e/n/d/e/e/k/w/e/s/k/d/e/n/i/d/e/w/i/d/n/s/i/e/d/u/i/e/n/d/k/n/e/s/i/s/e/e/i/0/ps/e/w/i/s/u/n/i/d/e/u/s/i/d/u/d/s/i/e/w/e/s/i/n/e/w/s/i/n/u/n/s/i/s/e/n/d/i/s/e/w/n/i/s/n/u/s/i/s/u/d/s/i/s/u/s/e/i/s/u/s/s/4/p/d/e/e/d/s/i/d/u/d/e/s/i/d/u/n/e/s/i/n/u/d/e/s/i/s/e/e/d/s/i/s/e/w/e/d/i/s/u/e/d/e/i/u/n/w/e/d/i/w/e/e/d/s/i/s/e/n/s/e/s/i/s/w/e/d/e/n/i/u/n/s/e/e/n/i/u/n/u/s/e/d/i/w/e/d/d/e/d/i/w/u/s/s/e/s/i/n/e/w/d/u/d/s/i/s/e/e/w/e/e/d/i/w/e/e/n/e/e/s/i/u/s/e/d/d/u/d/s/i/e/d/d/u/n/n/in"

test wnoslash with "j/b/dee/k/deedee/k/des/k/ewen/k/ned/k/sue/k/swen/k/uwe/k/wendee/k/wes/k/den/i/dew/i/dns/i/edu/i/end/k/nes/i/see/i/0/psew/i/sun/i/deus/i/duds/i/ewes/i/news/i/nuns/i/send/i/sewn/i/snus/i/suds/i/suse/i/suss/4/p/deeds/i/dudes/i/dunes/i/nudes/i/seeds/i/sewed/i/suede/i/unwed/i/weeds/i/senses/i/sweden/i/unseen/i/unused/i/wedded/i/wusses/i/newduds/i/seeweed/i/weenees/i/usedduds/i/eddunn/in"

test eggslash with "j/b/d/d/s/i/p/d/e/d/e/n/d/i/p/d/e/d/s/u/n/e/i/p/d/e/d/u/d/u/d/u/i/p/d/e/d/u/s/e/i/p/d/e/e/s/e/n/s/e/e/i/p/d/e/n/e/e/n/n/u/n/n/i/p/d/e/n/s/e/i/p/d/e/n/u/d/e/i/p/d/e/s/d/e/n/e/e/i/p/d/e/s/e/e/s/e/d/i/p/d/e/s/e/n/d/e/d/i/p/d/e/w/e/e/s/e/i/p/d/n/d/i/p/d/u/d/e/i/p/d/u/e/i/p/d/u/e/s/i/p/d/u/n/d/e/e/i/p/d/u/n/s/e/i/p/d/u/s/e/s/i/p/e/d/e/n/i/p/e/e/e/i/p/e/e/e/e/e/i/p/e/e/s/u/s/i/p/e/n/n/u/e/e/i/p/e/n/s/u/e/i/p/e/s/s/e/n/i/p/e/s/s/e/s/i/p/e/u/w/e/i/p/e/w/w/i/p/n/e/e/d/e/d/i/p/n/e/e/d/s/i/p/n/e/n/e/i/p/n/e/s/s/i/p/n/e/w/i/p/n/e/w/d/u/d/e/i/p/n/e/w/n/e/s/s/i/p/n/e/w/w/e/s/s/e/w/n/i/p/n/u/s/e/n/s/e/i/p/s/e/d/i/p/s/e/d/s/n/e/e/d/i/p/s/e/d/u/s/e/i/p/s/e/e/d/e/e/i/p/s/e/e/n/i/p/s/e/e/s/u/n/s/i/p/s/e/e/u/s/i/p/s/e/n/i/p/s/e/n/e/s/s/e/n/s/e/i/p/s/e/n/s/e/n/i/p/s/e/s/e/d/e/i/p/s/e/u/s/s/i/p/s/e/w/n/s/e/w/i/p/s/n/e/e/s/e/i/p/s/n/e/s/i/p/s/u/d/d/e/n/i/p/s/u/e/d/i/p/s/u/n/d/e/w/i/p/s/u/n/s/i/p/s/u/n/u/n/u/i/p/s/u/s/s/u/d/i/p/s/w/e/d/e/s/i/p/s/w/e/e/n/e/e/i/p/s/w/u/n/e/i/p/u/n/d/e/d/i/p/u/n/d/e/e/s/i/p/u/n/d/u/e/i/p/u/n/n/e/e/d/e/d/i/p/u/n/s/e/e/d/e/d/i/p/u/n/s/e/w/n/i/p/u/n/s/u/n/n/e/d/i/p/u/s/e/d/i/p/w/e/d/n/e/s/d/i/p/w/e/e/d/i/p/w/e/e/e/e/e/e/i/p/w/e/e/w/e/e/i/p/w/e/n/d/i/p/w/u/d/d/e/n/i/p/w/u/w/u/i/p/w/w/e/d/i/p/w/w/w/i/p/"]

test eggnoslash with "j/b/dds/i/p/dedend/i/p/dedsune/i/p/dedududu/i/p/deduse/i/p/deesensee/i/p/deneennunn/i/p/dense/i/p/denude/i/p/desdenee/i/p/deseesed/i/p/desended/i/p/deweese/i/p/dnd/i/p/dude/i/p/due/i/p/dues/i/p/dundee/i/p/dunse/i/p/duses/i/p/eden/i/p/eee/i/p/eeeee/i/p/eesus/i/p/ennuee/i/p/ensue/i/p/essen/i/p/esses/i/p/euwe/i/p/eww/i/p/needed/i/p/needs/i/p/nene/i/p/ness/i/p/new/i/p/newdude/i/p/newness/i/p/newwessewn/i/p/nusense/i/p/sed/i/p/sedsneed/i/p/seduse/i/p/seedee/i/p/seen/i/p/seesuns/i/p/seeus/i/p/sen/i/p/senessense/i/p/sensen/i/p/sesede/i/p/seuss/i/p/sewnsew/i/p/sneese/i/p/snes/i/p/sudden/i/p/sued/i/p/sundew/i/p/suns/i/p/sununu/i/p/sussud/i/p/swedes/i/p/sweenee/i/p/swune/i/p/unded/i/p/undees/i/p/undue/i/p/unneeded/i/p/unseeded/i/p/unsewn/i/p/unsunned/i/p/used/i/p/wednesd/i/p/weed/i/p/weeeeee/i/p/weewee/i/p/wend/i/p/wudden/i/p/wuwu/i/p/wwed/i/p/www/i/p/"

[#Generated walkthrough

$random = 0;
$brief = 0;

if (@ARGV[0] =~ /r/) { $random = 1; print "[Random sort]\n\n"; }
if (@ARGV[0] =~ /b/) { $brief = 1; print "[Brief on]\n\n"; }

wtest("/", "wslash", "table of findies");
wtest("", "wnoslash", "table of findies");

$scenery = 1;

wtest("/", "eggslash", "table of scenery");
wtest("", "eggnoslash", "table of scenery");

#open(B, ">debug.txt");

sub getDefaultArray
{
  open(A, "story.ni");
}

sub wtest
{
my %front;

my $readIt = 0, $count = 0, $lines = 0;
my $cmds;
my $b = "", $final = "";

if ($_[0] eq "") { $un = "/"; } else { $un = ""; }

$front{"dee"} = $front{"des"} = $front{"end"} =  $front{"ewen"} = $front{"ned"} = $front{"sue"} = $front{"swen"} = $front{"uwe"} = $front{"wendee"} = $front{"wes"} = 1;

open(A, "story.ni");

my @myAry = ();

while ($a = <A>)
{
  print B "$lines: $_[2] !~ $a, $readIt";
  if ($a =~ /^$_[2]/) { $readIt = 1; print "test $_[1] with \"j/b/"; $a = <A>; next; }
  if ($readIt)
  {
	chomp($a);
	$a =~ s/^.//g;
	$a =~ s/\".*//g;
	$a = lc ($a);
	if ($a !~ /[a-z]/) { last; }
	@myAry = (@myAry, $a);
  }
}

close(A);

if ($random) { fisheryates(\@myAry); }

for $a (@myAry)
{
	@b = split(//, $a);
	if ($a =~ /^eddunn$/i)
	{ $final = join("$_[0]", @b) . "/in"; next;
	} else
	{
	for (@b) { print "$_$_[0]"; }
	}
	if ($a =~ /^suss$/i) { print $un . "4/p/"; next; }
	if ($a =~ /^see$/i) { print $un . "i/0/p"; next; }
	if (!$_[0]) { print "/"; }
	if ($front{$a}) { print "k/"; } else { print "i/"; }
	if ($scenery) { #if (!$_[0]) { print "/"; }
	  print "p/"; next; }


 }


print "$final\"\n\n";

close(A);

}

sub fisheryates
{
  my $deck = shift; # $deck is a reference to an array
  my $i = @$deck;
  if ($i < 1) { return; } #avoid stupid errors
  while (--$i) {
	my $j = int rand ($i+1);
	@$deck[$i,$j] = @$deck[$j,$i];
  }
}

]
