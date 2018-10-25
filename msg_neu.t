#charset "latin1"

/* 
 *   Copyright (c) 2000, 2006 Michael J. Roberts.  All Rights Reserved. 
 *
 *   TADS 3 Library - "neutral" messages for US English
 *   German translation by Michael Baltes (c) 2011
 *
 *   This module provides the German standard library messages that are specific 
 *   to the German language as spoken (and written) in Germany.
 *
 *   This module provides standard library messages with a parser/narrator 
 *   that's as invisible (neutral) as possible.  These messages are designed 
 *   to reduce the presence of the computer as mediator in the story, to 
 *   give the player the most direct contact that we can with the scenario.
 *
 *   The parser almost always refers to itself in the third person (by 
 *   calling itself something like "this story") rather than in the first 
 *   person, and, whenever possible, avoids referring to itself in the first 
 *   place.  Our ideal phrasing is either second-person, describing things 
 *   directly in terms of the player character's experience, or "no-person," 
 *   simply describing things without mentioning the speaker or listener at 
 *   all.  For example, rather than saying "I don't see that here," we say 
 *   "you don't see that here," or "that's not here."  We occasionally stray 
 *   from this ideal where achieving it would be too awkward.
 *
 *   In the earliest days of adventure games, the parser was usually a 
 *   visible presence: the early parsers frequently reported things in the 
 *   first person, and some even had specific personalities.  This 
 *   conspicuous parser style has become less prevalent in modern games, 
 *   though, and authors now usually prefer to treat the parser as just 
 *   another part of the user interface, which like all good UI's is best 
 *   when the user doesn't notice it.  
 */

#include "adv3.h"
#include "de_de.h"

// -- setup of version info for Messages

messagesInfo: object
    version = '2.2 - 150930'
;

/* ------------------------------------------------------------------------ */
/*
 *   Build a message parameter string with the given parameter type and
 *   name.
 *   
 *   This is useful when we have a name from a variable, and we need to
 *   build the message substitution string for embedding in a larger
 *   string.  We can't just embed the name variable using <<var>>, because
 *   that would process the output piecewise - the output filter needs to
 *   see the whole {typ var} expression in one go.  So, instead of writing
 *   this:
 *   
 *.     {The/he <<var>>} {is} ...
 *   
 *   write this:
 *   
 *.     <<buildParam('The/he', var)>> {is} ...
 */
buildParam(typeString, nm)
{
    return '{' + typeString + ' ' + nm + '}';
}

/*
 *   Synthesize a message parameter, and build it into a parameter string
 *   with the given substitution type.
 *   
 *   For example, buildSynthParam('abc', obj) returns '{abc xxx}', where
 *   'xxx' is a synthesized message parameter name (created using
 *   gSynthMessageParam) for the object obj.  
 */
buildSynthParam(typeString, obj)
{
    return '{' + typeString + ' ' + gSynthMessageParam(obj) + '}';
}


/* ------------------------------------------------------------------------ */
/*
 *   Library Messages 
 */
