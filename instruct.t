#charset "iso-8859-1"

/* 
 *   Copyright (c) 2000, 2006 Michael J. Roberts.  All Rights Reserved. 
 *   
 *   TADS 3 Library: Instructions for new players
 *   
 *   This module defines the INSTRUCTIONS command, which provides the
 *   player with an overview of how to play IF games in general.  These
 *   instructions are especially designed as an introduction to IF for
 *   inexperienced players.  The instructions given here are meant to be
 *   general enough to apply to most games that follow the common IF
 *   conventions. 
 *   
 *   This module defines the German version of the instructions.
 *   
 *   In most cases, each author should customize these general-purpose
 *   instructions at least a little for the specific game.  We provide a
 *   few hooks for some specific parameter-driven customizations that don't
 *   require modifying the original text in this file.  Authors should also
 *   feel free to make more extensive customizations as needed to address
 *   areas where the game diverges from the common conventions described
 *   here.
 *   
 *   One of the most important things you should do to customize these
 *   instructions for your game is to add a list of any special verbs or
 *   command phrasings that your game uses.  Of course, you might think
 *   you'll be spoiling part of the challenge for the player if you do
 *   this; you might worry that you'll give away a puzzle if you don't keep
 *   a certain verb secret.  Be warned, though, that many players - maybe
 *   even most - don't think "guess the verb" puzzles are good challenges;
 *   a lot of players feel that puzzles that hinge on finding the right
 *   verb or phrasing are simply bad design that make a game less
 *   enjoyable.  You should think carefully about exactly why you don't
 *   want to disclose a particular verb in the instructions.  If you want
 *   to withhold a verb because the entire puzzle is to figure out what
 *   command to use, then you have created a classic guess-the-verb puzzle,
 *   and most everyone in the IF community will feel this is simply a bad
 *   puzzle that you should omit from your game.  If you want to withhold a
 *   verb because it's too suggestive of a particular solution, then you
 *   should at least make sure that a more common verb - one that you are
 *   willing to disclose in the instructions, and one that will make as
 *   much sense to players as your secret verb - can achieve the same
 *   result.  You don't have to disclose every *accepted* verb or phrasing
 *   - as long as you disclose every *required* verb *and* phrasing, you
 *   will have a defense against accusations of using guess-the-verb
 *   puzzles.
 *   
 *   You might also want to mention the "cruelty" level of the game, so
 *   that players will know how frequently they should save the game.  It's
 *   helpful to point out whether or not it's possible for the player
 *   character to be killed; whether it's possible to get into situations
 *   where the game becomes "unwinnable"; and, if the game can become
 *   unwinnable, whether or not this will become immediately clear.  The
 *   kindest games never kill the PC and are always winnable, no matter
 *   what actions the player takes; it's never necessary to save these
 *   games except to suspend a session for later resumption.  The cruelest
 *   games kill the PC without warning (although if they offer an UNDO
 *   command from a "death" prompt, then even this doesn't constitute true
 *   cruelty), and can become unwinnable in ways that aren't readily and
 *   immediately apparent to the player, which means that the player could
 *   proceed for quite some time (and thus invest substantial effort) after
 *   the game is already effectively lost.  Note that unwinnable situations
 *   can often be very subtle, and might not even be intended by the
 *   author; for example, if the player needs a candle to perform an
 *   exorcism at some point, but the candle can also be used for
 *   illumination in dark areas, the player could make the game unwinnable
 *   simply by using up the candle early on while exploring some dark
 *   tunnels, and might not discover the problem until much further into
 *   the game.  
 */

/*
 *   TADS 3 Library - German (German variant) implementation by Michael Baltes
 */

#include "adv3.h"
#include "de_de.h"

/*
 *   The INSTRUCTIONS command.  Make this a "system" action, because it's
 *   a meta-action outside of the story.  System actions don't consume any
 *   game time.  
 */