libMessages: MessageHelper
    /*
     *   The pronoun to use for the objective form of the personal
     *   interrogative pronoun.  Strictly speaking, the right word for
     *   this usage is "whom"; but regardless of what the grammar books
     *   say, most American English speakers these days use "who" for both
     *   the subjective and objective cases; to many ears, "whom" sounds
     *   old-fashioned, overly formal, or even pretentious.  (Case in
     *   point: a recent television ad tried to make a little kid look
     *   ultra-sophisticated by having him answer the phone by asking
     *   "*whom* may I ask is calling?", with elaborate emphasis on the
     *   "whom."  Of course, the correct usage in this case is "who," so
     *   the ad only made the kid look pretentious.  It goes to show that,
     *   at least in the mind of the writer of the ad, "whom" is just the
     *   snooty, formal version of "who" that serves only to signal the
     *   speaker's sophistication.)
     *   
     *   By default, we distinguish "who" and "whom."  Authors who prefer
     *   to use "who" everywhere can do so by changing this property's
     *   value to 'who'.  
     */
    whomPronoun = 'wen' //VORHER WHOM

    /*
     *   Flag: offer an explanation of the "OOPS" command when it first
     *   comes up.  We'll only show this the first time the player enters
     *   an unknown word.  If you never want to offer this message at all,
     *   simply set this flag to nil initially.
     *   
     *   See also oopsNote() below.  
     */
    offerOopsNote = true

    /*
     *   some standard commands for insertion into <a> tags - these are in
     *   the messages so they can translated along with the command set
     */
    commandLookAround = 'schau dich um' 
    commandFullScore = 'volle punkte'
    
    /* announce a completely remapped action */
    announceRemappedAction(action)
    {
        return '<./p0>\n<.assume>' + action.getParticiplePhrase()
            + '<./assume>\n';
    }

    /*
     *   Get a string to announce an implicit action.  This announces the
     *   current global action.  'ctx' is an ImplicitAnnouncementContext
     *   object describing the context in which the message is being
     *   displayed.  
     */
    announceImplicitAction(action, ctx)
    {
        /* build the announcement from the basic verb phrase */
        return ctx.buildImplicitAnnouncement(action.getImplicitPhrase(ctx));
    }

    /*
     *   Announce a silent implied action.  This allows an implied action
     *   to work exactly as normal (including the suppression of a default
     *   response message), but without any announcement of the implied
     *   action. 
     */
    silentImplicitAction(action, ctx) { return ''; }

    /*
     *   Get a string to announce that we're implicitly moving an object to
     *   a bag of holding to make room for taking something new.  If
     *   'trying' is true, it means we want to phrase the message as merely
     *   trying the action, not actually performing it.  
     */
    announceMoveToBag(action, ctx)
    {
        /* build the announcement, adding an explanation */
        return ctx.buildImplicitAnnouncement(
            action.getImplicitPhrase(ctx) + ', um Platz zu schaffen');
    }

    /* show a library credit (for a CREDITS listing) */
    showCredit(name, byline) { "<<name>> <<byline>>"; }

    /* show a library version number (for a VERSION listing) */
    showVersion(name, version) { "<<name>> Version <<version>>"; }

    /* there's no "about" information in this game */
    noAboutInfo = "<.parser>Diese Geschichte hat keine INFO.<./parser> "

    /*
     *   Show a list state name - this is extra state information that we
     *   show for an object in a listing involving the object.  For
     *   example, a light source might add a state like "(providing
     *   light)".  We simply show the list state name in parentheses.  
     */
    showListState(state) { " (<<state>>)"; }

    /* a set of equivalents are all in a given state */
    allInSameListState(lst, stateName)
        { " (<<lst.length() == 2 ? 'beide' : 'alle'>> <<stateName>>)"; }

    /* generic long description of a Thing from a distance */
    distantThingDesc(obj)
    {
        gMessageParams(obj);
        "{Du/er} {koennt} aus dieser Entfernung nichts Genaueres erkennen{*}. ";
    }

    /* generic long description of a Thing under obscured conditions */
    obscuredThingDesc(obj, obs)
    {
        gMessageParams(obj, obs);
        "{Du/er} {koennt} durch {den obs/ihn} nichts Besonderes erkennen{*}. ";
    }

    /* generic "listen" description of a Thing at a distance */
    distantThingSoundDesc(obj)
        { "{Du/er} {koennt} aus dieser Entfernung nichts hören{*}. "; }

    /* generic obscured "listen" description */
    obscuredThingSoundDesc(obj, obs)
    {
        gMessageParams(obj, obs);
        "{Du/er} {koennt} durch {den obs/ihn} nichts Besonderes hören{*}. ";
    }

    /* generic "smell" description of a Thing at a distance */
    distantThingSmellDesc(obj)
        { "{Du/er} {koennt} aus dieser Entfernung nichts riechen{*}. "; }

    /* generic obscured "smell" description */
    obscuredThingSmellDesc(obj, obs)
    {
        gMessageParams(obj, obs);
        "{Du/er} {koennt} durch {den obs/ihn} nichts Besonderes riechen{*}. ";
    }

    /* generic "taste" description of a Thing */
    thingTasteDesc(obj)
    {
        gMessageParams(obj);
        "{Er/es obj} {schmeckt} wie erwartet{*}. ";
    }

    /* generic "feel" description of a Thing */
    thingFeelDesc(obj)
        { "{Du/er} {fuehlt} nichts Außergewöhnliches{*}. "; }

    /* obscured "read" description */
    obscuredReadDesc(obj)
    {
        gMessageParams(obj);
        "{Du/er} {koennt} {den obj/ihn} nicht gut genug sehen{*}, um
        etwas zu lesen. ";
    }

    /* dim light "read" description */
    dimReadDesc(obj)
    {
        gMessageParams(obj);
        "Es {ist singular} nicht hell genug{*}, um etwas zu lesen. ";
    }

    /* lit/unlit match description */
    litMatchDesc(obj) { "\^<<obj.derName>> <<obj.verbZuSein>> angezündet{*}. "; }
    unlitMatchDesc(obj) { "\^<<obj.derName>> <<obj.verbZuSein>> ein 
        gewöhnliches Streichholz{*}. "; }

    /* lit candle description */
    litCandleDesc(obj) { "\^<<obj.derName>> <<obj.verbZuSein>> angezündet{*}. "; }

    /*
     *   Prepositional phrases for putting objects into different types of
     *   objects. 
     */
    putDestContainer(obj) { return 'in ' + obj.denNameObj; }
    putDestSurface(obj) { return 'auf ' + obj.denNameObj; }
    putDestUnder(obj) { return 'unter ' + obj.denNameObj; }
    putDestBehind(obj) { return 'hinter ' + obj.denNameObj; }
    putDestFloor(obj) { return 'auf ' + obj.denNameObj; }
    putDestRoom(obj) { return 'in ' + obj.denNameObj; }
    
    /* the list separator character in the middle of a list */
    listSepMiddle = ", "

    /* the list separator character for a two-element list */
    listSepTwo = " und "

    /* the list separator for the end of a list of at least three elements */
    listSepEnd = " und "

    /*
     *   the list separator for the middle of a long list (a list with
     *   embedded lists not otherwise set off, such as by parentheses) 
     */
    longListSepMiddle = ", "

    /* the list separator for a two-element list of sublists */
    longListSepTwo = " und "

    /* the list separator for the end of a long list */
    longListSepEnd = " und " // -- we have no ";" as list seperator in German

    /* show the basic score message */
    showScoreMessage(points, maxPoints, turns)
    {
        "In <<turns>> <<turns == 1 ? 'Zug' : 'Zügen'>> hast du
        <<points>> <<points == 1 ? 'Punkt' : 'Punkte'>> von 
        <<maxPoints>> <<maxPoints == 1 ? 'Punkt' : 'Punkten'>> erreicht. ";
    }

    /* show the basic score message with no maximum */
    showScoreNoMaxMessage(points, turns)
    {
        "In <<turns>> <<turns == 1 ? 'Zug' : 'Zügen'>> hast du
        <<points>> <<points == 1 ? 'Punkt' : 'Punkte'>> erreicht. ";
    }

    /* show the full message for a given score rank string */
    showScoreRankMessage(msg) { "Das macht dich <<msg>>. "; }

    /*
     *   show the list prefix for the full score listing; this is shown on
     *   a line by itself before the list of full score items, shown
     *   indented and one item per line 
     */
    showFullScorePrefix = "Deine Punkte setzen sich wie folgt zusammen:"

    /*
     *   show the item prefix, with the number of points, for a full score
     *   item - immediately after this is displayed, we'll display the
     *   description message for the achievement 
     */
    fullScoreItemPoints(points)
    {
        "<<points>> <<points == 1 ? 'Punkt' : 'Punkte'>> für ";
    }

    /* score change - first notification */
    firstScoreChange(delta)
    {
        scoreChange(delta);
        scoreChangeTip.showTip();
    }

    /* score change - notification other than the first time */
    scoreChange(delta)
    {
        "<.commandsep><.notification><<
        basicScoreChange(delta)>><./notification> ";
    }

    /*
     *   basic score change notification message - this is an internal
     *   service routine for scoreChange and firstScoreChange 
     */
    basicScoreChange(delta)
    {
        "Dein <<aHref(commandFullScore, 'Punktestand', 'Zeige volle Punkte an')>>
        hat sich gerade um <<delta == 1 || delta == -1 ? 'einen' : spellInt(delta > 0 ? delta : -delta)>>
        Punkt<<delta is in (1, -1) ? '' : 'e'>> <<delta > 0 ? 'erhöht' : 'verringert'>>.";
    }

    /* acknowledge turning tips on or off */
    acknowledgeTipStatus(stat)
    {
        "<.parser>Tipps sind jetzt <<stat ? 'ein' : 'aus'>>geschaltet.<./parser> ";
    }

    /* describe the tip mode setting */
    tipStatusShort(stat)
    {
        "TIPPS <<stat ? 'EIN' : 'AUS'>>";
    }

    /* get the string to display for a footnote reference */
    footnoteRef(num)
    {
        local str;

        /* set up a hyperlink for the note that enters the "note n" command */
        str = '<sup>[<a href="footnote ' + num + '"><.a>';

        /* show the footnote number in square brackets */
        str += num;
        
        /* end the hyperlink */
        str += '<./a></a>]</sup>';

        /* return the text */
        return str;
    }

    /* first footnote notification */
    firstFootnote()
    {
        footnotesTip.showTip();
    }

    /* there is no such footnote as the given number */
    noSuchFootnote(num)
    {
        "<.parser>Diese Fußnote gibt es nicht.<./parser> ";
    }

    /* show the current footnote status */
    showFootnoteStatus(stat)
    {
        "Die momentane Einstellung ist FUSSNOTEN ";
        switch(stat)
        {
        case FootnotesOff:
            "AUS, alle Fußnotenanzeigen sind unterdrückt.
            Gib <<aHref('Fußnoten mittel', 'FUSSNOTEN MITTEL',
            'Setze Fußnoten auf mittel')>> ein , um nur Fußnoten 
            Referenzen zu zeigen, die du noch nicht gelesen
            hast, oder <<aHref('Fußnoten voll', 
            'FUSSNOTEN VOLL','Setze Fußnoten auf voll')>>,
            um alle Fußnoten Referenzen anzuzeigen. ";
            break;

        case FootnotesMedium:
            "MITTEL, zeigt nur Fussnoten an, die du noch nicht gelesen
            hast und versteckt Referenzen, die du bereits gelesen hast. Gib
            <<aHref('Fußnoten aus', 'FUSSNOTEN AUS',
                    'Schalte Fußnoten aus')>> ein, um die Fußnotenanzeigen
            komplett auszuschalten, oder <<aHref('Fußnoten voll', 'FUSSNOTEN VOLL',
                'Setze Fußnoten auf voll')>> um jede Referenz anzuzeigen, selbst
            wenn du diese bereits gelsen hast. ";
            break;

        case FootnotesFull:
            "VOLL, zeigt jede Fussnoten Referenz an, selbst wenn du diese
            bereits gelesen hast.  Gib <<aHref('Fußnoten mittel',
            'FUSSNOTEN MITTEL', 'Setze Fußnoten auf mittel')>>ein, um nur
            Referenzen anzuzeigen, die du noch nicht gelesen hast, oder <<
              aHref('Fußnoten aus', 'FUSSNOTEN AUS', 'Schalte Fußnoten aus')>>,
            um die Fußnotenanzeigen komplett auszuschalten. ";
            break;
        }
    }

    /* acknowledge a change in the footnote status */
    acknowledgeFootnoteStatus(stat)
    {
        "<.parser>Die Einstellung ist jetzt
        <<shortFootnoteStatus(stat)>>.<./parser> ";
    }

    /* show the footnote status, in short form */
    shortFootnoteStatus(stat)
    {
        "FUSSNOTEN <<
          stat == FootnotesOff ? 'AUS'
          : stat == FootnotesMedium ? 'MITTEL'
          : 'VOLL' >>";
    }

    /*
     *   Show the main command prompt.
     *   
     *   'which' is one of the rmcXxx phase codes indicating what kind of
     *   command we're reading.  This default implementation shows the
     *   same prompt for every type of input, but games can use the
     *   'which' value to show different prompts for different types of
     *   queries, if desired.  
     */
    mainCommandPrompt(which) { "\b&gt;"; }

    /*
     *   Show a pre-resolved error message string.  This simply displays
     *   the given string.  
     */
    parserErrorString(actor, msg) { say(msg); }

    /* show the response to an empty command line */
    emptyCommandResponse = "<.parser>Wie bitte?<./parser> "

    /* invalid token (i.e., punctuation) in command line */
    invalidCommandToken(ch)
    {
        "<.parser>Das Zeichen &lsquo;<<ch>>&rsquo; ist ungültig.<./parser> ";
    }

    /*
     *   Command group prefix - this is displayed after a command line and
     *   before the first command results shown after the command line.
     *   
     *   By default, we'll show the "zero-space paragraph" marker, which
     *   acts like a paragraph break in that it swallows up immediately
     *   following paragraph breaks, but doesn't actually add any space.
     *   This will ensure that we don't add any space between the command
     *   input line and the next text.  
     */
    commandResultsPrefix = '<.p0>'

    /*
     *   Command "interruption" group prefix.  This is displayed after an
     *   interrupted command line - a command line editing session that
     *   was interrupted by a timeout event - just before the text that
     *   interrupted the command line.
     *   
     *   By default, we'll show a paragraph break here, to set off the
     *   interrupting text from the command line under construction.  
     */
    commandInterruptionPrefix = '<.p>'

    /*
     *   Command separator - this is displayed after the results from a
     *   command when another command is about to be executed without any
     *   more user input.  That is, when a command line contains more than
     *   one command, this message is displayed between each successive
     *   command, to separate the results visually.
     *   
     *   This is not shown before the first command results after a
     *   command input line, and is not shown after the last results
     *   before a new input line.  Furthermore, this is shown only between
     *   adjacent commands for which output actually occurs; if a series
     *   of commands executes without any output, we won't show any
     *   separators between the silent commands.
     *   
     *   By default, we'll just start a new paragraph.  
     */
    commandResultsSeparator = '<.p>'

    /*
     *   "Complex" result separator - this is displayed between a group of
     *   messages for a "complex" result set and adjoining messages.  A
     *   command result list is "complex" when it's built up out of
     *   several generated items, such as object identification prefixes
     *   or implied command prefixes.  We use additional visual separation
     *   to set off these groups of messages from adjoining messages,
     *   which is especially important for commands on multiple objects,
     *   where we would otherwise have several results shown together.  By
     *   default, we use a paragraph break.  
     */
    complexResultsSeparator = '<.p>'

    /*
     *   Internal results separator - this is displayed to visually
     *   separate the results of an implied command from the results for
     *   the initiating command, which are shown after the results from
     *   the implied command.  By default, we show a paragraph break.
     */
    internalResultsSeparator = '<.p>'

    /*
     *   Command results suffix - this is displayed just before a new
     *   command line is about to be read if any command results have been
     *   shown since the last command line.
     *   
     *   By default, we'll show nothing extra.  
     */
    commandResultsSuffix = ''

    /*
     *   Empty command results - this is shown when we read a command line
     *   and then go back and read another without having displaying
     *   anything.
     *   
     *   By default, we'll return a message indicating that nothing
     *   happened.  
     */
    commandResultsEmpty =
        ('Es {passiert singular} offensichtlich nichts{*}.<.p>')

    /*
     *   Intra-command report separator.  This is used to separate report
     *   messages within a single command's results.  By default, we show
     *   a paragraph break.  
     */
    intraCommandSeparator = '<.p>'

    /*
     *   separator for "smell" results - we ordinarily show each item's
     *   odor description as a separate paragraph 
     */
    smellDescSeparator()
    {
        "<.p>";
    }

    /*
     *   separator for "listen" results 
     */
    soundDescSeparator()
    {
        "<.p>";
    }

    /* a command was issued to a non-actor */
    cannotTalkTo(targetActor, issuingActor)
    {
        "\^<<issuingActor.derName>> <<issuingActor.verbZuKannKon>> mit <<targetActor.demName>> nicht reden{*}.";
    }

    /* greeting actor while actor is already talking to us */
    alreadyTalkingTo(actor, greeter)
    {
        "\^<<greeter.derName>> <<greeter.verbZuSein>> schon im Gespräch mit <<actor.demName>>{*}. ";
    }

    /* no topics to suggest when we're not talking to anyone */
    noTopicsNotTalking = "<.parser>{Du/er} {spricht} momentan mit niemandem{*}.<./parser> "

    /*
     *   Show a note about the OOPS command.  This is, by default, added
     *   to the "I don't know that word" error the first time that error
     *   occurs.  
     */
    oopsNote()
    {
        oopsTip.showTip();
    }

    /* can't use OOPS right now */
    oopsOutOfContext = "<.parser>Du kannst UPS nur verwenden, um
        einen Tippfehler zu korrgieren, unmittelbar nachdem die 
        Geschichte ein Wort nicht erkannt hat.<./parser> "

    /* OOPS in context, but without the word to correct */
    oopsMissingWord = "<.parser>Um mit UPS einen Tippfehler zu
        korrigieren, schreib das zu korrigierende Wort nach UPS,
        also beispielsweise UPS BUCH.<./parser> "

    /* acknowledge setting VERBOSE mode (true) or TERSE mode (nil) */
    acknowledgeVerboseMode(verbose)
    {
        if (verbose)
            "<.parser>WORTREICHER Modus ausgewählt.<./parser> ";
        else
            "<.parser>KNAPPER Modus ausgewählt.<./parser> ";
    }

    /* show the current VERBOSE setting, in short form */
    shortVerboseStatus(stat) { "<<stat ? 'WORTREICH' : 'KNAPP'>> mode"; }

    /* show the current score notify status */
    showNotifyStatus(stat)
    {
        "<.parser>Mitteilung der Punkte momentan
        <<stat ? 'ein' : 'aus'>>geschaltet.<./parser> ";
    }

    /* show the current score notify status, in short form */
    shortNotifyStatus(stat) { "PUNKTE <<stat ? 'AN' : 'AUS'>>"; }

    /* acknowledge a change in the score notification status */
    acknowledgeNotifyStatus(stat)
    {
        "<.parser>Mitteilung der Punkte nun 
        <<stat ? 'ein' : 'aus'>>geschaltet.<./parser> ";
    }

    /*
     *   Announce the current object of a set of multiple objects on which
     *   we're performing an action.  This is used to tell the player
     *   which object we're acting upon when we're iterating through a set
     *   of objects specified in a command targeting multiple objects.  
     */
    announceMultiActionObject(obj, whichObj, action)
    {
        local prep;
        local ret;
        curcase.d_flag = nil;

        switch(whichObj)
        {
        case DirectObject:
            /* use the preposition in the first "(what)" phrase */
            rexSearch('<lparen>(.*?)<space>*<alpha>+<rparen>', action.verbPhrase);
            prep = rexGroup(1)[3];
            break;

        case IndirectObject:
            /* use the preposition in the second "(what)" phrase */
            rexSearch('<rparen>.*<lparen>(.*?)<space>*<alpha>+<rparen>',
                      action.verbPhrase);
            prep = rexGroup(1)[3];
            break;
        }

        if (prep.endsWith('dativ'))
        {
            curcase.d_flag = true;
            prep = prep.substr(1 ,prep.length() - 5);
        }

        if (prep.endsWith(' '))
        {
            curcase.d_flag = true;
            prep = prep.substr(1 ,prep.length() - 1);
        }
        
        // -- German: this is expanded: check whether the verb requires a dative case
        // -- and set the appropriate name property

        if (curcase.d_flag)
            ret = obj.getAnnouncementDistinguisher(
                action.getResolvedObjList(whichObj)).demName(obj);
        else
            ret = obj.getAnnouncementDistinguisher(
                action.getResolvedObjList(whichObj)).denName(obj);
        return '<./p0>\n<.announceObj>'
            + ret
            + ':<./announceObj> <.p0>';
    }

    /*
     *   Announce a singleton object that we selected from a set of
     *   ambiguous objects.  This is used when we disambiguate a command
     *   and choose an object over other objects that are also logical but
     *   are less likely.  In such cases, it's courteous to tell the
     *   player what we chose, because it's possible that the user meant
     *   one of the other logical objects - announcing this type of choice
     *   helps reduce confusion by making it immediately plain to the
     *   player when we make a choice other than what they were thinking.  
     */
    announceAmbigActionObject(obj, whichObj, action)
    {
        local prep;
        local ret;
        curcase.d_flag = nil;

        switch(whichObj)
        {
        case DirectObject:
            /* use the preposition in the first "(what)" phrase */
            rexSearch('<lparen>(.*?)<space>*<alpha>+<rparen>', action.verbPhrase);
            prep = rexGroup(1)[3];
            break;

        case IndirectObject:
            /* use the preposition in the second "(what)" phrase */
            rexSearch('<rparen>.*<lparen>(.*?)<space>*<alpha>+<rparen>',
                      action.verbPhrase);
            prep = rexGroup(1)[3];
            break;
        }

        if (prep.endsWith('dativ'))
        {
            curcase.d_flag = true;
            prep = prep.substr(1 ,prep.length() - 5);
        }

        if (prep.endsWith(' '))
        {
            curcase.d_flag = true;
            prep = prep.substr(1 ,prep.length() - 1);
        }
        
        // -- German: this is expanded: check whether the verb requires a dative case
        // -- and set the appropriate name property

        /* announce the object in "assume" style, ending with a newline */
        if (curcase.d_flag)
            ret = obj.getAnnouncementDistinguisher(gActor.scopeList())
            .demName(obj);
        else
            ret = obj.getAnnouncementDistinguisher(gActor.scopeList())
            .denName(obj);

        return '<.assume>'
            + ret
            + '<./assume>\n';
    }

    /*
     *   Announce a singleton object we selected as a default for a
     *   missing noun phrase.
     *   
     *   'resolvedAllObjects' indicates where we are in the command
     *   processing: this is true if we've already resolved all of the
     *   other objects in the command, nil if not.  We use this
     *   information to get the phrasing right according to the situation.
     */
    announceDefaultObject(obj, whichObj, action, resolvedAllObjects)
    {
        /*
         *   put the action's default-object message in "assume" style,
         *   and start a new line after it 
         */
        return '<.assume>'
            + action.announceDefaultObject(obj, whichObj, resolvedAllObjects)
            + '<./assume>\n';
    }

    /* 'again' used with no prior command */
    noCommandForAgain()
    {
        "<.parser>Es gibt noch keinen Befehl zum Wiederholen.<./parser> ";
    }

    /* 'again' cannot be directed to a different actor */
    againCannotChangeActor()
    {
        "<.parser>Um einen Befehl wie <q>Floyd, geh nach Norden</q> zu
        wiederholen, sag <q>nochmal</q>, statt <q>Floyd, nochmal.</q><./parser> ";
    }

    /* 'again': can no longer talk to target actor */
    againCannotTalkToTarget(issuer, target)
    {
        "\^<<issuer.derName>> <<issuer.verbZuKannKon>> diesen Befehl nicht wiederholen{*}. ";
    }

    /* the last command cannot be repeated in the present context */
    againNotPossible(issuer)
    {
        "Der Befehl kann jetzt nicht wiederholt werden. ";
    }

    /* system actions cannot be directed to non-player characters */
    systemActionToNPC()
    {
        "<.parser>Dieser Befehl kann keiner Person erteilt werden.<./parser> ";
    }

    /* confirm that we really want to quit */
    confirmQuit()
    {
        "Willst du das Spiel wirklich verlassen?\ (Mit <<aHref('j', 'J', 'Zustimmung')
        >> stimmst du zu) >\ ";
    }

    /*
     *   QUIT message.  We display this to acknowledge an explicit player
     *   command to quit the game.  This is the last message the game
     *   displays on the way out; there is no need to offer any options at
     *   this point, because the player has decided to exit the game.
     *   
     *   By default, we show nothing; games kann override this to display an
     *   acknowledgment if desired.  Note that this isn't a general
     *   end-of-game 'goodbye' message; the library only shows this to
     *   acknowledge an explicit QUIT command from the player.  
     */
    okayQuitting() { }

    /*
     *   "not terminating" confirmation - this is displayed when the
     *   player doesn't acknowledge a 'quit' command with an affirmative
     *   response to our confirmation question 
     */
    notTerminating()
    {
        "<.parser>Geschichte fortgesetzt.<./parser> ";
    }

    /* confirm that they really want to restart */
    confirmRestart()
    {
        "Willst du wirklich neu beginnen?\ (mit <<aHref('J', 'J',
        'Bestätigen')>> stimmst du zu) >\ ";
    }

    /* "not restarting" confirmation */
    notRestarting() { "<.parser>Geschichte fortgesetzt.<./parser> "; }

    /*
     *   Show a game-finishing message - we use the conventional "*** You
     *   have won! ***" format that text games have been using since the
     *   dawn of time. 
     */
    showFinishMsg(msg) { "<.p>*** <<msg>>\ ***<.p>"; }

    /* standard game-ending messages for the common outcomes */
    // *** HIER WEITER ***
    finishDeathMsg = '{DU/ER pc} {IST} GESTORBEN'
    finishVictoryMsg = ('DU HAST GEWONNEN')
    finishFailureMsg = ('DU HAST VERLOREN')
    finishGameOverMsg = 'SPIEL VORBEI'

    /*
     *   Get the save-game file prompt.  Note that this must return a
     *   single-quoted string value, not display a value itself, because
     *   this prompt is passed to inputFile(). 
     */
    getSavePrompt =
        'Bitte wähle die Datei, in die gespeichert werden soll'

    /* get the restore-game prompt */
    getRestorePrompt = 'Bitte wähle die Datei, die geladen werden soll'

    /* successfully saved */
    saveOkay() { "<.parser>Gespeichert.<./parser> "; }

    /* save canceled */
    saveCanceled() { "<.parser>Abgebrochen.<./parser> "; }

    /* saved failed due to a file write or similar error */
    saveFailed(exc)
    {
        "<.parser>Fehlgeschlagen. Entweder hat dein Rechner keinen Speicherplatz
        mehr auf dem Datenträger oder du hast nicht die notwendigen Rechte, auf
        diesen Datenträger zu schreiben.<./parser> ";
    }

    /* save failed due to storage server request error */
    saveFailedOnServer(exc)
    {
        "<.parser>Fehlgeschlagen aufgrund eines Zugriffsproblems des Servers:
        <<makeSentence(exc.errMsg)>><./parser>";
    }

    /* 
     *   make an error message into a sentence, by capitalizing the first
     *   letter and adding a period at the end if it doesn't already have
     *   one 
     */
    makeSentence(msg)
    {
        return rexReplace(
            ['^<space>*[a-z]', '(?<=[^.?! ])<space>*$'], msg,
            [{m: m.toUpper()}, '.']);
    }

    /* note that we're restoring at startup via a saved-position launch */
    noteMainRestore() { "<.parser>Wiederherstellen der Geschichte...<./parser>\n"; }

    /* successfully restored */
    restoreOkay() { "<.parser>Wiederhergestellt.<./parser> "; }

    /* restore canceled */
    restoreCanceled() { "<.parser>Abgebrochen.<./parser> "; }

    /* restore failed due to storage server request error */
    restoreFailedOnServer(exc)
    {
        "<.parser>Fehlgeschlagen aufgrund eines Zugriffsproblems des Servers:
        <<makeSentence(exc.errMsg)>><./parser>";
    }

    /* restore failed because the file was not a valid saved game file */
    restoreInvalidFile()
    {
        "<.parser>Fehlgeschlagen: kein gültiger gespeicherter Spielstand.<./parser> ";
    }

    /* restore failed because the file was corrupted */
    restoreCorruptedFile()
    {
        "<.parser>Fehlgeschlagen: die Speicherdatei scheint korrupt zu
        sein. Dies kann passieren, wenn die Datei von einem anderen Programm
        modifiziert wurde, wenn die Datei zwischen zwei Computern
        in einem nicht-binären Transfermodus kopiert wurde oder wenn
        das Medium beschädigt ist.<./parser> ";
    }

    /* restore failed because the file was for the wrong game or version */
    restoreInvalidMatch()
    {
        "<.parser>Fehlgeschlagen: die Datei wurde nicht gespeichert 
        (oder wurde mit einer anderen nicht-kompatiblen Version
        dieser Geschichte gespeichert).<./parser> ";
    }

    /* restore failed for some reason other than those distinguished above */
    restoreFailed(exc)
    {
        "<.parser>Fehlgeschlagen: der Stand konnte nicht wieder hergestellt
        werden.<./parser> ";
    }

    /* error showing the input file dialog (or whatever) */
    filePromptFailed()
    {
        "<.parser>Ein Systemfehler trat beim Dateidialog auf.
        Der Computer kann ein Speicher- oder Konfigurationsproblem 
        haben.<./parser> ";
    }
	
    /* error showing the input file dialog, with a system error message */
    filePromptFailedMsg(msg)
    {
        "<.parser>Fehlgeschlagen: <<makeSentence(msg)>><./parser> ";
    }

    /* Web UI inputFile error: uploaded file is too large */
    webUploadTooBig = 'Die ausgewählte Datei ist zu groß für den Upload.'

    /* PAUSE prompt */
    pausePrompt()
    {
        "<.parser>Die Geschichte pausiert.  Bitte drücke die
        Leertaste, wenn du bereit bist, weiterzumachen oder drücke die 
        &lsquo;S&rsquo; Taste, um den aktuellen Stand zu speichern.<./parser><.p>";
    }

    /* saving from within a pause */
    pauseSaving()
    {
        "<.parser>Speichern der Geschichte...<./parser><.p>";
    }

    /* PAUSE ended */
    pauseEnded()
    {
        "<.parser>Geschichte fortgesetzt.<./parser> ";
    }

    /* acknowledge starting an input script */
    inputScriptOkay(fname)
    {
        "<.parser>Befehle einlesen von <q><<File.getRootName(fname).htmlify()>></q>...<./parser>\n ";
    }

    /* error opening input script */
    inputScriptFailed = "<.parser>Fehlgeschlagen, die Skriptdatei konnte nicht
        geöffnet werden.<./parser> "
        

    /* get the scripting inputFile prompt message */
    getScriptingPrompt = 'Bitte wähle einen Namen für eine neue Skriptdatei'

    /* acknowledge scripting on */
    scriptingOkay()
    {
        "<.parser>Der Text wird nun in die Skriptdatei gespeichert.
        Gib <<aHref('Skript aus', 'SKRIPT AUS', 'Schalte Skript aus')>> ein, um
        die Skriptfunktion auszuschalten.<./parser> ";
    }

 scriptingOkayWebTemp()
    {
        "<.parser>Der Text wird nun gespeichert.
  Gib <<aHref('Skript aus', 'SKRIPT AUS', 'Schalte Skript aus')>> ein, um
        die Skriptfunktion auszuschalten und das gespeicherte Skript downzuloaden
        <./parser> ";
    }

    /* scripting failed */
    scriptingFailed = "<.parser>Fehlgeschlagen, ein Fehler trat beim Öffnen der
        Skriptdatei auf.<./parser> "

    /* scripting failed with an exception */
    scriptingFailedException(exc)
    {
        "<.parser>Fehlgeschlagen: <<exc.displayException>><./parser>";
    }

    /* acknowledge cancellation of script file dialog */
    scriptingCanceled = "<.parser>Skript abgebrochen.<./parser> "

    /* acknowledge scripting off */
    scriptOffOkay = "<.parser>Skript beendet.<./parser> "

    /* SCRIPT OFF ignored because we're not in a script file */
    scriptOffIgnored = "<.parser>Im Moment wird kein Skript aufgezeichnet.<./parser> "

    /* get the RECORD prompt */
    getRecordingPrompt = 'Bitte wähle einen Namen für eine neue Befehlsdatei'

    /* acknowledge recording on */
    recordingOkay = "<.parser>Befehle werden jetzt in die Befehlsdatei übertragen. Gib
                     <<aHref('Aufnahme aus', 'AUFNAHME AUS',
                             'Schalte Aufnahme aus')>>, um
                     die Befehlsaufnahme zu beenden.<.parser> "
	  
    /* recording failed */
    recordingFailed = "<.parser>Fehlgeschlagen. Ein Fehler trat beim Öffnen der
        Speicherdatei auf.<./parser> "

    /* recording failed with exception */
    recordingFailedException(exc)
    {
        "<.parser>Fehlgeschlagen: <<exc.displayException()>><./parser> ";
    }


    /* acknowledge cancellation */
    recordingCanceled = "<.parser>Befehlsaufzeichnung abgebrochen.<./parser> "

    /* recording turned off */
    recordOffOkay = "<.parser>Befehlsaufzeichnung beendet.<./parser> "

    /* RECORD OFF ignored because we're not recording commands */
    recordOffIgnored = "<.parser>Im Moment läuft keine Befehlsaufzeichnung.<./parser> "

    /* REPLAY prompt */
    getReplayPrompt = 'Bitte wähle eine Befehlsdatei, die abgespult werden soll'

    /* REPLAY file selection kannceled */
    replayCanceled = "<.parser>Abgebrochen.<./parser> "

    /* undo command succeeded */
    undoOkay(actor, cmd)
    {
        "<.parser>Einen Zug zurück genommen: <q>";

        /* show the target actor prefix, if an actor was specified */
        if (actor != nil)
            "<<actor>>, ";

        /* show the command */
        "<<cmd>></q>.<./parser><.p>";
    }

    /* undo command failed */
    undoFailed()
    {
        "<.parser>Keine weitere UNDO Information verfügbar.<./parser> ";
    }

    /* comment accepted, with or without transcript recording in effect */
    noteWithScript = "<.parser>Kommentar aufgezeichnet.<./parser> "
    noteWithoutScript = "<.parser>Kommentar <b>nicht</b> aufgezeichnet.<./parser> "

    /* on the first comment without transcript recording, warn about it */
    noteWithoutScriptWarning = "<.parser>Kommentar <b>nicht</b> aufgezeichnet.
        Benutze <<aHref('Skript', 'SKRIPT', 'Beginn mit der Skriptaufzeichnung')
          >>, wenn du die Skriptaufzeichnung starten willst.<./parser> "

    /* invalid finishGame response */
    invalidFinishOption(resp)
    {
        "\bDas war keine der Wahlmöglichkeiten. ";
    }

    /* acknowledge new "exits on/off" status */
    exitsOnOffOkay(stat, look)
    {
        if (stat && look)
            "<.parser>Die Ausgänge werden nun sowohl in der Statuszeile
            als auch in der Ortsbeschreibung ausgegeben.<./parser> ";
        else if (!stat && !look)
            "<.parser>Die Ausgänge werden nicht mehr in der Statuszeile
            und auch nicht mehr in der Ortsbeschreibung ausgegeben.<./parser> ";
        else
            "<.parser>Die Ausgänge <<stat ? 'werden' : 'werden nicht'>> in der 
            Statuszeile<<look ? ', aber' : ' und nicht'>>
            in der Ortsbeschreibung ausgegeben.<./parser> ";
    }

    /* explain how to turn exit display on and off */
    explainExitsOnOff()
    {
        exitsTip.showTip();
    }

    /* describe the current EXITS settings */
    currentExitsSettings(statusLine, roomDesc)
    {
        "AUSGÄNGE ";
        if (statusLine && roomDesc)
            "AN";
        else if (statusLine)
            "STATUS";
        else if (roomDesc)
            "RAUM";
        else
            "AUS";
    }

    /* acknowledge HINTS OFF */
    hintsDisabled = '<.parser>Hinweise sind jetzt ausgeschaltet.<./parser> '

    /* rebuff a request for hints when they've been previously disabled */
    sorryHintsDisabled = '<.parser>Wie gewünscht sind Hinweise für diesen
        Durchgang ausgeschaltet. Wenn du deine Meinung geändert hast, musst du
        den Fortschritt speichern, den TADS Interpreter verlassen und einen
        neuen Durchgang starten.<./parser> '

    /* this game has no hints */
    hintsNotPresent = '<.parser>Diese Geschichte hat keine Hinweise
        eingebaut.<./parser> '

    /* there are currently no hints available (but there might be later) */
    currentlyNoHints = '<.parser>Momentan sind keine Hinweise verfügbar.
                        Bitte schau später wieder nach.<./parser> '

    /* show the hint system warning */
    showHintWarning =
       "<.notification>Warnung: Manche mögen keine eingebauten Hinweise,
       weil die Versuchung, diese zu konsultieren, auf diese einfache Art
       sehr mächtig sein kann.  Wenn du dir Sorgen machst, dass deine 
       Willenskraft zu schwach ist, kann du die Hinweise für diesen Durchgang
       ausschalten, indem du <<aHref('Hinweise aus', 'HINWEISE AUS')>> eingibst.
       Wenn du die Hinweise trotzdem noch sehen willst, gib stattdessen
       <<aHref('Hinweise', 'HINWEISE')>> ein.<./notification> "

    /* done with hints */
    hintsDone = '<.parser>Erledigt.<./parser> '

    /* optional command is not supported in this game */
    commandNotPresent = "<.parser>Dieser Befehl wird in dieser Geschichte
        nicht benötigt.<./parser> "

    /* this game doesn't use scoring */
    scoreNotPresent = "<.parser>Diese Geschichte verwendet keine Punkte.<./parser> "

    /* mention the FULL SCORE command */
    mentionFullScore()
    {
        fullScoreTip.showTip();
    }

    /* SAVE DEFAULTS successful */
    savedDefaults()
    {
        "<.parser>Die momentanen Einstellungen sind als Standard abgespeichert
        worden. Die gepseicherten Einstellungen sind: ";

        /* show all of the settings */
        settingsUI.showAll();

        ".  Die meisten neueren Geschichten werden deise Einstellungen automatisch
        übernehmen, wenn du beginnst (oder neustartest), aber manche der älteren möglichwerweise
        nicht.<./parser> ";
    }

    /* RESTORE DEFAULTS successful */
    restoredDefaults()
    {
        "<.parser>Die gespeicherten Einstellungen sind wiederhergestellt.  Die
        neuen Einstellungen sind: ";

        /* show all of the settings */
        settingsUI.showAll();

        ".<./parser> ";
    }

    /* show a separator for the settingsUI.showAll() list */
    settingsItemSeparator = "; "

    /* SAVE/RESTORE DEFAULTS not supported (old interpreter version) */
    defaultsFileNotSupported = "<.parser>Leider unterstützt diese Version des
        TADS Interpreters kein Speichern oder Wiederherstellen
        der Einstellungen. Du musst eine neuere Version installieren, um
        diese Funktion zu benutzen.<./parser> "

    /* RESTORE DEFAULTS file open/read error */
    defaultsFileReadError(exc)
    {
        "<.parser>Ein Fehler trat beim Lesen der Einstellungen
        auf. Die Standardeinstellungen konnten nicht wiederhergestellt werden.<./parser> ";
    }

    /* SAVE DEFAULTS file creation error */
    defaultsFileWriteError = "<.parser>Ein Fehler trat beim Speichern der
        Einstellungen auf.  Die Standardeinstellungen wurden nicht gespeichert.  
        Du hast entweder zuwenig Speicherplatz auf dem Datenträger oder
        keine Berechtigung, darauf zu schreiben.<./parser> "

    /*
     *   Command key list for the menu system.  This uses the format
     *   defined for MenuItem.keyList in the menu system.  Keys must be
     *   given as lower-case in order to match input, since the menu
     *   system converts input keys to lower case before matching keys to
     *   this list.  
     *   
     *   Note that the first item in each list is what will be given in
     *   the navigation menu, which is why the fifth list contains 'ENTER'
     *   as its first item, even though this will never match a key press.
     */
    menuKeyList = [
                   ['q'],
                   ['p', '[left]', '[bksp]', '[esc]'],
                   ['u', '[up]'],
                   ['d', '[down]'],
                   ['ENTER', '\n', '[right]', ' ']
                  ]

    /* link title for 'previous menu' navigation link */
    prevMenuLink = '<font size=-1>Previous</font>'

    /* link title for 'next topic' navigation link in topic lists */
    nextMenuTopicLink = '<font size=-1>Next</font>'

    /*
     *   main prompt text for text-mode menus - this is displayed each
     *   time we ask for a keystroke to navigate a menu in text-only mode 
     */
    textMenuMainPrompt(keylist)
    {
        "\bWähle eine Nummer aus oder drücke &lsquo;<<
        keylist[M_PREV][1]>>&rsquo; für das vorhergehende Menü oder 
        &lsquo;<<keylist[M_QUIT][1]>>&rsquo; zum Verlassen:\ ";
    }

    /* prompt text for topic lists in text-mode menus */
    textMenuTopicPrompt()
    {
        "\bDrücke die Leertaste, um die nächste Zeile anzuzeigen,
        &lsquo;<b>P</b>&rsquo; um zum vorhergehenden Menü zu springen, oder
        &lsquo;<b>Q</b>&rsquo; zum Verlassen.\b";
    }

    /*
     *   Position indicator for topic list items - this is displayed after
     *   a topic list item to show the current item number and the total
     *   number of items in the list, to give the user an idea of where
     *   they are in the overall list.  
     */
    menuTopicProgress(cur, tot) { " [<<cur>>/<<tot>>]"; }

    /*
     *   Message to display at the end of a topic list.  We'll display
     *   this after we've displayed all available items from a
     *   MenuTopicItem's list of items, to let the user know that there
     *   are no more items available.  
     */
    menuTopicListEnd = '[Ende]'

    /*
     *   Message to display at the end of a "long topic" in the menu
     *   system.  We'll display this at the end of the long topic's
     *   contents.  
     */
    menuLongTopicEnd = '[Ende]'

    /*
     *   instructions text for banner-mode menus - this is displayed in
     *   the instructions bar at the top of the screen, above the menu
     *   banner area 
     */
    menuInstructions(keylist, prevLink)
    {
        "<tab align=right ><b>\^<<keylist[M_QUIT][1]>></b>=Quit <b>\^<<
        keylist[M_PREV][1]>></b>=Vorhergehendes Menü<br>
        <<prevLink != nil ? aHrefAlt('vorher', prevLink, '') : ''>>
        <tab align=right ><b>\^<<keylist[M_UP][1]>></b>=Hoch <b>\^<<
        keylist[M_DOWN][1]>></b>=Runter <b>\^<<
        keylist[M_SEL][1]>></b>=Auswahl<br>";
    }

    /* show a 'next chapter' link */
    menuNextChapter(keylist, title, hrefNext, hrefUp)
    {
        "Nächstes: <a href='<<hrefNext>>'><<title>></a>;
        <b>\^<<keylist[M_PREV][1]>></b>=<a href='<<hrefUp>>'>Menü</a>";
    }

    /*
     *   cannot reach (i.e., touch) an object that is to be manipulated in
     *   a command - this is a generic message used when we cannot
     *   identify the specific reason that the object is in scope but
     *   cannot be touched 
     */
    cannotReachObject(obj)
    {
        "{Du/er} {koennt} <<obj.denNameObj>> nicht erreichen{*}. ";
    }

    /*
     *   cannot reach an object, because the object is inside the given
     *   container 
     */
    cannotReachContents(obj, loc)
    {
        gMessageParams(obj, loc);
        return '{Du/er} {koennt} {den obj/ihn} in '
            + '{dem loc/ihn} nicht erreichen{*}. ';
    }

    /* cannot reach an object because it's outisde the given container */
    cannotReachOutside(obj, loc)
    {
        gMessageParams(obj, loc);
        return '{Du/er} {koennt} {den obj/ihn} von '
            + '{dem loc/ihm} aus nicht erreichen{*}. ';
    }

    /* sound is coming from inside/outside a container */
    soundIsFromWithin(obj, loc)
    {
        "\^<<obj.derName>> <<obj.verbZuKommen>> offenbar aus
        <<loc.demNameObj>>{*}. ";
    }
    soundIsFromWithout(obj, loc)
    {
        "\^<<obj.derName>> <<obj.verbZuKommen>> offenbar von
        <<loc.demNameObj>>{*}. ";
    }

    /* odor is coming from inside/outside a container */
    smellIsFromWithin(obj, loc)
    {
        "\^<<obj.derName>> <<obj.verbZuKommen>> offenbar aus
        <<loc.demNameObj>>{*}. ";
    }
    smellIsFromWithout(obj, loc)
    {
        "\^<<obj.derName>> <<obj.verbZuKommen>> offenbar von
        <<loc.demNameObj>>{*}. ";
    }

    /* default description of the player character */
    pcDesc(actor)
    {
        "\^<<actor.derName>> <<actor.verbZuSehen>> wie immer aus<<actor.dummyPartWithoutBlank>>. ";
    }

    /*
     *   Show a status line addendum for the actor posture, without
     *   mentioning the actor's location.  We won't mention standing, since
     *   this is the default posture.  
     */
    roomActorStatus(actor)
    {
        /* mention any posture other than standing */
        if (actor.posture != standing)
            " (<<buildSynthParam('subj', actor)>><<actor.posture.participle>>)";
    }

    /* show a status line addendum: standing in/on something */
    actorInRoomStatus(actor, room)
        { " (<<buildSynthParam('subj', actor)>><<room.actorInName>>
            <<actor.posture.participle>>)"; }

    /* generic short description of a dark room */
    roomDarkName = 'Dunkelheit'

    /* generic long description of a dark room */
    roomDarkDesc = "Es {ist singular} {hier|dort} stockdunkel{*}. "

    /*
     *   mention that an actor is here, without mentioning the enclosing
     *   room, as part of a room description 
     */
    roomActorHereDesc(actor)
    {
        "\^<<actor.derName>> <<buildSynthParam('subj', actor)>> 
        <<actor.posture.msgVerbT>> {hier|dort}{*}. ";
    }

    /*
     *   mention that an actor is visible at a distance or remotely,
     *   without mentioning the enclosing room, as part of a room
     *   description 
     */
    roomActorThereDesc(actor) //HIER EINGEFÜGT BUILD SYNTH PARAM FUNKTION UM SUBJ RICHTIG ZU SETZEN
    {
        "\^<<actor.derName>> <<buildSynthParam('subj', actor)>> 
        <<actor.posture.msgVerbT>> ganz in der Nähe{*}. ";
    }

    /*
     *   Mention that an actor is in a given local room, as part of a room
     *   description.  This is used as a default "special description" for
     *   an actor.  
     */
    actorInRoom(actor, cont)
    {
        "\^<<actor.derName>> <<buildSynthParam('subj', actor)>>
        <<actor.posture.msgVerbT>> <<cont.actorInName>>{*}. ";
    }

    /*
     *   Describe an actor as standing/sitting/lying on something, as part
     *   of the actor's EXAMINE description.  This is additional
     *   information added to the actor's description, so we refer to the
     *   actor with a pronoun ("He's standing here").  
     */
    actorInRoomPosture(actor, room)
    {
        "\^<<actor.itNom>> <<buildSynthParam('subj', actor)>>
        <<actor.posture.msgVerbT>> <<room.actorInName>>{*}. ";
    }

    /*
     *   Describe an actor's posture, as part of an actor's "examine"
     *   description.  If the actor is standing, don't bother mentioning
     *   anything, as standing is the trivial default condition.  
     */
    roomActorPostureDesc(actor)
    {
        if (actor.posture != standing)
            "\^<<actor.itNom>> <<buildSynthParam('subj', actor)>>
            <<actor.posture.msgVerbT>> {hier|dort}{*}. ";
    }

    /*
     *   mention that the given actor is visible, at a distance or
     *   remotely, in the given location; this is used in room
     *   descriptions when an NPC is visible in a remote or distant
     *   location 
     */
    actorInRemoteRoom(actor, room, pov)
    {
        /* say that the actor is in the room, using its remote in-name */
        "\^<<actor.derName>> <<buildSynthParam('subj', actor)>>
        <<actor.posture.msgVerbT>> <<room.inRoomName(pov)>>{*}. ";
    }

    /*
     *   mention that the given actor is visible, at a distance or
     *   remotely, in the given nested room within the given outer
     *   location; this is used in room descriptions 
     */
    actorInRemoteNestedRoom(actor, inner, outer, pov)
    {
        /*
         *   say that the actor is in the nested room, in the current
         *   posture, and add then add that we're in the outer room as
         *   well 
         */
        "\^<<actor.derName>> <<outer.inRoomName(pov)>>,
        <<buildSynthParam('subj', actor)>><<actor.posture.msgVerbT>> 
        <<inner.actorInName>>{*}. ";
    }

    /*
     *   Prefix/suffix messages for listing actors in a room description,
     *   for cases when the actors are in the local room in a nominal
     *   container that we want to mention: "Bob and Bill are sitting on
     *   the couch."  
     */
    
    // -- German: provide modified actor descriptions with the new 
    // -- msgVerbTPastPlural etc ...
    
    actorInGroupPrefix(posture, cont, lst) { "\^<<withListCaseNominative>><<withListArtIndefinite>>"; }
    actorInGroupSuffix(posture, cont, lst)
    {
        " <<lst.length() == 1 ? posture.msgVerbT 
          : posture.msgVerbTPlural>> 
        <<cont.actorInName>>{*}. ";
    }

    /*
     *   Prefix/suffix messages for listing actors in a room description,
     *   for cases when the actors are inside a nested room that's inside
     *   a remote location: "Bob and Bill are in the courtyard, sitting on
     *   the bench." 
     */
    
    // -- German: provide modified actor descriptions with the new 
    // -- msgVerbTPastPlural etc ...
    
    actorInRemoteGroupPrefix(pov, posture, cont, remote, lst) { "\^<<withListCaseNominative>><<withListArtIndefinite>>"; }
    actorInRemoteGroupSuffix(pov, posture, cont, remote, lst)
    {
        " <<lst.length() == 1 ? '{ist singular}' : '{ist plural}'>>
        <<remote.inRoomName(pov)>> und <<lst.length() == 1 ? posture.msgVerbT 
          : posture.msgVerbTPlural>> <<cont.actorInName>>{*}. ";
    }

    /*
     *   Prefix/suffix messages for listing actors in a room description,
     *   for cases when the actors' nominal container cannot be seen or is
     *   not to be stated: "Bob and Bill are standing here."
     *   
     *   Note that we don't always want to state the nominal container,
     *   even when it's visible.  For example, when actors are standing on
     *   the floor, we don't bother saying that they're on the floor, as
     *   that's stating the obvious.  The container will decide whether or
     *   not it wants to be included in the message; containers that don't
     *   want to be mentioned will use this form of the message.  
     */
    
    // -- German: provide modified actor descriptions with the new 
    // -- msgVerbTPastPlural etc ...
    
    actorHereGroupPrefix(posture, lst) { "\^<<withListCaseNominative>><<withListArtIndefinite>>"; }
    actorHereGroupSuffix(posture, lst)
    {
        " <<lst.length() == 1 ? posture.msgVerbT : posture.msgVerbTPlural>> {hier|dort}{*}. ";
    }

    /*
     *   Prefix/suffix messages for listing actors in a room description,
     *   for cases when the actors' immediate container cannot be seen or
     *   is not to be stated, and the actors are in a remote location:
     *   "Bob and Bill are in the courtyard."  
     */
    actorThereGroupPrefix(pov, posture, remote, lst) { "\^<<withListCaseNominative>><<withListArtIndefinite>>"; }
    actorThereGroupSuffix(pov, posture, remote, lst)
    {
        " <<lst.length() == 1 ? posture.msgVerbT: posture.msgVerbTPlural>> 
        <<remote.inRoomName(pov)>>{*}. ";
    }

    /* a traveler is arriving, but not from a compass direction */
    sayArriving(traveler)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuBetreten>>
        <<traveler.denTravelerLocName>>{*}. ";
    }

    /* a traveler is departing, but not in a compass direction */
    sayDeparting(traveler)
    {
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuVerlassen>>
        <<traveler.denTravelerLocName>>{*}. ";
    }

    /*
     *   a traveler is arriving locally (staying within view throughout the
     *   travel, and coming closer to the PC) 
     */
    sayArrivingLocally(traveler, dest)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuBetreten>>
        <<traveler.denTravelerLocName>>{*}. ";
    }

    /*
     *   a traveler is departing locally (staying within view throughout
     *   the travel, and moving further away from the PC) 
     */
    sayDepartingLocally(traveler, dest)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuVerlassen>>
        <<traveler.denTravelerLocName>>{*}. ";
    }

    /*
     *   a traveler is traveling remotely (staying within view through the
     *   travel, and moving from one remote top-level location to another) 
     */
    sayTravelingRemotely(traveler, dest)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuGehen>> zu
        <<traveler.demTravelerLocName>>{*}. ";
    }

    /* a traveler is arriving from a compass direction */
    sayArrivingDir(traveler, dirName)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuBetreten>>
        <<traveler.denTravelerRemoteLocName>> von \^<<dirName>>{*}. ";
    }

    /* a traveler is leaving in a given compass direction */
    sayDepartingDir(traveler, dirName)
    {
        local nm = traveler.denTravelerRemoteLocName;
        
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuVerlassen>>
        <<nm != '' ? ' ' + nm : ''>> nach \^<<dirName>>{*}. ";
    }
    
    /* a traveler is arriving from a shipboard direction */
    sayArrivingShipDir(traveler, dirName)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuBetreten>>
        <<traveler.denTravelerRemoteLocName>> von \^<<dirName>>{*}. ";
    }

    /* a traveler is leaving in a given shipboard direction */
    sayDepartingShipDir(traveler, dirName)
    {
        local nm = traveler.demTravelerRemoteLocName;
        
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuGehen>>
        <<nm != '' ? ' von ' + nm : ''>> nach <<dirName>>{*}. ";
    }

    /* a traveler is going aft */
    sayDepartingAft(traveler)
    {
        local nm = traveler.demTravelerRemoteLocName;
        
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuGehen>>
        <<nm != '' ? ' von ' + nm : ''>> nach hinten{*}. ";
    }

    /* a traveler is going fore */
    sayDepartingFore(traveler)
    {
        local nm = traveler.demTravelerRemoteLocName;

        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuGehen>>
        <<nm != '' ? ' von ' + nm : ''>> nach vorne{*}. ";
    }

    /* a shipboard direction was attempted while not onboard a ship */
    notOnboardShip = "Diese Richtung {hat singular} {hier|dort} keine Bedeutung{*}. "

    /* a traveler is leaving via a passage */
    sayDepartingThroughPassage(traveler, passage)
    {
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuVerlassen>>
        <<traveler.denTravelerRemoteLocName>> durch <<passage.denNameObj>>{*}. ";
    }

    /* a traveler is arriving via a passage */
    sayArrivingThroughPassage(traveler, passage)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuBetreten>>
        <<traveler.denTravelerRemoteLocName>> durch <<passage.denNameObj>>{*}. ";
    }

    /* a traveler is leaving via a path */
    sayDepartingViaPath(traveler, passage)
    {
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuVerlassen>>
        <<traveler.denTravelerRemoteLocName>>{*} und <<traveler.verbZuBetreten>> 
        <<passage.denNameObj>>{*}. ";
    }

    /* a traveler is arriving via a path */
    sayArrivingViaPath(traveler, passage)
    {
        "\^<<traveler.travelerName(true)>> <<traveler.verbZuBetreten>>
        <<traveler.denTravelerRemoteLocName>> von <<passage.demNameObj>>{*}. ";
    }

    /* a traveler is leaving up a stairway */
    sayDepartingUpStairs(traveler, stairs)
    {
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuGehen>>
        <<stairs.denNameObj>> hinauf{*}. ";
    }

    /* a traveler is leaving down a stairway */
    sayDepartingDownStairs(traveler, stairs)
    {
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuGehen>>
        <<stairs.denNameObj>> hinunter{*}. ";
    }

    /* a traveler is arriving by coming up a stairway */
    sayArrivingUpStairs(traveler, stairs)
    {
        local nm = traveler.denTravelerRemoteLocName;

        "\^<<traveler.travelerName(true)>> <<traveler.verbZuKommen>>
        <<stairs.denNameObj>> hoch<<nm != '' ? ' in ' + nm : ''>>{*}. ";
    }

    /* a traveler is arriving by coming down a stairway */
    sayArrivingDownStairs(traveler, stairs)
    {
        local nm = traveler.denTravelerRemoteLocName;

        "\^<<traveler.travelerName(true)>> <<traveler.verbZuKommen>>
        <<stairs.denNameObj>> hinunter<<nm != '' ? ' in ' + nm : ''>>{*}. ";
    }

    /* acompanying another actor on travel */
    sayDepartingWith(traveler, lead)
    {
        "\^<<traveler.travelerName(nil)>> <<traveler.verbZuKommen>>
        mit <<lead.demNameObj>>{*}. ";
    }

    /*
     *   Accompanying a tour guide.  Note the seemingly reversed roles:
     *   the lead actor is the one initiating the travel, and the tour
     *   guide is the accompanying actor.  So, the lead actor is
     *   effectively following the accompanying actor.  It seems
     *   backwards, but really it's not: the tour guide merely shows the
     *   lead actor where to go, but it's up to the lead actor to actually
     *   initiate the travel.  
     */
    sayDepartingWithGuide(guide, lead)
    {
        "\^<<lead.derName>> <<lead.verbZuGehen>>
        <<guide.demNameObj>> voraus{*}. ";
    }

    /* note that a door is being opened/closed remotely */
    sayOpenDoorRemotely(door, stat)
    {
        "Jemand <<stat ? '{oeffnet}' : '{schliesst}'>>
        <<door.denNameObj>> von der anderen Seite{*}. ";
    }

    /*
     *   open/closed status - these are simply adjectives that can be used
     *   to describe the status of an openable object 
     */
    openMsg(obj) { return 'offen'; }
    closedMsg(obj) { return 'geschlossen'; }

    /* object is currently open/closed */
    currentlyOpen = '{Es dobj/er} {ist} momentan offen{*}. '
    currentlyClosed = '{Es dobj/er} {ist} momentan geschlossen{*}. '

    /* stand-alone independent clause describing current open status */
    openStatusMsg(obj) { return obj.derNameIs + ' ' + obj.openDesc; } //BEDARF

    /* locked/unlocked status - adjectives describing lock states */
    lockedMsg(obj) { return 'abgesperrt'; }
    unlockedMsg(obj) { return 'aufgesperrt'; }

    /* object is currently locked/unlocked */
    currentlyLocked = '{Es dobj/er} {ist} momentan abgesperrt{*}. '
    currentlyUnlocked = '{Es dobj/er} {ist} momentan aufgesperrt{*}. '

    /*
     *   on/off status - these are simply adjectives that can be used to
     *   describe the status of a switchable object 
     */
    onMsg(obj) { return 'an'; }
    offMsg(obj) { return 'aus'; }

    /* daemon report for burning out a match */
    matchBurnedOut(obj)
    {
        gMessageParams(obj);
        "{Der obj/er} {ist} zu einem Aschehäufchen abgebrannt{*}. ";
    }

    /* daemon report for burning out a candle */
    candleBurnedOut(obj)
    {
        gMessageParams(obj);
        "{Der obj/er} {ist} abgebrannt und ausgegangen{*}. ";
    }

    /* daemon report for burning out a generic fueled light source */
    objBurnedOut(obj)
    {
        gMessageParams(obj);
        "{Der obj/er} {ist} ausgegangen{*}. ";
    }

    /* 
     *   Standard dialog titles, for the Web UI.  These are shown in the
     *   title bar area of the Web UI dialog used for inputDialog() calls.
     *   These correspond to the InDlgIconXxx icons.  The conventional
     *   interpreters use built-in titles when titles are needed at all,
     *   but in the Web UI we have to generate these ourselves. 
     */
    dlgTitleNone = 'Note'
    dlgTitleWarning = 'Warning'
    dlgTitleInfo = 'Note'
    dlgTitleQuestion = 'Question'
    dlgTitleError = 'Error'

    /*
     *   Standard dialog button labels, for the Web UI.  These are built in
     *   to the conventional interpreters, but in the Web UI we have to
     *   generate these ourselves.  
     */
    dlgButtonOk = 'OK'
    dlgButtonCancel = 'Cancel'
    dlgButtonYes = 'Yes'
    dlgButtonNo = 'No'

    /* web UI alert when a new user has joined a multi-user session */
    webNewUser(name) { "\b[<<name>> ist der Runde beigetreten.]\n"; }

    /*
     *   Warning prompt for inputFile() warnings generated when reading a
     *   script file, for the Web UI.  The interpreter normally displays
     *   these warnings directly, but in Web UI mode, the program is
     *   responsible, so we need localized messages.  
     */
    inputFileScriptWarning(warning, filename)
    {
        /* remove the two-letter error code at the start of the string */
        warning = warning.substr(3);

        /* build the message */
        return warning + ' Willst du fortfahren?';
    }
    inputFileScriptWarningButtons = [
        '&Ja, verwende diese Datei', '&Wähle eine andere Datei', '&Halte das Skript an']
;

/* ------------------------------------------------------------------------ */
/*
 *   Player Character messages.  These messages are generated when the
 *   player issues a regular command to the player character (i.e.,
 *   without specifying a target actor).  
 */
playerMessages: libMessages
    /* invalid command syntax */
    commandNotUnderstood(actor)
    {
        "<.parser>Die Geschichte versteht diesen Befehl nicht.<./parser> ";
    }

    /* a special topic can't be used right now, because it's inactive */
    specialTopicInactive(actor)
    {
        "<.parser>Dieser Befehl kann jetzt nicht verwendet werden.<./parser> ";
    }

    /* no match for a noun phrase */
    noMatch(actor, action, txt) { action.noMatch(self, actor, txt); }

    /*
     *   No match message - we can't see a match for the noun phrase.  This
     *   is the default for most verbs. 
     */
    noMatchCannotSee(actor, txt) { 
        "\^<<actor.derName>> <<actor.verbZuSehen>> {hier|dort} <<actor.keinen(txt)>>{* actor}. "; 
    }

    /*
     *   No match message - we're not aware of a match for the noun phrase.
     *   Some sensory actions, such as LISTEN TO and SMELL, use this
     *   variation instead of the normal version; the things these commands
     *   refer to tend to be intangible, so "you can't see that" tends to
     *   be nonsensical. 
     */
    noMatchNotAware(actor, txt) {
        "{Du/er} {bemerkt} {hier|dort} <<actor.keinen(txt)>>{*}. "; 
    }

    /* 'all' is not allowed with the attempted action */
    allNotAllowed(actor)
    {
        "<.parser>Das Wort <q>alles</q> kann mit diesem Verb nicht verwendet werden.<./parser> ";
    }

    /* no match for 'all' */
    noMatchForAll(actor)
    {
        "<.parser>{Du/er} {sieht} {hier|dort} nichts Passendes.<./parser> ";
    }

    /* nothing left for 'all' after removing 'except' items */
    noMatchForAllBut(actor)
    {
        "<.parser>{Du/er} {sieht} {hier|dort} sonst nichts.<./parser> ";
    }

    /* nothing left in a plural phrase after removing 'except' items */
    noMatchForListBut(actor) { noMatchForAllBut(actor); }

    /* no match for a pronoun */
    noMatchForPronoun(actor, typ, pronounWord)
    {
        /* show the message */
        "<.parser>Das Wort <q><<pronounWord>></q> bezieht sich momentan
        auf nichts.<./parser> ";
    }

    /*
     *   Ask for a missing object - this is called when a command is
     *   completely missing a noun phrase for one of its objects.  
     */
    askMissingObject(actor, action, which)
    {
        reportQuestion('<.parser>\^' + action.getQuestionWord(which)
                       + (actor.referralPerson == ThirdPerson
                          ? ' soll ' : 
                          actor.referralPerson == FourthPerson
                          ? ' sollen ' + (gameMain.useCapitalizedAdress ? '\^' : '') + 'wir ' :
                          actor.referralPerson == FifthPerson
                          ? ' wollt ' + (gameMain.useCapitalizedAdress ? '\^' : '') + 'ihr ' :
                          actor.referralPerson == SixthPerson
                          ? ' sollen ' + (gameMain.useCapitalizedAdress ? '\^' : '') + 'sie ' 
                          : ' willst ' + (gameMain.useCapitalizedAdress ? '\^' : '') + 'du ')
                       + (actor.referralPerson == ThirdPerson
                          ? actor.derName + ' ' : '')
                       + action.getQuestionObject(which) + ' ' 
                       + action.getQuestionVerb(which) + '?<./parser> ');
    }

    /*
     *   An object was missing - this is called under essentially the same
     *   circumstances as askMissingObject, but in cases where interactive
     *   resolution is impossible and we simply wish to report the problem
     *   and do not wish to ask for help.
     */
    missingObject(actor, action, which)
    {
        "<.parser>Sag bitte genauer,
        <<action.whatObj(which)>> <<actor.derName>>
        <<action.getQuestionInf(which)>> <<actor.referralPerson == SecondPerson
          ? 'willst' : actor.referralPerson == FourthPerson ? 'sollen' : 
          actor.referralPerson == FifthPerson ? 'wollt' : 
          actor.referralPerson == SixthPerson ? 'sollen' : 'soll'>>.<./parser> ";
    }

    /*
     *   Ask for a missing literal phrase. 
     */
    askMissingLiteral(actor, action, which)
    {
        /* use the standard missing-object message */
        askMissingObject(actor, action, which);
    }

    /*
     *   Show the message for a missing literal phrase.
     */
    missingLiteral(actor, action, which)
    {
        "<.parser>Sag bitte genauer
        <<action.whatObj(which)>> du
        <<action.getQuestionVerb(which)>> willst.  Versuch, zum Beispiel,
        <q>etwas</q> zu <<action.getQuestionVerb(which)>>.<./parser> ";
    }

    /* reflexive pronoun not allowed */
    reflexiveNotAllowed(actor, typ, pronounWord)
    {
        "<.parser>Diese Geschichte versteht das Wort 
        <q><<pronounWord>></q> in diesem Zusammenhang nicht.<./parser> ";
    }

    /*
     *   a reflexive pronoun disagrees in gender, number, or something
     *   else with its referent 
     */
    wrongReflexive(actor, typ, pronounWord)
    {
        "<.parser>Diese Geschichte versteht nicht, worauf sich das
        Wort <q><<pronounWord>></q> bezieht.<./parser> ";
    }

    /* no match for a possessive phrase */
    noMatchForPossessive(actor, owner, txt)
    {
        "<.parser>\^<<owner.derName>> <<owner.verbZuScheinen>>
        so etwas nicht zu besitzen.<./parser> ";
    }

    /* no match for a plural possessive phrase */
    noMatchForPluralPossessive(actor, txt)
    {
        "<.parser>\^Sie <<tSel('scheinen', 'schienen')>> so etwas nicht zu besitzen.<./parser> ";
    }

    /* no match for a containment phrase */
    noMatchForLocation(actor, loc, txt)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuSehen>>
        <<loc.childInName(txt)>>.<./parser> ";
    }

    /* nothing in a container whose contents are specifically requested */
    nothingInLocation(actor, loc)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuSehen>>
        nichts Ungewöhnliches <<loc.objInPrep>> <<loc.demName>>.<./parser> ";
    }

    /* no match for the response to a disambiguation question */
    noMatchDisambig(actor, origPhrase, disambigResponse)
    {
        /*
         *   show the message, leaving the <.parser> tag mode open - we
         *   always show another disambiguation prompt after this message,
         *   so we'll let the prompt close the <.parser> mode 
         */
        "<.parser>Das war keine der Wahlmöglichkeiten. ";
    }

    /* empty noun phrase ('take the') */
    emptyNounPhrase(actor)
    {
        "<.parser>Du scheinst Wörter ausgelassen zu haben.<./parser> ";
    }

    /* 'take zero books' */
    zeroQuantity(actor, txt)
    {
        "<.parser>\^Das macht doch keinen Sinn.<./parser> ";
    }

    /* insufficient quantity to meet a command request ('take five books') */
    insufficientQuantity(actor, txt, matchList, requiredNum)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuSehen>> {hier|dort}
        nicht so <<actor.viele(txt)>>.<./parser> ";
    }

    /* a unique object is required, but multiple objects were specified */
    uniqueObjectRequired(actor, txt, matchList)
    {
        "<.parser>Du kannst da nicht mehrere Objekte angeben.<./parser> ";
    }

    /* a single noun phrase is required, but a noun list was used */
    singleObjectRequired(actor, txt)
    {
        "<.parser>Mehrere Objekte sind in diesem Befehl nicht zugelassen.<./parser> ";
    }

    /*
     *   The answer to a disambiguation question specifies an invalid
     *   ordinal ("the fourth one" when only three choices were offered).
     *   
     *   'ordinalWord' is the ordinal word entered ('fourth' or the like).
     *   'originalText' is the text of the noun phrase that caused the
     *   disambiguation question to be asked in the first place.  
     */
    disambigOrdinalOutOfRange(actor, ordinalWord, originalText)
    {
        /* leave the <.parser> tag open, for the re-prompt that will follow */
        "<.parser>Da gab es nicht so viele Wahlmöglichkeiten. ";
    }

    /*
     *   Ask the canonical disambiguation question: "Which x do you
     *   mean...?".  'matchList' is the list of ambiguous objects with any
     *   redundant equivalents removed; and 'fullMatchList' is the full
     *   list, including redundant equivalents that were removed from
     *   'matchList'.
     *   
     *   If askingAgain is true, it means that we're asking the question
     *   again because we got an invalid response to the previous attempt
     *   at the same prompt.  We will have explained the problem, and now
     *   we're going to give the user another crack at the same response.
     *   
     *   To prevent interactive disambiguation, do this:
     *   
     *   throw new ParseFailureException(&ambiguousNounPhrase,
     *.  originalText, matchList, fullMatchList); 
     */
    askDisambig(actor, originalText, matchList, fullMatchList,
                requiredNum, askingAgain, dist)
    {
        /* mark this as a question report with a dummy report */
        reportQuestion('');
        
        /*
         *   Open the "<.parser>" tag, if we're not "asking again."  If we
         *   are asking again, we will already have shown a message
         *   explaining why we're asking again, and that message will have
         *   left us in <.parser> tag mode, so we don't need to open the
         *   tag again. 
         */
        if (!askingAgain)
            "<.parser>";
        
        /*
         *   the question varies depending on whether we want just one
         *   object or several objects in the final result 
         */
        if (requiredNum == 1)
        {
            /*
             *   One object needed - use the original text in the query.
             *   
             *   Note that if we're "asking again," we will have shown an
             *   additional message first explaining *why* we're asking
             *   again, and that message will have left us in <.parser>
             *   tag mode; so we need to close the <.parser> tag in this
             *   case, but we don't need to show a new one. 
             */
            if (askingAgain)
                "Was meinst du,
                <<askDisambigList(matchList, fullMatchList, nil, dist)>>?";
            else
                //"Was meinst du mit <q><<originalText>></q>,
                "Meinst du
                <<askDisambigList(matchList, fullMatchList, nil, dist)>>?";
        }
        else
        {
            /*
             *   Multiple objects required - ask by number, since we can't
             *   easily guess what the plural might be given the original
             *   text.
             *   
             *   As above, we only need to *close* the <.parser> tag if
             *   we're asking again, because we will already have shown a
             *   prompt that opened the tag in this case.  
             */
            if (askingAgain)
                "Welche <<spellInt(requiredNum)>> (von
                <<askDisambigList(matchList, fullMatchList, true, dist)>>)
                meinst du?";
            else
                "Welche <<spellInt(requiredNum)>>
                (von <<askDisambigList(matchList, fullMatchList,
                                      true, dist)>>) meinst du?";
        }

        /* close the <.parser> tag */
        "<./parser> ";
    }

    /*
     *   we found an ambiguous noun phrase, but we were unable to perform
     *   interactive disambiguation 
     */
    ambiguousNounPhrase(actor, originalText, matchList, fullMatchList)
    {
        "<.parser>Diese Geschichte versteht nicht, was du mit
        <q><<originalText>></q> meinst.<./parser> ";
    }

    /* the actor is missing in a command */
    missingActor(actor)
    {
        "<.parser>Sag bitte genauer, <<whomPronoun>> 
        du ansprechen willst.<./parser> ";
    }

    /* only a single actor kann be addressed at a time */
    singleActorRequired(actor)
    {
        "<.parser>Du kannst nur mit einer Person gleichzeitig reden.<./parser> ";
    }

    /* cannot change actor mid-command */
    cannotChangeActor()
    {
        "<.parser>In einem Befehl kannst du nur eine Person ansprechen.<./parser> ";
    }

    /*
     *   tell the user they entered a word we don't know, offering the
     *   chance to correct it with "oops" 
     */
    askUnknownWord(actor, txt)
    {
        /* start the message */
        "<.parser>Das Wort <q><<txt>></q> ist in dieser Geschichte nicht notwendig.<./parser> ";

        /* mention the OOPS command, if appropriate */
        oopsNote();
    }

    /*
     *   tell the user they entered a word we don't know, but don't offer
     *   an interactive way to fix it (i.e., we can't use OOPS at this
     *   point) 
     */
    wordIsUnknown(actor, txt)
    {
        "<.parser>Die Geschichte versteht diesen Befehl nicht.<./parser> ";
    }

    /* the actor refuses the command because it's busy with something else */
    refuseCommandBusy(targetActor, issuingActor)
    {
        "\^<<targetActor.derNameIs>> beschäftigt. ";
    }

    /* cannot speak to multiple actors */
    cannotAddressMultiple(actor)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuKann>> sich nicht an mehrere 
        Personen gleichzeitig wenden.<./parser> ";
    }

    /* 
     *   Remaining actions on the command line were aborted due to the
     *   failure of the current action.  This is just a hook for the game's
     *   use, if it wants to provide an explanation; by default, we do
     *   nothing.  Note that games that override this will probably want to
     *   use a flag property so that they only show this message once -
     *   it's really only desirable to explain the the mechanism, not to
     *   flag it every time it's used.  
     */
    explainCancelCommandLine()
    {
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Non-Player Character (NPC) messages - parser-mediated format.  These
 *   versions of the NPC messages report errors through the
 *   parser/narrator.
 *   
 *   Note that a separate set of messages can be selected to report
 *   messages in the voice of the NPC - see npcMessagesDirect below.  
 */

/*
 *   Standard Non-Player Character (NPC) messages.  These messages are
 *   generated when the player issues a command to a specific non-player
 *   character. 
 */
npcMessages: playerMessages
    /* the target cannot hear a command we gave */
    commandNotHeard(actor)
    {
        "\^<<actor.derName>> <<actor.verbZuAntworten>> nicht. ";
    }

    /* no match for a noun phrase */
    noMatchCannotSee(actor, txt) {
        "\^<<actor.derName>> <<actor.verbZuSehen>> {hier|dort} <<actor.keinen(txt)>>. "; 
    }
    noMatchNotAware(actor, txt) {
        "\^<<actor.derName>> <<actor.verbZuKennen>> {hier|dort} <<actor.keinen(txt)>>. ";  
    }

    /* no match for 'all' */
    noMatchForAll(actor)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuSehen>> nichts
        Passendes.<./parser> ";
    }

    /* nothing left for 'all' after removing 'except' items */
    noMatchForAllBut(actor)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuSehen>> sonst
        nichts.<./parser> ";
    }

    /* insufficient quantity to meet a command request ('take five books') */
    insufficientQuantity(actor, txt, matchList, requiredNum)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuSehen>> nicht so 
        <<actor.viele(txt)>>.<./parser> ";
    }

    /*
     *   we found an ambiguous noun phrase, but we were unable to perform
     *   interactive disambiguation 
     */
    ambiguousNounPhrase(actor, originalText, matchList, fullMatchList)
    {
        "<.parser>\^<<actor.derName>> <<actor.verbZuWissen>> nicht, 
        <<actor.welchen(originalText)>> du <<tSel('meinst', 'meintest')>>.<./parser> ";
    }

    /*
     *   Missing object query and error message templates 
     */
    askMissingObject(actor, action, which)
    {
        reportQuestion('<.parser>\^' + action.getQuestionWord(which)
                       + ' soll ' + actor.derNameObj + ' ' 
                       + action.getQuestionVerb(which) + '?<./parser> '); // -- now getQuestionVerb
    }
    missingObject(actor, action, which)
    {
        "<.parser>Sag bitte genauer, <<action.getQuestionWord(which)>> 
        <<actor.derNameObj>> <<action.getQuestionVerb(which)>> soll.<./parser> ";
    }

    /* missing literal phrase query and error message templates */
    
    missingLiteral(actor, action, which)
    {
        "<.parser>Sag bitte genauer, <<action.whatObj(which)>>
        <<actor.derNameObj>> <<action.getQuestionVerb(which)>> soll.
        Zum Beispiel: <<actor.derName>>, <<action.getQuestionVerb(which)>>
        <q>etwas</q>.<./parser> ";
    }