DefineSystemAction(Instructions)
    /*
     *   This property tells us how complete the verb list is.  By default,
     *   we'll assume that the instructions fail to disclose every required
     *   verb in the game, because the generic set we use here doesn't even
     *   try to anticipate the special verbs that most games include.  If
     *   you provide your own list of game-specific verbs, and your custom
     *   list (taken together with the generic list) discloses every verb
     *   required to complete the game, you should set this property to
     *   true; if you set this to true, the instructions will assure the
     *   player that they will not need to think of any verbs besides the
     *   ones listed in the instructions.  Authors are strongly encouraged
     *   to disclose a list of verbs that is sufficient by itself to
     *   complete the game, and to set this property to true once they've
     *   done so.  
     */
    allRequiredVerbsDisclosed = nil

    /* 
     *   A list of custom verbs.  Each game should set this to a list of
     *   single-quoted strings; each string gives an example of a verb to
     *   display in the list of sample verbs.  Something like this:
     *   
     *   customVerbs = ['brush my teeth', 'pick the lock'] 
     */
    customVerbs = []

    /* 
     *   Verbs relating specifically to character interaction.  This is in
     *   the same format as customVerbs, and has essentially the same
     *   purpose; however, we call these out separately to allow each game
     *   not only to supplement the default list we provide but to replace
     *   our default list.  This is desirable for conversation-related
     *   commands in particular because some games will not use the
     *   ASK/TELL conversation system at all and will thus want to remove
     *   any mention of the standard set of verbs.  
     */
    conversationVerbs =
    [
        'Frage Zauberer nach Zauberstab',
        'Bitte Zauberer um Trank',
        'Erz�hl Zauberer von staubigem Foliant',
        'Zeige dem Zauberer die Schriftrolle',
        'Gib dem Zauberer den Zauberstab',
        'JA (oder NEIN)'
    ]

    /* conversation verb abbreviations */
    conversationAbbr = "\n\tFRAGE NACH (thema) kann abgek�rzt werden mit F (thema)
                        \n\tERZ�HL VON (thema) kann als E (thema) eingegeben werden"

    /*
     *   Truncation length. If the game's parser allows words to be
     *   abbreviated to some minimum number of letters, this should
     *   indicate the minimum length.  The English parser uses a truncation
     *   length of 6 letters by default.
     *   
     *   Set this to nil if the game doesn't allow truncation at all.  
     */
    truncationLength = 16 // In German we have many rather long words ...

    /*
     *   This property should be set on a game-by-game basis to indicate
     *   the "cruelty level" of the game, which is a rough estimation of
     *   how likely it is that the player will encounter an unwinnable
     *   position in the game.
     *   
     *   Level 0 is "kind," which means that the player character can
     *   never be killed, and it's impossible to make the game unwinnable.
     *   When this setting is used, the instructions will reassure the
     *   player that saving is necessary only to suspend the session.
     *   
     *   Level 1 is "standard," which means that the player character can
     *   be killed, and/or that unwinnable positions are possible, but
     *   that there are no especially bad unwinnable situations.  When
     *   this setting is selected, we'll warn the player that they should
     *   save every so often.
     *   
     *   (An "especially bad" situation is one in which the game becomes
     *   unwinnable at some point, but this won't become apparent to the
     *   player until much later.  For example, suppose the first scene
     *   takes place in a location that can never be reached again after
     *   the first scene, and suppose that there's some object you can
     *   obtain in this scene.  This object will be required in the very
     *   last scene to win the game; if you don't have the object, you
     *   can't win.  This is an "especially bad" unwinnable situation: if
     *   you leave the first scene without getting the necessary object,
     *   the game is unwinnable from that point forward.  In order to win,
     *   you have to go back and play almost the whole game over again.
     *   Saved positions are almost useless in a case like this, since
     *   most of the saved positions will be after the fatal mistake; no
     *   matter how often you saved, you'll still have to go back and do
     *   everything over again from near the beginning.)
     *   
     *   Level 2 is "cruel," which means that the game can become
     *   unwinnable in especially bad ways, as described above.  If this
     *   level is selected, we'll warn the player more sternly to save
     *   frequently.
     *   
     *   We set this to 1 ("standard") by default, because even games that
     *   aren't intentionally designed to be cruel often have subtle
     *   situations where the game becomes unwinnable, because of things
     *   like the irreversible loss of an object, or an unrepeatable event
     *   sequence; it almost always takes extra design work to ensure that
     *   a game is always winnable.  
     */
    crueltyLevel = 1

    /*
     *   Does this game have any real-time features?  If so, set this to
     *   true.  By default, we'll explain that game time passes only in
     *   response to command input. 
     */
    isRealTime = nil

    /*
     *   Conversation system description.  Several different conversation
     *   systems have come into relatively widespread use, so there isn't
     *   any single convention that's generic enough that we can assume it
     *   holds for all games.  In deference to this variability, we
     *   provide this hook to make it easy to replace the instructions
     *   pertaining to the conversation system.  If the game uses the
     *   standard ASK/TELL system, it can leave this list unchanged; if
     *   the game uses a different system, it can replace this with its
     *   own instructions.
     *   
     *   We'll include information on the TALK TO command if there are any
     *   in-conversation state objects in the game; if not, we'll assume
     *   there's no need for this command.
     *   
     *   We'll mention the TOPICS command if there are any SuggestedTopic
     *   instances in the game; if not, then the game will never have
     *   anything to suggest, so the TOPICS command isn't needed.
     *   
     *   We'll include information on special topics if there are any
     *   SpecialTopic objects defined.  
     */
    conversationInstructions =
        "Du kannst mit anderen Charakteren Konversation betreiben, indem 
        du sie nach etwas fragst, oder ihnen von etwas erz�hlst, das in
        der Geschichte vorkommt. Zum Beispiel, k�nntest du FRAG ZAUBERER
        NACH ZAUBERSTAB oder ERZ�HL DER WACHE VON DEM ALARM eingeben. Du
        solltest immer das FRAG NACH oder ERZ�HL VON Schema einhalten, denn
        die Geschichte kann andere Formate in der Regel nicht verarbeiten. 
        Du musst dir nicht den Kopf �ber komplizierte Formulierungen wie 
        <q>frag die Wache, wie man das Fenster �ffnet</q> zerbrechen.
        In den meisten F�llen bekommst du das beste Ergebnis, wenn du nach
        bestimmten Gegenst�nden oder Personen, denen du im Spielverlauf 
        begegnet bist, fragst. Abstrakte Themen wie DIE BEDEUTUNG DES LEBENS
        d�rften eher selten akzeptiert werden. Wie auch immer: falls du zu der 
        �berzeugung gelangst, du <i>solltest</i> jemand nach einem akstrakten 
        Thema befragen, dann tu es - es kann nicht schaden.

        \bWenn du dieselbe Person nach mehreren Themen in Folge befragen oder
        ihr davon erz�hlen willst, kannst du dir einige Tipparneit sparen,
        indem du FRAGE NACH mit F oder ERZ�HLE VON mit E abk�rzst. Wenn du
        zum Beispiel mit dem Zauberer im Gespr�ch bist, kannst du FRAGE DEN
        ZAUBERER NACH DEM AMULETT mit F AMULETT abk�rzen. Diese Eingabe richtet
        deine Frage an dieselbe Person, die du in deinem letzten FRAGE oder
        ERZ�HLE Befehl angesprochen hast.

        <<firstObj(InConversationState, ObjInstances) != nil ?
          "\bUm mit jemandem ins Gespr�ch zu kommen, tippe REDE MIT (Person).  
          Damit versuchst du, die Aufmerksamkeit der Person auf dich zu lenken
          und eine Konversation zu beginnen. REDE MIT ist in der Regel optional,
          weil du direkt mit FRAGE oder ERZ�HLE starten kannst, wenn du willst." : "">>

        <<firstObj(SpecialTopic, ObjInstances) != nil ?
          "\bDie Geschichte kann gelegentlich spezielle M�glichkeiten in einem 
          Gespr�ch vorschlagen, wie z.B.:

          \b\t(Du kannst dich entschuldigen, oder erkl�ren warum du die Aliens nicht magst.)

          \bWenn du willst, kannst du einen der Vorschl�ge verwenden, indem du
          den Vorschlag w�rtlich eingibst. Normalerweise gen�gt es, die ersten
          paar W�rter einzugeben.

          \b\t&gt;ENTSCHULDIGE DICH
          \n\t&gt;ERKL�R WARUM DU DIE ALIENS NICHT MAGST

          \bSpezielle M�glichkeiten wie diese sind nur m�glich, wenn sie unmittelbar
          vorgeschlagen werden. Du musst sie daher nicht auswendig lernen. Die 
          Geschichte schl�gt dir diese zum gegebenen Zeitpunkt vor. Diese speziellen
          Optionen schr�nken dich nicht ein. Du kannst nach wie vor genauso gut einen
          gew�hnlichen Befehl eintippen, anstatt auf die spezielle Eingabe zur�ck
          zu greifen." : "">>

        <<firstObj(SuggestedTopic, ObjInstances) != nil ?
          "\bWenn du dir nicht sicher bist, welche Themen diskutiert werden k�nnen,
          hilft der Befehl THEMEN, wenn du dich im Gespr�ch mit einer Person
          befindest. Er zeigt dir eine Liste mit Dingen, die als Gespr�chsthemen
          zur Auswahl stehen und die den Gespr�chspartner interessieren k�nnten.
          Der Befehl listet f�r gew�hnlich nicht alle Themen auf, also experimentiere
          frei." : "">>

        \bDu kannst auch mit anderen Charakteren durch physische Objekte interagieren.
        Zum Beispiel kannst du versuchen, jemandem etwas zu zeigen oder zu geben, wie
        GIB DAS GELD DEM BEAMTEN oder ZEIGE DAS G�TZENBILD DEM PROFESSOR.  Du k�nntest
        auch mit anderen Charakteren k�mpfen wie GREIF TROLL MIT SCHWERT AN oder WIRF
        AXT AUF ZWERG.

        \bManchmal kannst du einem anderen Charakter dazu auffordern, etwas f�r dich
        zu erledigen. Hierf�r gibst du den Namen des Charakters ein, gefolgt von 
        einem Komma, und dann den entsprechenden Befehl, in der selben Form, wie du
        diesen Befehl auch f�r dich selbst verwendest. Zum Beispiel:

        \b\t&gt;ROBOTER, GEH NACH NORDEN

        \bEs gibt aber keine Garantie, dass der Charakter deinem Befehl Folge leistet.
        Die meisten Personen haben eine eigene Einstellung zu den Dingen und werden 
        nicht automatisch und blind alles was du willst, ausf�hren. "

    /* execute the command */
    execSystemAction()
    {
        local origElapsedTime;

        /* 
         *   note the elapsed game time on the real-time clock before we
         *   start, so that we can reset the game time when we're done; we
         *   don't want the instructions display to consume any real game
         *   time 
         */
        origElapsedTime = realTimeManager.getElapsedTime();

        /* show the instructions */
        showInstructions();

        /* reset the real-time game clock */
        realTimeManager.setElapsedTime(origElapsedTime);
    }