;

/*
 *   Deferred NPC messages.  We use this to report deferred messages from
 *   an NPC to the player.  A message is deferred when a parsing error
 *   occurs, but the NPC can't talk to the player because there's no sense
 *   path to the player.  When this happens, the NPC queues the message
 *   for eventual delivery; when a sense path appears later that lets the
 *   NPC talk to the player, we deliver the message through this object.
 *   Since these messages describe conditions that occurred in the past,
 *   we use the past tense to phrase the messages.
 *   
 *   This default implementation simply doesn't report deferred errors at
 *   all.  The default message voice is the parser/narrator character, and
 *   there is simply no good way for the parser/narrator to say that a
 *   command failed in the past for a given character: "Bob looks like he
 *   didn't know which box you meant" just doesn't work.  So, we'll simply
 *   not report these errors at all.
 *   
 *   To report messages in the NPC's voice directly, modify the NPC's
 *   Actor object, or the Actor base class, to return
 *   npcDeferredMessagesDirect rather than this object from
 *   getParserMessageObj().  
 */
npcDeferredMessages: object
;

/* ------------------------------------------------------------------------ */
/*
 *   NPC messages, reported directly in the voice of the NPC.  These
 *   messages are not selected by default, but a game can use them instead
 *   of the parser-mediated versions by modifying the actor object's
 *   getParserMessageObj() to return these objects.  
 */

/*
 *   Standard Non-Player Character (NPC) messages.  These messages are
 *   generated when the player issues a command to a specific non-player
 *   character. 
 */
npcMessagesDirect: npcMessages
    /* no match for a noun phrase */
    noMatchCannotSee(actor, txt) {
        "\^<<actor.derName>> <<actor.verbZuSehen>> <<actor.itReflexive>> um{-*}. <q>Ich sehe hier
            <<actor.keinen(txt)>>.</q> ";
    }
    noMatchNotAware(actor, txt) {
        "<q>Ich kenne <<actor.keinen(txt)>></q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* no match for 'all' */
    noMatchForAll(actor)
    {
        "<q>Ich sehe nichts Passendes</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* nothing left for 'all' after removing 'except' items */
    noMatchForAllBut(actor)
    {
        "<q>Ich sehe sonst nichts hier</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* 'take zero books' */
    zeroQuantity(actor, txt)
    {
        "<q>Das macht doch keinen Sinn</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* insufficient quantity to meet a command request ('take five books') */
    insufficientQuantity(actor, txt, matchList, requiredNum)
    {
        "<q>Ich sehe hier nicht so <<actor.viele(txt)>></q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* a unique object is required, but multiple objects were specified */
    uniqueObjectRequired(actor, txt, matchList)
    {
        "<q>Ich kann hier nur mehrere Objekte verwenden</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* a single noun phrase is required, but a noun list was used */
    singleObjectRequired(actor, txt)
    {
        "<q>Ich kann hier nur ein Objekt verwenden</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* no match for the response to a disambiguation question */
    noMatchDisambig(actor, origPhrase, disambigResponse)
    {
        /* leave the quote open for the re-prompt */
        "<q>Das war keine der Wahlmöglichkeiten</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /*
     *   The answer to a disambiguation question specifies an invalid
     *   ordinal ("the fourth one" when only three choices were offered).
     *   
     *   'ordinalWord' is the ordinal word entered ('fourth' or the like).
     *   'originalText' is the text of the noun phrase that caused the
     *   disambiguation question to be asked in the first place.  
     */
    disambigOrdinalOutOfRange(actor, ordinalWord, originalText)
    {
        /* leave the quote open for the re-prompt */
        "<q>Da waren nicht so viele Wahlmöglichkeiten</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /*
     *   Ask the canonical disambiguation question: "Which x do you
     *   mean...?".  'matchList' is the list of ambiguous objects with any
     *   redundant equivalents removed, and 'fullMatchList' is the full
     *   list, including redundant equivalents that were removed from
     *   'matchList'.  
     *   
     *   To prevent interactive disambiguation, do this:
     *   
     *   throw new ParseFailureException(&ambiguousNounPhrase,
     *.  originalText, matchList, fullMatchList); 
     */
    askDisambig(actor, originalText, matchList, fullMatchList,
                requiredNum, askingAgain, dist)
    {
        /* mark this as a question report */
        reportQuestion('');

        /* the question depends on the number needed */
        if (requiredNum == 1)
        {
            /* one required - ask with the original text */
            if (!askingAgain)
                "\^<<actor.derName>> <<actor.verbZuFragen>>{*}, <q>";
            
            "Meinst du <<
            askDisambigList(matchList, fullMatchList, nil, dist)>>?</q> ";
        }
        else
        {
            /*
             *   more than one required - we can't guess at the plural
             *   given the original text, so just use the number 
             */
            if (!askingAgain)
                "\^<<actor.derName>> <<actor.verbZuFragen>>{*}, <q>";
            
            "Welche <<spellInt(requiredNum)>> (von <<
            askDisambigList(matchList, fullMatchList, true, dist)>>)
            meinst du?</q> ";
        }
    }

    /*
     *   we found an ambiguous noun phrase, but we were unable to perform
     *   interactive disambiguation 
     */
    ambiguousNounPhrase(actor, originalText, matchList, fullMatchList)
    {
        "\^<<actor.derName>> <<actor.verbZuSagen>>{*},
        <q>Ich weiß nicht, was du mit <<originalText>> genau meinst.</q> ";
    }

    /*
     *   Missing object query and error message templates 
     */
    askMissingObject(actor, action, which)
    {
        reportQuestion('\^' + actor.derName + ' ' + actor.verbZuSagen
                       + ', <q>\^' + action.getQuestionWord(which)
                       + ' soll ich '
                       + action.getQuestionVerb(which) + '?</q> ');
    }
    missingObject(actor, action, which)
    {
        "\^<<actor.derName>> <<actor.verbZuSagen>>{*},
        <q>Ich weiß nicht <<action.whatObj(which)>>
        ich <<action.getQuestionVerb(which)>> soll.</q> ";
    }
    missingLiteral(actor, action, which)
    {
        /* use the same message we use for a missing ordinary object */
        missingObject(actor, action, which);
    }

    /* tell the user they entered a word we don't know */
    askUnknownWord(actor, txt)
    {
        "\^<<actor.derName>> <<actor.verbZuSagen>>{*},
        <q>Ich kenne das Wort <q><<txt>></q> nicht.</q> ";
    }

    /* tell the user they entered a word we don't know */
    wordIsUnknown(actor, txt)
    {
        "\^<<actor.derName>> <<actor.verbZuSagen>>{*},
        <q>Du hast ein Wort verwendet, das ich nicht kenne.</q> ";
    }
;

/*
 *   Deferred NPC messages.  We use this to report deferred messages from
 *   an NPC to the player.  A message is deferred when a parsing error
 *   occurs, but the NPC can't talk to the player because there's no sense
 *   path to the player.  When this happens, the NPC queues the message
 *   for eventual delivery; when a sense path appears later that lets the
 *   NPC talk to the player, we deliver the message through this object.
 *   Since these messages describe conditions that occurred in the past,
 *   we use the past tense to phrase the messages.
 *   
 *   Some messages will never be deferred:
 *   
 *   commandNotHeard - if a command is not heard, it will never enter an
 *   actor's command queue; the error is given immediately in response to
 *   the command entry.
 *   
 *   refuseCommandBusy - same as commandNotHeard
 *   
 *   noMatchDisambig - interactive disambiguation will not happen in a
 *   deferred response situation, so it is impossible to have an
 *   interactive disambiguation failure.  
 *   
 *   disambigOrdinalOutOfRange - for the same reason noMatchDisambig kann't
 *   be deferred.
 *   
 *   askDisambig - if we couldn't display a message, we definitely
 *   couldn't perform interactive disambiguation.
 *   
 *   askMissingObject - for the same reason that askDisambig kann't be
 *   deferred
 *   
 *   askUnknownWord - for the same reason that askDisambig kann't be
 *   deferred.  
 */
npcDeferredMessagesDirect: npcDeferredMessages
    commandNotUnderstood(actor)
    {
        "<q>Ich habe nicht verstanden, was du meinst</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* no match for a noun phrase */
    noMatchCannotSee(actor, txt) {
        "<q>Ich habe hier <<actor.keinen(txt)>> gesehen</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. "; 
    }
    noMatchNotAware(actor, txt) {
        "<q>Ich habe hier <<actor.keinen(txt)>> bemerkt</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* no match for 'all' */
    noMatchForAll(actor)
    {
        "<q>Ich habe hier nichts Passendes gesehen</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* nothing left for 'all' after removing 'except' items */
    noMatchForAllBut(actor)
    {
        "<q>Ich weiß nicht, was du meinst</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* empty noun phrase ('take the') */
    emptyNounPhrase(actor)
    {
        "<q>Du hast Wörter ausgelassen</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* 'take zero books' */
    zeroQuantity(actor, txt)
    {
        "<q>Ich habe nicht verstanden, was du meinst</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* insufficient quantity to meet a command request ('take five books') */
    insufficientQuantity(actor, txt, matchList, requiredNum)
    {
        "<q>Ich habe hier nicht so <<actor.viele(txt)>> gesehen</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* a unique object is required, but multiple objects were specified */
    uniqueObjectRequired(actor, txt, matchList)
    {
        "<q>Ich habe nicht verstanden, was du meinst</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* a unique object is required, but multiple objects were specified */
    singleObjectRequired(actor, txt)
    {
        "<q>Ich habe nicht verstanden, was du meinst</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /*
     *   we found an ambiguous noun phrase, but we were unable to perform
     *   interactive disambiguation 
     */
    ambiguousNounPhrase(actor, originalText, matchList, fullMatchList)
    {
        "<q>Ich kann nicht sagen, <<actor.welchen(originalText)>> du meinst</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }

    /* an object phrase was missing */
    askMissingObject(actor, action, which)
    {
        reportQuestion('<q>Ich weiß nicht, ' + action.getQuestionWord(which) + ' ich '
                       + action.getQuestionVerb(which) + ' soll</q>, ' + actor.verbZuSagen + ' ' + actor.derName + ' ' 
                       + '{*}. ');
    }

    /* tell the user they entered a word we don't know */
    wordIsUnknown(actor, txt)
    {
        "<q>Du hast ein Wort verwendet, das ich nicht kenne</q>, <<actor.verbZuSagen>> <<actor.derName>>{*}. ";
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Verb messages for standard library verb implementations for actions
 *   performed by the player character.  These return strings suitable for
 *   use in VerifyResult objects as well as for action reports
 *   (defaultReport, mainReport, and so on).
 *   
 *   Most of these messages are generic enough to be used for player and
 *   non-player character alike.  However, some of the messages either are
 *   too terse (such as the default reports) or are phrased awkwardly for
 *   NPC use, so the NPC verb messages override those.  
 */
playerActionMessages: MessageHelper
    /*
     *   generic "can't do that" message - this is used when verification
     *   fails because an object doesn't define the action ("doXxx")
     *   method for the verb 
     */
    cannotDoThatMsg = '{Du/er} {koennt} so etwas nicht machen{*}. '

    /* must be holding something before a command */
    mustBeHoldingMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {muss} dazu erst {den obj/ihn} in der Hand halten{*}. ';
    }

    /* it's too dark to do that */
    tooDarkMsg = 'Es {ist singular} dazu zu dunkel{*}. '

    /* object must be visible */
    mustBeVisibleMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} nicht sehen{*}. ';
    }

    /* object can be heard but not seen */
    heardButNotSeenMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} zwar {einen obj/eine} hören{*}, {ihn obj/sie} aber nicht sehen{*}. ';
    }

    /* object can be smelled but not seen */
    smelledButNotSeenMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} zwar {einen obj/eine} riechen{*}, {ihn obj/sie} aber nicht sehen{*}. ';
    }

    /* cannot hear object */
    cannotHearMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} nicht hören{*}. ';
    }

    /* cannot smell object */
    cannotSmellMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} nicht riechen{*}. ';
    }

    /* cannot taste object */
    cannotTasteMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} nicht schmecken{*}. ';
    }

    /* must remove an article of clothing before a command */
    cannotBeWearingMsg(obj)
    {
        gMessageParams(obj);
        return 'Dazu {muss actor} {du/er} {den obj/ihn} erst ausziehen{*}. ';
    }

    /* all contents must be removed from object before doing that */
    mustBeEmptyMsg(obj)
    {
        gMessageParams(obj);
        return 'Dazu {muss actor} {du/er} erst alles aus {dem obj/ihm} entfernen{*}. ';
    }

    /* object must be opened before doing that */
    mustBeOpenMsg(obj)
    {
        gMessageParams(obj);
        return 'Dazu {muss actor} {du/er} {den obj/ihn} erst öffnen{*}. ';
    }

    /* object must be closed before doing that */
    mustBeClosedMsg(obj)
    {
        gMessageParams(obj);
        return 'Dazu {muss actor} {du/er} {den obj/ihn} erst schließen{*}. ';
    }

    /* object must be unlocked before doing that */
    mustBeUnlockedMsg(obj)
    {
        gMessageParams(obj);
        return 'Dazu {muss actor} {du/er} {den obj/ihn} erst aufsperren{*}. ';
    }

    /* no key is needed to lock or unlock this object */
    noKeyNeededMsg = '{Der dobj/er} {benoetigt} offenbar keinen Schlüssel{*}. '

    /* actor must be standing before doing that */
    mustBeStandingMsg = 'Dazu {muss actor} {du/er} erst aufstehen{*}. '

    /* must be sitting on/in chair */
    mustSitOnMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {muss} {dich/sich} erst auf {den obj/ihn} setzen{*}. ';
    }

    /* must be lying on/in object */
    mustLieOnMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {muss} {dich/sich} erst auf {den obj/ihn} legen{*}. ';
    }

    /* must get on/in object */
    mustGetOnMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {muss} erst in {den obj/ihn} steigen{*}. ';
    }

    /* object must be in loc before doing that */
    mustBeInMsg(obj, loc)
    {
        gMessageParams(obj, loc);
        return 'Dazu {muss actor} {du/er} {dich/sich} erst in {dem obj/ihm} befinden{*}. ';
    }

    /* actor must be holding the object before we kann do that */
    mustBeCarryingMsg(obj, actor)
    {
        gMessageParams(obj, actor);
        return 'Dazu {muss actor} {du/er} {den obj/ihn} erst in der Hand halten{*}. ';
    }

    /* generic "that's not important" message for decorations */
    decorationNotImportantMsg(obj)
    {
        gMessageParams(obj);
        return '{Der obj/er} {ist} uninteressant{*}. ';
    }

    /* generic "you don't see that" message for "unthings" */
    unthingNotHereMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {sieht} {den obj/ihn} {hier|dort} nicht{*}. ';
    }

    /* generic "that's too far away" message for Distant items */
    tooDistantMsg(obj)
    {
        gMessageParams(obj);
        return '{Der obj/er} {ist} zu weit weg{*}. ';
    }

    /* generic "no can do" message for intangibles */
    notWithIntangibleMsg(obj)
    {
        gMessageParams(obj);
        return 'Das kann man mit {einem obj/ihm} nicht machen. ';
    }

    /* generic failure message for varporous objects */
    notWithVaporousMsg(obj)
    {
        gMessageParams(obj);
        return 'Das kann man mit {einem obj/ihm} nicht machen. ';
    }

    /* look in/look under/look through/look behind/search vaporous */
    lookInVaporousMsg(obj)
    {
        gMessageParams(obj);
        return 'Da {ist obj} nur {der obj/er}{*}. ';
    }

    /*
     *   cannot reach (i.e., touch) an object that is to be manipulated in
     *   a command - this is a generic message used when we cannot
     *   identify the specific reason that the object is in scope but
     *   cannot be touched 
     */
    cannotReachObjectMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} nicht erreichen{*}. ';
    }

    /* cannot reach an object through an obstructor */
    cannotReachThroughMsg(obj, loc)
    {
        gMessageParams(obj, loc);
        return '{Du/er} {kommt} durch {den loc/ihn} nicht an {den obj/ihn} heran{-*}. ';
    }

    /* generic long description of a Thing */
    thingDescMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {sieht} nichts Ungewöhnliches an ' + '{dem obj/ihm}{*}. ';
    }

    /* generic LISTEN TO description of a Thing */
    thingSoundDescMsg(obj)
        { return '{Du/er} {hoert} nichts Ungewöhnliches{*}. '; }

    /* generic "smell" description of a Thing */
    thingSmellDescMsg(obj)
        { return '{Du/er} {riecht} nichts Ungewöhnliches{*}. '; }

    /* default description of a non-player character */
    npcDescMsg(npc)
    {
        gMessageParams(npc);
        return '{Du/er} {sieht} nichts Ungewöhnliches an ' + '{dem npc/ihm}{*}. ';
    }

    /* generic messages for looking prepositionally */
    nothingInsideMsg =
        'Da {ist singular} nichts Ungewöhnliches in {dem dobj/ihm}{*}. '
    nothingUnderMsg =
        '{Du/er} {sieht} nichts Ungewöhnliches unter {dem dobj/ihm}{*}. '
    nothingBehindMsg =
        '{Du/er} {sieht} nichts Ungewöhnliches hinter {dem dobj/ihm}{*}. '
    nothingThroughMsg =
        '{Du/er} {koennt} durch {den dobj/ihn} nichts erkennen{*}. '

    /* this is an object we can't look behind/through */
    cannotLookBehindMsg = '{Du/er} {koennt} nicht hinter {den dobj/ihn} schauen{*}. '
    cannotLookUnderMsg = '{Du/er} {koennt} nicht unter {den dobj/ihn} schauen{*}. '
    cannotLookThroughMsg = '{Du/er} {koennt} nicht durch {den dobj/ihn} schauen{*}. '

    /* looking through an open passage */
    nothingThroughPassageMsg = '{Du/er} {koennt} von {hier|dort} aus nichts Besonderes erkennen{*}. '

    /* there's nothing on the other side of a door we just opened */
    nothingBeyondDoorMsg = 'Das Öffnen {des dobj/dessen} {bringt singular} nichts
        Ungewöhnliches zum Vorschein{*}. '

    /* there's nothing here with a specific odor */
    nothingToSmellMsg =
        '{Du/er} {riecht} {hier|dort} nichts Besonderes{*}. '

    /* there's nothing here with a specific noise */
    nothingToHearMsg = '{Du/er} {hoert} {hier|dort} nichts Besonderes{*}. '

    /* a sound appears to be coming from a source */
    noiseSourceMsg(src)
    {
        return '{Der dobj/er} {kommt} anscheinend ' + (gDobj.ofKind(Container) ? 'aus ' : 'von ')
            + src.demNameObj + '{*}. ';
    }

    /* an odor appears to be coming from a source */
    odorSourceMsg(src)
    {
        return '{Der dobj/er} {kommt} anscheinend ' + (gDobj.ofKind(Container) ? 'aus ' : 'von ')
            + src.demNameObj + '{*}. ';
    }

    /* an item is not wearable */
    notWearableMsg =
        '{Den dobj/ihn} {koennt actor} {du/er} nicht anziehen{*}. '

    /* doffing something that isn't wearable */
    notDoffableMsg =
        '{Den dobj/ihn} {koennt actor} {du/er} nicht ausziehen{*}. '

    /* already wearing item */
    alreadyWearingMsg = '{Du/er} {hat} {den dobj/ihn} schon angezogen{*}. '

    /* not wearing (item being doffed) */
    notWearingMsg = '{Du/er} {hat} {den dobj/ihn} nicht angezogen{*}. '

    /* default response to 'wear obj' */
    okayWearMsg = '{Du/er} {zieht} {den dobj/ihn} an{-*}. '

    /* default response to 'doff obj' */
    okayDoffMsg = '{Du/er} {zieht} {den dobj/ihn} aus{-*}. '

    /* default response to open/close */
    okayOpenMsg = shortTMsg(
        '{Du/er} {oeffnet} {den dobj/ihn}{*}. ', '{Du/er} {oeffnet} {den dobj/ihn}{*}. ')
    okayCloseMsg = shortTMsg(
        '{Du/er} {schliesst} {den dobj/ihn}{*}. ', '{Du/er} {schliesst} {den dobj/ihn}{*}. ')

    /* default response to lock/unlock */
    okayLockMsg = shortTMsg(
        '{Du/er} {schliesst} {den dobj/ihn} zu{-*}. ', '{Du/er} {schliesst} {den dobj/ihn} zu{-*}. ')
    okayUnlockMsg = shortTMsg(
        '{Du/er} {schliesst} {den dobj/ihn} auf{-*}. ', '{Du/er} {schliesst} {den dobj/ihn} auf{-*}. ')

    /* cannot dig here */
    cannotDigMsg = '{Du/er} {sieht} keinen Sinn darin{*}, in {dem dobj/ihm} zu graben. '

    /* not a digging implement */
    cannotDigWithMsg =
        '{Der iobj/er} {ist} fürs Graben nicht geeignet{*}. '

    /* taking something already being held */
    alreadyHoldingMsg = '{Du/er} {hat} {den dobj/ihn} schon{*}. '

    /* actor taking self ("take me") */
    takingSelfMsg = '{Du/er} {koennt} {dich/sich} nicht nehmen{*}. '

    /* dropping an object not being carried */
    notCarryingMsg = '{Du/er} {hat} {den dobj/ihn} gar nicht{*}. '

    /* actor dropping self */
    droppingSelfMsg = '{Du/er} {koennt} {dich/sich} nicht ablegen{*}. '

    /* actor putting self in something */
    puttingSelfMsg = '{Du/er} {koennt} das nicht mit {dir} tun{*}. '

    /* actor throwing self */
    throwingSelfMsg = '{Du/er} {koennt} {dich/sich} nicht werfen{*}. '

    /* we can't put the dobj in the iobj because it's already there */
    alreadyPutInMsg = '{Der dobj/er} {ist} schon in {dem iobj/ihm}{*}. '

    /* we can't put the dobj on the iobj because it's already there */
    alreadyPutOnMsg = '{Der dobj/er} {ist} schon auf {dem iobj/ihm}{*}. '

    /* we can't put the dobj under the iobj because it's already there */
    alreadyPutUnderMsg = '{Der dobj/er} {ist} schon unter {dem iobj/ihm}{*}. '

    /* we can't put the dobj behind the iobj because it's already there */
    alreadyPutBehindMsg = '{Der dobj/er} {ist} schon hinter {dem iobj/ihm}{*}. '

    /*
     *   trying to move a Fixture to a new container by some means (take,
     *   drop, put in, put on, etc) 
     */
    cannotMoveFixtureMsg = '{Der dobj/er} {koennt} nicht bewegt werden{*}. '

    /* trying to take a Fixture */
    cannotTakeFixtureMsg = '{Du/er} {koennt} {den dobj/ihn} nicht nehmen{*}. '

    /* trying to put a Fixture in something */
    cannotPutFixtureMsg = '{Du/er} {koennt} {den dobj/ihn} nicht irgendwohin legen{*}. '

    /* trying to take/move/put an Immovable object */
    cannotTakeImmovableMsg = '{Du/er} {koennt} {den dobj/ihn} nicht nehmen{*}. '
    cannotMoveImmovableMsg = '{Der dobj/er} {koennt} nicht bewegt werden{*}. '
    cannotPutImmovableMsg = '{Du/er} {koennt} {den dobj/ihn} nicht irgendwohin legen{*}. '

    /* trying to take/move/put a Heavy object */
    cannotTakeHeavyMsg = '{Der dobj/er} {ist} viel zu schwer{*}. '
    cannotMoveHeavyMsg = '{Der dobj/er} {ist} viel zu schwer{*}. '
    cannotPutHeavyMsg = '{Der dobj/er} {ist} viel zu schwer{*}. '

    /* trying to move a component object */
    cannotMoveComponentMsg(loc)
    {
        return '{Der dobj/er} {ist} Teil ' + loc.desNameObj + '{*}. ';
    }

    /* trying to take a component object */
    cannotTakeComponentMsg(loc)
    {
        return '{Du/er} {koennt} {den dobj/ihn} nicht nehmen{*}, '
            + '{er dobj/es} {ist} Teil ' + loc.desNameObj + '{*}. ';
    }

    /* trying to put a component in something */
    cannotPutComponentMsg(loc)
    {
        return '{Du/er} {koennt} {den dobj/ihn} nicht irgendwohin legen{*}, '
            + '{er dobj/es} {ist} Teil ' + loc.desNameObj + '{*}. ';
    }

    /* specialized Immovable messages for TravelPushables */
    cannotTakePushableMsg = '{Du/er} {koennt} {den dobj/ihn} nicht nehmen,
        {ihn dobj/sie} aber vielleicht herumschieben{*}. '
    cannotMovePushableMsg = '{Du/er} {koennt} {den dobj/ihn} herumschieben{*}, vielleicht auch 
        in eine bestimmte Richtung. '
    cannotPutPushableMsg = '{Du/er} {koennt} {den dobj/ihn} nicht irgendwo hinlegen,
        {ihn dobj/sie} aber vielleicht schieben{*}. '

    /* can't take something while occupying it */
    cannotTakeLocationMsg = '{Du/er} {koennt} {den dobj/ihn} nicht nehmen{*},
        solange {du actor/er} {ihn dobj/sie} in Beschlag {!*}{nimmt actor}. '

    /* can't REMOVE something that's being held */
    cannotRemoveHeldMsg = 'Da {ist singular} nichts zu entfernen{*}. '

    /* default 'take' response */
    okayTakeMsg = shortTMsg(
        '{Du/er} {nimmt} {den dobj/ihn} mit{-*}. ', '{Du/er} {nimmt} {den dobj/ihn} mit{-*}. ')

    /* default 'drop' response */
    okayDropMsg = shortTMsg(
        '{Du/er} {legt} {den dobj/ihn} ab{-*}. ', '{Du/er} {legt} {den dobj/ihn} ab{-*}. ')

    /* dropping an object */
    droppingObjMsg(dropobj)
    {
        gMessageParams(dropobj);
        return '{Du/er} {legt} {den dropobj/ihn} ab{-*}. ';
    }

    /* default receiveDrop suffix for floorless rooms */
    floorlessDropMsg(dropobj)
    {
        gMessageParams(dropobj);
        return '{Der dropobj/er} {faellt} unter {dir actor} in die Tiefe{*}. ';
    }

    /* default successful 'put in' response */
    okayPutInMsg = shortTIMsg(
        '{Du/er} {legt} {den dobj/ihn} in {den iobj/ihn}{*}. ', 
        '{Du/er} {legt} {den dobj/ihn} in {den iobj/ihn}{*}. ')

    /* default successful 'put on' response */
    okayPutOnMsg = shortTIMsg(
        '{Du/er} {legt} {den dobj/ihn} auf {den iobj/ihn}{*}. ', 
        '{Du/er} {legt} {den dobj/ihn} auf {den iobj/ihn}{*}. ')

    /* default successful 'put under' response */
    okayPutUnderMsg = shortTIMsg(
        '{Du/er} {legt} {den dobj/ihn} unter {den iobj/ihn}{*}. ', 
        '{Du/er} {legt} {den dobj/ihn} unter {den iobj/ihn}{*}. ')

    /* default successful 'put behind' response */
    okayPutBehindMsg = shortTIMsg(
        '{Du/er} {legt} {den dobj/ihn} hinter {den iobj/ihn}{*}. ', 
        '{Du/er} {legt} {den dobj/ihn} hinter {den iobj/ihn}{*}. ')

    /* try to take/move/put/taste an untakeable actor */
    cannotTakeActorMsg = '{Der dobj/er} {will} {dich actor} nicht lassen{*}. '
    cannotMoveActorMsg = '{Der dobj/er} {will} {dich actor} nicht lassen{*}. '
    cannotPutActorMsg = '{Der dobj/er} {will} {dich actor} nicht lassen{*}. '
    cannotTasteActorMsg = '{Der dobj/er} {will} {dich actor} nicht lassen{*}. '

    /* trying to take/move/put/taste a person */
    cannotTakePersonMsg =
        '{Dem dobj/ihm} hätte das sicher nicht gefallen. '
    cannotMovePersonMsg =
        '{Dem dobj/ihm} hätte das sicher nicht gefallen. '
    cannotPutPersonMsg =
        '{Dem dobj/ihm} hätte das sicher nicht gefallen. '
    cannotTastePersonMsg =
        '{Dem dobj/ihm} hätte das sicher nicht gefallen. '

    /* cannot move obj through obstructor */
    cannotMoveThroughMsg(obj, obs)
    {
        gMessageParams(obj, obs);
        return '{Du/er} {bekommt} {den obj/ihn} nicht durch '
               + '{den obs/ihn} hindurch{-*}. ';
    }

    /* cannot move obj in our out of container cont */
    cannotMoveThroughContainerMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Du/er} {bekommt} {den obj/ihn} nicht aus '
               + '{dem cont/ihm} heraus{-*}. ';
    }

    /* cannot move obj because cont is closed */
    cannotMoveThroughClosedMsg(obj, cont)
    {
        gMessageParams(cont);
        return '{Du/er} {kommt} nicht an {den obj/ihn}{*}, weil {der cont/er} 
            geschlossen {!*}{ist}. ';
    }

    /* cannot fit obj into cont through cont's opening */
    cannotFitIntoOpeningMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {ist} zu groß{*},
            um {ihn obj/sie} in {den cont/ihn} zu legen. ';
    }

    /* cannot fit obj out of cont through cont's opening */
    cannotFitOutOfOpeningMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {ist} zu groß{*},
            um {ihn obj/sie} aus {dem cont/ihm} heraus zu bekommen. ';
    }

    /* actor 'obj' cannot reach in our out of container 'cont' */
    cannotTouchThroughContainerMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {koennt} nichts außerhalb '
               + '{des cont/dessen} erreichen{*}. ';
    }

    /* actor 'obj' cannot reach through cont because cont is closed */
    cannotTouchThroughClosedMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {koennt} nichts außerhalb
            {des cont/dessen} erreichen{*}, weil {der/er} geschlossen {!*}{ist}. ';
    }

    /* actor cannot fit hand into cont through cont's opening */
    cannotReachIntoOpeningMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {koennt} mit der Hand nicht in '
               + '{den cont/ihn} greifen{*}. ';
    }

    /* actor cannot fit hand into cont through cont's opening */
    cannotReachOutOfOpeningMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {koennt} mit der Hand nicht durch
            {den cont/ihn} greifen{*}. ';
    }

    /* the object is too large for the actor to hold */
    tooLargeForActorMsg(obj)
    {
        gMessageParams(obj);
        return '{Der obj/er} {ist} zu groß{*}, um {ihn obj/sie} zu halten. '; 
    }

    /* the actor doesn't have room to hold the object */
    handsTooFullForMsg(obj)
    {
        return '{Deine} Hände {ist plural} zu voll{*}, um '
               + obj.denName + ' zu halten. ';
    }

    /* the object is becoming too large for the actor to hold */
    becomingTooLargeForActorMsg(obj)
    {
        gMessageParams(obj);
        return '{Der obj/er} {ist} zu groß{*}, um {ihn obj/sie} in der Hand zu halten. ';
    }

    /* the object is becoming large enough that the actor's hands are full */
    handsBecomingTooFullForMsg(obj)
    {
        gMessageParams(obj);
        return '{Deine} Hände {ist plural} zu voll{*}, um {den obj/ihn} zu halten. ';
    }

    /* the object is too heavy (all by itself) for the actor to hold */
    tooHeavyForActorMsg(obj)
    {
        gMessageParams(obj);
        return '{Der obj/er} {ist} zu schwer{*}, um {ihn/sie} mitzunehmen. ';
    }

    /*
     *   the object is too heavy (in combination with everything else
     *   being carried) for the actor to pick up 
     */
    totalTooHeavyForMsg(obj)
    {
        gMessageParams(obj);
        return '{Der obj/er} {ist} zu schwer{*}, {du/er} {muss} dafür erst etwas
            ablegen{*}. ';
    }

    /* object is too large for container */
    tooLargeForContainerMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {ist} zu groß für {den cont/ihn}{*}. ';
    }

    /* object is too large to fit under object */
    tooLargeForUndersideMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {ist} zu groß{*}, um {ihn obj/sie} unter {den cont/ihn} zu legen. ';
    }

    /* object is too large to fit behind object */
    tooLargeForRearMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {ist} zu groß{*}, um {ihn obj/sie} hinter {den cont/ihn} zu legen. ';
    }

    /* container doesn't have room for object */
    containerTooFullMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der cont/er} {ist} schon zu voll{*}, um {den obj/ihn} aufzunehmen. ';
    }

    /* surface doesn't have room for object */
    surfaceTooFullMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return 'Da {ist singular} kein Platz für {den obj/ihn} auf '
               + '{dem cont/ihm}{*}. ';
    }

    /* underside doesn't have room for object */
    undersideTooFullMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return 'Da {ist singular} kein Platz für {den obj/ihn} unter '
               + '{dem cont/ihm}{*}. ';
    }

    /* rear surface/space doesn't have room for object */
    rearTooFullMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return 'Da {ist singular} kein Platz für {den obj/ihn} hinter '
               + '{dem cont/ihm}{*}. ';
    }

    /* the current action would make obj too large for its container */
    becomingTooLargeForContainerMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {wird} dann zu groß für {den cont/ihn}{*}. ';
    }

    /*
     *   the current action would increase obj's bulk so that container is
     *   too full 
     */
    containerBecomingTooFullMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der cont/er} {wird} dann zu voll für {den obj/ihn}{*}. ';
    }

    /* trying to put an object in a non-container */
    notAContainerMsg = '{Du/er} {koennt} nichts in {den iobj/ihn} legen{*}. '

    /* trying to put an object on a non-surface */
    notASurfaceMsg = 'Dazu {ist singular} keine geeignete Fläche auf
        {dem iobj/ihm}{*}. '

    /* can't put anything under iobj */
    cannotPutUnderMsg =
        '{Du/er} {koennt} nichts unter {den iobj/ihn} legen{*}. '

    /* nothing kann be put behind the given object */
    cannotPutBehindMsg = 
        '{Du/er} {koennt} nichts hinter {den iobj/ihn} legen{*}. '

    /* trying to put something in itself */
    cannotPutInSelfMsg = '{Du/er} {koennt} {den dobj/ihn} nicht in {ihn/sie} selbst legen{*}. '

    /* trying to put something on itself */
    cannotPutOnSelfMsg = '{Du/er} {koennt} {den dobj/ihn} nicht auf {ihn/sie} selbst legen{*}. '

    /* trying to put something under itself */
    cannotPutUnderSelfMsg = 
        '{Du/er} {koennt} {den dobj/ihn} nicht unter {ihn/sie} selbst legen{*}. '

    /* trying to put something behind itself */
            
    cannotPutBehindSelfMsg = 
        '{Du/er} {koennt} {den dobj/ihn} nicht hinter {ihn/sie} selbst legen{*}. '

    /* can't put something in/on/etc a restricted container/surface/etc */
    cannotPutInRestrictedMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht in {den iobj/ihn} legen{*}. '
    cannotPutOnRestrictedMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht auf {den iobj/ihn} legen{*}. '
    cannotPutUnderRestrictedMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht unter {den iobj/ihn} legen{*}. '
    cannotPutBehindRestrictedMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht hinter {den iobj/ihn} legen{*}. '

    /* trying to return something to a remove-only dispenser */
    cannotReturnToDispenserMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht in {den iobj/ihn} zurücklegen{*}. '

    /* wrong item type for dispenser */
    cannotPutInDispenserMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht in {den iobj/ihn} legen{*}. '

    /* the dobj doesn't fit on this keyring */
    objNotForKeyringMsg = '{Der dobj/er} {passt} nicht an {den iobj/ihn}{*}. '

    /* the dobj isn't on the keyring */
    keyNotOnKeyringMsg = '{Der dobj/er} {ist} nicht an {dem iobj/ihm} festgemacht{*}. '

    /* kann't detach key (with no iobj specified) because it's not on a ring */
    keyNotDetachableMsg = '{Der dobj/er} {ist} nicht festgemacht{*}. '

    /* we took a key and attached it to a keyring */
    takenAndMovedToKeyringMsg(keyring)
    {
        gMessageParams(keyring);
        return '{Du/er} {nimmt} {den dobj/ihn}{*} und
            {haengt actor} {ihn dobj/sie} an {den keyring/ihn}{*}. ';
    }

    /* we attached a key to a keyring automatically */
    movedKeyToKeyringMsg(keyring)
    {
        gMessageParams(keyring);
        return '{Du/er} {haengt} {den dobj/ihn} an {den keyring/ihn}{*}. ';
    }

    /* we moved several keys to a keyring automatically */
    movedKeysToKeyringMsg(keyring, keys)
    {
        gMessageParams(keyring);
        return '{Du/er} {haengt} {deine} losen Schlüssel '
            + ' an {den keyring/ihn}{*}. ';
    }

    /* putting y in x when x is already in y */
    circularlyInMsg(x, y)
    {
        gMessageParams(x, y);
        return '{Der x/er} {ist} aber in {dem y/ihm}{*}. ';
    }

    /* putting y in x when x is already on y */
    circularlyOnMsg(x, y)
    {
        gMessageParams(x, y);
        return '{Der x/er} {ist} aber auf {dem y/ihm}{*}. ';
    }

    /* putting y in x when x is already under y */
    circularlyUnderMsg(x, y)
    {
        gMessageParams(x, y);
        return '{Der x/er} {ist} aber unter {dem y/ihm}{*}. ';
    }

    /* putting y in x when x is already behind y */
    circularlyBehindMsg(x, y)
    {
        gMessageParams(x, y);
        return '{Der x/er} {ist} aber hinter {dem y/ihm}{*}. ';
    }

    /* taking dobj from iobj, but dobj isn't in iobj */
    takeFromNotInMsg = '{Der dobj/er} {ist} nicht in {dem iobj/ihm}{*}. '

    /* taking dobj from surface, but dobj isn't on iobj */
    takeFromNotOnMsg = '{Der dobj/er} {ist} nicht auf {dem iobj/ihm}{*}. '

    /* taking dobj from under something, but dobj isn't under iobj */
    takeFromNotUnderMsg = '{Der dobj/er} {ist} nicht unter {dem iobj/ihm}{*}. '

    /* taking dobj from behind something, but dobj isn't behind iobj */
    takeFromNotBehindMsg = '{Der dobj/er} {ist} nicht hinter {dem iobj/ihm}{*}. '

    /* taking dobj from an actor, but actor doesn't have iobj */
    takeFromNotInActorMsg = '{Der iobj/er} {hat} {den dobj/ihn} gar nicht{*}. '

    /* actor won't let go of a possession */
    willNotLetGoMsg(holder, obj)
    {
        gMessageParams(holder, obj);
        return '{Der holder/er} {will} {den obj/ihn} nicht hergeben{*}. ';
    }

    /* must say which way to go */
    whereToGoMsg = '{Du/er} {muss} sagen{*}, in welche Richtung. '

    /* travel attempted in a direction with no exit */
    cannotGoThatWayMsg = '{Du/er} {koennt} nicht in diese Richtung gehen{*}. '

    /* travel attempted in the dark in a direction with no exit */
    cannotGoThatWayInDarkMsg = 'Es {ist singular} zu dunkel{*}. {Du/er}
        {koennt} nicht sehen{*}, wohin {du/er} {!*}{geht}. '

    /* we don't know the way back for a GO BACK */
    cannotGoBackMsg = '{Du/er} {weiss} nicht{*}, wie. '

    /* cannot carry out a command from this location */
    cannotDoFromHereMsg = '{Du/er} {koennt} das von {hier|dort} aus nicht tun{*}. '

    /* can't travel through a close door */
    cannotGoThroughClosedDoorMsg(door)
    {
        gMessageParams(door);
        return 'Das {geht singular} nicht{*}, weil {der door/er} geschlossen {!*}{ist}. ';
    }

    /* cannot carry out travel while 'dest' is within 'cont' */
    invalidStagingContainerMsg(cont, dest)
    {
        gMessageParams(cont, dest);
        return '{Der dest/er} {ist} aber in {dem cont/ihm}{*}. ';
    }

    /* cannot carry out travel while 'cont' (an actor) is holding 'dest' */
    invalidStagingContainerActorMsg(cont, dest)
    {
        gMessageParams(cont, dest);
        return 'Das {geht singular} nicht{*}, solange {der cont/er} 
            {den dest/ihn} in der Hand {!*}{hat cont}. ';
    }
    
    /* can't carry out travel because 'dest' isn't a valid staging location */
    invalidStagingLocationMsg(dest)
    {
        gMessageParams(dest);
        return '{Du/er} {koennt} {den dest/ihn} nicht betreten{*}. ';
    }

    /* destination is too high to enter from here */
    nestedRoomTooHighMsg(obj)
    {
        gMessageParams(obj);
        return '{Der obj/er} {ist} zu weit oben{*}, um {ihn/sie} von {hier|dort} 
            zu erreichen. ';
    }

    /* enclosing room is too high to reach by GETTING OUT OF here */
    nestedRoomTooHighToExitMsg(obj)
    {
        return 'Dazu {subj actor} {ist} {du/er} {hier|dort} zu weit oben{*}. ';
    }

    /* cannot carry out a command from a nested room */
    cannotDoFromMsg(obj)
    {
        gMessageParams(obj);
        return 'Das {geht singular} von {dem obj/ihm} aus nicht{*}. ';
    }

    /* cannot carry out a command from within a vehicle in a nested room */
    vehicleCannotDoFromMsg(obj)
    {
        local loc = obj.location;
        gMessageParams(obj, loc);
        return 'Das {geht singular} nicht{*}, solange {der obj/er} in {dem loc/ihm} {!*}{ist obj}. ';
    }

    /* cannot go that way in a vehicle */
    cannotGoThatWayInVehicleMsg(traveler)
    {
        gMessageParams(traveler);
        return '{Du/er} {koennt} dorthin nicht mit {dem traveler/ihm} gelangen{*}. ';
    }

    /* cannot push an object that way */
    cannotPushObjectThatWayMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} nicht dorthin schieben{*}. ';
    }

    /* cannot push an object to a nested room */
    cannotPushObjectNestedMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} nicht dorthin schieben{*}. ';
    }

    /* cannot enter an exit-only passage */
    cannotEnterExitOnlyMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} {den obj/ihn} von {hier|dort} aus nicht betreten{*}. ';
    }

    /* must open door before going that way */
    mustOpenDoorMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {muss} {den obj/ihn} erst öffnen{*}. ';
    }

    /* door closes behind actor during travel through door */
    doorClosesBehindMsg(obj)
    {
        gMessageParams(obj);
        return '<.p>Danach {schliesst obj} sich {der obj/er} hinter {dem actor/ihm}{*}. ';
    }

    /* the stairway does not go up/down */
    stairwayNotUpMsg = '{Der dobj/er} {fuehrt} von {hier|dort} nur nach unten{*}. '
    stairwayNotDownMsg = '{Der dobj/er} {fuehrt} von {hier|dort} nur nach oben{*}. '

    /* "wait" */
    timePassesMsg = 'Die Zeit {vergeht singular}{*}... '

    /* "hello" with no target actor */
    sayHelloMsg = (addressingNoOneMsg)

    /* "goodbye" with no target actor */
    sayGoodbyeMsg = (addressingNoOneMsg)

    /* "yes"/"no" with no target actor */
    sayYesMsg = (addressingNoOneMsg)
    sayNoMsg = (addressingNoOneMsg)

    /* an internal common handler for sayHelloMsg, sayGoodbyeMsg, etc */
    addressingNoOneMsg
    {
        return 'Sag bitte genauer, zu wem. ';
    }

    /* "yell" */
    okayYellMsg = '{Du/er} {schreit} so laut{*} wie {er actor/es} {!*}{kann}. '

    /* "jump" */
    okayJumpMsg = '{Du/er} {springt} auf der Stelle{*}. '

    /* cannnot jump over object */
    cannotJumpOverMsg = '{Du/er} {koennt} nicht über {den dobj/ihn} springen{*}. '

    /* cannnot jump off object */
    cannotJumpOffMsg = '{Du/er} {koennt} nicht von {dem dobj/ihm} springen{*}. '

    /* cannnot jump off (with no direct object) from here */
    cannotJumpOffHereMsg = '{Hier|Dort} {koennt actor} {er actor/sie} nicht hinunter springen{*}. '

    /* failed to find a topic in a consultable object */
    cannotFindTopicMsg =
        '{Du/er} {koennt} darüber nichts in {dem dobj/ihm} finden{*}. '

    /* an actor doesn't accept a command from another actor */
    refuseCommand(targetActor, issuingActor)
    {
        gMessageParams(targetActor, issuingActor);
        return '{Der targetActor/er} {weigert} sich{*}, das zu tun. ';
    }

    /* cannot talk to an object (because it makes no sense to do so) */
    notAddressableMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {koennt} nicht mit {dem obj/ihm} reden{*}. ';
    }

    /* actor won't respond to a request or other communicative gesture */
    noResponseFromMsg(other)
    {
        gMessageParams(other);
        return '{Der other/er} {antwortet} nicht{*}. ';
    }

    /* trying to give something to someone who already has the object */
    giveAlreadyHasMsg = '{Der iobj/er} {hat} {den dobj/ihn} schon in der Hand{*}. '

    /* can't talk to yourself */
    cannotTalkToSelfMsg = 'Selbstgespräche zu führen,
        {bringt singular} wenig{*}. '

    /* can't ask yourself about anything */
    cannotAskSelfMsg = '{Dichselbst} zu fragen,
        {bringt singular} wenig{*}. '

    /* can't ask yourself for anything */
    cannotAskSelfForMsg = '{Dichselbst} zu bitten,
        {bringt singular} wenig{*}. '

    /* can't tell yourself about anything */
    cannotTellSelfMsg = 'Mit {dirselbst} zu reden,
        {bringt singular} wenig{*}. '

    /* can't give yourself something */
    cannotGiveToSelfMsg = '{Dirselbst} {den dobj/ihn} zu geben,
        {bringt singular} wenig{*}. '
    
    /* can't give something to itself */
    cannotGiveToItselfMsg = '{Dem dobj/ihm} {den dobj/ihn} zu geben,
        {bringt singular} wenig{*}. '

    /* can't show yourself something */
    cannotShowToSelfMsg = '{Dirselbst} {den dobj/ihn} zu zeigen,
        {bringt singular} wenig{*}. '

    /* can't show something to itself */
    cannotShowToItselfMsg = '{Dem dobj/ihm} {den dobj/ihn} zu zeigen,
        {bringt singular} wenig{*}. '

    /* can't give/show something to a non-actor */
    cannotGiveToMsg = '{Du/er} {koennt} {dem iobj/ihm} nichts geben{*}. '
    cannotShowToMsg = '{Du/er} {koennt} {dem iobj/ihm} nichts zeigen{*}. '

    /* actor isn't interested in something being given/shown */
    notInterestedMsg(actor)
    {
        return '\^<<buildSynthParam('subj', actor)>>' + actor.derName + ' ' + actor.verbZuSein + ' offenbar daran nicht interessiert{*}. ';
    }

    /* vague ASK/TELL (for ASK/TELL <actor> <topic> syntax errors) */
    askVagueMsg = '<.parser>Bitte verwende FRAG JEMAND NACH EINEM THEMA (oder einfach F THEMA).<./parser> '
    tellVagueMsg = '<.parser>Bitte verwende ERZÄHL JEMAND VON EINEM THEMA (oder einfach E THEMA).<./parser> '

    /* object cannot hear actor */
    objCannotHearActorMsg(obj)
    {
        return '\^<<buildSynthParam('subj', obj)>>' + obj.derName + ' ' + obj.verbZuHoeren +
            ' {dich} offenbar nicht{*}. ';
    }

    /* actor cannot see object being shown to actor */
    actorCannotSeeMsg(actor, obj)
    {
        return '\^<<buildSynthParam('subj', actor)>>' + actor.derName + ' ' + actor.verbZuSehen + ' ' + obj.denNameObj 
            + ' offenbar nicht{*}. ';
    }

    /* not a followable object */
    notFollowableMsg = '{Du/er} {koennt} {dem dobj/ihm} nicht folgen{*}. '

    /* cannot follow yourself */
    cannotFollowSelfMsg = '{Du/er} {koennt} schlecht {dirselbst} folgen{*}. '

    /* following an object that's in the same location as the actor */
    followAlreadyHereMsg = '{Der dobj/er} {ist} schon {hier|dort}{*}. '

    /*
     *   following an object that we *think* is in our same location (in
     *   other words, we're already in the location where we thought we
     *   last saw the object go), but it's too dark to see if that's
     *   really true 
     */
    followAlreadyHereInDarkMsg = 'Es {ist singular} zu dunkel{*}, um {den dobj/ihn} zu sehen. '

    /* trying to follow an object, but don't know where it went from here */
    followUnknownMsg = '{Du/er} {ist} {dir} nicht sicher{*}, wohin {der dobj/er} gegangen {!*}{ist}. '

    /*
     *   we're trying to follow an actor, but we last saw the actor in the
     *   given other location, so we have to go there to follow 
     */
    cannotFollowFromHereMsg(srcLoc)
    {
        return 'Der letzte Ort, an dem {du/er} {den dobj/ihn} gesehen {!*}{hat}, 
            {ist singular}<<withCaseNominative>> ' + srcLoc.getDestName(gActor, gActor.location) + '{*}. ';
    }

    /* acknowledge a 'follow' for a target that was in sight */
    okayFollowInSightMsg(loc)
    {
        return '{Du/er} {folgt} {dem dobj/ihm} '
            + loc.actorIntoName + '{*}. ';
    }

    /* obj is not a weapon */
    notAWeaponMsg = '{Der iobj/er} {ist} dafür nicht zu gebrauchen{*}. '

    /* no effect attacking obj */
    uselessToAttackMsg = '{Du/er} {kommt} {hier|dort} mit Gewalt auch nicht weiter{*}. '

    /* pushing object has no effect */
    pushNoEffectMsg = '{Den dobj/ihn} zu schieben {zeigt singular} keinerlei Wirkung{*}. '

    /* default 'push button' acknowledgment */
    okayPushButtonMsg = '<q>Klick.</q> '

    /* lever is already in pushed state */
    alreadyPushedMsg =
        '{Der dobj/er} {ist} schon soweit wie möglich hinein gedrückt{*}. '

    /* default acknowledgment to pushing a lever */
    okayPushLeverMsg = '{Du/er} {drueckt} {den dobj/ihn} soweit wie möglich hinein{*}. '

    /* pulling object has no effect */
    pullNoEffectMsg = 'An {dem dobj/ihm} zu ziehen {zeigt singular} keinerlei Wirkung{*}. '

    /* lever is already in pulled state */
    alreadyPulledMsg =
        '{Der dobj/er} {ist} schon soweit wie möglich heraus gezogen{*}. '

    /* default acknowledgment to pulling a lever */
    okayPullLeverMsg = '{Du/er} {zieht} {den dobj/ihn} soweit wie
        möglich heraus{*}. '

    /* default acknowledgment to pulling a spring-loaded lever */
    okayPullSpringLeverMsg = '{Du/er} {zieht} {den dobj/ihn}{*} und {er/sie}
        {springt} zurück in die Ausgangsposition{*}, sobald {du/er} 
        {ihn dobj/sie} los {!*}{laesst}. '

    /* moving object has no effect */
    moveNoEffectMsg = '{Den dobj/ihn} zu bewegen {bringt singular} wenig{*}. '

    /* cannot move object to other object */
    moveToNoEffectMsg = 'Das {bringt singular} wenig{*}. '

    /* cannot push an object through travel */
    cannotPushTravelMsg = 'Das {bringt singular} wenig{*}. '

    /* acknowledge pushing an object through travel */
    okayPushTravelMsg(obj)
    {
        return '<.p>{Du/er} {schiebt} ' + obj.denNameObj
            + ' {hierher|dorthin}{*}. ';
    }

    /* cannot use object as an implement to move something */
    cannotMoveWithMsg =
        '{Du/er} {koennt} mit {dem iobj/ihm} nichts bewegen{*}. '

    /* cannot set object to setting */
    cannotSetToMsg = '{Du/er} {koennt} {den dobj/ihn} nicht auf etwas einstellen{*}. '

    /* invalid setting for generic Settable */
    setToInvalidMsg = '{Der dobj/er} {hat} keine solche Einstellung{*}. '

    /* default 'set to' acknowledgment */
    okaySetToMsg(val)
        { return 'In Ordnung, {der dobj/er} {ist} jetzt auf ' + val + ' eingestellt{*}. '; }

    /* cannot turn object */
    cannotTurnMsg = '{Du/er} {koennt} {den dobj/ihn} nicht drehen{*}. '

    /* must specify setting to turn object to */
    mustSpecifyTurnToMsg = 'Sag bitte genauer, worauf {du/er} 
        {den dobj/ihn} einstellen {will actor}{*}. '

    /* cannot turn anything with object */
    cannotTurnWithMsg =
        '{Du/er} {koennt} mit {dem iobj/ihm} nichts drehen{*}. '

    /* invalid setting for dial */
    turnToInvalidMsg = '{Der dobj/er} {hat} keine solche Einstellung{*}. '

    /* default 'turn to' acknowledgment */
    okayTurnToMsg(val)
        { return 'In Ordnung, {der dobj/er} {ist} nun auf ' + val + ' eingestellt{*}. '; }

    /* switch is already on/off */
    alreadySwitchedOnMsg = '{Der dobj/er} {ist} schon an{*}. '
    alreadySwitchedOffMsg = '{Der dobj/er} {ist} schon aus{*}. '

    /* default acknowledgment for switching on/off */
    okayTurnOnMsg = 'In Ordnung, {der dobj/er} {ist} jetzt an{*}. '
    okayTurnOffMsg = 'In Ordnung, {der dobj/er} {ist} jetzt aus{*}. '

    /* flashlight is on but doesn't light up */
    flashlightOnButDarkMsg = '{Du/er} {schaltet} {den dobj/ihn} ein{-*}, 
        aber es {passiert singular} anscheinend nichts{*}. '

    /* default acknowledgment for eating something */
    okayEatMsg = '{Du/er} {isst} {den dobj/ihn}{*}. '

    /* object must be burning before doing that */
    mustBeBurningMsg(obj)
    {
        return '{Du/er} {muss} ' + obj.denNameObj
            + ' zuerst anzünden{*}. ';
    }

    /* match not lit */
    matchNotLitMsg = '{Der dobj/er} {ist} nicht angezündet{*}. '

    /* lighting a match */
    okayBurnMatchMsg =
        '{Du/er} {zuendet} {den dobj/ihn} an{-*} und eine kleine Flamme {erscheint singular}{*}. '

    /* extinguishing a match */
    okayExtinguishMatchMsg = '{Du/er} {macht} {den dobj/ihn} aus{-*} und {er dobj/sie}
        {loest} {sich} in einer Aschewolke auf{-*}. '

    /* trying to light a kanndle with no fuel */
    candleOutOfFuelMsg =
        '{Der dobj/er} {ist} heruntergebrannt und {koennt} nicht mehr angezündet werden{*}. '

    /* lighting a kanndle */
    okayBurnCandleMsg = '{Du/er} {zuendet} {den dobj/ihn} an{-*}. '

    /* extinguishing a kanndle that isn't lit */
    candleNotLitMsg = '{Der dobj/er} {ist} nicht angezündet{*}. '

    /* extinguishing a kanndle */
    okayExtinguishCandleMsg = 'Erledigt. '

    /* cannot consult object */
    cannotConsultMsg =
        '{Du/er} {koennt} in {dem dobj/ihm} nichts nachschlagen{*}. '

    /* cannot type anything on object */
    cannotTypeOnMsg = '{Du/er} {koennt} auf {dem dobj/ihm} nichts tippen{*}. '

    /* cannot enter anything on object */
    cannotEnterOnMsg = '{Du/er} {koennt} auf {dem dobj/ihm} nichts eingeben{*}. '
    
    /* cannot switch object */
    cannotSwitchMsg = '{Du/er} {koennt} {den dobj/ihn} nicht an- oder ausschalten{*}. '

    /* cannot flip object */
    cannotFlipMsg = '{Du/er} {koennt} {den dobj/ihn} nicht umdrehen{*}. '

    /* cannot turn object on/off */
    cannotTurnOnMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht einschalten{*}. '
    cannotTurnOffMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht ausschalten{*}. '
    
    /* cannot light */
    cannotLightMsg = '{Du/er} {will} {den dobj/ihn} nicht anzünden{*}. '

    /* cannot burn */
    cannotBurnMsg = '{Du/er} {will} {den dobj/ihn} nicht verbrennen{*}. '
    cannotBurnWithMsg =
        '{Du/er} {koennt} mit {dem iobj/ihm} nichts verbrennen{*}. '

    /* cannot burn this specific direct object with this specific iobj */
    cannotBurnDobjWithMsg = '{Du/er} {koennt} {den dobj/ihn} nicht mit
                          {dem iobj/ihm} anzünden{*}. '

    /* object is already burning */
    alreadyBurningMsg = '{Der dobj/er} {brennt} schon{*}. '

    /* cannot extinguish */
    cannotExtinguishMsg = '{Du/er} {koennt} {den dobj/ihn} nicht löschen{*}. '

    /* cannot pour/pour in/pour on */
    cannotPourMsg = '{Du/er} {koennt} {den dobj/ihn} nicht schütten{*}. '
    cannotPourIntoMsg =
        '{Du/er} {koennt} nichts in {den iobj/ihn} schütten{*}. '
    cannotPourOntoMsg =
        '{Du/er} {koennt} nichts auf {den iobj/ihn} schütten{*}. '

    /* cannot attach object to object */
    cannotAttachMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht an etwas befestigen{*}. '
    cannotAttachToMsg =
        '{Du/er} {koennt} nichts an {dem iobj/ihm} befestigen{*}. '

    /* cannot attach to self */
    cannotAttachToSelfMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht an {sichselbst} befestigen{*}. '

    /* cannot attach because we're already attached to the given object */
    alreadyAttachedMsg =
        '{Der dobj/er} {ist} schon an {dem iobj/ihm} befestigt{*}. '

    /*
     *   dobj and/or iobj can be attached to certain things, but not to
     *   each other 
     */
    wrongAttachmentMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht an {dem iobj/ihm} befestigen{*}. '

    /* dobj and iobj are attached, but they can't be taken apart */
    wrongDetachmentMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht von {dem iobj/ihm} lösen{*}. '

    /* must detach the object before proceeding */
    mustDetachMsg(obj)
    {
        gMessageParams(obj);
        return '{Du/er} {muss} {den obj/ihn} erst lösen{*}. ';
    }

    /* default message for successful Attachable attachment */
    okayAttachToMsg = 'Erledigt. '

    /* default message for successful Attachable detachment */
    okayDetachFromMsg = 'Erledigt. '

    /* cannot detach object from object */
    cannotDetachMsg = '{Du/er} {koennt} {den dobj/ihn} nicht lösen{*}. '
    cannotDetachFromMsg =
        '{Du/er} {koennt} nichts von {dem iobj/ihm} lösen{*}. '

    /* no obvious way to detach a permanent attachment */
    cannotDetachPermanentMsg =
        'Es {gibt singular} offensichtlich keine Möglichkeit{*}, {den dobj/ihn} zu lösen. '

    /* dobj isn't attached to iobj */
    notAttachedToMsg = '{Der dobj/er} {ist} an {dem iobj/ihm} gar nicht befestigt{*}. '

    /* breaking object would serve no purpose */
    shouldNotBreakMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht zerbrechen{*}. '

    /* cannot cut that */
    cutNoEffectMsg = '{Der iobj/er} {koennt} {den dobj/ihn} nicht durchschneiden{*}. '

    /* can't use iobj to cut anything */
    cannotCutWithMsg = '{Du/er} {koennt} mit {dem iobj/ihm} nichts schneiden{*}. '

    /* cannot climb object */
    cannotClimbMsg =
        'Auf {den dobj/ihn} {koennt singular} nicht geklettert werden{*}. '

    /* object is not openable/closable */
    cannotOpenMsg = '{Der dobj/er} {koennt} nicht geöffnet werden{*}. '
    cannotCloseMsg =
        '{Der dobj/er} {koennt} nicht geschlossen werden{*}. '

    /* already open/closed */
    alreadyOpenMsg = '{Der dobj/er} {ist} schon offen{*}. '
    alreadyClosedMsg = '{Der dobj/er} {ist} schon geschlossen{*}. '

    /* already locked/unlocked */
    alreadyLockedMsg = '{Der dobj/er} {ist} schon abgesperrt{*}. '
    alreadyUnlockedMsg = '{Der dobj/er} {ist} schon aufgesperrt{*}. '
    
    /* cannot look in container because it's closed */
    cannotLookInClosedMsg = '{Der dobj/er} {ist} geschlossen{*}. '

    /* object is not lockable/unlockable */
    cannotLockMsg =
        '{Der dobj/er} {koennt} nicht abgesperrt werden{*}. '
    cannotUnlockMsg =
        '{Der dobj/er} {koennt} nicht aufgesperrt werden{*}. '
    
    /* attempting to open a locked object */
    cannotOpenLockedMsg = '{Der dobj/er} {ist} anscheinend abgesperrt{*}. '

    /* object requires a key to unlock */
    unlockRequiresKeyMsg =
        '{Du/er} {braucht} offenbar einen Schlüssel{*}, um {den dobj/ihn} aufzusperren. '

    /* object is not a key */
    cannotLockWithMsg =
        '{Der iobj/er} {ist} dafür nicht geeignet{*}. '
    cannotUnlockWithMsg =
        '{Der iobj/er} {ist} dafür nicht geeignet{*}. '

    /* we don't know how to lock/unlock this */
    unknownHowToLockMsg =
        'Es {ist singular} unklar{*}, wie man {den dobj/ihn} absperren kann. '
    unknownHowToUnlockMsg =
        'Es {ist singular} unklar{*}, wie man {den dobj/ihn} aufsperren kann. '

    /* the key (iobj) does not fit the lock (dobj) */
    keyDoesNotFitLockMsg = '{Der iobj/er} {passt} anscheinend nicht{*}. '

    /* found key on keyring */
    foundKeyOnKeyringMsg(ring, key)
    {
        gMessageParams(ring, key);
        return '{Du/er} {probiert} alle Schlüssel an {dem ring/ihm}{*}. {Der key/er} {passt}{*}! ';
    }

    /* failed to find a key on keyring */
    foundNoKeyOnKeyringMsg(ring)
    {
        gMessageParams(ring);
        return '{Du/er} {probiert} alle Schlüssel an {dem ring/ihm}{*}, aber keiner davon {passt singular}{*}. ';
    }

    /* not edible/drinkable */
    cannotEatMsg = '{Der dobj/er} {ist} nicht essbar{*}. '
    cannotDrinkMsg = '{Der dobj/er} {ist} nicht trinkbar{*}. '

    /* cannot clean object */
    cannotCleanMsg =
        '{Du/er} {will} {den dobj/ihn} nicht reinigen{*}. '
    cannotCleanWithMsg =
        '{Du/er} {koennt} mit {dem iobj/ihm} nichts reinigen{*}. '

    /* cannot attach key (dobj) to (iobj) */
    cannotAttachKeyToMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht an {dem iobj/ihm} befestigen{*}. '

    /* actor cannot sleep */
    cannotSleepMsg = '{Du/er} {muss} jetzt nicht schlafen{*}. '

    /* cannot sit/lie/stand/get on/get out of */
    cannotSitOnMsg =
        '{Du/er} {koennt} nicht {aufdem dobj} sitzen{*}. '
    cannotLieOnMsg =
        '{Du/er} {koennt} nicht {aufdem dobj} liegen{*}. '
    cannotStandOnMsg = '{Du/er} {koennt} nicht {aufdem dobj} stehen{*}. '
    cannotBoardMsg = '{Du/er} {koennt} nicht {aufden dobj} steigen{*}. '
    cannotUnboardMsg = '{Du/er} {koennt} {den dobj/ihn} nicht verlassen{*}. '
    cannotGetOffOfMsg = '{Du/er} {koennt} nicht von {dem dobj/ihm} steigen{*}. '

    /* standing on a PathPassage */
    cannotStandOnPathMsg = 'Wenn {du/er} {dem dobj/ihm} folgen {will}{*},
        sag es einfach. '

    /* cannot sit/lie/stand on something being held */
    cannotEnterHeldMsg =
        'Das geht nicht, solange {du/er} {den dobj/ihn} in der Hand {!*}{hat}. '

    /* cannot get out (of current location) */
    cannotGetOutMsg = '{Hier|Dort} {gibt singular} es nichts zu verlassen{*}. '

    /* actor is already in a location */
    alreadyInLocMsg = '{Du/er} {ist} schon {in dobj}{*}. '

    /* actor is already standing/sitting on/lying on */
    alreadyStandingMsg = '{Du/er} {steht} schon{*}. '
    alreadyStandingOnMsg = '{Du/er} {steht} schon {auf dobj}{*}. '
    alreadySittingMsg = '{Du/er} {sitzt} schon{*}. '
    alreadySittingOnMsg = '{Du/er} {sitzt} schon {auf dobj}{*}. '
    alreadyLyingMsg = '{Du/er} {liegt} schon{*}. '
    alreadyLyingOnMsg = '{Du/er} {liegt} schon {auf dobj}{*}. '

    /* getting off something you're not on */
    notOnPlatformMsg = '{Du/er} {ist} nicht {auf dobj}{*}. '

    /* no room to stand/sit/lie on dobj */
    noRoomToStandMsg =
        'Da {ist singular} kein Platz{*}, um {auf dobj} zu stehen. '
    noRoomToSitMsg =
        'Da {ist singular} kein Platz{*}, um {auf dobj} zu sitzen. '
    noRoomToLieMsg =
        'Da {ist singular} kein Platz{*}, um {auf dobj} zu liegen. '

    /* default report for standing up/sitting down/lying down */
    okayPostureChangeMsg(posture)
    { return 'In Ordnung, {du/er} ' + posture.msgVerbT + ' nun{*}. '; } //vorher posture.participle

    /* default report for standing/sitting/lying in/on something */
    roomOkayPostureChangeMsg(posture, obj)
    {
        gMessageParams(obj);
        return 'In Ordnung, {du/er} ' + posture.msgVerbT + ' nun {auf obj}{*}. '; //vorher posture.participle
    }

    /* default report for getting off of a platform */
    okayNotStandingOnMsg = 'In Ordnung, {du/er} {verlaesst} {den dobj/ihn}{*}. '

    /* cannot fasten/unfasten */ // -- We have no fasten / unfasten in german
    cannotFastenMsg = '{Du/er} {cannot} fasten {the dobj/him}. '
    cannotFastenToMsg =
        '{Du/er} {cannot} fasten anything to {the iobj/him}. '
    cannotUnfastenMsg = '{Du/er} {cannot} unfasten {the dobj/him}. '
    cannotUnfastenFromMsg =
        '{Du/er} {cannot} unfasten anything from {the iobj/him}. '

    /* cannot plug/unplug */
    cannotPlugInMsg = '{Du/er} {sieht} keine Möglichkeit{*}, {den dobj/ihn} irgendwo einzustecken. '
    cannotPlugInToMsg =
        '{Du/er} {sieht} keine Möglichkeit{*}, etwas in {den iobj/ihn} zu stecken. '
    cannotUnplugMsg = '{Du/er} {sieht} keine Möglichkeit{*}, {den dobj/ihn} auszustecken. '
    cannotUnplugFromMsg =
        '{Du/er} {sieht} keine Möglichkeit{*}, etwas aus {dem iobj/ihm} zu ziehen. '

    /* cannot screw/unscrew */
    cannotScrewMsg = '{Du/er} {koennt} {den dobj/ihn} nicht zuschrauben{*}. '
    cannotScrewWithMsg =
        '{Du/er} {koennt} nichts mit {dem iobj/ihm} festschrauben{*}. '
    cannotUnscrewMsg = '{Du/er} {koennt} {den dobj/ihn} nicht aufschrauben{*}. '
    cannotUnscrewWithMsg =
        '{Du/er} {koennt} nichts mit {dem iobj/ihm} aufschrauben{*}. '

    /* cannot enter/go through */
    cannotEnterMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht betreten{*}. '
    cannotGoThroughMsg =
        '{Du/er} {koennt} nicht durch {den dobj/ihn} gehen{*}. '
        
    /* can't throw something at itself */
    cannotThrowAtSelfMsg =
        '{Du/er} {koennt} {den dobj/ihn} nicht auf {sichselbst} selbst werfen{*}. '

    /* can't throw something at an object inside itself */
    cannotThrowAtContentsMsg = 'Dazu {muss actor} {du/er} erst {den iobj/ihn}
        von {dem dobj/ihm} entfernen{*}. '

    /* shouldn't throw something at the floor */
    shouldNotThrowAtFloorMsg =
        '{Du/er} {koennt} {den dobj/ihn} stattdessen einfach ablegen{*}. '

    /* THROW <obj> <direction> isn't supported; use THROW AT instead */
    dontThrowDirMsg =
        ('<.parser>Sag bitte genauer, worauf {du/er}'
         + ' {den dobj/ihn} werfen ' 
         + (gActor.referralPerson == FirstPerson ? ' soll' : 
            gActor.referralPerson == ThirdPerson ? ' soll' : 
            gActor.referralPerson == FourthPerson ? ' sollen' : 
            gActor.referralPerson == FifthPerson ? ' wollt' : 
            gActor.referralPerson == SixthPerson ? ' sollen' : ' willst') + '.<./parser> ')

    /* thrown object bounces off target (short report) */
    throwHitMsg(projectile, target)
    {
        gMessageParams(projectile, target);
        return '{Der projectile/er} {trifft} {den target/ihn} ohne nennenswerte Wirkung{*}. ';
    }

    /* thrown object lands on target */
    throwFallMsg(projectile, target)
    {
        gMessageParams(projectile, target);
        return '{Der projectile/er} {faellt} auf {den target/ihn}{*}. ';
    }

    /* thrown object bounces off target and falls to destination */
    throwHitFallMsg(projectile, target, dest)
    {
        gMessageParams(projectile, target);
        return '{Der projectile/er} {trifft} {den target/ihn}{*}
            und {faellt projectile} '
            + dest.putInName + '{*}. ';
    }

    /* thrown object falls short of distant target (sentence prefix only) */
    throwShortMsg(projectile, target)
    {
        gMessageParams(projectile, target);
        return '{Der projectile/er} {faellt} vor '
               + '{den target/ihn}{*}. ';
    }
        
    /* thrown object falls short of distant target */
    throwFallShortMsg(projectile, target, dest)
    {
        gMessageParams(projectile, target);
        return '{Der projectile/er} {faellt} vor {dem target/ihm} auf den Boden ' 
            + dest.desName + '{*}. ';
    }

    /* target catches object */
    throwCatchMsg(obj, target)
    {
        return '\^' + target.derName + ' '
            + target.verbZuFangen 
            + ' ' + obj.denNameObj + '{*}. ';
    }

    /* we're not a suitable target for THROW TO (because we're not an NPC) */
    cannotThrowToMsg = '{Du/er} {koennt} nichts auf {den iobj/ihn} werfen{*}. '

    /* target does not want to catch anything */
    willNotCatchMsg(catcher)
    {
        return '\^' + catcher.derName + ' ' 
            + catcher.verbZuSehen + ' nicht so aus{-*}, als ob ' + catcher.itNom 
            + ' etwas fangen will. ';
    }

    /* cannot kiss something */
    cannotKissMsg = '{Den dobj/ihn} zu küssen {bringt singular} nichts{*}. '

    /* person uninterested in being kissed */
    cannotKissActorMsg
    = '{Der dobj/er} {will} das sicher nicht{*}. '

    /* cannot kiss yourself */
    cannotKissSelfMsg = '{Du/er} {koennt} {dich/sich} nicht küssen{*}. '

    /* it is now dark at actor's location */
    newlyDarkMsg = 'Es {ist singular} {jetzt|daraufhin} stockdunkel{*}. '