#ifdef INSTRUCTIONS_MENU
    /*
     *   Show the instructions, using a menu-based table of contents.
     */
    showInstructions()
    {
        /* run the instructions menu */
        topInstructionsMenu.display();

        /* show an acknowledgment */
        "Erledigt. ";
    }
    
#else /* INSTRUCTIONS_MENU */

    /*
     *   Show the instructions as a standard text display.  Give the user
     *   the option of turning on a SCRIPT file to capture the text.  
     */
    showInstructions()
    {
        local startedScript;

        /* presume we won't start a new script file */
        startedScript = nil;
        
        /* show the introductory message */
        "Diese Geschichte kann detaillierte Instruktionen zu Interactive
        Fiction anzeigen, speziell f�r jemanden, der mit den Konventionen 
        von IF bislang nicht vertraut ist";

        /*
         *   Check to see if we're already scripting.  If we aren't, offer
         *   to save the instructions to a file. 
         */
        if (scriptStatus.scriptFile == nil)
        {
            local str;
            
            /* 
             *   they're not already logging; ask if they'd like to start
             *   doing so 
             */
            ", und du kannst diese in eine Datei schreiben lassen, die du
            dann ausdrucken kannst. Willst du fortfahren? Mit
            \n(<a href='Ja'>J</a> stimmst du zu, oder tipp 
            <a href='Skript'>SKRIPT</a> um diese in eine Datei zu schreiben) &gt; ";

            /* ask for input */
            str = inputManager.getInputLine(nil, nil);

            /* if they want to capture them to a file, set up scripting */
            if (rexMatch('<nocase><space>*s(c(r(i(pt?)?)?)?)?<space>*', str)
                == str.length())
            {
                /* try setting up a scripting file */
                ScriptAction.setUpScripting(nil);

                /* if that failed, don't proceed */
                if (scriptStatus.scriptFile == nil)
                    return;
                
                /* note that we've started a script file */
                startedScript = true;
            }
            else if (rexMatch('<nocase><space>*j.*', str) != str.length())
            {
                "Abgebrochen. ";
                return;
            }
        }
        else
        {
            /* 
             *   they're already logging; just confirm that they want to
             *   see the instructions 
             */
            "; willst du fortfahren?
            \n(Zustimmung mit J) &gt; ";

            /* stop if they don't want to proceed */
            if (!yesOrNo())
            {
                "Abgebrochen. ";
                return;
            }
        }

        /* make sure we have something for the next "\b" to skip from */
        "\ ";

        /* show each chapter in turn */
        showCommandsChapter();
        showAbbrevChapter();
        showTravelChapter();
        showObjectsChapter();
        showConversationChapter();
        showTimeChapter();
        showSaveRestoreChapter();
        showSpecialCmdChapter();
        showUnknownWordsChapter();
        showAmbiguousCmdChapter();
        showAdvancedCmdChapter();
        showTipsChapter();

        /* if we started a script file, close it */
        if (startedScript)
            ScriptOffAction.turnOffScripting(nil);
    }

#endif /* INSTRUCTIONS_MENU */

    /* Entering Commands chapter */
    showCommandsChapter()
    {
        "\b<b>Eingeben von Befehlen</b>\b
        Du hast eventuell schon bemerkt, dass du mit der Geschichte interagierst,
        indem du einen Befehl eingibst, wann immer das folgende Zeichen ausgegeben
        wird:
        \b";

        gLibMessages.mainCommandPrompt(rmcCommand);

        "\bSo weit so gut, jetzt denkst du wahrscheinlich an zwei Dinge:
        <q>Super, Ich kann tippen was auch immer ich will, in deutscher
        Sprache und die Geschichte wird erkennen, was ich will,</q> oder <q>
        Super, jetzt muss ich auch noch eine weitere komplexe Sprache f�r ein
        Computer Programm lernen. Ich werde stattdessen etwas anderes 
        spielen.</q>  Nun ja, keins von beiden ist die ganze Wahrheit.

        \bW�hrend des Spielens ben�tigst du nur eine eher kleine Liste von
        Befehlen und diese sind meist in gew�hnlichem Deutsch, im Imperativ
        formuliert. Obwohl das Befehlszeichen durchaus abschreckend wirken
        kann, lass dich bitte davon nicht beeinflussen. Es gibt nur wenige
        Dinge, die du wissen musst.

        \bErstens, du musst dich zu keinem Zeitpunkt auf irgendetwas beziehen,
        was nicht direkt in der Geschichte erw�hnt wurde. Schlie�lich ist das
        eine interaktive Geschichte und kein Ratespiel. Ein Beispiel: wenn du
        eine Jacke tr�gst, k�nntest du vermuten, dass diese Taschen, Kn�pfe
        oder einen Rei�verschluss hat. Aber wenn diese Sachen in der Geschichte
        nicht explizit erw�hnt werden, solltest du dir dar�ber keine Gedanken
        machen. Dann ist es eben f�r die Geschichte unwichtig. 
        
        \bZweitens, du musst dich nicht mit jedem denkbaren Verb herumschlagen,
        um eine Aktion auszuf�hren. Es kommt nicht darauf an, Verben zu raten.
        Stattdessen verwendest du einen relativ kleinen Stamm an Verben, die zu
        einfachen und gew�hnlichen Aktionen passen. Um dir eine Vorstellung
        zu geben, was gemeint ist, folgen hier ein paar Beispiele:";
        
        "\b
        \n\t Schau dich um
        \n\t Inventar
        \n\t Gehe nach Norden (oder Osten, S�dwesten, und so weiter, oder Hoch, Runter, Rein, Raus)
        \n\t Warte
        \n\t Nimm die Schachtel
        \n\t Leg die Diskette ab
        \n\t Schau die Diskette an
        \n\t Lies das Buch
        \n\t �ffne die Schachtel
        \n\t Schlie�e die Schachtel
        \n\t Schau in die Schachtel
        \n\t Schau durch das Fenster
        \n\t Lege die Diskette in die Schachtel
        \n\t Lege die Schachtel auf den Tisch
        \n\t Trage den Hut
        \n\t Nimm den Hut ab
        \n\t Schalte Lampe ein
        \n\t Z�nde Streichholz an
        \n\t Z�nde Kerze mit Streichholz an
        \n\t Dr�ck den Knopf
        \n\t Zieh den Hebel
        \n\t Dreh den Knopf
        \n\t Dreh Rad auf 11
        \n\t Ess den Keks
        \n\t Trinke die Milch
        \n\t Wirf Kuchen auf Clown
        \n\t Greif den Troll mit dem Schwert an
        \n\t Sperr T�r mit Schl�ssel auf
        \n\t Sperr T�r mit Schl�ssel ab
        \n\t Kletter die Leiter hoch
        \n\t Steig in den Wagen
        \n\t Setz dich auf den Stuhl
        \n\t Stell dich auf den Tisch
        \n\t Stell dich auf das Blumenbett
        \n\t Leg dich auf das Bett
        \n\t Tippe Hallo auf Tastatur
        \n\t Schlage Bob im Telefonbuch nach";

        /* show the conversation-related verbs */
        foreach (local cur in conversationVerbs)
            "\n\t <<cur>>";

        /* show the custom verbs */
        foreach (local cur in customVerbs)
            "\n\t <<cur>>";

        /* 
         *   if the list is exhaustive, say so; otherwise, mention that
         *   there might be some other verbs to find 
         */
        if (allRequiredVerbsDisclosed)
            "\bDas wars! Alles was du brauchst, ist oben erw�hnt und gezeigt.
            Wenn du irgendwo stecken bleibst und denkst, dass die Geschichte
            von dir erwartet, das Rad neu zu erfinden, erinnere dich an
            Folgendes: was auch immer du tun musst, du kannst es mit einem
            oder mehreren der erw�hnten Befehle tun - Alles was du brauchst,
            ist oben erw�hnt. ";
        else
            "\bDie meisten Verben, die du ben�tigst, um die Geschichte zu
            vollenden, sind oben gezeigt. In seltenen F�llen werden zus�tzliche
            Befehle ben�tigt, sie folgen aber mit Sicherheit dem obigen Schema.";

        "\bEin paar dieser Befehle bed�rfen einer genauerer Erkl�rung.
        Schau dich um (das kannst du abk�rzen mit schau oder l) zeigt dir
        die Beschreibung deines momentanen Aufenthaltsortes an.  Damit kannst
        du jederzeit deine Erinnerung an den Ort und die hier erw�hnten Objekte
        auffrischen.  Inventar (oder nur i) zeigt alles an, das du angezogen hast
        oder mit dir herum tr�gst. Warte (oder w) l�sst einen Zug in der Geschichte
        ohne Aktion vergehen.";
    }

    /* Abbreviations chapter */
    showAbbrevChapter()
    {
        "\b<b>Abk�rzungen</b>
        \bDu ben�tigst manche Befehle extrem oft, daher kannst du die gebr�uchlichsten
        auch abk�rzen:

        \b
        \n\t Schau dich um entspricht schau oder einfach l
        \n\t Inventar wird abgek�rzt mit i
        \n\t Geh nach Norden kann einfach als Norden eingegeben werden, oder nur n 
        (genauso o, w, s, no, so, nw, sw, H f�r Hoch und R f�r Runter)
        \n\t Schau die Diskette an kann als untersuche Diskette oder einfach x 
        Diskette eingegeben werden
        \n\t Warte kann zu z verk�rzt werden
        <<conversationAbbr>>

        \b<b>Ein paar weitere Feinheiten</b>
        \bWenn du Befehle eingibst, kannst du Gro�- und Kleinschreibung nach
        Belieben verwenden. Du kannst Artikel wie der, die, das eingeben oder
        kannst sie nach Belieben auch weglassen. ";

        if (truncationLength != nil)
        {
            "Du kannst ein Wort auf die ersten <<
            spellInt(truncationLength)>> Buchstaben abk�rzen, darfst aber keine
            Buchstaben hinzuf�gen. Das bedeutet, du kannst, zum Beispiel, das
            Wort EXTREMGUTANGENOMMENERMEDIKAMENTENMIX abk�rzen mit <<
            'EXTREMGUTANGENOMMENERMEDIKAMENTENMIX'.substr(1, truncationLength)
            >> oder <<
            'EXTREMGUTANGENOMMENERMEDIKAMENTENMIX'.substr(1, truncationLength+2)
            >>, aber nicht mit <<
            'EXTREMGUTANGENOMMENERMEDIKAMENTENMIX'.substr(1, truncationLength)
            >>SDF. ";
        }
    }

    /* Travel chapter */
    showTravelChapter()
    {
        "\b<b>Fortbewegung</b>
        \bDu befindest dich jederzeit w�hrend der Geschichte an einem
        bestimmten <q>Aufenthaltsort.</q> Dieser wird beschrieben, wenn du
        ihn das erste mal betrittst, und wieder, wenn du SCHAU eingibst.
        Jeder Ort hat normalerweise einen Namen, der vor der Beschreibung
        ausgegeben wird. Der Name ist n�tzlich, wenn du eine Karte zeichnest
        und hilft dir, die Orientierung zu behalten, wenn du dich fortbewegst.

        \bJeder Aufenthaltsort ist ein einzelner Raum oder Teil einer Landschaft
        oder einer Stadt. (Manchmal ist ein einzelner Raum so gro�, dass er durch
        mehrere zusammenh�ngende Orte repr�sentiert wird, aber das kommt eher
        selten vor.) Bist du einmal an einem Ort angelangt, kannst du f�r 
        gew�hnlich alle dort vorhandenen Objekte sehen und erreichen. Somit
        spielt es keine Rolle, wo genau innerhalb des Raums du dich befindest.
        Manchmal ist etwas au�erhalb deiner Reichweite, vielleicht weil sich
        der Gegenstand auf einem hohen Regal oder auf der anderen Seite eines
        Grabens befindet. In diesen F�llen lohnt es sich, die Position genauer
        zu betrachten -- vielleicht l�sst sich der Gegenstand erreichen, wenn
        du dich z.B. auf einen Tisch stellst (STELL DICH AUF DEN TISCH.)

        \bDie Fortbewegung zwischen den R�umen erfolgt normalerweise mit einem
        Richtungsbefehl wie Geh nach Norden, Geh hoch, usw.
        (Du kannst die Kardinalrichtungen und vertikalen Richtungen allesamt
        abk�rzen mit: N, S, O, W, H, R. Das geht auch mit den Diagonalen:
        NO, NW, SO, SW.) Die Geschichte erw�hnt m�gliche Ausg�nge in der Regel
        in der entsprechenden Beschreibung des Aufenthaltsortes, so dass du
        niemals blind raten musst.
        
        \bIn den meisten F�llen bringt dich die Umkehrung der Richtung wieder
        zur�ck in den Raum, den du verlassen hast, aber manchmal k�nnen die
        Passagen sich auch winden und drehen.

        \bWenn eine T�r (oder Tor) beschrieben wird, brauchst du dich meistens
        nicht darum bem�hen, sie zu �ffnen, das passiert automatisch.
        Nur wenn die T�re durch etwas blockiert wird oder sie verschlossen ist,
        musst du dich genauer um die L�sung des Problems k�mmern.";
    }

    /* Objects chapter */
    showObjectsChapter()
    {
        "\b<b>Interaktion mit Objekten</b>
        \bDu kannst in der Geschichte Gegenst�nde finden, die du mitnhemen
        oder auf andere Weise manipulieren kannst. Wenn du etwas mitnehmen
        willst, gib NIMM gefolgt von dem Namen des Gegenstands ein: NIMM
        BUCH. Wenn du etwas ablegen willst, LEG es AB.
        
        \bDu brauchst dich nicht darum zu k�mmern, wie du etwas mit dir 
        herumtr�gst, also spielt es keine Rolle, in welcher Hand du etwas
        hast und so weiter. Manchmal macht es Sinn einen Gegenstand in
        oder auf einen anderen zu legen, zum Beispiel: LEG BUCH IN 
        EINKAUFSTASCHE oder LEG VASE AUF TISCH. Falls deine H�nde voll sind,
        lege Gegenst�nde in eine Tasche oder einen �hnlichen Beh�lter, etwa
        einen Rucksack etc. Das erh�ht in diesem Fall deine Tragekapazit�t.

        \bOft bekommst du einen Haufen Zusatzinformationen (und manchmal
        lebenswichtige Hinweise) wenn du Objekte n�her untersuchst. Das 
        kannst du mit UNTERSUCHE etwas, SCHAU etwas AN, BETRACHTE etwas, 
        machen. Der Befehl kann mit X oder B abgek�rzt werden (X GEM�LDE).
        Erfahrene Spieler haben die Angewohnheit, ALLES und JEDEN erstmal
        zu untersuchen, wenn sie einen neuen Raum betreten. ";
    }

    /* show the Conversation chapter */
    showConversationChapter()
    {
        "\b<b>Interaktion mit anderen Charakteren</b>
        \bDu kannst im Verlauf der Geschichte auf andere Leute oder 
        Kreaturen treffen. Manchmal kannst du mit diesen interagieren.\b";

        /* show the customizable conversation instructions */
        conversationInstructions;
    }

    /* Time chapter */
    showTimeChapter()
    {
        "\b<b>Zeit</b>";

        if (isRealTime)
        {
            "\bImmer wenn du einen Befehl eingibst, vergeht etwas Zeit in der
            Geschichte. Zus�tzlich k�nnen einige Geschichten in <q>Echtzeit</q> spielen,
            das hei�t, dass Dinge sogar passieren k�nnen w�hrend du �ber deinen
            n�chsten Zug nachdenkst.

            \bIn diesem Fall kannst du die Geschichte stoppen, wenn du den Computer
            kurz verl�sst oder eben einen Moment in Ruhe naachdenken willst, indem du
            PAUSE eingibst.";
        }
        else
        {
            "\bIn dieser Geschichte vergeht Zeit nur, wenn du einen Befehl eintippst.
            Das hei�t, dass nichts passiert, w�hrend die Geschichte auf deine Eingabe
            wartet. Jeder Befehl nimmt etwa die gleiche Zeit in Anspruch. Wenn du
            einfach abwarten und keine spezielle Aktion ausf�hren willst,
            weil du meinst, dass gerade etwas passieren wird, gib WARTE ein (oder
            nur Z). ";
        }
    }

    /* Saving, Restoring, and Undo chapter */
    showSaveRestoreChapter()
    {
        "\b<b>Speichern und Laden</b>
        \bDu kannst einen Schnappschuss deinen momentanen Position in der
        Geschichte speichern, so dass du sp�ter an derselben Stelle 
        weiterspielen kannst. Der Schnappschuss wird in eine Datei
        geschrieben, auf einem Datentr�ger gespeichert und du kannst
        beliebig viele dieser Schnappsch�sse speichern (sofern du gen�gend
        Speicherplatz auf dem Datentr�ger hast).\b";

        switch (crueltyLevel)
        {
        case 0:
            "In dieser Geschichte kannst du nicht sterben und du wirst in
            keine Situation geraten, wo es unm�glich ist, die Geschichte
            zu Ende zu bringen. Was dir auch immer passiert, du findest
            immer einen Ausweg. Damit musst du nicht in allen m�glichen
            Situationen speichern, um dich vor Sackgassen, aus denen du
            nicht mehr herauskommst, zu sch�tzen. Nat�rlich kannst du so
            oft speichern wie du willst, falls du die Geschichte sp�ter
            fortsetzen oder eine bestimmte Stelle sp�ter noch einmal 
            aufsuchen m�chtest, um eine andere L�sung oder einen anderen
            Weg zu probieren.";
            break;

        case 1:
        case 2:
            "Es kann passieren, dass du in dieser Geschichte stirbst, oder
            dich in eine Situation bringst, in der ein Beenden der Geschichte
            unm�glich ist. Also solltest du deinen Spielstand 
            <<crueltyLevel == 1 ? 'gelegentlich' : 'h�ufig'>> speichern, um
            nicht wieder ganz von vorn beginnen zu m�ssen, falls dies passiert. ";

            if (crueltyLevel == 2)
                "(Du solltest vorsichtshalber alle �lteren Spielst�nde aufheben
                statt sie zu �berschreiben, weil du unter Umst�nden nicht immer
                gleich merken wirst, wenn das Spiel ungewinnbar wird. Du wirst
                feststellen, manchmal weiter zur�ck gehen zu m�ssen, als deine
                letzte gespeicherte Position, die du als sicher betrachtest 
                hattest.)";
            break;
        }

        "\bTo save your position, type SAVE at the command prompt.
        The story will ask you for the name of a disk file to use to store
        snapshot.  You&rsquo;ll have to specify a filename suitable for
        your computer system, and the disk will need enough free space
        to store the file; you&rsquo;ll be told if there&rsquo;s any problem
        saving the file.  You should use a filename that doesn&rsquo;t already
        exist on your machine, because the new file will overwrite any
        existing file with the same name.

        \bDu kannst die Geschichte wieder fortsetzen, indem du LADEN eingibst.
        Die Geschichte fragt dich nach dem Namen der Datei, in die gespeichert
        wurde. Nach dem Lesen der Datei, ist der Zustand der Geschichte wieder
        exakt derselbe wie vor dem Speichern.";

        "\b<b>Undo</b>
        \bSogar wenn du den Spielstand nicht gespeichert hast, kannst du wenige
        Befehle zur�cknehmen, wenn du UNDO oder ZUR�CK eingibst. Jedes mal wenn
        du UNDO eingibst, nimmt die Geschichte einen Befehl zur�ck. Der Vorgang
        ist auf ein paar wenige Versuche beschr�nkt, so dass dies das Speichern
        nicht ersetzt, aber es ist gerade richtig, falls du unversehens in eine
        gef�hrliche Situation ger�tst und wieder zur�ck willst.";
    }

    /* Other Special Commands chapter */
    showSpecialCmdChapter()
    {
        "\b<b>Einige spezielle Befehle</b>
        \bDie Geschichte versteht einige spezielle Befehel, die n�tzlich sein
        k�nnen.

        \bNOCHMAL (oder nur G): Wiederholt den letzten Befehl. (Wenn dein
        letzter Befehl mehrere Befehle beinhaltet hatte, gilt das nur f�r den
        letzten Befehl an sich.)
        \bINVENTAR (oder nur I): Zeigt an, was du gerade angezogen hast und was
        du bei dir tr�gst.
        \bSCHAU (oder nur L): Zeigt die vollst�ndige Raumbeschreibung deines
        momentanen Aufenthaltsortes an.";

        /* if the exit lister module is active, mention the EXITS command */
        if (gExitLister != nil)
            "\bAUSGANG: Listet alle offensichtlichen Ausg�nge von deinem
            momentanen Aufenthaltsort auf.
            \bAUSGANG AN/AUS/STATUS/RAUM: Kontrolliert die Art und Weise, wie
            die Ausg�nge angezeigt werden. AUSGANG AN legt eine Liste der 
            Ausg�nge in der Statuszeile an und listet die Ausg�nge nochmals
            nach der Raumbeschreibung getrennt auf. AUSGANG AUS schaltet beide
            Anzeigen aus. AUSGANG STATUS zeigt die Ausg�nge nur in der Statuszeile
            und AUSGANG RAUM zeigt die Ausg�nge nur nach der Raumbeschreibung.";
        
        "\UPS: korrigiert ein einzelnes, vertipptes Wort in einem Befehl, ohne
        den ganze Eingabe wiederholen zu m�ssen. Des geht nur unmittelbar nach
        dem die Geschichte ein Wort in deinem Befehl nicht erkannt hat. Tippe
        UPS gefolgt von dem korrigierten Wort.
        \bENDE (oder nur Q): Beendet die Geschichte.
        \bNEUSTART: Beginnt die Geschichte von Neuem.
        \bLADEN: Stellt einen Spielstand wieder her, der zuvor mittels 
        SPEICHERN gespeichert wurde.
        \bSPEICHERN: Speichert den aktuellen Spielstand ein eine Datei.
        \bSKRIPT: Beginnt einen Mitschnitt deines Spiels und speichert
        deine Befehle und die Textausgabe in eine Datei, die du sp�ter
        ausdrucken oder weiterverwenden kannst.
        \bSKRIPT AUS: Beendet den Mitschnitt der mit SKRIPT gestartet wurde. 
        \bUNDO: Nimmt den letzten Befehl zur�ck.
        \bSPEICHER STANDARD: Speichert deine Einstellungen f�r Sachen wie
        NACHRICHT, AUSGANG und FUSSNOTEN als Standard. Das hei�t, deine
        Einstellungen werden automatisch wiederhergestellt, sobald du
        ein neues Spiel startest oder das Spiel neustartest.
        \bLADE STANDARD: Stellt die Einstellungen wieder her, die zuvor
        mit SPEICHER STANDARD gespeichert wurden. ";
    }
    
    /* Unknown Words chapter */
    showUnknownWordsChapter()
    {
        "\b<b>Unbekannte W�rter</b>
        \bDie Geschichte gibt nicht vor, jedes Wort der deutschen Sprache zu
        verstehen. Es mag vorkommen, dass die Geschichte W�rter, die sie in
        den Beschreibungen verwendet, nicht erkennt. Wenn du ein unbekanntes
        Wort eingibst, wird dir die Geschichte sagen, welches Wort das war.
        Wenn dies passiert und die Geschichte auch keine Synonyme f�r das Wort
        versteht, kannst du davon ausgehen, dass dieses Objekt f�r das Spiel
        nicht wichtig ist. ";
    }

    /* Ambiguous Commands chapter */
    showAmbiguousCmdChapter()
    {
        "\b<b>Mehrdeutige Befehle</b>
        \bWenn du in deinem Befehl etwas ausl�sst, versucht die Geschichte
        heraus zu finden, was genau du meinst. Wenn es offensichtlich ist,
        was du tun willst, macht die Geschichte einen Vorschlag und f�hrt
        den Befehl aus. Du siehst das Ergebnis in Klammern, um 
        Missverst�ndniss zu vermeiden. Zum Beispiel:

        \b
        \n\t &gt;BINDE DAS SEIL
        \n\t (an den Haken)
        \n\t Das Seil befindet sich nun am Haken. Das Ende des Seils erreicht
        \n\t fast den Boden der Grube unter dir.
        
        \bWenn der Befehl so unklar ist, dass die Geschichte nicht sicher
        entscheiden kann, was du meinst, wirst du nach genauerer Angabe
        gefragt. Beantworte die Frage, indem du die fehlende Information 
        eingibst.

        \b
        \n\t &gt;SPERR DIE T�R AUF
        \n\t Womit willst du sie aufsperren?
        \b
        \n\t &gt;SCHL�SSEL
        \n\t Meinst du den goldenen Schl�ssel, oder den silbernen Schl�ssel?
        \b
        \n\t &gt;GOLDENEN
        \n\t Aufgesperrt.

        \bWenn die Geschcihte eine Frage stellt und du nicht mit dem Befehl
        weitermachen willst ,kannst du auch einen ganz neuen Befehl eingeben,
        statt die Frage zu beantworten.";
    }

    /* Advance Command Formats chapter */
    showAdvancedCmdChapter()
    {
        "\b<b>Fortgeschrittene Befehlseingabe</b>
        \bBist du erst einmal mit der Eingabe der Befehle vertraut,
        gibt es ein paar komplexere Eingaben, die die Geschichte 
        versteht. Diese sind optional, weil du dasselbe Ergebnis 
        auch mit einfacheren Befehlen erreichen kannst, aber 
        erfahrene Spieler verwenden diese oft, um etwas Tipparbeit
        zu sparen.

        \b<b>Mehrere Objekte verwednen</b>
        \bIn den meisten Eingaben kannst du mehrere Objekte statt
        nur einem verwenden. Trenn die Objekte mit einem UND oder
        einem KOMMA:

        \b
        \n\t NIMM DIE SCHACHTEL, DIE CD UND DAS SEIL
        \n\t LEGE CD UND SEIL IN DIE SCHACHTEL
        \n\t LEGE SEIL UND SCHACHTEL AB
        
        \bDu kannst das Wort ALLES verwenden um dich auf alles
        erreichbare zu beziehen, oder AUSSER (direkt nach ALLES),
        um manche Objekte auszuschlie�en:

        \b
        \n\t NIMM ALLES
        \n\t LEG ALLES AUSSER DER CD UND DEM SEIL IN DIE SCHACHTEL
        \n\t NIMM ALLES AUS DER SCHACHTEL
        \n\t NIMM ALLES VOM REGAL

        \bALLES spricht alle Objekte an, die f�r den Befehl Sinn machen,
        bis auf Objekte in anderen Objekten. Zum Beispiel: Wenn du eine
        Schachtel und ein Seil bei dir tr�gst, und die Schachtel eine CD
        enth�lt, legst du mit LEG ALLES AB die Schachtel und das Seil ab,
        die CD bleibt aber in der Schachtel.

        \b<b><q>Es, ihn, sie</q> und <q>sie, ihnen</q></b>
        \bDu kannst die Artikel verwenden, um dich auf das letzte Objekt
        aus einem vorangegangenen Befehl zu beziehen, das dem jeweiligen Genus
        entsprach:

        \b
        \n\t NIMM DIE SCHACHTEL
        \n\t �FFNE SIE
        \n\t NIMM DIE CD UND DAS SEIL
        \n\t LEG SIE IN DIE SCHACHTEL
        
        \b<b>Mehrere Befehle auf einmal</b>
        \bDu kannst in einer Eingabezeile mehrere Befehele auf einmal
        eingeben, wenn du diese trennst durch einen PUNKT, durch ein KOMMA und
        DANN oder durch ein KOMMA oder ein UND. Zum Beispiel:

        \b
        \n\t NIMM DIE CD UND LEG SIE IN DIE SCHACHTEL
        \n\t NIMM DIE SCHACHTEL. �FFNE SIE
        \n\t SCHLIESS DIE T�R MIT DEM SCHL�SSEL AUF. �FFNE SIE, DANN GEH NACH NORDEN

        \bWenn die Geschichte einen dieser Befehle nicht versteht, wird dir gesagt,
        warum und alles in der Zeile danach ignoriert.";
    }

    /* General Tips chapter */
    showTipsChapter()
    {
        "\b<b>Ein paar Tipps</b>
        \bJetzt wo du einige technische Details bei der Befehlseingabe kennst,
        willst du vielleicht mehr �ber eine erfolgreiche Strategie zum
        Weiterkommen in der Geschichte lernen. Erfahrene Spieler gehen
        nach folgendem Schema vor:

        \bSCHAU alles AN, besonders wenn du einen neuen Ort betrittst. Das
        Untersuchen der Objekte f�rdert das ein oder andere Detail zu Tage,
        das aus der Raumbeschreibung nicht hervorgeht. Nennt die Geschichte
        weitere Teile an einem Objekt, untersuche diese auch.

        \bZeichne eine Karten, wenn die Geschichte mehr als ein paar Orte hat.
        Wenn du einen Ort betrittst, zeichne die Ausg�nge ein - so ist es leicht
        zu sehen, falls du einen Ausgang noch nichterkundet hast. Wenn du festh�ngst,
        erkunde die unerforschten Gebiete zuerst. Vielleicht findest du dort, was
        du gerade brauchst.

        \bWenn die Geschichte ein Wort oder Synonyme nicht erkennt, ist dieses
        Wort f�r die Geschichte wahrscheinlich nicht relevant. Wenn du mit
        etwas interagierst und die Meldung <q>das ist nicht wichtig</q> erscheint,
        kannst du dieses Objekt ziemlich wahrscheinlich ignorieren. Es existiert 
        eher der Atmosph�re wegen, nicht der Interaktion wegen.

        \bWenn du etwas tun willst und es partout nicht funktioniert, pass auf,
        warum es nicht geht. Wenn alles, was du versuchst, unter die Kategorie
        (<q>nichts passiert</q> oder <q>Das kannst du nicht �ffnen</q>) f�llt,
        bist du vielleicht einfach auf der falschen F�hrte. Geh einen Schritt
        zur�ck und denk dir alternative Wege aus, an das Problem heranzugehen.
        Wenn die Antwort etwas spezieller ausf�llt, k�nnte das ein wichtiger
        Hinweis sein. <q>Die Wache sagt, <q>Du kannst das hier nicht �ffnen!</q>\ 
        und schnappt sich die Schachtel aus deiner Hand.</q> Das k�nnte darauf
        hinweisen, dass du entweder die Wache dazu bringen musst, diesen Ort zu
        verlassen oder du eben die Schachtel woandershin mitnehmen musst, bevor
        du sie �ffnen kannst, zum Beispiel.

        \bWenn du ganz steckenbleibst, versuche das Problem zur�ck zu stellen
        und l�se erst ein anderes Problem. Oder speichere den Spielstand und
        mach eine Pause. Vielleicht kommt die Einsicht zur L�sung des Problems,
        wenn du es am wenigsten erwartest. Einige Geschichten spielt man besser
        �ber einen l�ngeren Zeitraum, und wenn dir die Geschichte gef�llt, warum
        sich dann abhetzten?

        \bLetztendlich, wenn alles schiefgeht, kannst du um Hilfe fragen. Ein
        guter Platz hierf�r ist das deutsche IF Forum unter
        <a href='http://forum.ifzentrale.de/'>http://forum.ifzentrale.de/</a>. ";

        "\n";
    }

    /* INSTRUCTIONS doesn't affect UNDO or AGAIN */
    isRepeatable = nil
    includeInUndo = nil