;

/*
 *   Non-player character verb messages.  By default, we inherit all of
 *   the messages defined for the player character, but we override some
 *   that must be rephrased slightly to make sense for NPC's.
 */
npcActionMessages: playerActionMessages
    /* "wait" */
    timePassesMsg = '{Du/er} {wartet}{*}. '

    /* trying to move a Fixture/Immovable */
    cannotMoveFixtureMsg = '{Du/er} {koennt} {den dobj/ihn} nicht bewegen{*}. '
    cannotMoveImmovableMsg = '{Du/er} {koennt} {den dobj/ihn} nicht bewegen{*}. '

    /* trying to take/move/put a Heavy object */
    cannotTakeHeavyMsg =
        '{Der dobj/er} {ist} zu schwer{*}, um ihn zu nehmen. '
    cannotMoveHeavyMsg =
        '{Der dobj/er} {ist} zu schwer{*}, um ihn zu bewegen. '
    cannotPutHeavyMsg =
        '{Der dobj/er} {ist} zu schwer{*}, um ihn zu bewegen. '

    /* trying to move a component object */
    cannotMoveComponentMsg(loc)
    {
        return '{Du/er} {koennt} das nicht tun{*}, weil {der dobj/er} 
            Teil von ' + loc.demNameObj + '{!*}{ist dobj}. ';
    }

    /* default successful 'take' response */
    okayTakeMsg = '{Du/er} {nimmt} {den dobj/ihn}{*}. '

    /* default successful 'drop' response */
    okayDropMsg = '{Du/er} {legt} {den dobj/ihn} hin{-*}. '

    /* default successful 'put in' response */
    okayPutInMsg = '{Du/er} {legt} {den dobj/ihn} in {den iobj/ihn}{*}. '

    /* default successful 'put on' response */
    okayPutOnMsg = '{Du/er} {legt} {den dobj/ihn} auf {den iobj/ihn}{*}. '

    /* default successful 'put under' response */
    okayPutUnderMsg =
        '{Du/er} {legt} {den dobj/ihn} unter {den iobj/ihn}{*}. '

    /* default successful 'put behind' response */
    okayPutBehindMsg =
        '{Du/er} {legt} {den dobj/ihn} hinter {den iobj/ihn}{*}. '

    /* default succesful response to 'wear obj' */
    okayWearMsg =
        '{Du/er} {zieht} {den dobj/ihn} an{-*}. '

    /* default successful response to 'doff obj' */
    okayDoffMsg = '{Du/er} {zieht} {den dobj/ihn} aus{-*}. '

    /* default successful responses to open/close */
    okayOpenMsg = '{Du/er} {oeffnet} {den dobj/ihn}{*}. '
    okayCloseMsg = '{Du/er} {schliesst} {den dobj/ihn}{*}. '

    /* default successful responses to lock/unlock */
    okayLockMsg = '{Du/er} {schliesst} {den dobj/ihn} auf{-*}. '
    okayUnlockMsg = '{Du/er} {schliesst} {den dobj/ihn} zu{-*}. '

    /* push/pull/move with no effect */
    pushNoEffectMsg = '{Du/er} {versucht}{*} {den dobj/ihn} zu schieben,
                      aber ohne nennenswerte Wirkung. '
    pullNoEffectMsg = '{Du/er} {versucht}{*} {den dobj/ihn} zu ziehen,
                      aber ohne nennenswerte Wirkung. '
    moveNoEffectMsg = '{Du/er} {versucht}{*} {den dobj/ihn} zu bewegen,
                      aber ohne nennenswerte Wirkung. '
    moveToNoEffectMsg = '{Du/er} {laesst} {den dobj/ihn} besser{*}, wo {er/sie} {!*}{ist}. '

    whereToGoMsg =
        'Sag bitte genauer, in welche Richtung {du/er} gehen ' + (gActor.isPlural ? 'sollen' : 'soll') + '. '

    /* object is too large for container */
    tooLargeForContainerMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {ist} zu groß für {den cont/ihn}{*}. ';
    }

    /* object is too large for underside */
    tooLargeForUndersideMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {passt} nicht unter {den cont/ihn}{*}. ';
    }

    /* object is too large to fit behind something */
    tooLargeForRearMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der obj/er} {passt} nicht hinter {den cont/ihn}{*}. ';
    }

    /* container doesn't have room for object */
    containerTooFullMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return '{Der cont/er} {ist} schon zu voll für {den obj/ihn}{*}. ';
    }

    /* surface doesn't have room for object */
    surfaceTooFullMsg(obj, cont)
    {
        gMessageParams(obj, cont);
        return 'Für {den obj/ihn} {ist} kein Platz auf {dem cont/ihm}{*}. ';
    }

    /* the dobj doesn't fit on this keyring */
    objNotForKeyringMsg = '{Der dobj/er} {passt} nicht an {den iobj/ihn}{*}. '

    /* taking dobj from iobj, but dobj isn't in iobj */
    takeFromNotInMsg = 'Aber {der dobj/er} {ist} gar nicht in {dem iobj/ihm}{*}. '

    /* taking dobj from surface, but dobj isn't on iobj */
    takeFromNotOnMsg = 'Aber {der dobj/er} {ist} gar nicht auf {dem iobj/ihm}{*}. '

    /* taking dobj under something, but dobj isn't under iobj */
    takeFromNotUnderMsg = 'Aber {der dobj/er} {ist} gar nicht unter {dem iobj/ihm}{*}. '

    /* taking dobj from behind something, but dobj isn't behind iobj */
    takeFromNotBehindMsg = 'Aber {der dobj/er} {ist} gar nicht hinter {dem iobj/ihm}{*}. '

    /* cannot jump off (with no direct object) from here */
    cannotJumpOffHereMsg = '{Hier|Dort} {koennt dobj} {der dobj/er} nicht hinunter springen{*}. '

    /* should not break object */
    shouldNotBreakMsg = '{Du/er} {will} {den dobj/ihn} nicht beschädigen{*}. '

    /* report for standing up/sitting down/lying down */
    okayPostureChangeMsg(posture)
        { return '{Du/er} ' + posture.msgVerbT + ' nun{*}. '; }

    /* report for standing/sitting/lying in/on something */
    roomOkayPostureChangeMsg(posture, obj)
    {
        gMessageParams(obj);
        return '{Du/er} ' + posture.msgVerbT + ' nun {auf obj}{*}. ';
    }

    /* report for getting off a platform */
    okayNotStandingOnMsg = '{Du/er} {verlaesst} {den dobj/ihn}{*}. '

    /* default 'turn to' acknowledgment */
    okayTurnToMsg(val)
        { return '{Du/er} {stellt} {den dobj/ihn} auf ' + val + '{*}. '; }

    /* default 'push button' acknowledgment */
    okayPushButtonMsg = '{Du/er} {drueckt} {den dobj/ihn}{*}. '

    /* default acknowledgment for switching on/off */
    okayTurnOnMsg = '{Du/er} {schaltet} {den dobj/ihn} an{-*}. '
    okayTurnOffMsg = '{Du/er} {schaltet} {den dobj/ihn} aus{-*}. '

    /* the key (iobj) does not fit the lock (dobj) */
    keyDoesNotFitLockMsg = '{Du/er} {probiert} {den iobj/ihn}{*}, aber
        {er iobj/sie} {passt} nicht ins Schloss{*}. '

    /* acknowledge entering "follow" mode */
    okayFollowModeMsg = '<q>In Ordnung, Ich werde {dem dobj/ihm} folgen.</q> '

    /* note that we're already in "follow" mode */
    alreadyFollowModeMsg = '<q>Ich folge schon {dem dobj/ihm}.</q> '

    /* extinguishing a candle */
    okayExtinguishCandleMsg = '{Du/er} {loescht} {den dobj/ihn}{*}. '

    /* acknowledge attachment */
    okayAttachToMsg =
        '{Du/er} {verbindet} {den dobj/ihn} mit {dem iobj/ihm}{*}. '

    /* acknowledge detachment */
    okayDetachFromMsg =
        '{Du/er} {loest} {den dobj/ihn} von {dem iobj/ihm}{*}. '

    /*
     *   the PC's responses to conversational actions applied to oneself
     *   need some reworking for NPC's 
     */
    cannotTalkToSelfMsg = 'Mit {dirselbst} zu reden, {bringt} wenig{*}. '
    cannotAskSelfMsg = '{Dichselbst} danach zu fragen, {bringt} wenig{*}. '
    cannotAskSelfForMsg = '{Dichselbst} darum zu bitten, {bringt} wenig{*}. '
    cannotTellSelfMsg = '{Dirselbst} davon zu erzählen, {bringt} wenig{*}. '
    cannotGiveToSelfMsg = '{Den dobj/ihn} {dirselbst} zu geben, {bringt} wenig{*}. '
    cannotShowToSelfMsg = '{Den dobj/ihn} {dirselbst} zu zeigen, {bringt} wenig{*}. '