;


/* ------------------------------------------------------------------------ */
/*
 *   define the INSTRUCTIONS command's grammar 
 */
VerbRule(instructions) 'instruktion' : InstructionsAction
;


/* ------------------------------------------------------------------------ */
/*
 *   The instructions, rendered in menu form.  The menu format helps break
 *   up the instructions by dividing the instructions into chapters, and
 *   displaying a menu that lists the chapters.  This way, players can
 *   easily go directly to the chapters they're most interested in, but
 *   can also still read through the whole thing fairly easily.
 *   
 *   To avoid creating an unnecessary dependency on the menu subsystem for
 *   games that don't want the menu-style instructions, we'll only define
 *   the menu objects if the preprocessor symbol INSTRUCTIONS_MENU is
 *   defined.  So, if you want to use the menu-style instructions, just
 *   add -D INSTRUCTIONS_MENU to your project makefile.  
 */
#ifdef INSTRUCTIONS_MENU

/* a base class for the instruction chapter menus */
class InstructionsMenu: MenuLongTopicItem
    /* 
     *   present the instructions in "chapter" format, so that we can
     *   navigate from one chapter directly to the next 
     */
    isChapterMenu = true

    /* the InstructionsAction property that we invoke to show our chapter */
    chapterProp = nil

    /* don't use a heading, as we provide our own internal chapter titles */
    heading = ''

    /* show our chapter text */
    menuContents = (InstructionsAction.(self.chapterProp)())
;

InstructionsMenu template 'title' ->chapterProp;

/*
 *   The main instructions menu.  This can be used as a top-level menu;
 *   just call the 'display()' method on this object to display the menu.
 *   This can also be used as a sub-menu of any other menu, simply by
 *   inserting this menu into a parent menu's 'contents' list.  
 */
topInstructionsMenu: MenuItem 'Wie man Interactive Fiction spielt';

/* the chapter menus */
+ MenuLongTopicItem
    isChapterMenu = true
    title = 'Einf�hrung'
    heading = nil
    menuContents =
        "\b<b>Einf�hrung</b>
        \bWillkommen! Wenn du noch nie zuvor Interactive Fiction
        gespielt hast, k�nnen dir diese Informationen weiterhelfen.
        Wenn du bereits wei�t, wie man diese Art von Spiel spielt,
        wirst du wahrscheinlich auf diese ausf�hrlichen Instruktionen
        verzichten k�nnen, aber vielleicht gibt es mit INFO noch
        einige wichtige Hinweise auf die speziellen Funktionen dieser
        Geschichte.
        \b
        Um das Ganze �bersichtlicher zu machen, ist der Inhalt in
        Kapitel untergliedert. Am Ende jedes Kapitels dr�ckst du 
        <b><<curKeyList[M_SEL][1].toUpper()>></b> um zu dem n�chsten
        Kapitel zu gelangen, oder <b><<curKeyList[M_PREV][1].toUpper()>></b>
        um zur Kapitel�bersicht zur�ck zu gelangen. "
;

+ InstructionsMenu 'Eingeben von Befehlen' ->(&showCommandsChapter);
+ InstructionsMenu 'Abk�rzungen' ->(&showAbbrevChapter);
+ InstructionsMenu 'Fortbewegung' ->(&showTravelChapter);
+ InstructionsMenu 'Interaktion mit Objekten' ->(&showObjectsChapter);
+ InstructionsMenu 'Interaktion mit anderen Charakteren'
    ->(&showConversationChapter);
+ InstructionsMenu 'Zeit' ->(&showTimeChapter);
+ InstructionsMenu 'Speichern und Laden' ->(&showSaveRestoreChapter);
+ InstructionsMenu 'Spezielle Befehle' ->(&showSpecialCmdChapter);
+ InstructionsMenu 'Unbekannte W�rter' ->(&showUnknownWordsChapter);
+ InstructionsMenu 'Mehrdeutige Befehle' ->(&showAmbiguousCmdChapter);
+ InstructionsMenu 'Fortgeschrittene Befehle' ->(&showAdvancedCmdChapter);
+ InstructionsMenu 'Ein paar Tipps' ->(&showTipsChapter);

#endif /* INSTRUCTIONS_MENU */