;   

/* ------------------------------------------------------------------------ */
/*
 *   Standard tips
 */

scoreChangeTip: Tip
    "Wenn du zukünftig nicht mehr über Änderungen des Punktestands informiert 
    werden möchtest, tippe <<aHref('nachricht aus', 'NACHRICHT AUS', 'Schalte Punktebenachrichtigung aus')>>."
;

footnotesTip: Tip
    "Eine Nummer in eckigen [Klammern] bezieht sich auf eine Fußnote, die du
    lesen kannst, wenn du FUSSNOTE gefolgt von der Nummer tippst:
    <<aHref('Fußnote 1', 'FUSSNOTE 1', 'Zeige Fußnote [1]')>>, zum Beispiel.
    Fußnoten enthalten zusätzliche Hintergrundinformationen, sind aber für die
    eigentliche Geschichte nicht zwingend notwendig. Wenn du die Fußnoten nicht
    sehen willst, tippe <<aHref('Fußnoten', 'FUSSNOTEN', 'Stelle Fußnoten an oder aus')>>."
;

oopsTip: Tip
    "Wenn das ein Tippfehler war, kannst du ihn korrigieren, indem du UPS, gefolgt 
    von dem korrigierten Wort eingibst."
;

fullScoreTip: Tip
    "Um eine detallierte Aufstellung der Punkte zu sehen, tippe
    <<aHref('volle Punkte', 'VOLLE PUNKTE')>>."
;

exitsTip: Tip
    "Du kannst mit dem Befehl AUSGÄNGE die Anzeige der Ausgänge ändern.
    <<aHref('Ausgänge Status', 'AUSGÄNGE STATUS',
            'Zeige Ausgänge in Statuszeile')>>
    zeige die Ausgänge in der Status Zeile an,
    <<aHref('Ausgänge Raum', 'AUSGÄNGE RAUM', 'Zeige Ausgänge in Raumbeschreibung')>>
    zeigt die Ausgänge in der Raumbeschreibung an,
    <<aHref('Ausgänge ein', 'AUSGÄNGE EIN', 'Zeige Ausgänge in Statuszeile und Raumbeschreibung')>>
    zeigt beides an und
    <<aHref('Ausgänge aus', 'AUSGÄNGE AUS', 'Schalte die Anzeige der Ausgänge aus')>>
    schaltet beide Anzeigen aus."
;

undoTip: Tip
    "Wenn sich heraustsellt, dass ein Zug nicht das von dir gewünschte
    Ergebnis bringt, kannst du ihn jederzeit zurücknehmen, wenn
    du <<aHref('undo', 'UNDO','Nimm den letzten Befehl zurück')>> tippst.
    Du kannst UNDO wiederholt verwenden, um mehrere Züge in Folge
    zurückzunehmen. "
;


/* ------------------------------------------------------------------------ */
/*
 *   Listers
 */

/*
 *   The basic "room lister" object - this is the object that we use by
 *   default with showList() to construct the listing of the portable
 *   items in a room when displaying the room's description.  
 */
roomLister: Lister
    /* show the prefix/suffix in wide mode */
    showListPrefixWide(itemCount, pov, parent) { "{Du/er} {sieht}{+*} {hier|dort} <<withListCaseAccusative>><<withListArtIndefinite>>"; }
    showListSuffixWide(itemCount, pov, parent) { "{**}. "; }

    /* show the tall prefix */
    showListPrefixTall(itemCount, pov, parent) { "{Du/er} {sieht}{*}:<<withListCaseAccusative>><<withListArtIndefinite>>"; }
;

/*
 *   The basic room lister for dark rooms 
 */
darkRoomLister: Lister
    showListPrefixWide(itemCount, pov, parent)
        { "In der Dunkelheit {koennt actor} {du/er} <<withListCaseAccusative>><<withListArtIndefinite>>"; }

    showListSuffixWide(itemCount, pov, parent) { "sehen{*}. "; }

    showListPrefixTall(itemCount, pov, parent)
        { "In der Dunkelheit {sieht actor} {du/er}{*}:<<withListCaseAccusative>><<withListArtIndefinite>>"; }
;

/*
 *   A "remote room lister".  This is used to describe the contents of an
 *   adjoining room.  For example, if an actor is standing in one room,
 *   and can see into a second top-level room through a window, we'll use
 *   this lister to describe the objects the actor can see through the
 *   window. 
 */
class RemoteRoomLister: Lister
    construct(room) { remoteRoom = room; }
    
    showListPrefixWide(itemCount, pov, parent)
        { "\^<<remoteRoom.inRoomName(pov)>>, {sieht actor} {du/er} <<withListCaseAccusative>><<withListArtIndefinite>>"; }
    showListSuffixWide(itemCount, pov, parent)
        { "{*}. "; }

    showListPrefixTall(itemCount, pov, parent)
        { "\^<<remoteRoom.inRoomName(pov)>>, {sieht actor} {du/er}{*}:<<withListCaseAccusative>><<withListArtIndefinite>>"; }

    /* the remote room we're viewing */
    remoteRoom = nil
;

/*
 *   A simple customizable room lister.  This can be used to create custom
 *   listers for things like remote room contents listings.  We act just
 *   like any ordinary room lister, but we use custom prefix and suffix
 *   strings provided during construction.  
 */
class CustomRoomLister: Lister
    construct(prefix, suffix)
    {
        prefixStr = prefix;
        suffixStr = suffix;
    }

    showListPrefixWide(itemCount, pov, parent) { "<<prefixStr>> "; }
    showListSuffixWide(itemCount, pov, parent) { "<<suffixStr>> "; }
    showListPrefixTall(itemCount, pov, parent) { "<<prefixStr>>:"; }

    /* our prefix and suffix strings */
    prefixStr = nil
    suffixStr = nil
;

/*
 *   Single-list inventory lister.  This shows the inventory listing as a
 *   single list, with worn items mixed in among the other inventory items
 *   and labeled "(being worn)".  
 */
actorSingleInventoryLister: InventoryLister
    showListPrefixWide(itemCount, pov, parent)
        { "<<buildSynthParam('Du/er', parent)>><<withListCaseAccusative>><<withListArtIndefinite>> {hat} "; }
    showListSuffixWide(itemCount, pov, parent)
        { "bei {dir}{*}. "; }

    showListPrefixTall(itemCount, pov, parent)
        { "<<buildSynthParam('Du/er', parent)>><<withListCaseAccusative>><<withListArtIndefinite>> {hat} Folgendes bei sich{*}:"; }
    showListContentsPrefixTall(itemCount, pov, parent)
        { "<<buildSynthParam('Einer/er', parent)>>,<<withListCaseAccusative>><<withListArtIndefinite>> der Folgendes bei {dir} {hat}{*}:"; }

    showListEmpty(pov, parent)
        { "<<buildSynthParam('Du/er', parent)>> {hat} nichts bei {dir}{*}. "; }
;

/*
 *   Standard inventory lister for actors - this will work for the player
 *   character and NPC's as well.  This lister uses a "divided" format,
 *   which segregates the listing into items being carried and items being
 *   worn.  We'll combine the two lists into a single sentence if the
 *   overall list is short, otherwise we'll show two separate sentences for
 *   readability.  
 */
actorInventoryLister: DividedInventoryLister
    /*
     *   Show the combined inventory listing, putting together the raw
     *   lists of the items being carried and the items being worn. 
     */

    // -- German: the following code added to provide an own function which
    // -- sets the accusative by default (to provide confusion with other
    // -- lists and cases ...
    
    showList(pov, parent, lst, options, indent, infoTab, parentGroup)
    {
        withListArtIndefinite;
        withListCaseAccusative;   // -- German: set list case to accusative, before
                            // -- buildung the strings ...
        /* 
         *   If this is a 'tall' listing, use the normal listing style; for
         *   a 'wide' listing, use our special segregated style.  If we're
         *   being invoked recursively to show a contents listing, we
         *   similarly want to use the base handling. 
         */
        if ((options & (ListTall | ListContents)) != 0)
        {
            /* inherit the standard behavior */
            inherited(pov, parent, lst, options, indent, infoTab,
                      parentGroup);
        }
        else
        {
            local carryingLst, wearingLst;
            local carryingStr, wearingStr;

            /* divide the lists into 'carrying' and 'wearing' sublists */
            carryingLst = new Vector(32);
            wearingLst = new Vector(32);
            foreach (local cur in lst)
                (cur.isWornBy(parent) ? wearingLst : carryingLst).append(cur);

            /* generate and capture the 'carried' listing */
            carryingStr = outputManager.curOutputStream.captureOutput({:
                carryingLister.showList(pov, parent, carryingLst, options,
                                        indent, infoTab, parentGroup)});

            /* generate and capture the 'worn' listing */
            wearingStr = outputManager.curOutputStream.captureOutput({:
                wearingLister.showList(pov, parent, wearingLst, options,
                                       indent, infoTab, parentGroup)});

            /* generate the combined listing */
            showCombinedInventoryList(parent, carryingStr, wearingStr);

            /* 
             *   Now show the out-of-line contents for the whole list, if
             *   appropriate.  We save this until after showing both parts
             *   of the list, to keep the direct inventory parts together
             *   at the beginning of the output.  
             */
            if ((options & ListRecurse) != 0
                && indent == 0
                && (options & ListContents) == 0)
            {
                /* show the contents of each object we didn't list */
                showSeparateContents(pov, lst, options | ListContents,
                                     infoTab);
            }
        }
    }

    showCombinedInventoryList(parent, carrying, wearing)
    {
        //withListCaseAccusative; // -- German: we set the inventory list to accusative by default: this
        /* if one or the other sentence is empty, the format is simple */
        if (carrying == '' && wearing == '')
        {
            /* the parent is completely empty-handed */
            showInventoryEmpty(parent);
        }
        else if (carrying == '')
        {
            /* the whole list is being worn */
            showInventoryWearingOnly(parent, wearing);
        }
        else if (wearing == '')
        {
            /* the whole list is being carried */
            showInventoryCarryingOnly(parent, carrying);
        }
        else
        {
            /*
             *   Both listings are populated.  Count the number of
             *   comma-separated or semicolon-separated phrases in each
             *   list.  This will give us an estimate of the grammatical
             *   complexity of each list.  If we have very short lists, a
             *   single sentence will be easier to read; if the lists are
             *   long, we'll show the lists in separate sentences.  
             */
            if (countPhrases(carrying) + countPhrases(wearing)
                <= singleSentenceMaxNouns)
            {
                /* short enough: use a single-sentence format */
                showInventoryShortLists(parent, carrying, wearing);
            }
            else
            {
                /* long: use a two-sentence format */
                showInventoryLongLists(parent, carrying, wearing);
            }
        }
    }

    /*
     *   Count the noun phrases in a string.  We'll count the number of
     *   elements in the list as indicated by commas and semicolons.  This
     *   might not be a perfect count of the actual number of noun phrases,
     *   since we could have commas setting off some other kind of clauses,
     *   but it nonetheless will give us a good estimate of the overall
     *   complexity of the text, which is what we're really after.  The
     *   point is that we want to break up the listings if they're long,
     *   but combine them into a single sentence if they're short.  
     */
    countPhrases(txt)
    {
        local cnt;
        
        /* if the string is empty, there are no phrases at all */
        if (txt == '')
            return 0;

        /* a non-empty string has at least one phrase */
        cnt = 1;

        /* scan for commas and semicolons */
        for (local startIdx = 1 ;;)
        {
            local idx;
            
            /* find the next phrase separator */
            idx = rexSearch(phraseSepPat, txt, startIdx);

            /* if we didn't find it, we're done */
            if (idx == nil)
                break;

            /* count it */
            ++cnt;

            /* continue scanning after the separator */
            startIdx = idx[1] + idx[2];
        }

        /* return the count */
        return cnt;
    }

    phraseSepPat = static new RexPattern(',(?! und )|;| und |<rparen>')

    /*
     *   Once we've made up our mind about the format, we'll call one of
     *   these methods to show the final sentence.  These are all separate
     *   methods so that the individual formats can be easily tweaked
     *   without overriding the whole combined-inventory-listing method. 
     */
    showInventoryEmpty(parent)
    {
        /* empty inventory */
        "<<buildSynthParam('Einer/er', parent)>> {hat} nichts bei {dir/sich}{*}. ";
    }
    showInventoryWearingOnly(parent, wearing)
    {
        /* we're carrying nothing but wearing some items */
        "<<buildSynthParam('Du/er', parent)>> {hat} nichts bei {dir/sich}{*}
        und {hat} <<wearing>> angezogen{*}. ";
    }
    showInventoryCarryingOnly(parent, carrying)
    {
        /* we have only carried items to report */
        "<<buildSynthParam('Du/er', parent)>> {hat} <<carrying>> bei {dir/sich}{*}. ";
    }
    showInventoryShortLists(parent, carrying, wearing)
    {
        local nm = gSynthMessageParam(parent);
        
        /* short lists - combine carried and worn in a single sentence */
        "<<buildParam('Du/er', nm)>> {hat} <<carrying>> bei {dir/sich}{*},
        und <<buildParam('hat', nm)>>{subj} <<wearing>> angezogen{*}. ";
    }
    showInventoryLongLists(parent, carrying, wearing)
    {
        local nm = gSynthMessageParam(parent);

        /* long lists - show carried and worn in separate sentences */
        "<<buildParam('Du/er', nm)>> {hat} <<carrying>> bei {dir/sich}{*}.
        <<buildParam('Du/er', nm)>> {hat} <<wearing>> angezogen{*}. ";
    }

    /*
     *   For 'tall' listings, we'll use the standard listing style, so we
     *   need to provide the framing messages for the tall-mode listing.  
     */
    showListPrefixTall(itemCount, pov, parent)
        { "<<buildSynthParam('Du/er', parent)>> {hat} bei {dir/sich}{*}:"; }
    showListContentsPrefixTall(itemCount, pov, parent)
        { "<<buildSynthParam('Einer/er', parent)>>, der Folgendes bei {dir/sich} {hat}{*}:"; }
    showListEmpty(pov, parent)
        { "<<buildSynthParam('Du/er', parent)>> {hat} nichts bei {dir/sich}{*}. "; }
;

/*
 *   Special inventory lister for non-player character descriptions - long
 *   form lister.  This is used to display the inventory of an NPC as part
 *   of the full description of the NPC.
 *   
 *   This long form lister is meant for actors with lengthy descriptions.
 *   We start the inventory listing on a new line, and use the actor's
 *   full name in the list preface.  
 */
actorHoldingDescInventoryListerLong: actorInventoryLister
    showInventoryEmpty(parent)
    {
        /* empty inventory - saying nothing in an actor description */
    }
    showInventoryWearingOnly(parent, wearing)
    {
        /* we're carrying nothing but wearing some items */
        "<.p><<buildSynthParam('Der/er', parent)>> {hat}
        <<wearing>> angezogen{*}. ";
    }
    showInventoryCarryingOnly(parent, carrying)
    {
        /* we have only carried items to report */
        "<.p><<buildSynthParam('Du/er', parent)>> {hat} <<carrying>> bei {dir/sich}{*}. ";
    }
    showInventoryShortLists(parent, carrying, wearing)
    {
        local nm = gSynthMessageParam(parent);

        /* short lists - combine carried and worn in a single sentence */
        "<.p><<buildParam('Du/er', nm)>> {hat} <<carrying>> bei {dir/sich}{*},
        und <<buildParam('hat', nm)>>{subj} <<wearing>> angezogen{*}. ";
    }
    showInventoryLongLists(parent, carrying, wearing)
    {
        local nm = gSynthMessageParam(parent);

        /* long lists - show carried and worn in separate sentences */
        "<.p><<buildParam('Du/er', nm)>> {hat} <<carrying>> bei {dir/sich}{*}.
        <<buildParam('Einer/er', nm)>> {hat} <<wearing>> angezogen{*}. ";
    }
;

/* short form of non-player character description inventory lister */
actorHoldingDescInventoryListerShort: actorInventoryLister
    showInventoryEmpty(parent)
    {
        /* empty inventory - saying nothing in an actor description */
    }
    showInventoryWearingOnly(parent, wearing)
    {
        /* we're carrying nothing but wearing some items */
        "<<buildSynthParam('Einer/er', parent)>> {hat} <<wearing>> angezogen{*}. ";
    }
    showInventoryCarryingOnly(parent, carrying)
    {
        /* we have only carried items to report */
        "<<buildSynthParam('Einer/er', parent)>> {hat} <<carrying>> bei {sich}{*}. ";
    }
    showInventoryShortLists(parent, carrying, wearing)
    {
        local nm = gSynthMessageParam(parent);

        /* short lists - combine carried and worn in a single sentence */
        "<<buildParam('Einer/er', nm)>> {hat} <<carrying>> bei {sich}{*} und
        <<buildParam('hat', nm)>>{subj} <<wearing>> angezogen{*}. ";
    }
    showInventoryLongLists(parent, carrying, wearing)
    {
        local nm = gSynthMessageParam(parent);

        /* long lists - show carried and worn in separate sentences */
        "<<buildParam('Einer/er', nm)>> {hat} <<carrying>> bei {sich}{*}.
        <<buildParam('Einer/er', nm)>> {hat} <<wearing>> angezogen{*}. ";
    }
;

/*
 *   Base contents lister for things.  This is used to display the contents
 *   of things shown in room and inventory listings; we subclass this for
 *   various purposes 
 */
class BaseThingContentsLister: Lister
    showListPrefixWide(itemCount, pov, parent)
        { "\^In <<parent.demName>> <<itemCount > 1 ? '{befindet plural}'
              : '{befindet singular}'>> sich <<withListCaseNominative>><<withListArtIndefinite>>"; }
    showListSuffixWide(itemCount, pov, parent)
        { "<<withListCaseAccusative>><<withListArtIndefinite>>{*}. "; }
    showListPrefixTall(itemCount, pov, parent)
        { "\^In <<parent.demName>><<withListCaseNominative>><<withListArtIndefinite>> <<itemCount > 1 ? '{befindet plural}'
              : '{befindet singular}'>> sich{*}:"; }
    showListSuffixTall(itemCount, pov, parent) // -- German: added to get the default listcase accusative!
        { "<<withListCaseAccusative>><<withListArtIndefinite>>"; }
    showListContentsPrefixTall(itemCount, pov, parent)
        { "in <<parent.einemName>> <<itemCount > 1 ? '{befindet plural}'
              : '{befindet singular}'>> sich{*}:"; }
    showListContentsSuffixTall(itemCount, pov, parent) // -- German: added to get the default listcase accusative!
        { "<<withListCaseAccusative>><<withListArtIndefinite>>"; }
;

// -- German: We have to decide when to use "befindet" or "befinden":
// -- This is true either for itemcount > 1 or when the only thing inside is plural-named.


/*
 *   Contents lister for things.  This is used to display the second-level
 *   contents lists for things listed in the top-level list for a room
 *   description, inventory listing, or object description.  
 */
thingContentsLister: ContentsLister, BaseThingContentsLister
;

/*
 *   Contents lister for descriptions of things - this is used to display
 *   the contents of a thing as part of the long description of the thing
 *   (in response to an "examine" command); it differs from a regular
 *   thing contents lister in that we use a pronoun to refer to the thing,
 *   rather than its full name, since the full name was probably just used
 *   in the basic long description.  
 */
thingDescContentsLister: DescContentsLister, BaseThingContentsLister
    showListPrefixWide(itemCount, pov, parent)
        { "\^<<parent.itNom>> <<parent.verbZuEnthalten>><<withListCaseAccusative>><<withListArtIndefinite>> "; }
    showListSuffixWide(itemCount, pov, parent)
        { "<<parent.dummyVerb>>. "; }
;
  
/*
 *   Contents lister for openable things.
 */
openableDescContentsLister: thingContentsLister
    showListEmpty(pov, parent)
    {
        "\^<<parent.openStatus>>. ";
    }
    showListPrefixWide(itemCount, pov, parent)
    {
        gMessageParams(parent);
        "\^<<parent.openStatus>>,<<withListCaseAccusative>><<withListArtIndefinite>> und {subj parent} {enthaelt} ";
    }
    showListSuffixWide(itemCount, pov, parent)
        { "<<withListCaseAccusative>><<withListArtIndefinite>>{*}. "; }
;

/*
 *   Base contents lister for "LOOK <PREP>" commands (LOOK IN, LOOK UNDER,
 *   LOOK BEHIND, etc).  This can be subclasses for the appropriate LOOK
 *   <PREP> command matching the container type - LOOK UNDER for
 *   undersides, LOOK BEHIND for rear containers, etc.  To use this class,
 *   combine it via multiple inheritance with the appropriate
 *   Base<Prep>ContentsLister for the preposition type.  
 */
class LookWhereContentsLister: DescContentsLister
    showListEmpty(pov, parent)
    {
        /* show a default message indicating the surface is empty */
        gMessageParams(parent);
        defaultDescReport('{Du/er} {sieht} nichts ' + parent.objInPrep
                          + ' {dem parent/ihm}{*}. ');
    }
;

/*
 *   Contents lister for descriptions of things whose contents are
 *   explicitly inspected ("look in").  This differs from a regular
 *   contents lister in that we explicitly say that the object is empty if
 *   it's empty.
 */
thingLookInLister: LookWhereContentsLister, BaseThingContentsLister
    showListEmpty(pov, parent)
    {
        /*
         *   Indicate that the list is empty, but make this a default
         *   descriptive report.  This way, if we report any special
         *   descriptions for items contained within the object, we'll
         *   suppress this default description that there's nothing to
         *   describe, which is clearly wrong if there are
         *   specially-described contents. 
         */
        gMessageParams(parent);
        defaultDescReport('{Du/er} {sieht} nichts Ungewöhnliches
            in {dem parent/ihm}{*}. ');
    }
;

/*
 *   Default contents lister for newly-revealed objects after opening a
 *   container.  
 */
openableOpeningLister: BaseThingContentsLister
    showListEmpty(pov, parent) { }
    showListPrefixWide(itemCount, pov, parent)
    {
        /*
         *   This list is, by default, generated as a replacement for the
         *   default "Opened" message in response to an OPEN command.  We
         *   therefore need different messages for PC and NPC actions,
         *   since this serves as the description of the entire action.
         *   
         *   Note that if you override the Open action response for a given
         *   object, you might want to customize this lister as well, since
         *   the message we generate (especially for an NPC action)
         *   presumes that we'll be the only response the command.  
         */
        gMessageParams(pov, parent);
        if (pov.isPlayerChar())
            "Das Öffnen {des parent/dessen} {bringt} <<withListCaseAccusative>><<withListArtIndefinite>>";
        else
            "{Der pov/er} {oeffnet} {den parent/ihn} und {bringt} <<withListCaseAccusative>><<withListArtIndefinite>>";
    }
    showListSuffixWide(itemCount, pov, parent)
    {
        " zum Vorschein{*}. ";
    }
;

/*
 *   Base contents lister.  This class handles contents listings for most
 *   kinds of specialized containers - Surfaces, RearConainers,
 *   RearSurfaces, and Undersides.  The main variation in the contents
 *   listings for these various types of containers is simply the
 *   preposition that's used to describe the relationship between the
 *   container and the contents, and for this we can look to the objInPrep
 *   property of the container.  
 */
class BaseContentsLister: Lister
    showListPrefixWide(itemCount, pov, parent)
    {
        "\^<<parent.objInPrep>> <<parent.demNameObj>><<withListCaseNominative>><<withListArtIndefinite>>
        <<itemCount == 1 ? '{ist singular}' : '{ist plural}'>> ";
    }
    showListSuffixWide(itemCount, pov, parent)
    {
        "<<withListCaseAccusative>><<withListArtIndefinite>>{*}. ";
    }
    showListPrefixTall(itemCount, pov, parent)
    {
        "\^<<parent.objInPrep>> <<parent.demNameObj>><<withListCaseNominative>><<withListArtIndefinite>>
        <<itemCount == 1 ? '{ist singular}' : '{ist plural}'>>{*}:";
    }
    showListSuffixTall(itemCount, pov, parent) // -- German: added to get the default listcase accusative!
    {
        "<<withListCaseAccusative>><<withListArtIndefinite>>";
    }
    showListContentsPrefixTall(itemCount, pov, parent)
    {
        "<<parent.einName>>, <<parent.objInPrep>><<withListCaseNominative>><<withListArtIndefinite>> <<parent.isPlural ? 'denen' : parent.isHer ? 'der' : 'dem' >>
        <<itemCount == 1 ? '{ist singular}' : '{ist plural}'>>{*}:";
    }
    showListContentsSuffixTall(itemCount, pov, parent) // -- German: added to get the default listcase accusative!
    {
        "<<withListCaseAccusative>><<withListArtIndefinite>>";
    }
;


/*
 *   Base class for contents listers for a surface 
 */
class BaseSurfaceContentsLister: BaseContentsLister
;

/*
 *   Contents lister for a surface 
 */
surfaceContentsLister: ContentsLister, BaseSurfaceContentsLister
;

/*
 *   Contents lister for explicitly looking in a surface 
 */
surfaceLookInLister: LookWhereContentsLister, BaseSurfaceContentsLister
;

/*
 *   Contents lister for a surface, used in a long description. 
 */
surfaceDescContentsLister: DescContentsLister, BaseSurfaceContentsLister
;

/*
 *   Contents lister for room parts
 */
roomPartContentsLister: surfaceContentsLister
    isListed(obj)
    {
        /* list the object if it's listed in the room part */
        return obj.isListedInRoomPart(part_);
    }

    /* the part I'm listing */
    part_ = nil
;

/*
 *   contents lister for room parts, used in a long description 
 */
roomPartDescContentsLister: surfaceDescContentsLister
    isListed(obj)
    {
        /* list the object if it's listed in the room part */
        return obj.isListedInRoomPart(part_);
    }

    part_ = nil
;

/*
 *   Look-in lister for room parts.  Most room parts act like surfaces
 *   rather than containers, so base this lister on the surface lister.  
 */
roomPartLookInLister: surfaceLookInLister
    isListed(obj)
    {
        /* list the object if it's listed in the room part */
        return obj.isListedInRoomPart(part_);
    }

    part_ = nil
;
                         
/*
 *   Base class for contents listers for an Underside.  
 */
class BaseUndersideContentsLister: BaseContentsLister
;

/* basic contents lister for an Underside */
undersideContentsLister: ContentsLister, BaseUndersideContentsLister
;

/* contents lister for explicitly looking under an Underside */
undersideLookUnderLister: LookWhereContentsLister, BaseUndersideContentsLister
;

/* contents lister for moving an Underside and abandoning its contents */
undersideAbandonContentsLister: undersideLookUnderLister
    showListEmpty(pov, parent) { }
    showListPrefixWide(itemCount, pov, parent)
        { "Das Nehmen <<parent.desNameObj>> {bringt singular} <<withListCaseAccusative>><<withListArtIndefinite>> "; }
    showListSuffixWide(itemCount, pov, parent)
        { " zum Vorschein. "; }
    showListPrefixTall(itemCount, pov, parent)
        { "Das Nehmen <<parent.desNameObj>> {bringt singular} zum Vorschein{*}: "; }
;
 
/* contents lister for an Underside, used in a long description */
undersideDescContentsLister: DescContentsLister, BaseUndersideContentsLister
    showListPrefixWide(itemCount, pov, parent)
    {
        "Unter <<parent.demNameObj>>
        <<itemCount == 1 ? '{ist singular}'
                         : '{ist plural}'>><<withListCaseNominative>> ";
    }
    showListSuffixWide(itemCount, pov, parent)
        { "{*}. "; }
;

/*
 *   Base class for contents listers for an RearContainer or RearSurface 
 */
class BaseRearContentsLister: BaseContentsLister
;

/* basic contents lister for a RearContainer or RearSurface */
rearContentsLister: ContentsLister, BaseRearContentsLister
;

/* contents lister for explicitly looking behind a RearContainer/Surface */
rearLookBehindLister: LookWhereContentsLister, BaseRearContentsLister
;
 
/* lister for moving a RearContainer/Surface and abandoning its contents */
rearAbandonContentsLister: undersideLookUnderLister
    showListEmpty(pov, parent) { }
    showListPrefixWide(itemCount, pov, parent)
        { "Das Bewegen <<parent.desNameObj>> {bringt singular} "; }
    showListSuffixWide(itemCount, pov, parent)
        { " hinter <<parent.itDat>> zum Vorschein{*}. "; }
    showListPrefixTall(itemCount, pov, parent)
        { "Das Bewegen <<parent.desNameObj>> {bringt singular} "; }
    showListSuffixTall(itemCount, pov, parent)
        { " zum Vorschein{*}. "; }
;
 
/* long-description contents lister for a RearContainer/Surface */
rearDescContentsLister: DescContentsLister, BaseRearContentsLister
    showListPrefixWide(itemCount, pov, parent)
    {
        "Hinter <<parent.demNameObj>>
        <<itemCount == 1 ? '{ist singular}'
                         : '{ist plural}'>><<withListCaseNominative>> ";
    }
    showListSuffixWide(itemCount, pov, parent)
        { "{*} "; }
;


/*
 *   Base class for specialized in-line contents listers.  This shows the
 *   list in the form "(<prep> which is...)", with the preposition obtained
 *   from the container's objInPrep property.  
 */
class BaseInlineContentsLister: ContentsLister
    showListEmpty(pov, parent) { }
    showListPrefixWide(cnt, pov, parent)
    {
        " (<<parent.objInPrep>> <<parent.isPlural ? 'denen' : parent.isHer ? 'der' : 'dem' >> 
        <<cnt == 1 ? '{ist singular}' : '{ist plural}'>><<withListCaseNominative>><<withListArtIndefinite>> ";
    }
    showListSuffixWide(itemCount, pov, parent)
        { "<<withListCaseAccusative>><<withListArtIndefinite>>{*})"; }
;

/*
 *   Contents lister for a generic in-line list entry.  We customize the
 *   wording slightly here: rather than saying "(in which...)" as the base
 *   class would, we use the slightly more readable "(which contains...)".
 */
inlineListingContentsLister: BaseInlineContentsLister
    showListPrefixWide(cnt, pov, parent)
        { verbHelper.lastVerb = 'undefined'; " (<<parent.itNom>> <<parent.verbZuEnthalten>> <<withListCaseAccusative>><<withListArtIndefinite>>"; }
;

/* in-line contents lister for a surface */
surfaceInlineContentsLister: BaseInlineContentsLister
;

/* in-line contents lister for an Underside */
undersideInlineContentsLister: BaseInlineContentsLister
;

/* in-line contents lister for a RearContainer/Surface */
rearInlineContentsLister: BaseInlineContentsLister
;

/*
 *   Contents lister for keyring list entry.  This is used to display a
 *   keyring's contents in-line with the name of the keyring,
 *   parenthetically. 
 */
keyringInlineContentsLister: inlineListingContentsLister
    showListPrefixWide(cnt, pov, parent)
        { " (mit <<withListCaseDative>><<withListArtIndefinite>>"; }
    showListSuffixWide(cnt, pov, parent)
        { " daran)<<withListCaseAccusative>><<withListArtIndefinite>>"; }
;


/*
 *   Contents lister for "examine <keyring>" 
 */
keyringExamineContentsLister: DescContentsLister
    showListEmpty(pov, parent)
    {
        "\^<<parent.derName>> <<parent.verbZuSein>> leer{*}. ";
    }
    showListPrefixWide(cnt, pov, parent)
    {
        "Verbunden mit <<parent.demNameObj>>
        <<cnt == 1 ? '{ist singular}'
                   : '{ist plural}'>> <<withListCaseNominative>><<withListArtIndefinite>>";
    }
    showListSuffixWide(itemCount, pov, parent)
    {
        "{*}. <<withListCaseAccusative>><<withListArtIndefinite>>";
    }
;

/*
 *   Lister for actors aboard a traveler.  This is used to list the actors
 *   on board a vehicle when the vehicle arrives or departs a location.  
 */
aboardVehicleLister: Lister
    showListPrefixWide(itemCount, pov, parent)
        { " (mit "; }
    showListSuffixWide(itemCount, pov, parent)
        { ")"; }

    /* list anything whose isListedAboardVehicle returns true */
    isListed(obj) { return obj.isListedAboardVehicle; }
;

/*
 *   A simple lister to show the objects to which a given Attachable
 *   object is attached.  This shows the objects which have symmetrical
 *   attachment relationships to the given parent object, or which are
 *   "major" items to which the parent is attached.  
 */
class SimpleAttachmentLister: Lister
    construct(parent) { parent_ = parent; }
    
    showListEmpty(pov, parent)
        { /* say nothing when there are no attachments */ }
    
    showListPrefixWide(cnt, pov, parent)
        { "<.p>\^<<parent.derName>> <<parent.verbZuSein>> mit <<withListCaseDative>><<withListArtIndefinite>>"; }
    showListSuffixWide(cnt, pov, parent)
        { " verbunden{*}. <<withListCaseAccusative>><<withListArtIndefinite>>"; }

    /* ask the parent if we should list each item */
    isListed(obj) { return parent_.isListedAsAttachedTo(obj); }

    /*
     *   the parent object - this is the object whose attachments are being
     *   listed 
     */
    parent_ = nil
;

/*
 *   The "major" attachment lister.  This lists the objects which are
 *   attached to a given parent Attachable, and for which the parent is
 *   the "major" item in the relationship.  The items in the list are
 *   described as being attached to the parent.  
 */
class MajorAttachmentLister: SimpleAttachmentLister
    showListPrefixWide(cnt, pov, parent) { "<.p>\^<<withListCaseNominative>><<withListArtIndefinite>>"; }
    showListSuffixWide(cnt, pov, parent)
    {
        " <<cnt == 1 ? '{ist singular}'
                     : '{ist plural}'>>
        mit <<parent.demNameObj>> verbunden{*}.<<withListCaseAccusative>><<withListArtIndefinite>> ";
    }

    /* ask the parent if we should list each item */
    isListed(obj) { return parent_.isListedAsMajorFor(obj); }
;

/*
 *   Finish Options lister.  This lister is used to offer the player
 *   options in finishGame(). 
 */
finishOptionsLister: Lister
    showListPrefixWide(cnt, pov, parent)
    {
        "<.p>Möchtest du ";
    }
    showListSuffixWide(cnt, pov, parent)
    {
        /* end the question, add a blank line, and show the ">" prompt */
        "?\b&gt;";
    }
    
    isListed(obj) { return obj.isListed; }
    listCardinality(obj) { return 1; }
    
    showListItem(obj, options, pov, infoTab)
    {
        /* obj is a FinishOption object; show its description */
        obj.desc;
    }
    
    showListSeparator(options, curItemNum, totalItems)
    {
        /*
         *   for the last separator, show "or" rather than "and"; for
         *   others, inherit the default handling 
         */
        if (curItemNum + 1 == totalItems)
        {
            if (totalItems == 2)
                " oder ";
            else
                ", oder ";
        }
        else
            inherited(options, curItemNum, totalItems);
    }
;

/*
 *   Equivalent list state lister.  This shows a list of state names for a
 *   set of otherwise indistinguishable items.  We show the state names in
 *   parentheses, separated by commas only (i.e., no "and" separating the
 *   last two items); we use this less verbose format so that we blend
 *   into the larger enclosing list more naturally.
 *   
 *   The items to be listed are EquivalentStateInfo objects.  
 */
equivalentStateLister: Lister
    showListPrefixWide(cnt, pov, parent) { " ("; }
    showListSuffixWide(cnt, pov, parent) { ")"; }
    isListed(obj) { return true; }
    listCardinality(obj) { return 1; }
    showListItem(obj, options, pov, infoTab)
    {
        if (obj.getEquivCount() == 1) {
            local list = obj.getEquivList();
            local test = list[1];
            "<<spellOneFrom(test)>> <<obj.getName()>>";
        }
        else
            "<<spellIntBelow(obj.getEquivCount(), 100)>> <<obj.getName()>>";
    }
    showListSeparator(options, curItemNum, totalItems)
    {
        if (curItemNum < totalItems)
            ", ";
    }
;

/* in case the exits module isn't included in the build */
property demDestName_, denDestName_, destName_, destIsBack_, others_, enableHyperlinks;

/*
 *   Basic room exit lister.  This shows a list of the apparent exits from
 *   a location.
 *   
 *   The items to be listed are DestInfo objects.  
 */
class ExitLister: Lister
    showListPrefixWide(cnt, pov, parent)
    {
        if (cnt == 1)
            "Der offenbar einzige Ausgang {fuehrt singular} ";
        else
            "Offensichtliche Ausgänge {fuehrt plural} ";
    }
    showListSuffixWide(cnt, pov, parent) { "{*}. "; }

    isListed(obj) { return true; }
    listCardinality(obj) { return 1; }

    showListItem(obj, options, pov, infoTab)
    {
        /*
         *   Show the back-to-direction prefix, if we don't know the
         *   destination name but this is the back-to direction: "back to
         *   the define" and so on. 
         */
        if (obj.destIsBack_ && obj.destName_ == nil)
            say(obj.dir_.backToPrefix + ' ');
        
        /* show the direction */
        "nach ";
        showListItemDirName(obj, nil);
      
        /* if the destination is known, show it as well */
        if (obj.destName_ != nil)
        {
            /*
             *   if we have a list of other directions going to the same
             *   place, show it parenthetically 
             */
            otherExitLister.showListAll(obj.others_, 0, 0);
            
            /*
             *   Show our destination name.  If we know the "back to"
             *   destination name, show destination names in the format
             *   "east, to the living room" so that they are consistent
             *   with "west, back to the dining room".  Otherwise, just
             *   show "east to the living room".  
             */
            if ((options & hasBackNameFlag) != 0)
                ",";

            /* if this is the way back, say so */
            
            if (obj.destIsBack_) {
                if (obj.dir_ != inDirection) {
                    " zurück <<obj.destIsProperName? 'nach' : 'zu'>>";
                    " <<obj.demDestName_>>";
                }
                else {
                    " zurück <<obj.destIsProperName? 'nach' : 'in'>>";
                    " <<obj.denDestName_>>";
                }
            }
            else {
                
                // If Direction is INSIDE, say ZURÜCK IN DEN ... else say ZURÜCK ZU DEM ... 
                /* show the destination */
                if (obj.dir_ == inDirection) {
                    " <<obj.destIsProperName? 'nach' : 'in'>>";
                    " <<obj.denDestName_>>";
                }
                else {
                    " <<obj.destIsProperName? 'nach' : 'zu'>>";
                    " <<obj.demDestName_>>";
                }
            }
        }
    }
    showListSeparator(options, curItemNum, totalItems)
    {
        /*
         *   if we have a "back to" name, use the "long" notation - this is
         *   important because we'll use commas in the directions with
         *   known destination names 
         */
        if ((options & hasBackNameFlag) != 0)
            options |= ListLong;

        /*
         *   for a two-item list, if either item has a destination name,
         *   show a comma or semicolon (depending on 'long' vs 'short' list
         *   mode) before the "and"; for anything else, use the default
         *   handling 
         */
        if (curItemNum == 1
            && totalItems == 2
            && (options & hasDestNameFlag) != 0)
        {
            if ((options & ListLong) != 0)
                " und ";
            else
                " und "; // -- we do not use the ";"
        }
        else
            inherited(options, curItemNum, totalItems);
    }

    /* show a direction name, hyperlinking it if appropriate */
    showListItemDirName(obj, initCap)
    {
        local dirname;
        local destName; // -- German: additional property
        
        /* get the name */
        // -- German: USE destName property from direction if availiable, else use name
        // -- e.g. show 'nach draußen' in exit description, but 'raus' in statusline
        if (obj.dir_.destName != nil) {
            dirname = obj.dir_.name;
            destName = obj.dir_.destName;
        }
        else
            dirname = obj.dir_.name;

        /* capitalize the first letter, if desired */
        if (initCap) {
            dirname = dirname.substr(1,1).toUpper() + dirname.substr(2);
            if (obj.dir_.destName != nil)
                destName = destName.substr(1,1).toUpper() + destName.substr(2);
        }
            
        /* show the name with a hyperlink or not, as configured */
        if (libGlobal.exitListerObj.enableHyperlinks) {
            if (obj.dir_.destName != nil)
                say(aHref(dirname, destName));
            else
                say(aHref(dirname, dirname));
        }
        else {
            if (obj.dir_.destName != nil)
                say(destName);
            else
                say(dirname);
        }
    }

    /* this lister shows destination names */
    listerShowsDest = true

    /*
     *   My special options flag: at least one object in the list has a
     *   destination name.  The caller should set this flag in our options
     *   if applicable. 
     */
    hasDestNameFlag = ListerCustomFlag(1)
    hasBackNameFlag = ListerCustomFlag(2)
    nextCustomFlag = ListerCustomFlag(3)
;

/*
 *   Show a list of other exits to a given destination.  We'll show the
 *   list parenthetically, if there's a list to show.  The objects to be
 *   listed are Direction objects.  
 */
otherExitLister: Lister
    showListPrefixWide(cnt, pov, parent) { " (oder "; }
    showListSuffixWide(cnt, pov, parent) { ")"; }

    isListed(obj) { return true; }
    listCardinality(obj) { return 1; }

    showListItem(obj, options, pov, infoTab)
    {
        if (libGlobal.exitListerObj.enableHyperlinks)
            say(aHref(obj.name, obj.name));
        else
            say(obj.name);
    }
    showListSeparator(options, curItemNum, totalItems)
    {
        /*
         *   simply show "or" for all items (these lists are usually
         *   short, so omit any commas) 
         */
        if (curItemNum != totalItems)
            " oder ";
    }
;

/*
 *   Show room exits as part of a room description, using the "verbose"
 *   sentence-style notation.  
 */
lookAroundExitLister: ExitLister
    showListPrefixWide(cnt, pov, parent)
    {
        /* add a paragraph break before the exit listing */
        "<.roompara>";

        /* inherit default handling */
        inherited(cnt, pov, parent);
    }    
;

/*
 *   Show room exits as part of a room description, using the "terse"
 *   notation. 
 */
lookAroundTerseExitLister: ExitLister
    showListPrefixWide(cnt, pov, parent)
    {
        "<.roompara><.parser>Offensichtliche Ausgänge: ";
    }
    showListItem(obj, options, pov, infoTab)
    {
        /* show the direction name */
        showListItemDirName(obj, true);
    }
    showListSuffixWide(cnt, pov, parent)
    {
        "<./parser> ";
    }
    showListSeparator(options, curItemNum, totalItems)
    {
        /* just show a comma between items */
        if (curItemNum != totalItems)
            ", ";
    }

    /* this lister does not show destination names */
    listerShowsDest = nil
;

/*
 *   Show room exits in response to an explicit request (such as an EXITS
 *   command).  
 */
explicitExitLister: ExitLister
    showListEmpty(pov, parent)
    {
        "Da {ist plural} offenbar keine Ausgänge{*}. ";
    }
;

/*
 *   Show room exits in the status line (used in HTML mode only)
 */
statuslineExitLister: ExitLister
    showListEmpty(pov, parent)
    {
        "<<statusHTML(3)>><b>Ausgänge:</b> <i>Keine</i><<statusHTML(4)>>";
    }
    showListPrefixWide(cnt, pov, parent)
    {
        "<<statusHTML(3)>><b>Ausgänge:</b> ";
    }
    showListSuffixWide(cnt, pov, parent)
    {
        "<<statusHTML(4)>>";
    }
    showListItem(obj, options, pov, infoTab)
    {
        "<<aHref(obj.dir_.name, obj.dir_.name, 'Geh ' + obj.dir_.name,
                 AHREF_Plain)>>";
    }
    showListSeparator(options, curItemNum, totalItems)
    {
        /* just show a space between items */
        if (curItemNum != totalItems)
            " &nbsp; ";
    }

    /* this lister does not show destination names */
    listerShowsDest = nil
;

/*
 *   Implied action announcement grouper.  This takes a list of
 *   ImplicitActionAnnouncement reports and returns a single message string
 *   describing the entire list of actions.  
 */
implicitAnnouncementGrouper: object
    /*
     *   Configuration option: keep all failures in a list of implied
     *   announcements.  If this is true, then we'll write things like
     *   "trying to unlock the door and then open it"; if nil, we'll
     *   instead write simply "trying to unlock the door".
     *   
     *   By default, we keep only the first of a group of failures.  A
     *   group of failures is always recursively related, so the first
     *   announcement refers to the command that actually failed; the rest
     *   of the announcements are for the enclosing actions that triggered
     *   the first action.  All of the enclosing actions failed as well,
     *   but only because the first action failed.
     *   
     *   Announcing all of the actions is too verbose for most tastes,
     *   which is why we set the default here to nil.  The fact that the
     *   first action in the group failed means that we necessarily won't
     *   carry out any of the enclosing actions, so the enclosing
     *   announcements don't tell us much.  All they really tell us is why
     *   we're running the action that actually failed, but that's almost
     *   always obvious, so suppressing them is usually fine.  
     */
    keepAllFailures = nil

    /* build the composite message */
    compositeMessage(lst)
    {
        local txt;
        local ctx = new ListImpCtx();

        /* add the text for each item in the list */
        for (txt = '', local i = 1, local len = lst.length() ; i <= len ; ++i)
        {
            local curTxt;

            /* get this item */
            local cur = lst[i];

            /* we're not in a 'try' or 'ask' sublist yet */
            ctx.isInSublist = nil;

            /* set the underlying context according to this item */
            ctx.setBaseCtx(cur);

            /*
             *   Generate the announcement for this element.  Generate the
             *   announcement from the message property for this item using
             *   our running list context.  
             */
            curTxt = cur.getMessageText(
                cur.getAction().getOriginalAction(), ctx);

            /*
             *   If this one is an attempt only, and it's followed by one
             *   or more other attempts, the attempts must all be
             *   recursively related (in other words, the first attempt was
             *   an implied action required by the second attempt, which
             *   was required by the third, and so on).  They have to be
             *   recursively related, because otherwise we wouldn't have
             *   kept trying things after the first failed attempt.
             *   
             *   To make the series of failed attempts sound more natural,
             *   group them into a single "trying to", and keep only the
             *   first failure: rather than "trying to unlock the door,
             *   then trying to open the door", write "trying to unlock the
             *   door and then open it".
             *   
             *   An optional configuration setting makes us keep only the
             *   first failed operation, so we'd instead write simply
             *   "trying to unlock the door".
             *   
             *   Do the same grouping for attempts interrupted for an
             *   interactive question.  
             */
            while ((cur.justTrying && i < len && lst[i+1].justTrying)
                   || (cur.justAsking && i < len && lst[i+1].justAsking))
            {
                local addTxt;
                
                /*
                 *   move on to the next item - we're processing it here,
                 *   so we don't need to handle it again in the main loop 
                 */
                ++i;
                cur = lst[i];

                /* remember that we're in a try/ask sublist */
                ctx.isInSublist = true;

                /* add the list entry for this action, if desired */
                if (keepAllFailures)
                {
                    /* get the added text */
                    addTxt = cur.getMessageText(
                        cur.getAction().getOriginalAction(), ctx);

                    /*
                     *   if both the text so far and the added text are
                     *   non-empty, string them together with 'and then';
                     *   if one or the other is empty, use the non-nil one 
                     */
                    if (addTxt != '' && curTxt != '')
                        curTxt += ' und dann ' + addTxt;
                    else if (addTxt != '')
                        curTxt = addTxt;
                }
            }

            /* add a separator before this item if it isn't the first */
            if (txt != '' && curTxt != '')
                txt += ', dann ';

            /* add the current item's text */
            txt += curTxt;
        }

        /* if we ended up with no text, the announcement is silent */
        if (txt == '')
            return '';

        /* wrap the whole list in the usual full standard phrasing */
        return standardImpCtx.buildImplicitAnnouncement(txt);
    }
;

/*
 *   Suggested topic lister. 
 */
class SuggestedTopicLister: Lister
    construct(asker, askee, explicit)
    {
        /* remember the actors */
        askingActor = asker;
        targetActor = askee;

        /* remember whether this is explicit or implicit */
        isExplicit = explicit;

        /* cache the actor's scope list */
        scopeList = asker.scopeList();
    }
    
    showListPrefixWide(cnt, pov, parent)
    {
        /* add the asking and target actors as global message parameters */
        gMessageParams(askingActor, targetActor);

        /* show the prefix; include a paren if not in explicit mode */
        "<<isExplicit ? '' : '('>>{Du askingActor/er} {koennt} ";
    }
    showListSuffixWide(cnt, pov, parent)
    {
        /* end the sentence; include a paren if not in explicit mode */
        "{*}.<<isExplicit? '' : ')'>> ";
    }
    showListEmpty(pov, parent)
    {
        /*
         *   say that the list is empty if it was explicitly requested;
         *   say nothing if the list is being added by the library 
         */
        if (isExplicit)
        {
            gMessageParams(askingActor, targetActor);
            "<<isExplicit ? '' : '('>>{Du askingActor/er} {hat} keine
            Ahnung{*}, worüber {er askingActor/sie} im Augenblick mit
            {dem targetActor/ihm} sprechen {!*}{koennt askingActor}.<<isExplicit ? '' : ')'>> ";
        }
    }

    showListSeparator(options, curItemNum, totalItems)
    {
        /* use "or" as the conjunction */
        if (curItemNum + 1 == totalItems)
            " oder ";
        else
            inherited(options, curItemNum, totalItems);
    }

    /* list suggestions that are currently active */
    isListed(obj) { return obj.isSuggestionActive(askingActor, scopeList); }

    /* each item counts as one item grammatically */
    listCardinality(obj) { return 1; }

    /* suggestions have no contents */
    contentsListed(obj) { return nil; }

    /* get the list group */
    listWith(obj) { return obj.suggestionGroup; }

    /* mark as seen - nothing to do for suggestions */
    markAsSeen(obj, pov) { }

    /* show the item - show the suggestion's theName */
    showListItem(obj, options, pov, infoTab)
    {
        /* note that we're showing the suggestion */
        obj.noteSuggestion();

        /* show the name */
        say(obj.fullName);
    }

    /* don't use semicolons, even in long lists */
    longListSepTwo { listSepTwo; }
    longListSepMiddle { listSepMiddle; }
    longListSepEnd { listSepEnd; }

    /* flag: this is an explicit listing (i.e., a TOPICS command) */
    isExplicit = nil

    /* the actor who's asking for the topic list (usually the PC) */
    askingActor = nil

    /* the actor we're talking to */
    targetActor = nil

    /* our cached scope list for the actor */
    scopeList = nil
;

/* ASK/TELL suggestion list group base class */
class SuggestionListGroup: ListGroupPrefixSuffix
    showGroupItem(sublister, obj, options, pov, infoTab)
    {
        /*
         *   show the short name of the item - the group prefix will have
         *   shown the appropriate long name 
         */
        say(obj.name);
    }
;

/* ASK ABOUT suggestion list group */
suggestionAskGroup: SuggestionListGroup
    groupPrefix = "{den targetActor/ihn} nach "
    groupSuffix = " fragen"
;

/* TELL ABOUT suggestion list group */
suggestionTellGroup: SuggestionListGroup
    groupPrefix = "{dem targetActor/ihm} von "
    groupSuffix = " erzählen"
;

/* ASK FOR suggestion list group */
suggestionAskForGroup: SuggestionListGroup
    groupPrefix = "{den targetActor/ihn} um "
    groupSuffix = " bitten"
;

/* GIVE TO suggestions list group */
suggestionGiveGroup: SuggestionListGroup
    groupPrefix = "{dem targetActor/ihm} "
    groupSuffix = " geben"
;

/* SHOW TO suggestions */
suggestionShowGroup: SuggestionListGroup
    groupPrefix = "{dem targetActor/ihm} "
    groupSuffix = " zeigen"
;

/* YES/NO suggestion group */
suggestionYesNoGroup: SuggestionListGroup
    showGroupList(pov, lister, lst, options, indent, infoTab)
    {
        /*
         *   if we have one each of YES and NO responses, make the entire
         *   list "say yes or no"; otherwise, use the default behavior 
         */
        if (lst.length() == 2
            && lst.indexWhich({x: x.ofKind(SuggestedYesTopic)}) != nil
            && lst.indexWhich({x: x.ofKind(SuggestedNoTopic)}) != nil)
        {
            /* we have a [yes, no] group - use the simple message */
            "ja oder nein sagen";
        }
        else
        {
            /* inherit the default behavior */
            inherited(pov, lister, lst, options, indent, infoTab);
        }
    }
    groupPrefix = "sagen";
;
