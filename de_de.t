#charset "latin1"

/*
 *   Copyright 2000, 2006 Michael J. Roberts.  All Rights Reserved.
 *.  Past-tense extensions written by Michel Nizette, and incorporated by
 *   permission.
 *   
 *   We have attempted to isolate here the parts of the library that are
 *   language-specific, so that translations to other languages or dialects
 *   can be created by replacing this module, without changing the rest of
 *   the library.
 *   
 *   In addition to this module, a separate set of US English messages are
 *   defined in the various msg_xxx.t modules.  Those modules define
 *   messages in English for different stylistic variations.  For a given
 *   game, the author must select one of the message modules - but only
 *   one, since they all define variations of the same messages.  To
 *   translate the library, a translator must create at least one module
 *   defining those messages as well; only one message module is required
 *   per language.
 *   
 *   The past-tense system was contributed by Michel Nizette.
 *   
 *.                                  -----
 *   
 *   "Watch an immigrant struggling with a second language or a stroke
 *   patient with a first one, or deconstruct a snatch of baby talk, or try
 *   to program a computer to understand English, and ordinary speech
 *   begins to look different."
 *   
 *.         Stephen Pinker, "The Language Instinct"
 */

/*
 *   TADS 3 Library - German (German variant) implementation by Michael Baltes
 *   
 *   -- This defines the parts of the TADS 3 library that are specific to the
 *   -- German language as spoken (and written) in Germany.
 *   
 */

#include "tads.h"
#include "tok.h"
#include "adv3.h"
#include "de_de.h"
#include <vector.h>
#include <dict.h>
#include <gramprod.h>
#include <strcomp.h>

// -- setup of version info for Library

libraryInfo: object
    version = '2.2 - 150930'
;

/* ------------------------------------------------------------------------ */
/*
 *   Fill in the default language for the GameInfo metadata class.
 */
modify GameInfoModuleID
    languageCode = 'de-de'
;

/* ------------------------------------------------------------------------ */
/*
 *   Simple yes/no confirmation.  The caller must display a prompt; we'll
 *   read a command line response, then return true if it's an affirmative
 *   response, nil if not.
 */
yesOrNo()
{
    /* switch to no-command mode for the interactive input */
    "<.commandnone>";

    /*
     *   Read a line of input.  Do not allow real-time event processing;
     *   this type of prompt is used in the middle of a command, so we
     *   don't want any interruptions.  Note that the caller must display
     *   any desired prompt, and since we don't allow interruptions, we
     *   won't need to redisplay the prompt, so we pass nil for the prompt
     *   callback.
     */
    local str = inputManager.getInputLine(nil, nil);

    /* switch back to mid-command mode */
    "<.commandmid>";

    /*   ##### 'J' instead if 'y' #####
     *   If they answered with something starting with 'J', it's
     *   affirmative, otherwise it's negative.  In reading the response,
     *   ignore any leading whitespace.
     */
    return rexMatch('<space>*[jJ]', str) != nil;
}

/* ------------------------------------------------------------------------ */
/*
 *   During start-up, install a case-insensitive truncating comparator in
 *   the main dictionary.
 */
PreinitObject
    execute()
    {
        /* set up the main dictionary's comparator */
        languageGlobals.setStringComparator(
            new StringComparator(gameMain.parserTruncLength, nil, [['\u00DF','ss',0,0],['\u00F6','oe',0,0],['\u00E4','ae',0,0],['\u00FC','ue',0,0]]));
    }

    /*
     *   Make sure we run BEFORE the main library preinitializer, so that
     *   we install the comparator in the dictionary before we add the
     *   vocabulary words to the dictionary.  This doesn't make any
     *   difference in terms of the correctness of the dictionary, since
     *   the dictionary will automatically rebuild itself whenever we
     *   install a new comparator, but it makes the preinitialization run
     *   a tiny bit faster by avoiding that rebuild step.
     */
    execAfterMe = [adv3LibPreinit]
;

/* ------------------------------------------------------------------------ */
/*
 *   Language-specific globals
 */
languageGlobals: object
    /*
     *   Set the StringComparator object for the parser.  This sets the
     *   comparator that's used in the main command parser dictionary. 
     */
    setStringComparator(sc)
    {
        /* remember it globally, and set it in the main dictionary */
        dictComparator = sc;
        cmdDict.setComparator(sc);
    }
    
    /*
     *   The character to use to separate groups of digits in large
     *   numbers.  US English uses commas; most Europeans use periods.
     *
     *   Note that this setting does not affect system-level BigNumber
     *   formatting, but this information can be passed when calling
     *   BigNumber formatting routines.
     */
    
    // ##### Changed into period #####
    digitGroupSeparator = '.'

    /*
     *   The decimal point to display in floating-point numbers.  US
     *   English uses a period; most Europeans use a comma.
     *
     *   Note that this setting doesn't affect system-level BigNumber
     *   formatting, but this information can be passed when calling
     *   BigNumber formatting routines.
     */
    // ##### Changed into comma #####
    decimalPointCharacter = ','

    /* the main dictionary's string comparator */
    dictComparator = nil
;


/* ------------------------------------------------------------------------ */
/*
 *   Language-specific extension of the default gameMain object
 *   implementation.
 */
modify GameMainDef
    
    /*
     *   Option setting: the parser's truncation length for player input.
     *   As a convenience to the player, we can allow the player to
     *   truncate long words, entering only the first, say, 6 characters.
     *   For example, rather than typing "x flashlight", we could allow the
     *   player to simply type "x flashl" - truncating "flashlight" to six
     *   letters.
     *   
     *   We use a default truncation length of 6, but games can change this
     *   by overriding this property in gameMain.  We use a default of 6
     *   mostly because that's what the old Infocom games did - many
     *   long-time IF players are accustomed to six-letter truncation from
     *   those games.  Shorter lengths are superficially more convenient
     *   for the player, obviously, but there's a trade-off, which is that
     *   shorter truncation lengths create more potential for ambiguity.
     *   For some games, a longer length might actually be better for the
     *   player, because it would reduce spurious ambiguity due to the
     *   parser matching short input against long vocabulary words.
     *   
     *   If you don't want to allow the player to truncate long words at
     *   all, set this to nil.  This will require the player to type every
     *   word in its entirety.
     *   
     *   Note that changing this property dynamicaly will have no effect.
     *   The library only looks at it once, during library initialization
     *   at the very start of the game.  If you want to change the
     *   truncation length dynamically, you must instead create a new
     *   StringComparator object with the new truncation setting, and call
     *   languageGlobals.setStringComparator() to select the new object.  
     */
    // #################################################
    // ## modified (standard = 6) because of rather   ##
    // ## "long" words like 'Schlüsselbund' in German ##
    // #################################################
    parserTruncLength = 16 

    /*
     *   Option: are we currently using a past tense narrative?  By
     *   default, we aren't.
     *
     *   This property can be reset at any time during the game in order to
     *   switch between the past and present tenses.  The macro
     *   setPastTense can be used for this purpose: it just provides a
     *   shorthand for setting gameMain.usePastTense directly.
     *
     *   Authors who want their game to start in the past tense can achieve
     *   this by overriding this property on their gameMain object and
     *   giving it a value of true.
     */
    usePastTense = nil
;


/* ------------------------------------------------------------------------ */
/*
 *   Language-specific modifications for ThingState.
 */
modify ThingState
    /*
     *   Our state-specific tokens.  This is a list of vocabulary words
     *   that are state-specific: that is, if a word is in this list, the
     *   word can ONLY refer to this object if the object is in a state
     *   with that word in its list.
     *   
     *   The idea is that you set up the object's "static" vocabulary with
     *   the *complete* list of words for all of its possible states.  For
     *   example:
     *   
     *.     + Matchstick 'lit unlit match';
     *   
     *   Then, you define the states: in the "lit" state, the word 'lit' is
     *   in the stateTokens list; in the "unlit" state, the word 'unlit' is
     *   in the list.  By putting the words in the state lists, you
     *   "reserve" the words to their respective states.  When the player
     *   enters a command, the parser will limit object matches so that the
     *   reserved state-specific words can only refer to objects in the
     *   corresponding states.  Hence, if the player refers to a "lit
     *   match", the word 'lit' will only match an object in the "lit"
     *   state, because 'lit' is a reserved state-specific word associated
     *   with the "lit" state.
     *   
     *   You can re-use a word in multiple states.  For example, you could
     *   have a "red painted" state and a "blue painted" state, along with
     *   an "unpainted" state.
     */
    stateTokens = []

    /*
     *   Match the name of an object in this state.  We'll check the token
     *   list for any words that apply only to *other* states the object
     *   can assume; if we find any, we'll reject the match, since the
     *   phrase must be referring to an object in a different state.
     */
    matchName(obj, origTokens, adjustedTokens, states)
    {
        /* scan each word in our adjusted token list */
        for (local i = 1, local len = adjustedTokens.length() ;
             i <= len ; i += 2)
        {
            /* get the current token */
            local cur = adjustedTokens[i];

            /*
             *   If this token is in our own state-specific token list,
             *   it's acceptable as a match to this object.  (It doesn't
             *   matter whether or not it's in any other state's token list
             *   if it's in our own, because its presence in our own makes
             *   it an acceptable matching word when we're in this state.) 
             */
            if (stateTokens.indexWhich({t: t == cur}) != nil)
                continue;

            /*
             *   It's not in our own state-specific token list.  Check to
             *   see if the word appears in ANOTHER state's token list: if
             *   it does, then this word CAN'T match an object in this
             *   state, because the token is special to that other state
             *   and thus can't refer to an object in a state without the
             *   token. 
             */
            if (states.indexWhich(
                {s: s.stateTokens.indexOf(cur) != nil}) != nil)
                return nil;
        }

        /* we didn't find any objection, so we can match this phrase */
        return obj;
    }

    /*
     *   Check a token list for any tokens matching any of our
     *   state-specific words.  Returns true if we find any such words,
     *   nil if not.
     *
     *   'toks' is the *adjusted* token list used in matchName().
     */
    findStateToken(toks)
    {
        /*
         *   Scan the token list for a match to any of our state-specific
         *   words.  Since we're using the adjusted token list, every
         *   other entry is a part of speech, so work through the list in
         *   pairs.
         */
        for (local i = 1, local len = toks.length() ; i <= len ; i += 2)
        {
            /*
             *   if this token matches any of our state tokens, indicate
             *   that we found a match
             */
            if (stateTokens.indexWhich({x: x == toks[i]}) != nil)
                return true;
        }

        /* we didn't find a match */
        return nil;
    }

    /* get our name */
    listName(lst) { return listName_; }

    /*
     *   our list name setting - we define this so that we can be easily
     *   initialized with a template (we can't initialize listName()
     *   directly in this manner because it's a method, but we define the
     *   listName() method to simply return this property value, which we
     *   can initialize with a template)
     */
    listName_ = nil
;

/* ------------------------------------------------------------------------ */
/*
 *   Language-specific modifications for VocabObject.
 */
modify VocabObject
    /*
     *   The vocabulary initializer string for the object - this string
     *   can be initialized (most conveniently via a template) to a string
     *   of this format:
     *
     *   'adj adj adj noun/noun/noun*plural plural plural'
     *
     *   The noun part of the string can be a hyphen, '-', in which case
     *   it means that the string doesn't specify a noun or plural at all.
     *   This can be useful when nouns and plurals are all inherited from
     *   base classes, and only adjectives are to be specified.  (In fact,
     *   any word that consists of a single hyphen will be ignored, but
     *   this is generally only useful for the adjective-only case.)
     *
     *   During preinitialization, we'll parse this string and generate
     *   dictionary entries and individual vocabulary properties for the
     *   parts of speech we find.
     *
     *   Note that the format described above is specific to the English
     *   version of the library.  Non-English versions will probably want
     *   to use different formats to conveniently encode appropriate
     *   language-specific information in the initializer string.  See the
     *   comments for initializeVocabWith() for more details.
     *
     *   You can use the special wildcard # to match any numeric
     *   adjective.  This only works as a wildcard when it stands alone,
     *   so a string like "7#" is matched as that literal string, not as a
     *   wildcard.  If you want to use a pound sign as a literal
     *   adjective, just put it in double quotes.
     *
     *   You can use the special wildcard "\u0001" (include the double
     *   quotes within the string) to match any literal adjective.  This
     *   is the literal adjective equivalent of the pound sign.  We use
     *   this funny character value because it is unlikely ever to be
     *   interesting in user input.
     *
     *   If you want to match any string for a noun and/or adjective, you
     *   can't do it with this property.  Instead, just add the property
     *   value noun='*' to the object.
     */
    vocabWords = ''

    /*
     *   On dynamic construction, initialize our vocabulary words and add
     *   them to the dictionary.
     */
    construct()
    {
        /* initialize our vocabulary words from vocabWords */
        initializeVocab();
        
        /* add our vocabulary words to the dictionary */
        addToDictionary(&noun);
        addToDictionary(&adjective);
        addToDictionary(&plural);
        addToDictionary(&adjApostS);
        addToDictionary(&literalAdjective);
        addToDictionary(&maleSyn);   // ##### new dictionary property for changing gender #####
        addToDictionary(&femaleSyn); // ##### new dictionary property for changing gender #####
        addToDictionary(&neuterSyn); // ##### new dictionary property for changing gender #####
        addToDictionary(&pluralSyn); // ##### new dictionary property for changing gender #####
        
        addToDictionary(&irregularNWord); // ##### new dictionary property for keinen(txt) #####
    }

    /* add the words from a dictionary property to the global dictionary */
    addToDictionary(prop)
    {
        /* if we have any words defined, add them to the dictionary */
        if (self.(prop) != nil)
            cmdDict.addWord(self, self.(prop), prop);
    }

    /* initialize the vocabulary from vocabWords */
    initializeVocab()
    {
        /* inherit vocabulary from this class and its superclasses */
        inheritVocab(self, new Vector(10));
    }

    /*
     *   Inherit vocabulary from this class and its superclasses, adding
     *   the words to the given target object.  'target' is the object to
     *   which we add our vocabulary words, and 'done' is a vector of
     *   classes that have been visited so far.
     *
     *   Since a class can be inherited more than once in an inheritance
     *   tree (for example, a class can have multiple superclasses, each
     *   of which have a common base class), we keep a vector of all of
     *   the classes we've visited.  If we're already in the vector, we'll
     *   skip adding vocabulary for this class or its superclasses, since
     *   we must have already traversed this branch of the tree from
     *   another subclass.
     */
    inheritVocab(target, done)
    {
        /*
         *   if we're in the list of classes handled already, don't bother
         *   visiting me again
         */
        if (done.indexOf(self) != nil)
            return;

        /* add myself to the list of classes handled already */
        done.append(self);

        /* 
         *   add words from our own vocabWords to the target object (but
         *   only if it's our own - not if it's only inherited, as we'll
         *   pick up the inherited ones explicitly in a bit) 
         */
        if (propDefined(&vocabWords, PropDefDirectly))
            target.initializeVocabWith(vocabWords);

        /* add vocabulary from each of our superclasses */
        foreach (local sc in getSuperclassList())
            sc.inheritVocab(target, done);
    }

    /*
     *   Initialize our vocabulary from the given string.  This parses the
     *   given vocabulary initializer string and adds the words defined in
     *   the string to the dictionary.
     *
     *   Note that this parsing is intentionally located in the
     *   English-specific part of the library, because it is expected that
     *   other languages will want to define their own vocabulary
     *   initialization string formats.  For example, a language with
     *   gendered nouns might want to use gendered articles in the
     *   initializer string as an author-friendly way of defining noun
     *   gender; languages with inflected (declined) nouns and/or
     *   adjectives might want to encode inflected forms in the
     *   initializer.  Non-English language implementations are free to
     *   completely redefine the format - there's no need to follow the
     *   conventions of the English format in other languages where
     *   different formats would be more convenient.
     */
    initializeVocabWith(str)
    {
        local sectPart;
        local modList = [];
        
        /* start off in the adjective section */
        sectPart = &adjective;

        /* scan the string until we run out of text */
        while (str != '')
        {
            local len;
            local cur;
            local cut;
            
            /*
             *   if it starts with a quote, find the close quote;
             *   otherwise, find the end of the current token by seeking
             *   the next delimiter
             */
            if (str.startsWith('"'))
            {
                /* find the close quote */
                len = str.find('"', 2);
            }
            else
            {
                /* no quotes - find the next delimiter */
                len = rexMatch('<^space|star|/>*', str);
            }

            /* if there's no match, use the whole rest of the string */
            if (len == nil)
                len = str.length();

            /* if there's anything before the delimiter, extract it */
            if (len != 0)
            {
                /* extract the part up to but not including the delimiter */
                cur = str.substr(1, len);

                /*
                 *   if we're in the adjectives, and either this is the
                 *   last token or the next delimiter is not a space, this
                 *   is implicitly a noun
                 */
                if (sectPart == &adjective
                    && (len == str.length()
                        || str.substr(len + 1, 1) != ' '))
                {
                    /* move to the noun section */
                    sectPart = &noun;
                }

                /*
                 *   if the word isn't a single hyphen (in which case it's
                 *   a null word placeholder, not an actual vocabulary
                 *   word), add it to our own appropriate part-of-speech
                 *   property and to the dictionary
                 */
                if (cur != '-')
                {
                    /*
                     *   by default, use the part of speech of the current
                     *   string section as the part of speech for this
                     *   word
                     */
                    local wordPart = sectPart;

                    /*
                     *   Check for parentheses, which indicate that the
                     *   token is "weak."  This doesn't affect anything
                     *   about the token or its part of speech except that
                     *   we must include the token in our list of weak
                     *   tokens.
                     */
                    if (cur.startsWith('(') && cur.endsWith(')'))
                    {
                        /* it's a weak token - remove the parens */
                        cur = cur.substr(2, cur.length() - 2);

                        /*
                         *   if we don't have a weak token list yet,
                         *   create the list
                         */
                        if (weakTokens == nil)
                            weakTokens = [];

                        /* add the token to the weak list */
                        weakTokens += cur;
                    }

                    // ##################################################
                    // ## new dictionary property &irregularNWord      ##
                    // ## for synonyms with a -n accusative ending, as ##
                    // ## in "affe[-n]" for keinen(txt) and viele(txt) ##
                    // ## "Du siehst hier keinen Affen. "              ##
                    // ##################################################
                    
                    if (cur.endsWith('[-n]'))
                    {

                        /* change the part of speech to 'irregularNWord' */
                        wordPart = &irregularNWord;

                        /* remove the '[-n]' suffix from the string */
                        cur = cur.substr(1, cur.length() - 4);
                        
                        // ##### remove possible changing genders before adding it #####
                        
                        if (cur.endsWith('[m]') || cur.endsWith('[f]') || cur.endsWith('[n]') ||cur.endsWith('[p]'))
                            cut = cur.substr(1, cur.length() - 3);
                        else 
                            cut = cur;
                            
                        /* add it to the dictionary */
                        cmdDict.addWord(self, cut, wordPart);
                        
                        /* move to the noun section */
                        wordPart = sectPart;
                    } 
                    
                    /*
                     *   Check for special formats: quoted strings,
                     *   apostrophe-S words.  These formats are mutually
                     *   exclusive.
                     */
                    if (cur.startsWith('"'))
                    {
                        /*
                         *   It's a quoted string, so it's a literal
                         *   adjective.
                         */

                        /* remove the quote(s) */
                        if (cur.endsWith('"'))
                            cur = cur.substr(2, cur.length() - 2);
                        else
                            cur = cur.substr(2);

                        /* change the part of speech to 'literal adjective' */
                        wordPart = &literalAdjective;
                    }
                    else if (cur.endsWith('\'s'))
                    {
                        /*
                         *   It's an apostrophe-s word.  Remove the "'s"
                         *   suffix and add the root word using adjApostS
                         *   as the part of speech.  The grammar rules are
                         *   defined to allow this part of speech to be
                         *   used exclusively with "'s" suffixes in input.
                         *   Since the tokenizer always pulls the "'s"
                         *   suffix off of a word in the input, we have to
                         *   store any vocabulary words with "'s" suffixes
                         *   the same way, with the "'s" suffixes removed.
                         */

                        /* change the part of speech to adjApostS */
                        wordPart = &adjApostS;

                        /* remove the "'s" suffix from the string */
                        cur = cur.substr(1, cur.length() - 2);
                    }
                    // -- German changing gender  -- if a string endswith [m] -> 
                    // cut it off and add it to maleSyn
                    else if (cur.endsWith('[m]'))
                    {
                        /*
                         *   It's a maleSyn, a synonym for an object which 
                         *   has another gender than the object itself
                         */

                        /* change the part of speech to 'maleSyn' */
                        wordPart = &maleSyn;

                        /* remove the '[m]' suffix from the string */
                        cur = cur.substr(1, cur.length() - 3);
                    }
                    // -- German changing gender  -- if a string endswith [f] -> 
                    // cut it off and add it to femaleSyn
                    else if (cur.endsWith('[f]'))
                    {
                        /*
                         *   It's a femaleSyn, a synonym for an object which 
                         *   has another gender than the object itself
                         */

                        /* change the part of speech to 'femaleSyn' */
                        wordPart = &femaleSyn;

                        /* remove the '[f]' suffix from the string */
                        cur = cur.substr(1, cur.length() - 3);
                    }
                    // -- German changing gender  -- if a string endswith [n] -> 
                    // cut it off and add it to neuterSyn
                    else if (cur.endsWith('[n]'))
                    {
                        /*
                         *   It's a neuterSyn, a synonym for an object which 
                         *   has another gender than the object itself
                         */

                        /* change the part of speech to 'neuterSyn' */
                        wordPart = &neuterSyn;

                        /* remove the '[n]' suffix from the string */
                        cur = cur.substr(1, cur.length() - 3);
                    }
                    // -- German changing gender  -- if a string endswith [p] -> 
                    // cut it off and add it to pluralSyn
                    else if (cur.endsWith('[p]'))
                    {
                        /*
                         *   It's a pluralSyn, a synonym for an object which 
                         *   has another gender than the object itself
                         */

                        /* change the part of speech to 'pluralSyn' */
                        wordPart = &pluralSyn;

                        /* remove the '[p]' suffix from the string */
                        cur = cur.substr(1, cur.length() - 3);
                    }
                    
                    // #############################################
                    // ## we put all vocabWords in ...Syn because ##
                    // ## we need this for correct disambiguation ##
                    // #############################################
                    
                    if (wordPart == &noun) {
                        if (self.isHim)
                            wordPart = &maleSyn;
                        else if (self.isHer)
                            wordPart = &femaleSyn;
                        else if (self.isPlural)
                            wordPart = &pluralSyn;
                        else
                            wordPart = &neuterSyn;
                    }
                    
                    /* add the word to our own list for this part of speech */
                    if (self.(wordPart) == nil)
                        self.(wordPart) = [cur];
                    else
                        self.(wordPart) += cur;

                    /* add it to the dictionary */
                    cmdDict.addWord(self, cur, wordPart);
                   
                    if (cur.endsWith('.'))
                    {
                        local abbr;

                        /*
                         *   It ends with a period, so this is an
                         *   abbreviated word.  Enter the abbreviation
                         *   both with and without the period.  The normal
                         *   handling will enter it with the period, so we
                         *   only need to enter it specifically without.
                         */
                        abbr = cur.substr(1, cur.length() - 1);
                        self.(wordPart) += abbr;
                        cmdDict.addWord(self, abbr, wordPart);
                    }

                    /* note that we added to this list */
                    if (modList.indexOf(wordPart) == nil)
                        modList += wordPart;
                }
            }

            /* if we have a delimiter, see what we have */
            if (len + 1 < str.length())
            {
                /* check the delimiter */
                switch(str.substr(len + 1, 1))
                {
                case ' ':
                    /* stick with the current part */
                    break;

                case '*':
                    /* start plurals */
                    sectPart = &plural;
                    break;

                case '/':
                    /* start alternative nouns */
                    sectPart = &noun;
                    break;
                }

                /* remove the part up to and including the delimiter */
                str = str.substr(len + 2);

                /* skip any additional spaces following the delimiter */
                if ((len = rexMatch('<space>+', str)) != nil)
                    str = str.substr(len + 1);
            }
            else
            {
                /* we've exhausted the string - we're done */
                break;
            }
        }

        /* uniquify each word list we updated */
        foreach (local p in modList)
            self.(p) = self.(p).getUnique();
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Language-specific modifications for Thing.  This class contains the
 *   methods and properties of Thing that need to be replaced when the
 *   library is translated to another language.
 *   
 *   The properties and methods defined here should generally never be used
 *   by language-independent library code, because everything defined here
 *   is specific to English.  Translators are thus free to change the
 *   entire scheme defined here.  For example, the notions of number and
 *   gender are confined to the English part of the library; other language
 *   implementations can completely replace these attributes, so they're
 *   not constrained to emulate their own number and gender systems with
 *   the English system.  
 */
modify Thing
    /*
     *   Flag that this object's name is rendered as a plural (this
     *   applies to both a singular noun with plural usage, such as
     *   "pants" or "scissors," and an object used in the world model to
     *   represent a collection of real-world objects, such as "shrubs").
     */
    isPlural = nil

    /*
     *   Flag that this is object's name is a "mass noun" - that is, a
     *   noun denoting a continuous (effectively infinitely divisible)
     *   substance or material, such as water, wood, or popcorn; and
     *   certain abstract concepts, such as knowledge or beauty.  Mass
     *   nouns are never rendered in the plural, and use different
     *   determiners than ordinary ("count") nouns: "some popcorn" vs "a
     *   kernel", for example.
     */
    isMassNoun = nil

    /*
     *   Flags indicating that the object should be referred to with
     *   gendered pronouns (such as 'he' or 'she' rather than 'it').
     *
     *   Note that these flags aren't mutually exclusive, so it's legal
     *   for the object to have both masculine and feminine usage.  This
     *   can be useful when creating collective objects that represent
     *   more than one individual, for example.
     */
    isHim = nil    // ##### for masculine nouns #####
    isHer = nil    // ##### for feminine nouns  #####
    isYours = nil  // ##### new property for yours, this adds a "dein/mein/sein" before derName, etc. #####
                   // ##### but does not(!) set the owner property, do this by owner = ...            #####
                   // ##### In the original library this is obsolete, as they use name = 'your cat'   #####
    isDefinite = nil    // ##### for thing that have only the definite #####
                        // ##### article like "Der junge Werther"      #####
    
    /*
     *   Flag indicating that the object can be referred to with a neuter
     *   pronoun ('it').  By default, this is true if the object has
     *   neither masculine nor feminine gender, but it can be overridden
     *   so that an object has both gendered and ungendered usage.  This
     *   can be useful for collective objects, as well as for cases where
     *   gendered usage varies by speaker or situation, such as animals.
     */
    isIt // ##### for neuter nouns #####
    {
        /* by default, we're an 'it' if we're not a 'him' or a 'her' or a pluralword */
        return !(isHim || isHer || isPlural);
    }

    /*
     *   Test to see if we can match the pronouns 'him', 'her', 'it', and
     *   'them'.  By default, these simply test the corresponding isXxx
     *   flags (except 'canMatchThem', which tests 'isPlural' to see if the
     *   name has plural usage).
     */
    canMatchHim = (isHim)
    canMatchHer = (isHer)
    canMatchIt = (isIt)
    canMatchThem = (isPlural)
    
    // ####################################################################
    // ## special flag which is used to check if the player refers to    ##
    // ## an synonym word, which has another gender as the object itself ##
    // ## e.g: 'die Jacke', but 'der Anorak'                             ##
    // ####################################################################
    
    maleSynFlag = nil
    femaleSynFlag = nil
    neuterSynFlag = nil
    pluralSynFlag = nil

    /* can we match the given PronounXxx pronoun type specifier? */
    canMatchPronounType(typ)
    {
        /* check the type, and return the appropriate indicator property */
        switch (typ)
        {
        case PronounHim:
            return canMatchHim;

        case PronounHer:
            return canMatchHer;

        case PronounIt:
            return canMatchIt;

        case PronounThem:
            return canMatchThem;

        default:
            return nil;
        }
    }

    /*
     *   The grammatical cardinality of this item when it appears in a
     *   list.  This is used to ensure verb agreement when mentioning the
     *   item in a list of items.  ("Cardinality" is a fancy word for "how
     *   many items does this look like").
     *
     *   English only distinguishes two degrees of cardinality in its
     *   grammar: one, or many.  That is, when constructing a sentence, the
     *   only thing the grammar cares about is whether an object is
     *   singular or plural: IT IS on the table, THEY ARE on the table.
     *   Since English only distinguishes these two degrees, two is the
     *   same as a hundred is the same as a million for grammatical
     *   purposes, so we'll consider our cardinality to be 2 if we're
     *   plural, 1 otherwise.
     *
     *   Some languages don't express cardinality at all in their grammar,
     *   and others distinguish cardinality in greater detail than just
     *   singular-vs-plural, which is why this method has to be in the
     *   language-specific part of the library.
     */
    listCardinality(lister) { return isPlural ? 2 : 1; }

    /*
     *   Proper name flag.  This indicates that the 'name' property is the
     *   name of a person or place.  We consider proper names to be fully
     *   qualified, so we don't add articles for variations on the name
     *   such as 'theName'.
     */
    isProperName = nil

    /*
     *   Qualified name flag.  This indicates that the object name, as
     *   given by the 'name' property, is already fully qualified, so
     *   doesn't need qualification by an article like "the" or "a" when
     *   it appears in a sentence.  By default, a name is considered
     *   qualified if it's a proper name, but this can be overridden to
     *   mark a non-proper name as qualified when needed.
     */
    isQualifiedName = (isProperName)

    /*
     *   The name of the object - this is a string giving the object's
     *   short description, for constructing sentences that refer to the
     *   object by name.  Each instance should override this to define the
     *   name of the object.  This string should not contain any articles;
     *   we use this string as the root to generate various forms of the
     *   object's name for use in different places in sentences.
     */
    name = ''

    /*
     *   The name of the object, for the purposes of disambiguation
     *   prompts.  This should almost always be the object's ordinary
     *   name, so we return self.name by default.
     *
     *   In rare cases, it might be desirable to override this.  In
     *   particular, if a game has two objects that are NOT defined as
     *   basic equivalents of one another (which means that the parser
     *   will always ask for disambiguation when the two are ambiguous
     *   with one another), but the two nonetheless have identical 'name'
     *   properties, this property should be overridden for one or both
     *   objects to give them different names.  This will ensure that we
     *   avoid asking questions of the form "which do you mean, the coin,
     *   or the coin?".  In most cases, non-equivalent objects will have
     *   distinct 'name' properties to begin with, so this is not usually
     *   an issue.
     *
     *   When overriding this method, take care to override
     *   theDisambigName, aDisambigName, countDisambigName, and/or
     *   pluralDisambigName as needed.  Those routines must be overridden
     *   only when the default algorithms for determining articles and
     *   plurals fail to work properly for the disambigName (for example,
     *   the indefinite article algorithm fails with silent-h words like
     *   "hour", so if disambigName is "hour", aDisambigName must be
     *   overridden).  In most cases, the automatic algorithms will
     *   produce acceptable results, so the default implementations of
     *   these other routines can be used without customization.
     */
    disambigName = (name)

    /*
     *   The "equivalence key" is the value we use to group equivalent
     *   objects.  Note that we can only treat objects as equivalent when
     *   they're explicitly marked with isEquivalent=true, so the
     *   equivalence key is irrelevant for objects not so marked.
     *   
     *   Since the main point of equivalence is to allow creation of groups
     *   of like-named objects that are interchangeable in listings and in
     *   command input, we use the basic disambiguation name as the
     *   equivalence key.  
     */
    equivalenceKey = (disambigName)

    /*
     *   The definite-article name for disambiguation prompts.
     *
     *   By default, if the disambiguation name is identical to the
     *   regular name (i.e, the string returned by self.disambigName is
     *   the same as the string returned by self.name), then we simply
     *   return self.theName.  Since the base name is the same in either
     *   case, presumably the definite article names should be the same as
     *   well.  This way, if the object overrides theName to do something
     *   special, then we'll use the same definite-article name for
     *   disambiguation prompts.
     *
     *   If the disambigName isn't the same as the regular name, then
     *   we'll apply the same algorithm to the base disambigName that we
     *   normally do to the regular name to produce the theName.  This
     *   way, if the disambigName is overridden, we'll use the overridden
     *   disambigName to produce the definite-article version, using the
     *   standard definite-article algorithm.
     *
     *   Note that there's an aspect of this conditional approach that
     *   might not be obvious.  It might look as though the test is
     *   redundant: if name == disambigName, after all, and the default
     *   theName returns theNameFrom(name), then this ought to be
     *   identical to returning theNameFrom(disambigName).  The subtlety
     *   is that theName could be overridden to produce a custom result,
     *   in which case returning theNameFrom(disambigName) would return
     *   something different, which probably wouldn't be correct: the
     *   whole reason theName would be overridden is that the algorithmic
     *   determination (theNameFrom) gets it wrong.  So, by calling
     *   theName directly when disambigName is the same as name, we are
     *   assured that we pick up any override in theName.
     *
     *   Note that in rare cases, neither of these default approaches will
     *   produce the right result; this will happen if the object uses a
     *   custom disambigName, but that name doesn't fit the normal
     *   algorithmic pattern for applying a definite article.  In these
     *   cases, the object should simply override this method to specify
     *   the custom name.
     */

    // -- German: we use either accusative (definite arcticle) for disambiguation questions, so ...
    
    denDisambigName = (name == disambigName
                       ? denName : denNameFrom(disambigName))

    // -- German: or dative for disambiguation questions, so ...
    
    demDisambigName = (name == disambigName
                       ? demName : demNameFrom(disambigName))
    
    /*
     *   The indefinite-article name for disambiguation prompts.  We use
     *   the same logic here as in theDisambigName.
     */

    // ##### we use accusative (indefinite arcticle) for disambiguation questions, so ... #####
    
    einenDisambigName = (name == disambigName
                       ? einenName : einenNameFrom(disambigName))
    
    // ##### or dative for disambiguation questions, so ... #####
       
    einemDisambigName = (name == disambigName
                       ? einemName : einemNameFrom(disambigName))
    
    /*
     *   The counted name for disambiguation prompts.  We use the same
     *   logic here as in theDisambigName.
     */
    
    countDisambigName(cnt)
    {
        return (name == disambigName && pluralName == pluralDisambigName
                ? countName(cnt)
                : countNameFrom(cnt, disambigName, pluralDisambigName));
    }

    /*
     *   The plural name for disambiguation prompts.  We use the same
     *   logic here as in theDisambigName.
     */
    pluralDisambigName = (name == disambigName
                          ? pluralName : pluralNameFrom(disambigName))

    /*
     *   The name of the object, for the purposes of disambiguation prompts
     *   to disambiguation among this object and basic equivalents of this
     *   object (i.e., objects of the same class marked with
     *   isEquivalent=true).
     *
     *   This is used in disambiguation prompts in place of the actual text
     *   typed by the user.  For example, suppose the user types ">take
     *   coin", then we ask for help disambiguating, and the player types
     *   ">gold".  This narrows things down to, say, three gold coins, but
     *   they're in different locations so we need to ask for further
     *   disambiguation.  Normally, we ask "which gold do you mean",
     *   because the player typed "gold" in the input.  Once we're down to
     *   equivalents, we don't have to rely on the input text any more,
     *   which is good because the input text could be fragmentary (as in
     *   our present example).  Since we have only equivalents, we can use
     *   the actual name of the objects (they're all the same, after all).
     *   This property gives the name we use.
     *
     *   For English, this is simply the object's ordinary disambiguation
     *   name.  This property is separate from 'name' and 'disambigName'
     *   for the sake of languages that need to use an inflected form in
     *   this context.
     */
    disambigEquivName = (disambigName)

    /*
     *   Single-item listing description.  This is used to display the
     *   item when it appears as a single (non-grouped) item in a list.
     *   By default, we just show the indefinite article description.
     */
    // ##############################################################
    // ## names in lists: the curlistcase object holds the key to  ##
    // ## the different list cases, so return the appropriate case ##
    // ## here artSelector selects indefinite/definite article     ##
    // ##############################################################
    
    artSelector = (curlistart.isIndef ? 1 : 2)
    
    listName { return [(curlistcase.isNom ? einName : curlistcase.isGen ? einesName 
        : curlistcase.isDat ? einemName : einenName),
        curlistcase.isNom ? derName : curlistcase.isGen ? desName 
        : curlistcase.isDat ? demName : denName][artSelector];}

    /*
     *   Return a string giving the "counted name" of the object - that is,
     *   a phrase describing the given number of the object.  For example,
     *   for a red book, and a count of 5, we might return "five red
     *   books".  By default, we use countNameFrom() to construct a phrase
     *   from the count and either our regular (singular) 'name' property
     *   or our 'pluralName' property, according to whether count is 1 or
     *   more than 1.  
     */
    countName(count) {
        local str = countNameFrom(count, name, pluralName);
        if (curlistcase.isGen) {
            return (count == 1 ? countEinesNameFrom(str) : countEinesPluralNameFrom(str));
        }
        else if (curlistcase.isDat) {
            return (count == 1 ? countEinemNameFrom(str) : countEinemPluralNameFrom(str));
        }
        else if (curlistcase.isAkk) {
            return (count == 1 ? countEinenNameFrom(str) : countEinenPluralNameFrom(str));
        }
        else {// we have the nominative case
            return (count == 1 ? countEinNameFrom(str) : countEinPluralNameFrom(str));
        }
    }

    /*
     *   Returns a string giving a count applied to the name string.  The
     *   name must be given in both singular and plural forms.
     */
    countNameFrom(count, singularStr, pluralStr)
    {
        /* if the count is one, use 'ein' plus adjective ending plus the singular name */
        if (count == 1)
            return 'ein[^] ' + singularStr;

        /*
         *   Get the number followed by a space - spell out numbers below
         *   100, but use numerals to denote larger numbers.  Append the
         *   plural name to the number and return the result.
         */
        return spellIntBelowExt(count, 100, 0, DigitFormatGroupSep)
            + ' ' + pluralStr;
    }
    
    // ##############################################
    // ## central function, which is convenient in ##
    // ## some cases: removes all special endings  ##
    // ##############################################
    
    cutEndings(txt) {
        txt = txt.findReplace('[-s]', '', ReplaceAll);   // ##### remove noun genitive endings
        txt = txt.findReplace('[-es]', '', ReplaceAll);  // ##### remove noun genitive endings
        txt = txt.findReplace('[-ses]', '', ReplaceAll); // ##### remove noun genitive endings
        txt = txt.findReplace('[-n]', '', ReplaceAll);   // ##### remove noun accusative/dative endings
        txt = txt.findReplace('[-en]', '', ReplaceAll);  // ##### remove noun genitive endings
        return txt;
    }
    
    // #################################################
    // ## central function to replace all the special ##
    // ## endings, like 'groß[^]' or 'Schal[-s]' etc. ##
    // #################################################
    
    replaceEndings(txt) {
        txt = txt.findReplace('[^]', self.adjEnding, ReplaceAll); // -- replace adjective endings
        if (curcase.isGen) {
            txt = txt.findReplace('[-s]', 's', ReplaceAll);   // -- print noun genitive endings
            txt = txt.findReplace('[-es]', 'es', ReplaceAll); // -- print noun genitive endings
            txt = txt.findReplace('[-ses]', 'ses', ReplaceAll); // -- print noun genitive endings
            txt = txt.findReplace('[-n]', 'n', ReplaceAll);    // -- print noun genitive endings
            txt = txt.findReplace('[-en]', 'en', ReplaceAll); // -- print noun genitive endings
        }
        else if (curcase.isDat || curcase.isAkk){
            txt = txt.findReplace('[-s]', '', ReplaceAll);    // -- remove noun genitive endings
            txt = txt.findReplace('[-es]', '', ReplaceAll);   // -- remove noun genitive endings
            txt = txt.findReplace('[-ses]', '', ReplaceAll); // -- remove noun genitive endings
            txt = txt.findReplace('[-n]', 'n', ReplaceAll);   // -- print noun accusative/dative endings
            txt = txt.findReplace('[-en]', 'en', ReplaceAll);   // -- print noun accusative/dative endings
        }
        else { // -- we have the nominative
            txt = txt.findReplace('[-s]', '', ReplaceAll);    // -- remove noun genitive endings
            txt = txt.findReplace('[-es]', '', ReplaceAll);   // -- remove noun genitive endings
            txt = txt.findReplace('[-ses]', '', ReplaceAll); // -- remove noun genitive endings
            txt = txt.findReplace('[-n]', '', ReplaceAll);    // -- reomve noun accusative/dative endings
            txt = txt.findReplace('[-en]', '', ReplaceAll);   // -- remove noun genitive endings
        }
        return txt;
    }
    
    // #################################################
    // ## central function to replace all the special ##
    // ## endings, like 'groß[^]' or 'Schal[-s]' etc. ##
    // #################################################

    replacePluralEndings(txt) {
        txt = txt.findReplace('[^]', self.adjPluralEnding, ReplaceAll); // -- replace adjective endings
        if (curcase.isGen) {
            txt = txt.findReplace('[-s]', 's', ReplaceAll);   // -- print noun genitive endings
            txt = txt.findReplace('[-es]', 'es', ReplaceAll); // -- print noun genitive endings
            txt = txt.findReplace('[-ses]', 'ses', ReplaceAll); // -- print noun genitive endings
            txt = txt.findReplace('[-n]', '', ReplaceAll);    // -- remove noun accusative/dative endings
        }
        else if (curcase.isDat){
            txt = txt.findReplace('[-s]', '', ReplaceAll);    // -- remove noun genitive endings
            txt = txt.findReplace('[-es]', '', ReplaceAll);   // -- remove noun genitive endings
            txt = txt.findReplace('[-ses]', '', ReplaceAll); // -- remove noun genitive endings
            txt = txt.findReplace('[-n]', 'n', ReplaceAll);   // -- print noun accusative/dative endings
        }
        else if (curcase.isAkk){
            txt = txt.findReplace('[-s]', '', ReplaceAll);    // -- remove noun genitive endings
            txt = txt.findReplace('[-es]', '', ReplaceAll);   // -- remove noun genitive endings
            txt = txt.findReplace('[-ses]', '', ReplaceAll); // -- remove noun genitive endings
            txt = txt.findReplace('[-n]', '', ReplaceAll);   // -- print noun accusative/dative endings
        }
        else { // -- we have the nominative
            txt = txt.findReplace('[-s]', '', ReplaceAll);    // -- remove noun genitive endings
            txt = txt.findReplace('[-es]', '', ReplaceAll);   // -- remove noun genitive endings
            txt = txt.findReplace('[-ses]', '', ReplaceAll); // -- remove noun genitive endings
            txt = txt.findReplace('[-n]', '', ReplaceAll);    // -- reomve noun accusative/dative endings
        }
        return txt;
    }
    
    
    // ##### countEinNameFrom(str) case = nominative, as in 'vier Bonbons' #####
    countEinNameFrom(str) {
        withCaseNominative;
        curcase.r_flag = true;
        str = replaceEndings(str);
        if (isYours)
        {
            str = yourNomPossAdj + str;
        }
        return str; 
    }
    
     // ##### countEinesNameFrom(str) case = genitive #####
    countEinesNameFrom(str) 
    {
        withCaseGenitive;
        str = replaceEndings(str);
        if (isYours)
        {
            str = yourGenPossAdj + str;
        }
        return str; 
    }
    
    // ##### countEinemNameFrom(str) case = dative #####
    countEinemNameFrom(str) 
    {
        withCaseDative;
        str = replaceEndings(str);
        if (isYours)
        {
            str = yourDatPossAdj + str;            
        }
        return str; 
    }
    
    // ##### countEinenNameFrom(str) case = accusative #####
    countEinenNameFrom(str) 
    {
        withCaseAccusative;
        curcase.r_flag = true;
        str = replaceEndings(str);
        if (isYours)
        {
            str = yourAkkPossAdj + str;         
        }
        return str; 
    }    
    
    // ######################################################
    // ## In some cases, a singular noun which is grouped  ##
    // ## via equivalent = true, so we get a plural phrase ##
    // ## like 'Du siehst hier sieben rote Gummibärchen.'  ##
    // ######################################################
    
    countEinPluralNameFrom(str) {
        withCaseNominative;
        curcase.r_flag = true;
        str = replacePluralEndings(str);
        
        return str; 
    }

    countEinesPluralNameFrom(str)
    {
        withCaseGenitive;
        str = replacePluralEndings(str);

        return str; 
    }

    countEinemPluralNameFrom(str) 
    {
        withCaseDative;
        str = replacePluralEndings(str);

        return str; 
    }
    
    countEinenPluralNameFrom(str) 
    {
        withCaseAccusative;
        curcase.r_flag = true;
        str = replacePluralEndings(str);

        return str; 
    }    
    
    /*
     *   Get the 'pronoun selector' for the various pronoun methods.  This
     *   returns:
     *   
     *.  - singular neuter = 1
     *.  - singular masculine = 2
     *.  - singular feminine = 3
     *.  - plural = 4
     */
    pronounSelector = (isPlural ? 4 : isHer ? 3 : isHim ? 2 : 1)

    /*
     *   get a string with the appropriate pronoun for the object for the
     *   nominative case, objective case, possessive adjective, possessive
     *   noun
     */
    itNom { return ['es', 'er', 'sie', 'sie'][pronounSelector]; }
    itGen { return ['dessen', 'dessen', 'dessen', 'derer'][pronounSelector]; }
    itDat { return ['ihm', 'ihm', 'ihr', 'sie'][pronounSelector]; }
    itAkk { return ['es', 'ihn', 'sie', 'sie'][pronounSelector]; }
    itObj { return ['es', 'ihm', 'ihr', 'ihnen'][pronounSelector]; }
    
    // ######################################
    // ## sometimes it is convenient just  ##
    // ## to have the direct article alone ##
    // ######################################
    
    dArt { return curcase.isNom ? ['das', 'der', 'die', 'die'][pronounSelector]
            : curcase.isGen ? ['des', 'des', 'der', 'der'][pronounSelector]
            : curcase.isDat ? ['dem', 'dem', 'der', 'den'][pronounSelector]
            : ['das', 'den', 'die', 'den'][pronounSelector]; }
            
    /* get the object reflexive pronoun (itself, etc) */
    itReflexive
    {
        return ['sich' , 'sich' , 'sich' , 'sich']
               [pronounSelector] + ' selbst';
    }
    itReflexiveDat
    {
        return ['sich', 'sich', 'sich', 'sich']
               [pronounSelector] + ' selbst';
    }

    itReflexiveWithoutSelf
    {
        return ['sich', 'sich', 'sich', 'sich']
               [pronounSelector];
    }
    
    itReflexiveDatWithoutSelf
    {
        return ['sich', 'sich', 'sich', 'sich']
               [pronounSelector];
    }
    
    // ##### get our correct possessive pronoun (for distinguisher's use) #####
    
    yourNomPossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + (isHer ? 'meine ' : isHim ? 'mein ' : isIt ? 'mein ' : 'meine ');
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + (isHer ? 'deine ' : isHim ? 'dein ' : isIt ? 'dein ' : 'deine ');
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + (isHer ? 'unsere ' : isHim ? 'unser ' : isIt ? 'unser ' : 'unsere ');
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + (isHer ? 'eure ' : isHim ? 'euer ' : isIt ? 'euer ' : 'eure ');
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + (isHer ? 'ihre ' : isHim ? 'ihr ' : isIt ? 'ihr ' : 'ihre ');
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + (isHer ? 'seine ' : isHim ? 'sein ' : isIt ? 'sein ' : 'seine ');
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + (isHer ? 'ihre ' : isHim ? 'ihr ' : isIt ? 'ihr ' : 'ihre '); 
        return str;
    }
    
    yourGenPossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + (isHer ? 'meiner ' : isHim ? 'meines ' : isIt ? 'meines ' : 'meiner ');
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + (isHer ? 'deiner ' : isHim ? 'deines ' : isIt ? 'deines ' : 'deiner ');
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + (isHer ? 'unserer ' : isHim ? 'unseres ' : isIt ? 'unseres ' : 'unserer ');
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + (isHer ? 'eurer ' : isHim ? 'eures ' : isIt ? 'eures ' : 'eurer ');
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + (isHer ? 'ihrer ' : isHim ? 'ihres ' : isIt ? 'ihres ' : 'ihrer ');
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + (isHer ? 'seiner ' : isHim ? 'seines ' : isIt ? 'seines ' : 'seiner ');
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + (isHer ? 'ihrer ' : isHim ? 'ihres ' : isIt ? 'ihres ' : 'ihrer '); 
        return str;
    }
    
    yourAkkPossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + (isHer ? 'meine ' : isHim ? 'meinen ' : isIt ? 'mein ' : 'meine ');
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + (isHer ? 'deine ' : isHim ? 'deinen ' : isIt ? 'dein ' : 'deine ');
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + (isHer ? 'unsere ' : isHim ? 'unseren ' : isIt ? 'unser ' : 'unsere ');    
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + (isHer ? 'eure ' : isHim ? 'euren ' : isIt ? 'euer ' : 'eure ');   
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + (isHer ? 'ihre ' : isHim ? 'ihren ' : isIt ? 'ihr ' : 'ihre ');
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + (isHer ? 'seine ' : isHim ? 'seinen ' : isIt ? 'sein ' : 'seine ');
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + (isHer ? 'ihre ' : isHim ? 'ihren ' : isIt ? 'ihr ' : 'ihre '); 
        return str;
    }
    
    yourDatPossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + (isHer ? 'meiner ' : isHim || isIt ? 'meinem ' : 'meinen ');
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + (isHer ? 'deiner ' : isHim || isIt ? 'deinem ' : 'deinen ');
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + (isHer ? 'unserer ' : isHim || isIt ? 'unserem ' : 'unseren '); 
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + (isHer ? 'eurer ' : isHim || isIt ? 'eurem ' : 'euren ');
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + (isHer ? 'ihrer ' : isHim || isIt ? 'ihrem ' : 'ihren ');
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + (isHer ? 'seiner ' : isHim || isIt ? 'seinem ' : 'seinen ');
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + (isHer ? 'ihrer ' : isHim || isIt ? 'ihrem ' : 'ihren ');   
        return str;
    }
    
    yourNomPossPluralAdj
    {
        return yourAkkPossPluralAdj;
    }
    
    yourGenPossPluralAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meine ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deine ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unsere ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'eure ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihre ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seine ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihre ';
        return str;
    }
    
    yourAkkPossPluralAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meine ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deine ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unsere ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'eure ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihre ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seine ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihre ';
        return str;
    }
    
    yourDatPossPluralAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meinen ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deinen ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unseren ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'euren ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihren ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seinen ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihren '; 
        return str;
    }
    
    // -- and the same without object -- it means we have to conjugate "dein" manually
    
    deinPossAdj
    {
        local str = '';
         if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'mein ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'dein ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unser ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'euer ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihr ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'sein ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihr ';
        return str;
    }
    
    deinePossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meine ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deine ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unsere ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'eure ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihre ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seine ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihre ';
        return str;
    }
    
    deinesPossAdj
    {
        local str = '';
         if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meines ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deines ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unseres ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'eures ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihres ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seines ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihres ';
        return str;
    }
    
    deinerPossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meiner ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deiner ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unserer ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'eurer ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihrer ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seiner ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihrer ';
        return str;
    }
    
    deinenPossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meinen ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deinen ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unseren ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'euren ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihren ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seinen ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihren ';
        return str;
    }
    
    deinemPossAdj
    {
        local str = '';
        if (gameMain.useCapitalizedAdress) 
            str = str + '\^';
        if (gPlayerChar.referralPerson == FirstPerson)
            str = str + 'meinem ';
        if (gPlayerChar.referralPerson == SecondPerson)
            str = str + 'deinem ';
        if (gPlayerChar.referralPerson == FourthPerson)
            str = str + 'unserem ';
        if (gPlayerChar.referralPerson == FifthPerson)
            str = str + 'eurem ';
        if (gPlayerChar.referralPerson == SixthPerson)
            str = str + 'ihrem ';
        if (gPlayerChar.referralPerson == ThirdPerson && gPlayerChar.isHim)
            str = str + 'seinem ';
        if (gPlayerChar.referralPerson == ThirdPerson && !gPlayerChar.isHim)
            str = str + 'ihrem ';
        return str;
    }
    
    /* demonstrative pronouns ('that' or 'those') */
    // ##### we have derObj instead #####
    
    derObj { return ['das', 'der', 'die', 'die'][pronounSelector]; }

    /*
     *   get a string with the appropriate pronoun for the object plus the
     *   correct conjugation of 'to be'
     */
    itIs { return itNom + ' ' + verbZuSein; }

    /* get a pronoun plus a 'to be' contraction */
    //##### we have esIstContraction instead #####
    
    esIstContraction
    {
        return itNom
            + tSel(isPlural ? ' sind' : ' ist', ' ' + verbZuSein);
    }
    /*
     *   get a string with the appropriate pronoun for the object plus the
     *   correct conjugation of the given regular verb for the appropriate
     *   person
     */
    
    itVerb(verb)
    {
        return itNom + ' ' + conjugateRegularVerb(verb);
    }

    /*
     *   Conjugate a regular verb in the present or past tense for our
     *   person and number.
     *
     *   In the present tense, this is pretty easy: we add an 's' for the
     *   third person singular, and leave the verb unchanged for plural (it
     *   asks, they ask).  The only complication is that we must check some
     *   special cases to add the -s suffix: -y -> -ies (it carries), -o ->
     *   -oes (it goes).
     *
     *   In the past tense, we can equally easily figure out when to use
     *   -d, -ed, or -ied.  However, we have a more serious problem: for
     *   some verbs, the last consonant of the verb stem should be repeated
     *   (as in deter -> deterred), and for others it shouldn't (as in
     *   gather -> gathered).  To figure out which rule applies, we would
     *   sometimes need to know whether the last syllable is stressed, and
     *   unfortunately there is no easy way to determine that
     *   programmatically.
     *
     *   Therefore, we do *not* handle the case where the last consonant is
     *   repeated in the past tense.  You shouldn't use this method for
     *   this case; instead, treat it as you would handle an irregular
     *   verb, by explicitly specifying the correct past tense form via the
     *   tSel macro.  For example, to generate the properly conjugated form
     *   of the verb "deter" for an object named "thing", you could use an
     *   expression such as:
     *
     *   'deter' + tSel(thing.verbEndingS, 'red')
     *
     *   This would correctly generate "deter", "deters", or "deterred"
     *   depending on the number of the object named "thing" and on the
     *   current narrative tense.
     */
    
    // ###################################################
    // ## from version 2.0 on this is obsolete, because ##
    // ## we use pcReferralTense in the player object   ##
    // ###################################################
    
    conjugateRegularVerb(verb)
    {
        /*
         *   Which tense are we currently using?
         */
        if (gameMain.usePastTense)
        {
            if (isPlural)
                return verb + 'ten';
            else return verb + 'te';
        }
        else
        {
            if (isPlural)
            {
                return verb + 'en';
            }
            else return verb + 't';            
        }
    }
    
    derName = (derNameFrom(name))
    desName = (desNameFrom(name))
    demName = (demNameFrom(name))
    denName = (denNameFrom(name))
    
    derPossName = (derPossNameFrom(name))
    desPossName = (desPossNameFrom(name))
    demPossName = (demPossNameFrom(name))
    denPossName = (denPossNameFrom(name))
    
    derPossPluralName = (derPossPluralNameFrom(pluralName))
    desPossPluralName = (desPossPluralNameFrom(pluralName))
    demPossPluralName = (demPossPluralNameFrom(pluralName))
    denPossPluralName = (denPossPluralNameFrom(pluralName))
    
    einName = (!isDefinite ? einNameFrom(name) : derNameFrom(name))
    einesName = (!isDefinite ? einesNameFrom(name) : desNameFrom(name))
    einemName = (!isDefinite ? einemNameFrom(name) : demNameFrom(name))
    einenName = (!isDefinite ? einenNameFrom(name) : denNameFrom(name))
    
    keinName = (isPlural ? 'keine ' + pureNameFrom(name) : 'k'+einNameFrom(name))
    keinesName = (isPlural ? 'keiner ' + pureNameFrom(name) : 'k'+einesNameFrom(name))
    keinemName = (isPlural ? 'keinen ' + pureNameFrom(name) : 'k'+einemNameFrom(name))
    keinenName = (isPlural ? 'keine ' + pureNameFrom(name) : 'k'+einenNameFrom(name))
    
    pureName = (pureNameFrom(name))
    pureAkkName = (pureAkkNameFrom(name))
    pureDatName = (pureDatNameFrom(name))
    
    derNameObj { return derName; }
    desNameObj { return desName; }
    demNameObj { return demName; }
    denNameObj { return denName; }
    
    derPossNameObj { return derName; }
    desPossNameObj { return desName; }
    demPossNameObj { return demName; }
    denPossNameObj { return denName; }
    
    einNameObj { return einName; }
    einesNameObj { return einesName; }
    einemNameObj { return einemName; }
    einenNameObj { return einenName; }
    
    pureNameObj { return pureName; } // #### pureName is our name without any endings ####
    
    /*
     *   Generate the definite-article name from the given name string.
     *   If my name is already qualified, don't add an article; otherwise,
     *   add a 'the' as the prefixed definite article.
     */

    derNameFrom(str) 
    {
        withCaseNominative;
        curcase.r_flag = nil;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourNomPossAdj + str;            
        }
        return (isQualifiedName || isYours ? '' : isPlural ? 'die ' : isHim ? 'der ' : 
                isHer ? 'die ' : 'das ') + str; 
    }
    
    // ##### desNameFrom(str) case = genitive, article is direct #####
    desNameFrom(str) 
    {
        withCaseGenitive;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourGenPossAdj + str;               
        }
        return (isQualifiedName || isYours ? '' : isPlural ? 'der ' : 
        isHim ? 'des ' : isHer ? 'der ' : 'des ' ) + str; 
    }
    
    // ##### demNameFrom(str) case = dative, article is direct #####
    demNameFrom(str) 
    {
        withCaseDative;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourDatPossAdj + str;              
        }
        return (isQualifiedName || isYours ? '' : isPlural ? 'den ' : 
        isHim ? 'dem ' : isHer ? 'der ' : 'dem ' ) + str; 
    }
    
    // ##### denNameFrom(str) case = accusative, article is direct #####
    denNameFrom(str) 
    {
        withCaseAccusative;
        curcase.r_flag = nil;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourAkkPossAdj + str;              
        }
        return (isQualifiedName || isYours ? '' : isPlural ? 'die ' : 
        isHim ? 'den ' : isHer ? 'die ' : 'das ' ) + str; 
    }
    
    // ###################################################################################
    // ## we have a irregular adjective ending when placed after a possessive pronoun   ##
    // ## "der schöne Hut", but "mein schöneR Hut" ... this is stored in curcase.r_flag ##
    // ###################################################################################
    
    // ##### derPossNameFrom(str) case = accusative #####
    derPossNameFrom(str) 
    {
        withCaseNominative;
        curcase.r_flag = true;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }

        return str; 
    }
    
    // ##### desPossNameFrom(str) case = genitive #####
    desPossNameFrom(str) 
    {
        withCaseGenitive;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        
        return str; 
    }
    
    // ##### demPossNameFrom(str) case = dative #####
    demPossNameFrom(str) 
    {
        withCaseDative;
         if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }

        return str; 
    }
    
    // ##### denPossNameFrom(str) case = accusative #####
    denPossNameFrom(str)
    {
        withCaseAccusative;
        curcase.r_flag = true;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        
        return str; 
    }
    
    // ##### derPossPluralNameFrom(str) case = accusative #####
    derPossPluralNameFrom(str) 
    {
        withCaseNominative;
        curcase.r_flag = true;
        str = replacePluralEndings(str);

        return str; 
    }
    
    // ##### desPossPluralNameFrom(str) case = genitive #####
    desPossPluralNameFrom(str) 
    {
        withCaseGenitive;
        str = replacePluralEndings(str);
        
        return str; 
    }
    
    // ##### demPossPluralNameFrom(str) case = dative #####
    demPossPluralNameFrom(str) 
    {
        withCaseDative;
        str = replacePluralEndings(str);

        return str; 
    }
    
    // ##### denPossPluralNameFrom(str) case = accusative #####
    denPossPluralNameFrom(str) 
    {
        withCaseAccusative;
        str = replacePluralEndings(str);
        
        return str; 
    }
    
    // ##### einNameFrom(str) case = nominative, article is indirect #####
    einNameFrom(str) 
    {
        withCaseNominative;
        curcase.r_flag = true;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourNomPossAdj + str;            
        }
        return (isQualifiedName || isYours || isMassNoun ? '' : isPlural ? 'einige ' : 
        isHim ? 'ein ' : isHer ? 'eine ' : 'ein ' ) + str; 
    }
    
    // ##### einesNameFrom(str) case = genitive, article is indirect #####
    einesNameFrom(str) 
    {
        withCaseGenitive;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourGenPossAdj + str;              
        }
        return (isQualifiedName || isYours || isMassNoun ? '' : isPlural ? 'einiger ' : 
        isHim ? 'eines ' : isHer ? 'einer ' : 'eines ' ) + str; 
    }
    
    // ##### einemNameFrom(str) case = dative, article is indirect #####
    einemNameFrom(str) 
    {
        withCaseDative;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourDatPossAdj + str;             
        }
        return (isQualifiedName || isYours || isMassNoun ? '' : isPlural ? 'einigen ' : 
        isHim ? 'einem ' : isHer ? 'einer ' : 'einem ' ) + str; 
    }
    
    // ##### einenNameFrom(str) case = accusative, article is indirect #####
    einenNameFrom(str) 
    {
        withCaseAccusative;
        curcase.r_flag = true;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        if (isYours)
        {
            str = yourAkkPossAdj + str;             
        }
        return (isQualifiedName || isYours || isMassNoun ? '' : isPlural ? 'einige ' : 
        isHim ? 'einen ' : isHer ? 'eine ' : 'ein ' ) + str; 
    }
    
    // ##### pureNameFrom(str) case = nominative, article is NOARTICLE #####
    pureNameFrom(str) 
    {
        withCaseNominative;
        curcase.r_flag = true;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        return str; 
    }
    pureAkkNameFrom(str) 
    {
        withCaseAccusative;
        curcase.r_flag = true;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        return str; 
    }
    pureDatNameFrom(str) 
    {
        withCaseDative;
        curcase.r_flag = true;
        if (isPlural) {
            str = replacePluralEndings(str);
        }
        else {
            str = replaceEndings(str);
        }
        return str; 
    }
    
    pureListNameFrom(str) 
    {
        return(curlistcase.isNom ? countEinNameFrom(str) : curlistcase.isGen ? countEinesNameFrom(str) 
               : curlistcase.isDat ? countEinemNameFrom(str) : countEinenNameFrom(str));
    }
    
    pureListPluralNameFrom(str) 
    {
        return(curlistcase.isNom ? countEinPluralNameFrom(str) : curlistcase.isGen ? countEinesPluralNameFrom(str) 
               : curlistcase.isDat ? countEinemPluralNameFrom(str) : countEinenPluralNameFrom(str));
    }
    
    /*
     *   theName as a possessive adjective (Bob's book, your book).  If the
     *   name's usage is singular (i.e., isPlural is nil), we'll simply add
     *   an apostrophe-S.  If the name is plural, and it ends in an "s",
     *   we'll just add an apostrophe (no S).  If it's plural and doesn't
     *   end in "s", we'll add an apostrophe-S.
     *
     *   Note that some people disagree about the proper usage for
     *   singular-usage words (especially proper names) that end in 's'.
     *   Some people like to use a bare apostrophe for any name that ends
     *   in 's' (so Chris -> Chris'); other people use apostrophe-s for
     *   singular words that end in an "s" sound and a bare apostrophe for
     *   words that end in an "s" that sounds like a "z" (so Charles
     *   Dickens -> Charles Dickens').  However, most usage experts agree
     *   that proper names take an apostrophe-S in almost all cases, even
     *   when ending with an "s": "Chris's", "Charles Dickens's".  That's
     *   what we do here.
     *
     *   Note that this algorithm doesn't catch all of the special
     *   exceptions in conventional English usage.  For example, Greek
     *   names ending with "-es" are usually written with the bare
     *   apostrophe, but we don't have a property that tells us whether the
     *   name is Greek or not, so we can't catch this case.  Likewise, some
     *   authors like to possessive-ize words that end with an "s" sound
     *   with a bare apostrophe, as in "for appearance' sake", and we don't
     *   attempt to catch these either.  For any of these exceptions, you
     *   must override this method for the individual object.
     */
    
    theNamePossAdj // ##### we use this only when isProperName is true #####
                   // ##### for "Janes Mantel" and so on.              #####
    {
        /* add apostrophe-S, unless it's a plural ending with 's' */
        // ##### if the name ends with "s", we have "Klaus'" else we have "Susannes" #####
        return desName
            + (derName.endsWith('s') ? '&rsquo' : 's');
    }
        
    /*
     *   TheName as a possessive noun (that is Bob's, that is yours).  We
     *   simply return the possessive adjective name, since the two forms
     *   are usually identical in English (except for pronouns, where they
     *   sometimes differ: "her" for the adjective vs "hers" for the noun).
     */
    theNamePossNoun = (theNamePossAdj)

    /*
     *   theName with my nominal owner explicitly stated, if we have a
     *   nominal owner: "your backpack," "Bob's flashlight."  If we have
     *   no nominal owner, this is simply my theName.
     */
    
    // ##### derNameWithOwner #####
    derNameWithOwner()
    {
        local owner;

        /*
         *   if we have a nominal owner, show with our owner name;
         *   otherwise, just show our regular theName
         */
        if ((owner = getNominalOwner()) != nil) {
            if (owner == gPlayerChar) {
                return yourNomPossAdj + derPossName;         
            }
            else if (!owner.isProperName) {
                return derName + ' ' + owner.desName;
            }
            else {
                return owner.theNamePossAdj + ' ' + derPossName;
            }
        }
        else
            return derName;
    }

    // ##### desNameWithOwner #####
    desNameWithOwner()
    {
        local owner;

        /*
         *   if we have a nominal owner, show with our owner name;
         *   otherwise, just show our regular theName
         */
        if ((owner = getNominalOwner()) != nil) {
            if (owner == gPlayerChar) {
                return yourGenPossAdj + desPossName;            
            }
            else if (!owner.isProperName) {
                return desName + ' ' + owner.desName;
            }
            else {
                return owner.theNamePossAdj + ' ' + desPossName;
            }
        }
        else
            return desName;
    }
       
    // ##### demNameWithOwner #####
    demNameWithOwner()
    {
        local owner;

        /*
         *   if we have a nominal owner, show with our owner name;
         *   otherwise, just show our regular theName
         */
        
        if ((owner = getNominalOwner()) != nil) {
            if (owner == gPlayerChar) {
                return yourDatPossAdj + demPossName;            
            }
            else if (!owner.isProperName) {
                return demName + ' ' + owner.desName;
            }
            else {
                return owner.theNamePossAdj + ' ' + demPossName;
            }
        }
        else
            return demName;
    }

    // ##### we have denNameWithOwner, accusative case #####
    denNameWithOwner()
    {
        local owner;

        /*
         *   if we have a nominal owner, show with our owner name;
         *   otherwise, just show our regular theName
         */
        if ((owner = getNominalOwner()) != nil) {
            if (owner == gPlayerChar) {
                return yourAkkPossAdj + denPossName;            
            }
            else if (!owner.isProperName) {
                return denName + ' ' + owner.desName;
            }
            else {
                return owner.theNamePossAdj + ' ' + denPossName;
            }
        }
        else
            return denName;
    }
    
    /*
     *   Default preposition to use when an object is in/on this object.
     *   By default, we use 'in' as the preposition; subclasses can
     *   override to use others (such as 'on' for a surface).
     */
    objInPrep = 'in'

    /*
     *   Default preposition to use when an actor is in/on this object (as
     *   a nested location), and full prepositional phrase, with no article
     *   and with an indefinite article.  By default, we use the objInPrep
     *   for actors as well.
     */
    actorInPrep = (objInPrep)

    /* preposition to use when an actor is being removed from this location */
    actorOutOfPrep = 'aus'
    
    // ##### we never us actorIntoPrep #####

    /*
     *   describe an actor as being in/being removed from/being moved into
     *   this location
     */
    
    actorInAName = (actorInPrep + ' ' + einemNameObj)
    actorOutOfName = (actorOutOfPrep + ' ' + demNameObj)
    actorIntoName = (actorInPrep + ' ' + denNameObj)

    // ##### we use 'im' instead of 'in' 'dem' #####
    actorInName = (
        ((self.isHim || self.isIt) && actorInPrep == 'in' && !self.isProperName) ? 'im' + ' ' + pureDatName 
        : ((self.isHim || self.isIt) && actorInPrep == 'an' && !self.isProperName) ? 'am' + ' ' + pureDatName 
        : actorInPrep + ' ' + demNameObj)
      
    /*
     *   A prepositional phrase that can be used to describe things that
     *   are in this room as seen from a remote point of view.  This
     *   should be something along the lines of "in the airlock", "at the
     *   end of the alley", or "on the lawn".
     *
     *   'pov' is the point of view from which we're seeing this room;
     *   this might be
     *
     *   We use this phrase in cases where we need to describe things in
     *   this room when viewed from a point of view outside of the room
     *   (i.e., in a different top-level room).  By default, we'll use our
     *   actorInName.
     */
    inRoomName(pov) { return actorInName; }

    /*
     *   Provide the prepositional phrase for an object being put into me.
     *   For a container, for example, this would say "into the box"; for
     *   a surface, it would say "onto the table."  By default, we return
     *   our library message given by our putDestMessage property; this
     *   default is suitable for most cases, but individual objects can
     *   customize as needed.  When customizing this, be sure to make the
     *   phrase suitable for use in sentences like "You put the book
     *   <<putInName>>" and "The book falls <<putInName>>" - the phrase
     *   should be suitable for a verb indicating active motion by the
     *   object being received.
     */
    putInName() { return gLibMessages.(putDestMessage)(self); }

    /*
     *   Get a description of an object within this object, describing the
     *   object's location as this object.  By default, we'll append "in
     *   <theName>" to the given object name.
     */
    childInName(childName)
        { return childInNameGen(childName, demName); }

    /*
     *   Get a description of an object within this object, showing the
     *   owner of this object.  This is similar to childInName, but
     *   explicitly shows the owner of the containing object, if any: "the
     *   flashlight in bob's backpack".
     */
    childInNameWithOwner(childName)
        { return childInNameGen(childName, demNameWithOwner); }

    /*
     *   get a description of an object within this object, as seen from a
     *   remote location
     */
    childInRemoteName(childName, pov)
        { return childInNameGen(childName, inRoomName(pov)); }

    /*
     *   Base routine for generating childInName and related names.  Takes
     *   the name to use for the child and the name to use for me, and
     *   combines them appropriately.
     *
     *   In most cases, this is the only one of the various childInName
     *   methods that needs to be overridden per subclass, since the others
     *   are defined in terms of this one.  Note also that if the only
     *   thing you need to do is change the preposition from 'in' to
     *   something else, you can just override objInPrep instead.
     */
    childInNameGen(childName, myName) {
        return gPlayerChar.keinenAsString(childName) + ' ' + objInPrep + ' ' + myName; 
    }

    /*
     *   Get my name (in various forms) distinguished by my owner or
     *   location.
     *
     *   If the object has an owner, and either we're giving priority to
     *   the owner or our immediate location is the same as the owner,
     *   we'll show using a possessive form with the owner ("bob's
     *   flashlight").  Otherwise, we'll show the name distinguished by
     *   our immediate container ("the flashlight in the backpack").
     *
     *   These are used by the ownership and location distinguishers to
     *   list objects according to owners in disambiguation lists.  The
     *   ownership distinguisher gives priority to naming by ownership,
     *   regardless of the containment relationship between owner and
     *   self; the location distinguisher gives priority to naming by
     *   location, showing the owner only if the owner is the same as the
     *   location.
     *
     *   We will presume that objects with proper names are never
     *   indistinguishable from other objects with proper names, so we
     *   won't worry about cases like "Bob's Bill".  This leaves us free
     *   to use appropriate articles in all cases.
     */
     
    // ##### einenNameOwnerLoc - accusative #####
    einenNameOwnerLoc(ownerPriority)
    {
        local owner;

        /* show in owner or location format, as appropriate */
        if ((owner = getNominalOwner()) != nil
            && (ownerPriority || isDirectlyIn(owner)))
        {
            local ret;
            local retAkk;
            local retDat;
            
            /*
             *   we have an owner - show as "one of Bob's items" (or just
             *   "Bob's items" if this is a mass noun or a proper name)
             */
            
            if (owner == gPlayerChar) {
                retAkk = yourAkkPossPluralAdj + ' ' + denPossPluralName;
                retDat = yourDatPossPluralAdj + ' ' + demPossPluralName;
            }
            else if (owner.isProperName) {
                retAkk = owner.theNamePossAdj + ' ' + denPossPluralName;
                retDat = owner.theNamePossAdj + ' ' + demPossPluralName;
            }
            else {
                retAkk = denName + ' ' + owner.desName;
                retDat = demName + ' ' + owner.desName;
            }
            
            if (!isMassNoun && !isPlural) {
                if (isHer) {
                    ret = 'eine von ' + retDat;
                }
                else {
                    ret = 'einen von ' + retDat;
                }
            }
            else {
                ret = retAkk;
            }
            /* return the result */
            return ret;
        }
        else
        {
            /* we have no owner - show as "an item in the location" */
            return location.childInNameWithOwner(einenName);
        }
    }

    // ##### einemNameOwnerLoc - dative (only for completeness sake) #####
    einemNameOwnerLoc(ownerPriority)
    {     
        local owner;

        /* show in owner or location format, as appropriate */
        if ((owner = getNominalOwner()) != nil
            && (ownerPriority || isDirectlyIn(owner)))
        {
            local ret;
            
            /*
             *   we have an owner - show as "one of Bob's items" (or just
             *   "Bob's items" if this is a mass noun or a proper name)
             */
            
            if (owner == gPlayerChar) {
                ret = yourDatPossPluralAdj + ' ' + demPossPluralName;
            }
            else if (owner.isProperName) {
                ret = owner.theNamePossAdj + ' ' + demPossPluralName;
            }
            else {
                ret = demName + ' ' + owner.desName;
            }
            
            if (!isMassNoun && !isPlural) {
                if (isHer) {
                    ret = 'einer von ' + ret;
                }
                else {
                    ret = 'einem von ' + ret;
                }
            }
            /* return the result */
            return ret;
        }
        else
        {
            /* we have no owner - show as "an item in the location" */
            return location.childInNameWithOwner(einemName);
        }
    }
    
    // ##### denNameOwnerLoc - accusative #####
    denNameOwnerLoc(ownerPriority)
    {
        local owner;

        /* show in owner or location format, as appropriate */
        if ((owner = getNominalOwner()) != nil
            && (ownerPriority || isDirectlyIn(owner)))
        {
            /* we have an owner - show as "Bob's item" */
            // -- we use pureName, because german name properties can have 
            // -- a [-s] or [-n] genitive ending
            // -- we use it only when owner is not proper-named
            if (owner == gPlayerChar)
                return yourAkkPossAdj + ' ' + denPossNameFrom(name);
            else if (owner.isProperName)
                return owner.theNamePossAdj + ' ' + denPossNameFrom(name);
            else
                return denName + ' ' + owner.desName;
        }
        else
        {
            /* we have no owner - show as "the item in the location" */
            return location.childInNameWithOwner(denName);
        }
    }

    // ##### demNameOwnerLoc - dative #####
    demNameOwnerLoc(ownerPriority)
    {
        local owner;

        /* show in owner or location format, as appropriate */
        if ((owner = getNominalOwner()) != nil
            && (ownerPriority || isDirectlyIn(owner)))
        {
            /* we have an owner - show as "Bob's item" */
            // we use pureName, because german name properties can have 
            // a [-s] or [-n] genitive ending
            // we use it only when owner is not proper-named
             if (owner == gPlayerChar)
                return yourDatPossAdj + ' ' + demPossNameFrom(name);
            else if (owner.isProperName)
                return owner.theNamePossAdj + ' ' + demPossNameFrom(name);
            else
                return demName + ' ' + owner.desName;
        }
        else
        {
            /* we have no owner - show as "the item in the location" */
            return location.childInNameWithOwner(demName);
        }
    }
    
    countNameOwnerLoc(cnt, ownerPriority)
    {
        local owner;

        /* show in owner or location format, as appropriate */
        if ((owner = getNominalOwner()) != nil
            && (ownerPriority || isDirectlyIn(owner)))
        {
            /* we have an owner - show as "Bob's five items" */
            return owner.theNamePossAdj + ' ' + countName(cnt);
        }
        else
        {
            /* we have no owner - show as "the five items in the location" */
            return location.childInNameWithOwner('die ' + countName(cnt));
        }
    }

    /*
     *   Note that I'm being used in a disambiguation prompt by
     *   owner/location.  If we're showing the owner, we'll set the
     *   antecedent for the owner's pronoun, if the owner is a 'him' or
     *   'her'; this allows the player to refer back to our prompt text
     *   with appropriate pronouns.
     */
    notePromptByOwnerLoc(ownerPriority)
    {
        local owner;

        /* show in owner or location format, as appropriate */
        if ((owner = getNominalOwner()) != nil
            && (ownerPriority || isDirectlyIn(owner)))
        {
            /* we are showing by owner - let the owner know about it */
            owner.notePromptByPossAdj();
        }
    }

    /*
     *   Note that we're being used in a prompt question with our
     *   possessive adjective.  If we're a 'him' or a 'her', set our
     *   pronoun antecedent so that the player's response to the prompt
     *   question can refer back to the prompt text by pronoun.
     */
    notePromptByPossAdj()
    {
        if (isHim)
            gPlayerChar.setHim(self);
        if (isHer)
            gPlayerChar.setHer(self);
    }

    /* pre-compile some regular expressions for aName */
    patTagOrQuoteChar = static new RexPattern('[<"\']')
    patLeadingTagOrQuote = static new RexPattern(
        '(<langle><^rangle>+<rangle>|"|\')+')
    patOneLetterWord = static new RexPattern('<alpha>(<^alpha>|$)')
    patOneLetterAnWord = static new RexPattern('<nocase>[aefhilmnorsx]')
    patIsAlpha = static new RexPattern('<alpha>')
    patElevenEighteen = static new RexPattern('1[18](<^digit>|$)')

    /*
     *   Get the default plural name.  By default, we'll use the
     *   algorithmic plural determination, which is based on the spelling
     *   of the name.
     *
     *   The algorithm won't always get it right, since some English
     *   plurals are irregular ("men", "children", "Attorneys General").
     *   When the name doesn't fit the regular spelling patterns for
     *   plurals, the object should simply override this routine to return
     *   the correct plural name string.
     */
    pluralName = (pluralNameFrom(name))

    // ##### denPluralName + denPluralNameFrom(str) #####
    denPluralName = (denPluralNameFrom(name))

    denPluralNameFrom(str) {
        return (denNameFrom(pluralNameFrom(str))); }
    
    /*
     *   Get the plural form of the given name string.  If the name ends in
     *   anything other than 'y', we'll add an 's'; otherwise we'll replace
     *   the 'y' with 'ies'.  We also handle abbreviations and individual
     *   letters specially.
     *
     *   This can only deal with simple adjective-noun forms.  For more
     *   complicated forms, particularly for compound words, it must be
     *   overridden (e.g., "Attorney General" -> "Attorneys General",
     *   "man-of-war" -> "men-of-war").  Likewise, names with irregular
     *   plurals ('child' -> 'children', 'man' -> 'men') must be handled
     *   with overrides.
     */
    
    pluralNameFrom(str)
    {
        local len;
        local lastChar;
        local lastPair;

        /*
         *   if it's marked as having plural usage, just use the ordinary
         *   name, since it's already plural
         */
        if (isPlural)
            return str;

        /* check for a 'phrase of phrase' format */
        if (rexMatch(patOfPhrase, str) != nil)
        {
            local ofSuffix; //TODO: PATOFPHRASE überarbeiten

            /*
             *   Pull out the two parts - the part up to the 'of' is the
             *   part we'll actually pluralize, and the rest is a suffix
             *   we'll stick on the end of the pluralized part.
             */
            str = rexGroup(1)[3];
            ofSuffix = rexGroup(2)[3];

            /*
             *   now pluralize the part up to the 'of' using the normal
             *   rules, then add the rest back in at the end
             */
            return pluralNameFrom(str) + ofSuffix;
        }

        /* if there's no short description, return an empty string */
        len = str.length();
        if (len == 0)
            return '';

        /*
         *   If it's only one character long, handle it specially.  If it's
         *   a lower-case letter, add an apostrophe-S.  If it's a capital
         *   A, E, I, M, U, or V, we'll add apostrophe-S (because these
         *   could be confused with words or common abbreviations if we
         *   just added "s": As, Es, Is, Ms, Us, Vs).  If it's anything
         *   else (any other capital letter, or any non-letter character),
         *   we'll just add an "s".
         */
        if (len == 1)
        {
            if (rexMatch(patSingleApostropheS, str) != nil)
                return str + '&rsquos';
            else
                return str + 's';
        }

        /* get the last character of the name, and the last pair of chars */
        lastChar = str.substr(len, 1);
        lastPair = (len == 1 ? lastChar : str.substr(len - 1, 2));

        /*
         *   If the last letter is a capital letter, assume it's an
         *   abbreviation without embedded periods (CPA, PC), in which case
         *   we just add an "s" (CPAs, PCs).  Likewise, if it's a number,
         *   just add "s": "the 1940s", "the low 20s".
         */
        // -- German: we use 'die 70er' ...
        if (rexMatch(patUpperOrDigit, lastChar) != nil)
            return str + 'er';

        /*
         *   If the last character is a period, it must be an abbreviation
         *   with embedded periods (B.A., B.S., Ph.D.).  In these cases,
         *   add an apostrophe-S.
         */
        if (lastChar == '.')
            return str + '&rsquos';

        /*
         *   If it ends in a non-vowel followed by 'y', change -y to -ies.
         *   (This doesn't apply if a vowel precedes a terminal 'y'; in
         *   such cases, we'll use the normal '-s' ending instead: "survey"
         *   -> "surveys", "essay" -> "essays", "day" -> "days".)
         */
        
        // ####################################################################
        // ## In most cases, the author has to define the pluralName, we     ##
        // ## have many irregular forms, like 'das Haus', 'die Häuser', but  ##
        // ## we provide a default mechanism, which may be right (sometimes) ##
        // ####################################################################
        
        if (!isHer && (rexMatch(patEandLNR, lastPair) == true))
            return str;
        
        if (!isHer && (rexMatch(patEandLNR, lastPair) != true))
            return str + 'e';
        
        // ################################################################
        // ## German: If we have a feminin, there a two cases; if it     ##
        // ## ends with a vowel, add 'n' as in 'die Blume', 'die Blumen' ##
        // ## Else add 'en' as in 'die Antwort', 'die Antworten'         ##
        // ################################################################
        
        if (isHer && (rexMatch(patLastVowel, lastChar) == true))
            return str + 'n';
            
        if (isHer && (rexMatch(patLastVowel, lastChar) != true))
            return str + 'en';
        
        /* for anything else, just add -n */
        return str + 'n';
    }

    /* some pre-compiled patterns for pluralName */
    patSingleApostropheS = static new RexPattern('<case><lower|A|E|I|M|U|V>')
    patUpperOrDigit = static new RexPattern('<upper|digit>')
    patVowelY = static new RexPattern('[^aeoiu]y')
    patEandLNR = static new RexPattern('e[^lnr]')
    patLastVowel = static new RexPattern('[^aeoiu]')
    patOfPhrase = static new RexPattern(
        '<nocase>(.+?)(<space>+of<space>+.+)')
    
    /* get my name plus a being verb ("the box is") */

    derNameIs { return derName + ' ' + verbZuSein; }
    desNameIs { return desName + ' ' + verbZuSein; }
    demNameIs { return demName + ' ' + verbZuSein; }
    denNameIs { return denName + ' ' + verbZuSein; }
    
    /* get my name plus a negative being verb ("the box isn't") */

    derNameIsnt { return derNameIs + ' nicht'; }
    desNameIsnt { return desNameIs + ' nicht'; }
    demNameIsnt { return demNameIs + ' nicht'; }
    denNameIsnt { return denNameIs + ' nicht'; }
    
    /*
     *   My name with the given regular verb in agreement: in the present
     *   tense, if my name has singular usage, we'll add 's' to the verb,
     *   otherwise we won't.  In the past tense, we'll add 'd' (or 'ed').
     *   This can't be used with irregular verbs, or with regular verbs
     *   that have the last consonant repeated before the past -ed ending,
     *   such as "deter".
     */

    derNameVerb(verb) { return derName + ' ' + conjugateRegularVerb(verb); }
    desNameVerb(verb) { return desName + ' ' + conjugateRegularVerb(verb); }
    demNameVerb(verb) { return demName + ' ' + conjugateRegularVerb(verb); }
    denNameVerb(verb) { return denName + ' ' + conjugateRegularVerb(verb); }
    
    // #######################################################################
    // ## German: German verbs used in msd_neu.t for the standard responses ##
    // ## which means we have all three persons, either singular or plural  ##
    // #######################################################################
    
    verbZuSein
    {
        conjugateVerb(['','','gewesen','gewesen','sein','gewesen sein'][tenseSelector],        
              tSelect(['ist', 'sind'],
                      ['war', 'waren'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbWuerdeWaere
    {
        return tSel(isPlural ? 'würden' : 'würde', isPlural ? 'wären' : 'wäre');
    }
    verbMoechteSoll
    {
        return tSel(isPlural ? 'möchten' : 'möchte', isPlural ? 'sollten' : 'sollte');
    }
    verbZuKann
    {
        conjugateVerb(['','','gekonnt','gekonnt','können','gekonnt haben'][tenseSelector],
              tSelect(['kann', 'können'],
                      ['konnte', 'konnten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuKennen
    {
        conjugateVerb(['','','gekannt','gekannt','kennen','gekannt haben'][tenseSelector],
              tSelect(['kennt', 'kennen'],
                      ['kannte', 'kannten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }    
    verbZuHaben
    {
         conjugateVerb(['','','gehabt','gehabt','haben','gehabt haben'][tenseSelector],
              tSelect(['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuScheinen
    {
        conjugateVerb(['','','gescheint','gescheint','scheinen','gescheint haben'][tenseSelector],
              tSelect(['scheint', 'scheinen'],
                      ['schien', 'schienen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuErscheinen
    {
        conjugateVerb(['','','erschienen','erschienen','erscheinen','erschienen sein'][tenseSelector],
              tSelect(['erscheint', 'erscheinen'],
                      ['erschien', 'erschienen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuBezwecken
    {
        conjugateVerb(['','','bezweckt','bezweckt','bezwecken','bezweckt haben'][tenseSelector],
              tSelect(['bezweckt', 'bezwecken'],
                      ['bezweckte', 'bezweckten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuGefallen
    {
        conjugateVerb(['','','gefallen','gefallen','gefallen','gefallen haben'][tenseSelector],
              tSelect(['gefällt', 'gefallen'],
                      ['gefiel', 'gefielen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuBekommen
    {
        conjugateVerb(['','','bekommen','bekommen','bekommen','bekommen haben'][tenseSelector],
              tSelect(['bekommt', 'bekommen'],
                      ['bekam', 'bekamen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuSehen
    {
        conjugateVerb(['','','gesehen','gesehen','sehen','gesehen haben'][tenseSelector],
              tSelect(['sieht', 'sehen'],
                      ['sah', 'sahen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }     
    verbZuHoeren
    {
        conjugateVerb(['','','gehört','gehört','hören','gehört haben'][tenseSelector],
              tSelect(['hört', 'hören'],
                      ['hörte', 'hörten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }    
    verbZuSprechen
    {
        conjugateVerb(['','','gesprochen','gesprochen','sprechen','gesprochen haben'][tenseSelector],
              tSelect(['spricht', 'sprechen'],
                      ['sprach', 'sprachen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    } 
    verbZuBetreten
    {
        conjugateVerb(['','','betreten','betreten','betreten','betreten haben'][tenseSelector],
              tSelect(['betritt', 'betreten'],
                      ['betrat', 'betraten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    } 
    verbZuBemerken
    {
        conjugateVerb(['','','bemerkt','bemerkt','bemerken','bemerkt haben'][tenseSelector],
              tSelect(['bemerkt', 'bemerken'],
                      ['bemerkte', 'bemerkten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }     
    verbZuSagen
    {
        conjugateVerb(['','','gesagt','gesagt','sagen','gesagt haben'][tenseSelector],
              tSelect(['sagt', 'sagen'],
                      ['sagte', 'sagten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuAntworten
    {
        conjugateVerb(['','','geantwortet','geantwortet','antworten','geantwortet haben'][tenseSelector],
              tSelect(['antwortet', 'antworten'],
                      ['antwortete', 'antworteten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuMuessen
    {
        conjugateVerb(['','','müssen','müssen','müssen','gemusst haben'][tenseSelector],
              tSelect(['muss', 'müssen'],
                      ['musste', 'mussten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuRiechen
    {
        conjugateVerb(['','','gerochen','gerochen','riechen','gerochen haben'][tenseSelector],
              tSelect(['riecht', 'riechen'],
                      ['roch', 'rochen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }     
    verbZuNehmen
    {
        conjugateVerb(['','','genommen','genommen','nehmen','genommen haben'][tenseSelector],
              tSelect(['nimmt', 'nehmen'],
                      ['nahm', 'nahmen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }        
    verbZuGeben
    {
        conjugateVerb(['','','gegeben','gegeben','geben','gegeben haben'][tenseSelector],
              tSelect(['gibt', 'geben'],
                      ['gab', 'gaben'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }  
    verbZuFallen
    {
        conjugateVerb(['','','gefallen','gefallen','fallen','gefallen sein'][tenseSelector],        
              tSelect(['fällt', 'fallen'],
                      ['fiel', 'fielen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }     
    verbZuWollen
    {
        conjugateVerb(['','','wollen','wollen','wollen','wollen haben'][tenseSelector],
              tSelect(['will', 'wollen'],
                      ['wollte', 'wollten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }      
    verbZuBefinden
    {
        conjugateVerb(['','','befunden','befunden','befinden','befunden haben'][tenseSelector],
              tSelect(['befindet', 'befinden'],
                      ['befand', 'befanden'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuZiehen
    {
        conjugateVerb(['','','gezogen','gezogen','ziehen','gezogen haben'][tenseSelector],
              tSelect(['zieht', 'ziehen'],
                      ['zog', 'zogen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuDruecken
    {
        conjugateVerb(['','','gedrückt','gedrückt','drücken','gedrückt haben'][tenseSelector],
              tSelect(['drückt', 'drücken'],
                      ['drückte', 'drückten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuBrennen
    {
        conjugateVerb(['','','gebrannt','gebrannt','brennen','gebrannt haben'][tenseSelector],
              tSelect(['brennt', 'brennen'],
                      ['brannte', 'brannten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuSchliessen
    {
        conjugateVerb(['','','geschlossen','geschlossen','schließen','geschlossen haben'][tenseSelector],
              tSelect(['schließt', 'schließen'],
                      ['schloss', 'schlossen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuGehen
    {
        conjugateVerb(['','','gegangen','gegangen','gehen','gegangen sein'][tenseSelector],        
              tSelect(['geht', 'gehen'],
                      ['ging', 'gingen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuVergehen
    {
        conjugateVerb(['','','vergangen','vergangen','vergehen','vergangen sein'][tenseSelector],        
              tSelect(['vergeht', 'vergehen'],
                      ['verging', 'vergingen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]); 
    }
    
    verbZuFuehren
    {
        conjugateVerb(['','','geführt','geführt','führen','geführt haben'][tenseSelector],        
              tSelect(['führt', 'führen'],
                      ['führte', 'führten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuWissen
    {
        conjugateVerb(['','','gewusst','gewusst','wissen','gewusst haben'][tenseSelector],
              tSelect(['weiß', 'wissen'],
                      ['wusste', 'wussten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }    
    verbZuSchreien
    {
        conjugateVerb(['','','geschrien','geschrien','schreien','geschrien haben'][tenseSelector],
              tSelect(['schreit', 'schreien'],
                      ['schrie', 'schrien'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuSpringen
    {
        conjugateVerb(['','','gesprungen','gesprungen','springen','gesprungen sein'][tenseSelector],        
              tSelect(['springt', 'springen'],
                      ['sprang', 'sprangen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuSchieben
    {
        conjugateVerb(['','','geschoben','geschoben','schieben','geschoben haben'][tenseSelector],
              tSelect(['schiebt', 'schieben'],
                      ['schob', 'schoben'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuPassen
    {
        conjugateVerb(['','','gepasst','gepasst','passen','gepasst haben'][tenseSelector],
              tSelect(['passt', 'passen'],
                      ['passte', 'passten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuStehen
    {
        conjugateVerb(['','','gestanden','gestanden','stehen','gestanden sein'][tenseSelector],
              tSelect(['steht', 'stehen'],
                      ['stand', 'standen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuLiegen
    {
        conjugateVerb(['','','gelegen','gelegen','liegen','gelegen sein'][tenseSelector],
              tSelect(['liegt', 'liegen'],
                      ['lag', 'lagen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuSitzen
    {
        conjugateVerb(['','','gesessen','gesessen','sitzen','gesessen sein'][tenseSelector],
              tSelect(['sitzt', 'sitzen'],
                      ['saß', 'saßen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuTreffen
    {
        conjugateVerb(['','','getroffen','getroffen','treffen','getroffen haben'][tenseSelector],
              tSelect(['trifft', 'treffen'],
                      ['traf', 'trafen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuFangen
    {
        conjugateVerb(['','','gefangen','gefangen','fangen','gefangen haben'][tenseSelector],
              tSelect(['fängt', 'fangen'],
                      ['fing', 'fingen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuEnthalten
    {
        conjugateVerb(['','','enthalten','enthalten','enthalten','enthalten haben'][tenseSelector],
              tSelect(['enthält', 'enthalten'],
                      ['enthielt', 'enthielten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuEntscheiden
    {
        conjugateVerb(['','','entschieden','entschieden','entscheiden','entschieden haben'][tenseSelector],
              tSelect(['entscheidet', 'entscheiden'],
                      ['entschied', 'entschieden'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);  
    }
    verbZuFragen
    {
        conjugateVerb(['','','gefragt','gefragt','fragen','gefragt haben'][tenseSelector],
              tSelect(['fragt', 'fragen'],
                      ['fragte', 'fragten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuVerlassen
    {
        conjugateVerb(['','','verlassen','verlassen','verlassen','verlassen haben'][tenseSelector],
              tSelect(['verlässt', 'verlassen'],
                      ['verließ', 'verließen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuKommen
    {
        conjugateVerb(['','','gekommen','gekommen','kommen','gekommen sein'][tenseSelector],
              tSelect(['kommt', 'kommen'],
                      ['kam', 'kamen'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuWerden
    {
        conjugateVerb(['','','werden','werden','werden','geworden sein'][tenseSelector],
              tSelect(['wird', 'werden'],
                      ['wird', 'werden'],
                      ['wird', 'werden'],
                      ['wird', 'werden'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuLassen
    {
        conjugateVerb(['','','gelassen','gelassen','lassen','gelassen haben'][tenseSelector],
              tSelect(['läßt', 'lassen'],
                      ['ließ', 'ließen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuKannKon
    {
        conjugateVerb(['','','können','können','können','gekonnt haben'][tenseSelector],
              tSelect(['kann', 'können'],
                      ['konnte', 'konnten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuWeigern
    {
        conjugateVerb(['','','geweigert','geweigert','weigern','geweigert haben'][tenseSelector],
              tSelect(['weigert', 'weigern'],
                      ['weigerte', 'weigerten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuBringen
    {
        conjugateVerb(['','','gebracht','gebracht','bringen','gebracht haben'][tenseSelector],
              tSelect(['bringt', 'bringen'],
                      ['brachte', 'brachten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuFolgen
    {
        conjugateVerb(['','','gefolgt','gefolgt','folgen','gefolgt haben'][tenseSelector],
              tSelect(['folgt', 'folgen'],
                      ['folgte', 'folgten'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuZeigen
    {
        conjugateVerb(['','','gezeigt','gezeigt','zeigen','gezeigt haben'][tenseSelector],
              tSelect(['zeigt', 'zeigen'],
                      ['zeigte', 'zeigten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuMachen
    {
        conjugateVerb(['','','gemacht','gemacht','machen','gemacht haben'][tenseSelector],
              tSelect(['macht', 'machen'],
                      ['machte', 'machten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuEssen
    {
        conjugateVerb(['','','gegessen','gegessen','essen','gegessen haben'][tenseSelector],
              tSelect(['isst', 'essen'],
                      ['aß', 'aßen'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuSchalten
    {
        conjugateVerb(['','','geschaltet','geschaltet','schalten','geschaltet haben'][tenseSelector],
              tSelect(['schaltet', 'schalten'],
                      ['schaltete', 'schalteten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuPassieren
    {
        conjugateVerb(['','','passiert','passiert','passieren','passiert haben'][tenseSelector],
              tSelect(['passiert', 'passieren'],
                      ['passierte', 'passierten'],
                      ['ist', 'sind'],
                      ['war', 'waren'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuZuenden
    {
        conjugateVerb(['','','gezündet','gezündet','zünden','gezündet haben'][tenseSelector],
              tSelect(['zündet', 'zünden'],
                      ['zündete', 'zündeten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuLoesen
    {
        conjugateVerb(['','','gelöst','gelöst','lösen','gelöst haben'][tenseSelector],
              tSelect(['löst', 'lösen'],
                      ['löste', 'lösten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuBrauchen
    {
        conjugateVerb(['','','gebraucht','gebraucht','brauchen','gebraucht haben'][tenseSelector],
              tSelect(['braucht', 'brauchen'],
                      ['brauchte', 'brauchten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuLegen
    {
        conjugateVerb(['','','gelegt','gelegt','legen','gelegt haben'][tenseSelector],
              tSelect(['legt', 'legen'],
                      ['legte', 'legten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuHaengen
    {
        conjugateVerb(['','','gehängt','gehängt','hängen','gehängt haben'][tenseSelector],
              tSelect(['hängt', 'hängen'],
                      ['hängte', 'hängten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuProbieren
    {
        conjugateVerb(['','','probiert','probiert','probieren','probiert haben'][tenseSelector],
              tSelect(['probiert', 'probieren'],
                      ['probierte', 'probierten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuBenoetigen
    {
        conjugateVerb(['','','benötigt','benötigt','benötigen','benötigt haben'][tenseSelector],
              tSelect(['benötigt', 'benötigen'],
                      ['benötigte', 'benötigten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuOeffnen
    {
        conjugateVerb(['','','geöffnet','geöffnet','öffnen','geöffnet haben'][tenseSelector],
              tSelect(['öffnet', 'öffnen'],
                      ['öffnete', 'öffneten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuWarten
    {
        conjugateVerb(['','','gewartet','gewartet','warten','gewartet haben'][tenseSelector],
              tSelect(['wartet', 'warten'],
                      ['wartete', 'warteten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuVersuchen
    {
        conjugateVerb(['','','versucht','versucht','versuchen','versucht haben'][tenseSelector],
              tSelect(['versucht', 'versuchen'],
                      ['versuchte', 'versuchten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuStellen
    {
        conjugateVerb(['','','gestellt','gestellt','stellen','gestellt haben'][tenseSelector],
              tSelect(['stellt', 'stellen'],
                      ['stellte', 'stellten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuLoeschen
    {
        conjugateVerb(['','','gelöscht','gelöscht','löschen','gelöscht haben'][tenseSelector],
              tSelect(['löscht', 'löschen'],
                      ['löschte', 'löschten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuVerbinden
    {
        conjugateVerb(['','','verbunden','verbunden','verbinden','verbunden haben'][tenseSelector],
              tSelect(['verbindet', 'verbinden'],
                      ['verband', 'verbanden'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuFuehlen
    {
        conjugateVerb(['','','gefühlt','gefühlt','fühlen','gefühlt haben'][tenseSelector],
              tSelect(['fühlt', 'fühlen'],
                      ['fühlte', 'fühlten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    verbZuSchmecken
    {
        conjugateVerb(['','','geschmeckt','geschmeckt','schmecken','geschmeckt haben'][tenseSelector],
              tSelect(['schmeckt', 'schmecken'],
                      ['schmeckte', 'schmeckten'],
                      ['hat', 'haben'],
                      ['hatte', 'hatten'],
                      ['wird', 'werden'])[pluralSelector]);
    }
    
    // ################################# NEW IN 2.0 #################################
    
    // ##############################################################################
    // ## dummyVerb returns our participle form or our (in some rare cases needed) ##
    // ## reversed form in side sentences like "wie du {gekonnt hast}"             ##
    // ##############################################################################
    
    dummyVerb
    {
        verbHelper.reversed = nil;

        if (verbHelper.participle == '')
            return '';
        else if (verbHelper.blank)
            return ' ' + verbHelper.participle;
        else {
            verbHelper.blank = true;
            return verbHelper.participle;
        }
    }
    
    // ########################################################################
    // ## we store a long participle for lists with nested parts like:       ##
    // ## "Ich habe hier einen Bottich (darin ist Wasser gewesen) gesehen. " ##
    // ########################################################################
    
    setPartLong {
        verbHelper.longParticiple = verbHelper.participle;
        return '';
    }
    
    printPartLong
    {
        if (verbHelper.longParticiple == '')
            return '';
        else
            return ' ' + verbHelper.longParticiple;
    }
    
    // ##############################################################################
    // ## dummyPart sets our participle form to reverse output. This is needed in  ##
    // ## rare cases (mostly side sentences) when the helping verb and the         ##
    // ## participle change their position.                                        ##
    // ##############################################################################
    
    dummyPart
    {
        verbHelper.reversed = true;
        return '';
    }
    
    // ##############################################################################
    // ## dummyPartWithoutBlank is needed when out pariciple form is tied against  ##
    // ## an adjective. This is useful in sentences like                           ## 
    // ## "Du {hast} den Fernseher an{-geschaltet}"                                ##
    // ##############################################################################
    
    dummyPartWithoutBlank
    {
        verbHelper.blank = nil;
        return dummyVerb;
    }
    
    /*
     *   Verb endings for regular '-s' verbs, agreeing with this object as
     *   the subject.  We define several methods each of which handles the
     *   past tense differently.
     *
     *   verbEndingS doesn't try to handle the past tense at all - use it
     *   only in places where you know for certain that you'll never need
     *   the past tense form, or in expressions constructed with the tSel
     *   macro: use verbEndingS as the macro's first argument, and specify
     *   the past tense ending explicitly as the second argument.  For
     *   example, you could generate the correctly conjugated form of the
     *   verb "to fit" for an object named "key" with an expression such
     *   as:
     *
     *   'fit' + tSel(key.verbEndingS, 'ted')
     *
     *   This would generate 'fit', 'fits', or 'fitted' according to number
     *   and tense.
     *
     *   verbEndingSD and verbEndingSEd return 'd' and 'ed' respectively in
     *   the past tense.
     *
     *   verbEndingSMessageBuilder_ is for internal use only: it assumes
     *   that the correct ending to be displayed in the past tense is
     *   stored in langMessageBuilder.pastEnding_.  It is used as part of
     *   the string parameter substitution mechanism.
     */
    
    /*
     *   Dummy name - this simply displays nothing; it's used for cases
     *   where messageBuilder substitutions want to refer to an object (for
     *   internal bookkeeping) without actually showing the name of the
     *   object in the output text.  This should always simply return an
     *   empty string.
     */
    dummyName = ''

    /*
     *   Invoke a property (with an optional argument list) on this object
     *   while temporarily switching to the present tense, and return the
     *   result.
     */
    propWithPresent(prop, [args])
    {
        return withPresent({: self.(prop)(args...)});
    }

    /*
     *   Method for internal use only: invoke on this object the property
     *   stored in langMessageBuilder.fixedTenseProp_ while temporarily
     *   switching to the present tense, and return the result.  This is
     *   used as part of the string parameter substitution mechanism.
     */
    propWithPresentMessageBuilder_
    {
        return propWithPresent(langMessageBuilder.fixedTenseProp_);
    }

;

/* ------------------------------------------------------------------------ */
/*
 *   An object that uses the same name as another object.  This maps all of
 *   the properties involved in supplying the object's name, number, and
 *   other usage information from this object to a given target object, so
 *   that all messages involving this object use the same name as the
 *   target object.  This is a mix-in class that can be used with any other
 *   class.
 *   
 *   Note that we map only the *reported* name for the object.  We do NOT
 *   give this object any vocabulary from the other object; in other words,
 *   we don't enter this object into the dictionary with the other object's
 *   vocabulary words.  
 */
class NameAsOther: object
    /* the target object - we'll use the same name as this object */
    targetObj = nil

    /* map our naming and usage properties to the target object */
    isPlural = (targetObj.isPlural)
    isMassNoun = (targetObj.isMassNoun)
    isHim = (targetObj.isHim)
    isHer = (targetObj.isHer)
    isIt = (targetObj.isIt)
    isProperName = (targetObj.isProperName)
    isQualifiedName = (targetObj.isQualifiedName)
    isYours = (targetObj.isYours)
    name = (targetObj.name)

    /* map the derived name properties as well, in case any are overridden */
    disambigName = (targetObj.disambigName)
    denDisambigName = (targetObj.denDisambigName)
    demDisambigName = (targetObj.demDisambigName)
    einenDisambigName = (targetObj.einenDisambigName)
    einemDisambigName = (targetObj.einemDisambigName)
    countDisambigName(cnt) { return targetObj.countDisambigName(cnt); }
    disambigEquivName = (targetObj.disambigEquivName)
    listName = (targetObj.listName)
    countName(cnt) { return targetObj.countName(cnt); }
    
    // ##### we provide all new name functions here, too #####
    einName = (targetObj.einName)
    einesName = (targetObj.einesName)
    einemName = (targetObj.einemName)
    einenName = (targetObj.einenName)
    
    keinName = (targetObj.keinName)
    keinesName = (targetObj.keinesName)
    keinemName = (targetObj.keinemName)
    keinenName = (targetObj.keinenName)
    
    derName = (targetObj.derName)
    desName = (targetObj.desName)
    demName = (targetObj.demName)
    denName = (targetObj.denName)
    
    itGen = (targetObj.itGen)
    itDat = (targetObj.itDat)
    itAkk = (targetObj.itAkk)
 
    yourNomPossAdj = (targetObj.yourNomPossAdj)
    yourGenPossAdj = (targetObj.yourNomPossAdj)
    yourAkkPossAdj = (targetObj.yourAkkPossAdj)
    yourDatPossAdj = (targetObj.yourDatPossAdj)
    
    yourNomPossPluralAdj = (targetObj.yourNomPossPluralAdj)
    yourGenPossPluralAdj = (targetObj.yourNomPossPluralAdj)
    yourAkkPossPluralAdj = (targetObj.yourAkkPossPluralAdj)
    yourDatPossPluralAdj = (targetObj.yourDatPossPluralAdj)
    
    deinPossAdj = (targetObj.deinPossAdj)
    deinePossAdj = (targetObj.deinePossAdj)
    deinesPossAdj = (targetObj.deinesPossAdj)
    deinerPossAdj = (targetObj.deinerPossAdj)
    deinenPossAdj = (targetObj.deinenPossAdj)
    deinemPossAdj = (targetObj.deinemPossAdj)
    
    /* map the pronoun properites, in case any are overridden */
    itNom = (targetObj.itNom)
    itObj = (targetObj.itObj)
    itPossAdj = (targetObj.itPossAdj)
 
    itPossNoun = (targetObj.itPossNoun)
    itReflexive = (targetObj.itReflexive)
    itReflexiveAkk = (targetObj.itReflexiveAkk)
    itReflexiveDat = (targetObj.itReflexiveDat)
    itReflexiveWithoutSelf = (targetObj.itReflexiveWithoutSelf)
    itReflexiveDatWithoutSelf = (targetObj.itReflexiveDatWithoutSelf)
    
    itIs = (targetObj.itIs)
    itIsContraction = (targetObj.itIsContraction)
    itVerb(verb) { return targetObj.itVerb(verb); }
    conjugateRegularVerb(verb)
        { return targetObj.conjugateRegularVerb(verb); }

    theNamePossAdj = (targetObj.theNamePossAdj)
    
    theNamePossNoun = (targetObj.theNamePossNoun)
    theNameWithOwner = (targetObj.theNameWithOwner)

    einenNameOwnerLoc(ownerPri)
        { return targetObj.einenNameOwnerLoc(ownerPri); }
    einemNameOwnerLoc(ownerPri)
        { return targetObj.einemNameOwnerLoc(ownerPri); }

    denNameOwnerLoc(ownerPri)
        { return targetObj.denNameOwnerLoc(ownerPri); }
    demNameOwnerLoc(ownerPri)
        { return targetObj.demNameOwnerLoc(ownerPri); }
    countNameOwnerLoc(cnt, ownerPri)
        { return targetObj.countNameOwnerLoc(cnt, ownerPri); }
    notePromptByOwnerLoc(ownerPri)
        { targetObj.notePromptByOwnerLoc(ownerPri); }
    notePromptByPossAdj()
        { targetObj.notePromptByPossAdj(); }

    pluralName = (targetObj.pluralName)
    nameIs = (targetObj.nameIs)
    nameIsnt = (targetObj.nameIsnt)
    nameVerb(verb) { return targetObj.nameVerb(verb); }
    verbToBe = (targetObj.verbToBe)
    verbWas = (targetObj.verbWas)
    verbToHave = (targetObj.verbToHave)
    verbToDo = (targetObj.verbToDo)
    nameDoes = (targetObj.nameDoes)
    verbToGo = (targetObj.verbToGo)
    verbToCome = (targetObj.verbToCome)
    verbToLeave = (targetObj.verbToLeave)
    verbToSee = (targetObj.verbToSee)
    nameSees = (targetObj.nameSees)
    verbToSay = (targetObj.verbToSay)
    nameSays = (targetObj.nameSays)
    verbMust = (targetObj.verbMust)
    verbCan = (targetObj.verbCan)
    verbCannot = (targetObj.verbCannot)
    verbCant = (targetObj.verbCant)
    verbWill = (targetObj.verbWill)
    verbWont = (targetObj.verbWont)

    verbZuSein = (targetObj.verbZuSein)
    verbZuKann = (targetObj.verbZuKann)
    verbZuKennen = (targetObj.verbZuKennen)
    verbZuHaben = (targetObj.verbZuHaben)
    verbZuScheinen = (targetObj.verbZuScheinen)
    verbZuErscheinen = (targetObj.verbZuErscheinen)
    verbZuBezwecken = (targetObj.verbZuBezwecken)
    verbZuGefallen = (targetObj.verbZuGefallen)
    verbZuBekommen = (targetObj.verbZuBekommen)
    verbZuSehen = (targetObj.verbZuSehen)
    verbZuHoeren = (targetObj.verbZuHoeren)
    verbZuSprechen = (targetObj.verbZuSprechen)
    verbZuBetreten = (targetObj.verbZuBetreten)
    verbZuBemerken = (targetObj.verbZuBemerken)
    verbZuSagen = (targetObj.verbZuSagen)
    verbZuAntworten = (targetObj.verbZuAntworten)
    verbZuMuessen = (targetObj.verbZuMuessen)
    verbZuRiechen = (targetObj.verbZuRiechen)
    verbZuNehmen = (targetObj.verbZuNehmen)
    verbZuGeben = (targetObj.verbZuGeben)
    verbZuFallen = (targetObj.verbZuFallen)
    verbZuWollen = (targetObj.verbZuWollen)
    verbZuBefinden = (targetObj.verbZuBefinden)
    verbZuZiehen = (targetObj.verbZuZiehen)
    verbZuDruecken = (targetObj.verbZuDruecken)
    verbZuBrennen = (targetObj.verbZuBrennen)
    verbZuSchliessen = (targetObj.verbZuSchliessen)
    verbZuGehen = (targetObj.verbZuGehen)
    verbZuVergehen = (targetObj.verbZuVergehen)
    verbZuFuehren = (targetObj.verbZuFuehren)
    verbZuWissen = (targetObj.verbZuWissen)
    verbZuSchreien = (targetObj.verbZuSchreien)
    verbZuSpringen = (targetObj.verbZuSpringen)
    verbZuSchieben = (targetObj.verbZuSchieben)
    verbZuPassen = (targetObj.verbZuPassen)
    verbZuStehen = (targetObj.verbZuStehen)
    verbZuLiegen = (targetObj.verbZuLiegen)
    verbZuSitzen = (targetObj.verbZuSitzen)
    verbZuTreffen = (targetObj.verbZuTreffen)
    verbZuFangen = (targetObj.verbZuFangen)
    verbZuEnthalten = (targetObj.verbZuEnthalten)
    verbZuEntscheiden = (targetObj.verbZuEntscheiden)
    verbZuFragen = (targetObj.verbZuFragen)
    verbZuVerlassen = (targetObj.verbZuVerlassen)
    verbZuKommen = (targetObj.verbZuKommen)
    verbZuWerden = (targetObj.verbZuWerden)
    verbZuLassen = (targetObj.verbZuLassen)
    verbZuKannKon = (targetObj.verbZuKannKon)
    verbZuWeigern = (targetObj.verbZuWeigern)
    verbZuBringen = (targetObj.verbZuBringen)
    verbZuFolgen = (targetObj.verbZuFolgen)
    verbZuZeigen = (targetObj.verbZuZeigen)
    verbZuMachen = (targetObj.verbZuMachen)
    verbZuEssen = (targetObj.verbZuEssen)
    verbZuSchalten = (targetObj.verbZuSchalten)
    verbZuPassieren = (targetObj.verbZuPassieren)
    verbZuZuenden = (targetObj.verbZuZuenden)
    verbZuLoesen = (targetObj.verbZuLoesen)
    verbZuBrauchen = (targetObj.verbZuBrauchen)
    verbZuLegen = (targetObj.verbZuLegen)
    verbZuHaengen = (targetObj.verbZuHaengen)
    verbZuProbieren = (targetObj.verbZuProbieren)
    verbZuBenoetigen = (targetObj.verbZuBenoetigen)
    verbZuOeffnen = (targetObj.verbZuOeffnen)
    verbZuWarten = (targetObj.verbZuWarten)
    verbZuVersuchen = (targetObj.verbZuVersuchen)
    verbZuStellen = (targetObj.verbZuStellen)
    verbZuLoeschen = (targetObj.verbZuLoeschen)
    verbZuVerbinden = (targetObj.verbZuVerbinden)
    verbZuFuehlen = (targetObj.verbZuFuehlen)
    verbZuSchmecken = (targetObj.verbZuSchmecken)
    
    // ##### adjective endings #####
    adjEnding = (targetObj.adjEnding)
    
    dummyVerb = (targetObj.dummyVerb)
    dummyPartWithoutBlank = (targetObj.dummyPartWithoutBlank)
    dummyPart = (targetObj.dummyPart)
    setPartLong = (targetObj.setPartLong)
    printPartLong = (targetObj.printPartLong)

;

/*
 *   Name as Parent - this is a special case of NameAsOther that uses the
 *   lexical parent of a nested object as the target object.  (The lexical
 *   parent is the enclosing object in a nested object definition; in other
 *   words, it's the object in which the nested object is embedded.)  
 */
class NameAsParent: NameAsOther
    targetObj = (lexicalParent)
;

/*
 *   ChildNameAsOther is a mix-in class that can be used with NameAsOther
 *   to add the various childInXxx naming to the mapped properties.  The
 *   childInXxx names are the names generated when another object is
 *   described as located within this object; by mapping these properties
 *   to our target object, we ensure that we use exactly the same phrasing
 *   as we would if the contained object were actually contained by our
 *   target rather than by us.
 *   
 *   Note that this should always be used in combination with NameAsOther:
 *   
 *   myObj: NameAsOther, ChildNameAsOther, Thing ...
 *   
 *   You can also use it the same way in combination with a subclass of
 *   NameAsOther, such as NameAsParent.  
 */
class ChildNameAsOther: object
    objInPrep = (targetObj.objInPrep)
    actorInPrep = (targetObj.actorInPrep)
    actorOutOfPrep = (targetObj.actorOutOfPrep)

    childInName(childName) { return targetObj.childInName(childName); }
    childInNameWithOwner(childName)
        { return targetObj.childInNameWithOwner(childName); }
    childInNameGen(childName, myName)
        { return targetObj.childInNameGen(childName, myName); }
    actorInName = (targetObj.actorInName)
    actorOutOfName = (targetObj.actorOutOfName)
    actorIntoName = (targetObj.actorIntoName)
    actorInAName = (targetObj.actorInAName)
;


/* ------------------------------------------------------------------------ */
/*
 *   Language modifications for the specialized container types
 */
modify Surface
    /*
     *   objects contained in a Surface are described as being on the
     *   Surface
     */
    objInPrep = 'auf'
    actorInPrep = 'auf'
    actorOutOfPrep = 'aus' 
    dobjFor(Climb) asDobjFor(StandOn)
;

modify Underside
    objInPrep = 'unter'
    actorInPrep = 'unter'
    actorOutOfPrep = 'unter'  
;

modify RearContainer
    objInPrep = 'hinter'
    actorInPrep = 'hinter'
    actorOutOfPrep = 'hinter'
;

/* ------------------------------------------------------------------------ */
/*
 *   Language modifications for Actor.
 *   
 *   An Actor has a "referral person" setting, which determines how we
 *   refer to the actor; this is almost exclusively for the use of the
 *   player character.  The typical convention is that we refer to the
 *   player character in the second person, but a game can override this on
 *   an actor-by-actor basis.  
 */
modify Actor
    /* by default, use my pronoun for my name */
    name = (itNom)

    /*
     *   Pronoun selector.  This returns an index for selecting pronouns
     *   or other words based on number and gender, taking into account
     *   person, number, and gender.  The value returned is the sum of the
     *   following components:
     *
     *   number/gender:
     *.  - singular neuter = 1
     *.  - singular masculine = 2
     *.  - singular feminine = 3
     *.  - plural = 4
     *
     *   person:
     *.  - first person = 0
     *.  - second person = 4
     *.  - third person = 8
     *.  - fourth person = 12
     *.  - fifth person = 16
     *.  - sixth person = 20
     *
     *   The result can be used as a list selector as follows (1=first
     *   person, etc; s=singular, p=plural; n=neuter, m=masculine,
     *   f=feminine):
     *
     *   [1/s/n, 1/s/m, 1/s/f, 1/p, 2/s/n, 2/s/m, 2/s/f, 2/p,
     *.  3/s/n, 3/s/m, 3/s/f, 3/p]
     */
    pronounSelector
    {
        return ((referralPerson - FirstPerson)*4
                + (isPlural ? 4 : isHim ? 2 : isHer ? 3 : 1));
    }

    thirdPersonPronounSelector = (isPlural ? 4 : isHer ? 3 : isHim ? 2 : 1)
    
    dArt { return curcase.isNom ? ['das', 'der', 'die', 'die'][thirdPersonPronounSelector]
            : curcase.isGen ? ['des', 'des', 'der', 'der'][thirdPersonPronounSelector]
            : curcase.isDat ? ['dem', 'dem', 'der', 'den'][thirdPersonPronounSelector]
            : ['das', 'den', 'die', 'den'][thirdPersonPronounSelector]; }
    
    /*
     *   get the verb form selector index for the person and number:
     *
     *   [1/s, 2/s, 3/s, 1/p, 2/p, 3/p]
     */
    conjugationSelector
    {
        return (referralPerson + (isPlural ? 3 : 0));
    }

    /*
     *   get an appropriate pronoun for the object in the appropriate
     *   person for the nominative case, objective case, possessive
     *   adjective, possessive noun, and objective reflexive
     */
    itNom
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') + 
            ['ich', 'ich', 'ich', 'wir',
            'du', 'du', 'du', 'sie',
            'es', 'er', 'sie', 'sie',
            'wir', 'wir', 'wir', 'wir',
            'ihr', 'ihr', 'ihr', 'ihr',
            'sie', 'sie', 'sie', 'sie'][pronounSelector];
    }
        
    // ##### the different cases #####
    
    itGen
    {
        return 'von ' + ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mir', 'mir', 'mir', 'mir',
            'dir', 'dir', 'dir', 'dir',
            'ihm', 'ihm', 'ihr', 'ihnen',
            'uns', 'uns', 'uns', 'uns',
            'euch', 'euch', 'euch', 'euch',
            'ihnen', 'ihnen', 'ihnen', 'ihnen'][pronounSelector];
    }
    itDat
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mir', 'mir', 'mir', 'mir',
            'dir', 'dir', 'dir', 'dir',
            'ihm', 'ihm', 'ihr', 'ihnen',
            'uns', 'uns', 'uns', 'uns',
            'euch', 'euch', 'euch', 'euch',
            'ihnen', 'ihnen', 'ihnen', 'ihnen'][pronounSelector];
    }
    itAkk
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mich', 'mich', 'mich', 'uns',
            'dich', 'dich', 'dich', 'euch',
            'es', 'ihn', 'sie', 'sie',
            'uns', 'uns', 'uns', 'uns',
            'euch', 'euch', 'euch', 'euch',
            'ihnen', 'ihnen', 'ihnen', 'ihnen'][pronounSelector];
    }
    whichObj
    {
        return ['welcher', 'welche', 'welches', 'welche',
               'welcher', 'welche', 'welches', 'welche',
               'welcher', 'welche', 'welches', 'welche',
               'welcher', 'welche', 'welches', 'welche',
               'welcher', 'welche', 'welches', 'welche',
               'welcher', 'welche', 'welches', 'welche'][pronounSelector];
    }
    
    itPossAdj
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mein', 'mein', 'mein', 'unser',
            'dein', 'dein', 'dein', 'euer',
            'sein', 'sein', 'ihr', 'ihre',
            'unser', 'unser', 'unser', 'unser',
            'euer', 'euer', 'euer', 'euer',
            'ihr', 'ihr', 'ihr', 'ihr'][pronounSelector];
    }
    
    itReflexive
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mich', 'mich', 'mich', 'mich',
            'dich', 'dich', 'dich', 'dich',
            'sich', 'sich', 'sich', 'sich',
            'uns', 'uns', 'uns', 'uns',
            'euch', 'euch', 'euch', 'euch',
            'ihr', 'ihr', 'ihr', 'ihr'][pronounSelector] + ' selbst';
    }
    
    itReflexiveDat 
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mir', 'mir', 'mir', 'uns',
            'dir', 'dir', 'dir', 'euch',
            'sich', 'sich', 'sich', 'sich',
            'uns', 'uns', 'uns', 'uns',
            'euch', 'euch', 'euch', 'euch',
            'ihr', 'ihr', 'ihr', 'ihr'][pronounSelector] + ' selbst';
    }
    
    itReflexiveWithoutSelf
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mich', 'mich', 'mich', 'mich',
            'dich', 'dich', 'dich', 'dich',
            'sich', 'sich', 'sich', 'sich',
            'uns', 'uns', 'uns', 'uns',
            'euch', 'euch', 'euch', 'euch',
            'ihr', 'ihr', 'ihr', 'ihr'][pronounSelector];
    }
    
    itReflexiveDatWithoutSelf
    {
        return ((gameMain.useCapitalizedAdress && gPlayerChar == self) ? '\^' : '') +
            ['mir', 'mir', 'mir', 'uns',
            'dir', 'dir', 'dir', 'euch',
            'sich', 'sich', 'sich', 'sich',
            'uns', 'uns', 'uns', 'uns',
            'euch', 'euch', 'euch', 'euch',
            'ihr', 'ihr', 'ihr', 'ihr'][pronounSelector];
    }
    
    /*
     *   Conjugate a regular verb in the present or past tense for our
     *   person and number.
     *
     *   In the present tense, this is pretty easy: we add an 's' for the
     *   third person singular, and leave the verb unchanged for every
     *   other case.  The only complication is that we must check some
     *   special cases to add the -s suffix: -y -> -ies, -o -> -oes.
     *
     *   In the past tense, we use the inherited handling since the past
     *   tense ending doesn't vary with person.
     */
    conjugateRegularVerb(verb)
    {
        /*
         *   If we're in the third person or if we use the past tense,
         *   inherit the default handling; otherwise, use the base verb
         *   form regardless of number (regular verbs use the same
         *   conjugated forms for every case but third person singular: I
         *   ask, you ask, we ask, they ask).
         */
        if (referralPerson != ThirdPerson && !gameMain.usePastTense)
        {
            /*
             *   we're not using the third-person or the past tense, so the
             *   conjugation is the same as the base verb form
             */
            return verb;
        }
        else
        {
            /*
             *   we're using the third person or the past tense, so inherit
             *   the base class handling, which conjugates these forms
             */
            return inherited(verb);
        }
    }

    /*
     *   Get the name with a definite article ("the box").  If the
     *   narrator refers to us in the first or second person, use a
     *   pronoun rather than the short description.
     */

    // ##### indefinite article #####
    
    einName
        { return (referralPerson == ThirdPerson ? inherited : itNom); }

    einesName 
        { return (referralPerson == ThirdPerson ? inherited : itGen); }
    
    einemName
        { return (referralPerson == ThirdPerson ? inherited : itDat); }
    
    einenName
        { return (referralPerson == ThirdPerson ? inherited : itAkk); }

    // ##### definite article #####
    
    derName
        { return (referralPerson == ThirdPerson ? inherited : itNom); }

    desName 
        { return (referralPerson == ThirdPerson ? inherited : itGen); }
    
    demName
        { return (referralPerson == ThirdPerson ? inherited : itDat); }
    
    denName
        { return (referralPerson == ThirdPerson ? inherited : itAkk); }
    
    /* theName in objective case */

    derNameObj
        { return (referralPerson == ThirdPerson ? inherited : itNom); }
    
    desNameObj
        { return (referralPerson == ThirdPerson ? inherited : itGen); }
    
    demNameObj
        { return (referralPerson == ThirdPerson ? inherited : itDat); }
    
    denNameObj
        { return (referralPerson == ThirdPerson ? inherited : itAkk); }
    
    /* theName as a possessive adjective */
    theNamePossAdj
        { return (referralPerson == ThirdPerson ? inherited : itPossAdj); }
    
    /* theName as a possessive noun */
    theNamePossNoun
    { return (referralPerson == ThirdPerson ? inherited : itPossNoun); }

    /* being verb agreeing with this object as subject */
    // ##### verbs for actors, which means we have all six persons #####

    verbZuSein
    {
        conjugateVerb(['','','gewesen','gewesen','sein','gewesen sein'][tenseSelector],        
              tSelect(['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbWuerdeWaere
    {
        return tSel(['würde', 'würdest', 'würde', 'würden', 'würdet', 'würden'],
                    ['wäre', 'wärst', 'wäre', 'wären', 'wärt', 'wären'])
               [conjugationSelector];
    }  
    VerbMoechteSoll
    {
        return tSel(['soll', 'möchtest', 'soll', 'sollen', 'möchtet', 'sollen'],
                    ['wäre', 'wärst', 'wäre', 'wären', 'wärt', 'wären'])
               [conjugationSelector];
    } 
    verbZuKann
    {
        conjugateVerb(['','','gekonnt','gekonnt','können','gekonnt haben'][tenseSelector],
              tSelect(['kann', 'kannst', 'kann', 'können', 'könnt', 'können'],
                      ['konnte', 'konntest', 'konnte', 'konnten', 'konntet', 'konnten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }     
    verbZuKennen
    {
        conjugateVerb(['','','gekannt','gekannt','kennen','gekannt haben'][tenseSelector],
              tSelect(['kenne', 'kennst', 'kennt', 'kennen', 'kennt', 'kennen'],
                      ['kannte', 'kanntest', 'kannte', 'kannten', 'kanntet', 'kannten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }    
    verbZuHaben
    {
         conjugateVerb(['','','gehabt','gehabt','haben','gehabt haben'][tenseSelector],
              tSelect(['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbZuScheinen
    {
        conjugateVerb(['','','gescheint','gescheint','scheinen','gescheint haben'][tenseSelector],
              tSelect(['scheine', 'scheinst', 'scheint', 'scheinen', 'scheint', 'scheinen'],
                      ['schien', 'schienst', 'schien', 'schienen', 'schient', 'schienen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbZuErscheinen
    {
        conjugateVerb(['','','erschienen','erschienen','erscheinen','erschienen sein'][tenseSelector],
              tSelect(['erscheine', 'erscheinst', 'erscheint', 'erscheinen', 'erscheint', 'erscheinen'],
                      ['erschien', 'erschienst', 'erschien', 'erschienen', 'erschient', 'erschienen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    } 
    verbZuBezwecken
    {
        conjugateVerb(['','','bezweckt','bezweckt','bezwecken','bezweckt haben'][tenseSelector],
              tSelect(['bezwecke', 'bezweckst', 'bezweckt', 'bezwecken', 'bezweckt', 'bezwecken'],
                      ['bezweckte', 'bezwecktest', 'bezweckte', 'bezweckten', 'bezwecktet', 'bezweckten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuGefallen
    {
        conjugateVerb(['','','gefallen','gefallen','gefallen','gefallen haben'][tenseSelector],
              tSelect(['gefalle', 'gefällst', 'gefällt', 'gefallen', 'gefallt', 'gefallen'],
                      ['gefiel', 'gefielst', 'gefiel', 'gefielen', 'gefielt', 'gefielen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbZuBekommen
    {
        conjugateVerb(['','','bekommen','bekommen','bekommen','bekommen haben'][tenseSelector],
              tSelect(['bekomme', 'bekommst', 'bekommt', 'bekommen', 'bekommt', 'bekommen'],
                      ['bekam', 'bekamst', 'bekam', 'bekamen', 'bekamt', 'bekamen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuSehen
    {
        conjugateVerb(['','','gesehen','gesehen','sehen','gesehen haben'][tenseSelector],
              tSelect(['sehe', 'siehst', 'sieht', 'sehen', 'seht', 'sehen'],
                      ['sah', 'sahst', 'sah', 'sahen', 'saht', 'sahen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }     
    verbZuHoeren
    {
        conjugateVerb(['','','gehört','gehört','hören','gehört haben'][tenseSelector],
              tSelect(['höre', 'hörst', 'hört', 'hören', 'hört', 'hören'],
                      ['hörte', 'hörtest', 'hörte', 'hörten', 'hörtet', 'hörten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }   
    verbZuSprechen
    {
        conjugateVerb(['','','gesprochen','gesprochen','sprechen','gesprochen haben'][tenseSelector],
              tSelect(['sprecht', 'sprichst', 'spricht', 'sprechen', 'sprecht', 'sprechen'],
                      ['sprach', 'sprachst', 'sprach', 'sprachen', 'spracht', 'sprachen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    } 
    verbZuBetreten
    {
        conjugateVerb(['','','betreten','betreten','betreten','betreten haben'][tenseSelector],
              tSelect(['betrete', 'betrittst', 'betritt', 'betreten', 'betretet', 'betreten'],
                      ['betrat', 'betratst', 'betrat', 'betraten', 'betratet', 'betraten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    } 
    verbZuBemerken
    {
        conjugateVerb(['','','bemerkt','bemerkt','bemerken','bemerkt haben'][tenseSelector],
              tSelect(['bemerke', 'bemerkst', 'bemerkt', 'bemerken', 'bemerkt', 'bemerken'],
                      ['bemerkte', 'bemerktest', 'bemerkte', 'bemerkten', 'bemerktet', 'bemerkten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }     
    verbZuSagen
    {
        conjugateVerb(['','','gesagt','gesagt','sagen','gesagt haben'][tenseSelector],
              tSelect(['sage', 'sagst', 'sagt', 'sagen', 'sagt', 'sagen'],
                      ['sagte', 'sagtest', 'sagte', 'sagten', 'sagtet', 'sagten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbZuAntworten
    {
        conjugateVerb(['','','geantwortet','geantwortet','antworten','geantwortet haben'][tenseSelector],
              tSelect(['antworte', 'antwortest', 'antwortet', 'antworten', 'antwortet', 'antworten'],
                      ['antwortete', 'antwortetest', 'antwortete', 'antworteten', 'antwortetet', 'antworteten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbZuMuessen
    {
        conjugateVerb(['','','müssen','müssen','müssen','gemusst haben'][tenseSelector],
              tSelect(['muss', 'musst', 'muss', 'müssen', 'müsst', 'müssen'],
                      ['musste', 'musstest', 'musste', 'mussten', 'musstet', 'mussten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbZuRiechen
    {
        conjugateVerb(['','','gerochen','gerochen','riechen','gerochen haben'][tenseSelector],
              tSelect(['rieche', 'riechst', 'riecht', 'riechen', 'riecht', 'riechen'],
                      ['roch', 'rochst', 'roch', 'rochen', 'rocht', 'rochen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }     
    verbZuNehmen
    {
        conjugateVerb(['','','genommen','genommen','nehmen','genommen haben'][tenseSelector],
              tSelect(['nehme', 'nimmst', 'nimmt', 'nehmen', 'nehmt', 'nehmen'],
                      ['nahm', 'nahmst', 'nahm', 'nahmen', 'nahmt', 'nahmen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }        
    verbZuGeben
    {
        conjugateVerb(['','','gegeben','gegeben','geben','gegeben haben'][tenseSelector],
              tSelect(['gebe', 'gibst', 'gibt', 'geben', 'gebt', 'geben'],
                      ['gab', 'gabst', 'gab', 'gaben', 'gabt', 'gaben'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }  
    verbZuFallen
    {
        conjugateVerb(['','','gefallen','gefallen','fallen','gefallen sein'][tenseSelector],        
              tSelect(['falle', 'fällst', 'fällt', 'fallen', 'fallt', 'fallen'],
                      ['fiel', 'fielst', 'fiel', 'fielen', 'fielt', 'fielen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }     
    verbZuWollen
    {
        conjugateVerb(['','','wollen','wollen','wollen','wollen haben'][tenseSelector],
              tSelect(['will', 'willst', 'will', 'wollen', 'wollt', 'wollen'],
                      ['wollte', 'wolltest', 'wollte', 'wollten', 'wolltet', 'wollten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }      
    verbZuBefinden
    {
        conjugateVerb(['','','befunden','befunden','befinden','befunden haben'][tenseSelector],
              tSelect(['befinde', 'befindest', 'befindet', 'befinden', 'befindet', 'befinden'],
                      ['befand', 'befandest', 'befand', 'befanden', 'befandet', 'befanden'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuZiehen
    {
        conjugateVerb(['','','gezogen','gezogen','ziehen','gezogen haben'][tenseSelector],
              tSelect(['ziehe', 'ziehst', 'zieht', 'ziehen', 'zieht', 'ziehen'],
                      ['zog', 'zogst', 'zog', 'zogen', 'zogt', 'zogen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuDruecken
    {
        conjugateVerb(['','','gedrückt','gedrückt','drücken','gedrückt haben'][tenseSelector],
              tSelect(['drücke', 'drückst', 'drückt', 'drücken', 'drückt', 'drücken'],
                      ['drückte', 'drücktest', 'drückte', 'drückten', 'drücktet', 'drückten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuBrennen
    {
        conjugateVerb(['','','gebrannt','gebrannt','brennen','gebrannt haben'][tenseSelector],
              tSelect(['brenne', 'brennst', 'brennt', 'brennen', 'brennt', 'brennen'],
                      ['brannte', 'branntest', 'brannte', 'brannten', 'branntet', 'brannten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuSchliessen
    {
        conjugateVerb(['','','geschlossen','geschlossen','schließen','geschlossen haben'][tenseSelector],
              tSelect(['schließe', 'schließst', 'schließt', 'schließen', 'schließt', 'schließen'],
                      ['schloss', 'schlosst', 'schloss', 'schlossen', 'schlosst', 'schlossen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuGehen
    {
        conjugateVerb(['','','gegangen','gegangen','gehen','gegangen sein'][tenseSelector],        
              tSelect(['gehe', 'gehst', 'geht', 'gehen', 'geht', 'gehen'],
                      ['ging', 'gingst', 'ging', 'gingen', 'gingt', 'gingen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]); 
    }
    verbZuVergehen
    {
        conjugateVerb(['','','vergangen','vergangen','vergehen','vergangen sein'][tenseSelector],        
              tSelect(['vergehe', 'vergehst', 'vergeht', 'vergehen', 'vergeht', 'vergehen'],
                      ['verging', 'vergingst', 'verging', 'vergingen', 'vergingt', 'vergingen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]); 
    }
    verbZuFuehren
    {
        conjugateVerb(['','','geführt','geführt','führen','geführt sein'][tenseSelector],        
              tSelect(['führe', 'führst', 'führt', 'führen', 'führt', 'führen'],
                      ['führte', 'führtest', 'führte', 'führten', 'führtet', 'führten'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[pluralSelector]); 
    }
    verbZuWissen
    {
        conjugateVerb(['','','gewusst','gewusst','wissen','gewusst haben'][tenseSelector],
              tSelect(['weiß', 'weißt', 'weiß', 'wissen', 'wisst', 'wissen'],
                      ['wusste', 'wusstest', 'wusste', 'wussten', 'wusstet', 'wussten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }    
    verbZuSchreien
    {
        conjugateVerb(['','','geschrien','geschrien','schreien','geschrien haben'][tenseSelector],
              tSelect(['schreie', 'schreist', 'schreit', 'schreien', 'schreit', 'schreien'],
                      ['schrie', 'schriest', 'schrie', 'schrien', 'schriet', 'schrien'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuSpringen
    {
        conjugateVerb(['','','gesprungen','gesprungen','springen','gesprungen sein'][tenseSelector],        
              tSelect(['springe', 'springst', 'springt', 'springen', 'springt', 'springen'],
                      ['sprang', 'sprangst', 'sprang', 'sprangen', 'sprangt', 'sprangen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]); 
    }
    verbZuSchieben
    {
        conjugateVerb(['','','geschoben','geschoben','schieben','geschoben haben'][tenseSelector],
              tSelect(['schiebe', 'schiebst', 'schiebt', 'schieben', 'schiebt', 'schieben'],
                      ['schob', 'schobst', 'schob', 'schoben', 'schobt', 'schoben'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuPassen
    {
        conjugateVerb(['','','gepasst','gepasst','passen','gepasst haben'][tenseSelector],
              tSelect(['passe', 'passt', 'passt', 'passen', 'passt', 'passen'],
                      ['passte', 'passtest', 'passte', 'passten', 'passtet', 'passten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuStehen
    {
        conjugateVerb(['','','gestanden','gestanden','stehen','gestanden sein'][tenseSelector],
              tSelect(['stehe', 'stehst', 'steht', 'stehen', 'steht', 'stehen'],
                      ['stand', 'standst', 'stand', 'standen', 'standet', 'standen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]); 
    }
    verbZuLiegen
    {
        conjugateVerb(['','','gelegen','gelegen','liegen','gelegen sein'][tenseSelector],
              tSelect(['liege', 'liegst', 'liegt', 'liegen', 'liegt', 'liegen'],
                      ['lag', 'lagst', 'lag', 'lagen', 'lagt', 'lagen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuSitzen
    {
        conjugateVerb(['','','gesessen','gesessen','sitzen','gesessen sein'][tenseSelector],
              tSelect(['sitze', 'sitzst', 'sitzt', 'sitzen', 'sitzt', 'sitzen'],
                      ['saß', 'saßst', 'saß', 'saßen', 'saßt', 'saßen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuTreffen
    {
        conjugateVerb(['','','getroffen','getroffen','treffen','getroffen haben'][tenseSelector],
              tSelect(['treffe', 'triffst', 'trifft', 'treffen', 'trefft', 'treffen'],
                      ['traf', 'trafst', 'traf', 'trafen', 'traft', 'trafen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuFangen
    {
        conjugateVerb(['','','gefangen','gefangen','fangen','gefangen haben'][tenseSelector],
              tSelect(['fange', 'fängst', 'fängt', 'fangen', 'fangt', 'fangen'],
                      ['fing', 'fingst', 'fing', 'fingen', 'fingt', 'fingen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuEnthalten
    {
        conjugateVerb(['','','enthalten','enthalten','enthalten','enthalten haben'][tenseSelector],
              tSelect(['enthalte', 'enthälst', 'enthält', 'enthalten', 'enthaltet', 'enthalten'],
                      ['enthielt', 'enthielst', 'enthielt', 'enthielten', 'enthielt', 'enthielten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuEntscheiden
    {
        conjugateVerb(['','','entschieden','entschieden','entscheiden','entschieden haben'][tenseSelector],
              tSelect(['entscheide', 'entscheidest', 'entscheidet', 'entscheiden', 'entscheidet', 'entscheiden'],
                      ['entschied', 'entschiedest', 'entschied', 'entschieden', 'entschiedet', 'entschieden'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);  
    }
    verbZuFragen
    {
        conjugateVerb(['','','gefragt','gefragt','fragen','gefragt haben'][tenseSelector],
              tSelect(['frage', 'fragst', 'fragt', 'fragen', 'fragt', 'fragen'],
                      ['fragte', 'fragtest', 'fragte', 'fragten', 'fragtet', 'fragten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuVerlassen
    {
        conjugateVerb(['','','verlassen','verlassen','verlassen','verlassen haben'][tenseSelector],
              tSelect(['verlasse', 'verlässt', 'verlässt', 'verlassen', 'verlasst', 'verlassen'],
                      ['verließ', 'verließt', 'verließ', 'verließen', 'verließt', 'verließen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuKommen
    {
        conjugateVerb(['','','gekommen','gekommen','kommen','gekommen sein'][tenseSelector],
              tSelect(['komme', 'kommst', 'kommt', 'kommen', 'kommt', 'kommen'],
                      ['kam', 'kamst', 'kam', 'kamen', 'kamt', 'kamen'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuWerden
    {
        conjugateVerb(['','','werden','werden','werden','geworden sein'][tenseSelector],
              tSelect(['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuLassen
    {
        conjugateVerb(['','','gelassen','gelassen','lassen','gelassen haben'][tenseSelector],
              tSelect(['lasse', 'läßt', 'läßt', 'lassen', 'lasst', 'lassen'],
                      ['ließ', 'ließst', 'ließ', 'ließen', 'ließt', 'ließen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuKannKon
    {
        conjugateVerb(['','','können','können','können','gekonnt haben'][tenseSelector],
              tSelect(['kann', 'kannst', 'kann', 'können', 'könnt', 'können'],
                      ['konnte', 'konntest', 'konnte', 'konnten', 'konntet', 'konnten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuWeigern
    {
        conjugateVerb(['','','geweigert','geweigert','weigern','geweigert haben'][tenseSelector],
              tSelect(['weigere', 'weigerst', 'weigert', 'weigern', 'weigert', 'weigern'],
                      ['weigerte', 'weigertest', 'weigerte', 'weigerten', 'weigertet', 'weigerten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuBringen
    {
        conjugateVerb(['','','gebracht','gebracht','bringen','gebracht haben'][tenseSelector],
              tSelect(['bringe', 'bringst', 'bringt', 'bringen', 'bringt', 'bringen'],
                      ['brachte', 'brachtest', 'brachte', 'brachten', 'brachtet', 'brachten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuFolgen
    {
        conjugateVerb(['','','gefolgt','gefolgt','folgen','gefolgt haben'][tenseSelector],
              tSelect(['folge', 'folgst', 'folgt', 'folgen', 'folgt', 'folgen'],
                      ['folgte', 'folgtest', 'folgte', 'folgten', 'folgtet', 'folgten'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuZeigen
    {
        conjugateVerb(['','','gezeigt','gezeigt','zeigen','gezeigt haben'][tenseSelector],
              tSelect(['zeige', 'zeigst', 'zeigt', 'zeigen', 'zeigt', 'zeigen'],
                      ['zeigte', 'zeigtest', 'zeigte', 'zeigten', 'zeigtet', 'zeigten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuMachen
    {
        conjugateVerb(['','','gemacht','gemacht','machen','gemacht haben'][tenseSelector],
              tSelect(['macht', 'machst', 'macht', 'machen', 'macht', 'machen'],
                      ['machte', 'machtest', 'machte', 'machten', 'machtet', 'machten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuEssen
    {
        conjugateVerb(['','','gegessen','gegessen','essen','gegessen haben'][tenseSelector],
              tSelect(['esse', 'isst', 'isst', 'essen', 'esst', 'essen'],
                      ['aß', 'aßt', 'aß', 'aßen', 'aßt', 'aßen'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuSchalten
    {
        conjugateVerb(['','','geschaltet','geschaltet','schalten','geschaltet haben'][tenseSelector],
              tSelect(['schalte', 'schaltest', 'schaltet', 'schalten', 'schaltet', 'schalten'],
                      ['schaltete', 'schaltetest', 'schaltete', 'schalteten', 'schaltetet', 'schalteten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuPassieren
    {
        conjugateVerb(['','','passiert','passiert','passieren','passiert haben'][tenseSelector],
              tSelect(['passiere', 'passierst', 'passiert', 'passieren', 'passiert', 'passieren'],
                      ['passierte', 'passiertest', 'passierte', 'passierten', 'passiertet', 'passierten'],
                      ['bin', 'bist', 'ist', 'sind', 'seid', 'sind'],
                      ['war', 'warst', 'war', 'waren', 'wart', 'waren'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }    
    verbZuZuenden
    {
        conjugateVerb(['','','gezündet','gezündet','zünden','gezündet haben'][tenseSelector],
              tSelect(['zünde', 'zündest', 'zündet', 'zünden', 'zündet', 'zünden'],
                      ['zündete', 'zündetest', 'zündete', 'zündeten', 'zündetet', 'zündeten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }   
    verbZuLoesen
    {
        conjugateVerb(['','','gelöst','gelöst','lösen','gelöst haben'][tenseSelector],
              tSelect(['löse', 'löst', 'löst', 'lösen', 'löst', 'lösen'],
                      ['löste', 'löstest', 'löste', 'lösten', 'löstet', 'lösten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }   
    verbZuBrauchen
    {
        conjugateVerb(['','','gebraucht','gebraucht','brauchen','gebraucht haben'][tenseSelector],
              tSelect(['brauche', 'brauchst', 'braucht', 'brauchen', 'braucht', 'brauchen'],
                      ['brauchte', 'brauchtest', 'brauchte', 'brauchten', 'brauchtet', 'brauchten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuLegen
    {
        conjugateVerb(['','','gelegt','gelegt','legen','gelegt haben'][tenseSelector],
              tSelect(['lege', 'legst', 'legt', 'legen', 'legt', 'legen'],
                      ['legte', 'legtest', 'legte', 'legten', 'legtet', 'legten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuHaengen
    {
        conjugateVerb(['','','gehängt','gehängt','hängen','gehängt haben'][tenseSelector],
              tSelect(['hänge', 'hängst', 'hängt', 'hängen', 'hängt', 'hängen'],
                      ['hängte', 'hängtest', 'hängte', 'hängten', 'hängtet', 'hängten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuProbieren
    {
        conjugateVerb(['','','probiert','probiert','probieren','probiert haben'][tenseSelector],
              tSelect(['probiere', 'probierst', 'probiert', 'probieren', 'probiert', 'probieren'],
                      ['probierte', 'probiertest', 'probierte', 'probierten', 'probiertet', 'probieren'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuBenoetigen
    {
        conjugateVerb(['','','benötigt','benötigt','benötigen','benötigt haben'][tenseSelector],
              tSelect(['benötige', 'benötigst', 'benötigt', 'benötigen', 'benötigt', 'benötigen'],
                      ['benötigte', 'benötigtest', 'benötigte', 'benötigten', 'benötigtet', 'benötigten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuOeffnen
    {
        conjugateVerb(['','','geöffnet','geöffnet','öffnen','geöffnet haben'][tenseSelector],
              tSelect(['öffne', 'öffnest', 'öffnet', 'öffnen', 'öffnet', 'öffnen'],
                      ['öffnete', 'öffnetest', 'öffnete', 'öffneten', 'öffnetet', 'öffneten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuWarten
    {
        conjugateVerb(['','','gewartet','gewartet','warten','gewartet haben'][tenseSelector],
              tSelect(['warte', 'wartest', 'wartet', 'warten', 'wartet', 'warten'],
                      ['wartete', 'wartetest', 'wartete', 'warteten', 'wartetet', 'warteten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuVersuchen
    {
        conjugateVerb(['','','versucht','versucht','versuchen','versucht haben'][tenseSelector],
              tSelect(['versuche', 'versuchst', 'versucht', 'versuchen', 'versucht', 'versuchen'],
                      ['versuchte', 'versuchtest', 'versuchte', 'versuchten', 'versuchtet', 'versuchten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuStellen
    {
        conjugateVerb(['','','gestellt','gestellt','stellen','gestellt haben'][tenseSelector],
              tSelect(['stelle', 'stellst', 'stellt', 'stellen', 'stellt', 'stellen'],
                      ['stellte', 'stelltest', 'stellte', 'stellten', 'stelltet', 'stellten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuLoeschen
    {
        conjugateVerb(['','','gelöscht','gelöscht','löschen','gelöscht haben'][tenseSelector],
              tSelect(['lösche', 'löschst', 'löscht', 'löschen', 'löscht', 'löschen'],
                      ['löschte', 'löschtest', 'löschte', 'löschten', 'löschtet', 'löschten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuVerbinden
    {
        conjugateVerb(['','','verbunden','verbunden','verbinden','verbunden haben'][tenseSelector],
              tSelect(['verbinde', 'verbindest', 'verbindet', 'verbinden', 'verbindet', 'verbinden'],
                      ['verband', 'verbandst', 'verband', 'verbanden', 'verbandet', 'verbanden'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuFuehlen
    {
        conjugateVerb(['','','gefühlt','gefühlt','fühlen','gefühlt haben'][tenseSelector],
              tSelect(['fühle', 'fühlst', 'fühlt', 'fühlen', 'fühlt', 'fühlen'],
                      ['fühlte', 'fühltest', 'fühlte', 'fühlten', 'fühltet', 'fühlten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    verbZuSchmecken
    {
        conjugateVerb(['','','geschmeckt','geschmeckt','schmecken','geschmeckt haben'][tenseSelector],
              tSelect(['schmecke', 'schmeckst', 'schmeckt', 'schmecken', 'schmeckt', 'schmecken'],
                      ['schmeckte', 'schmecktest', 'schmeckte', 'schmeckten', 'schmecktet', 'schmeckten'],
                      ['habe', 'hast', 'hat', 'haben', 'habt', 'haben'],
                      ['hatte', 'hattest', 'hatte', 'hatten', 'hattet', 'hatten'],
                      ['werde', 'wirst', 'wird', 'werden', 'werdet', 'werden'])[conjugationSelector]);
    }
    
    /*
     *   Show my name for an arrival/departure message.  If we've been seen
     *   before by the player character, we'll show our definite name,
     *   otherwise our indefinite name.
     */
    travelerName(arriving)
        { say(gPlayerChar.hasSeen(self) ? derName : einName); }

    /*
     *   Test to see if we can match the third-person pronouns.  We'll
     *   match these if our inherited test says we match them AND we can
     *   be referred to in the third person.
     */
    canMatchHim = (inherited && canMatch3rdPerson)
    canMatchHer = (inherited && canMatch3rdPerson)
    canMatchIt = (inherited && canMatch3rdPerson)
    canMatchThem = (inherited && canMatch3rdPerson)

    /*
     *   Test to see if we can match a third-person pronoun ('it', 'him',
     *   'her', 'them').  We can unless we're the player character and the
     *   player character is referred to in the first or second person.
     */
    canMatch3rdPerson = (!isPlayerChar || referralPerson == ThirdPerson)

    /*
     *   Set a pronoun antecedent to the given list of ResolveInfo objects.
     *   Pronoun handling is language-specific, so this implementation is
     *   part of the English library, not the generic library.
     *
     *   If only one object is present, we'll set the object to be the
     *   antecedent of 'it', 'him', or 'her', according to the object's
     *   gender.  We'll also set the object as the single antecedent for
     *   'them'.
     *
     *   If we have multiple objects present, we'll set the list to be the
     *   antecedent of 'them', and we'll forget about any antecedent for
     *   'it'.
     *
     *   Note that the input is a list of ResolveInfo objects, so we must
     *   pull out the underlying game objects when setting the antecedents.
     */
    setPronoun(lst)
    {
        /* if the list is empty, ignore it */
        if (lst == [])
            return;

        /*
         *   if we have multiple objects, the entire list is the antecedent
         *   for 'them'; otherwise, it's a singular antecedent which
         *   depends on its gender
         */
        if (lst.length() > 1)
        {
            local objs = lst.mapAll({x: x.obj_});

            /* it's 'them' */
            setThem(objs);
            setHer(objs); //before only setThem, because sie(female) und sie(plural)
            // ##### cannot be disambiguated in german #####

            /* forget any 'it' */
            setIt(nil);
        }
        else if (lst.length() == 1)
        {
            /*
             *   We have only one object, so set it as an antecedent
             *   according to its gender.
             */
            setPronounObj(lst[1].obj_);
        }
    }

    /*
     *   Set a pronoun to refer to multiple potential antecedents.  This is
     *   used when the verb has multiple noun slots - UNLOCK DOOR WITH KEY.
     *   For verbs like this, we have no way of knowing in advance whether
     *   a future pronoun will refer back to the direct object or the
     *   indirect object (etc) - we could just assume that 'it' will refer
     *   to the direct object, but this won't always be what the player
     *   intended.  In natural English, pronoun antecedents must often be
     *   inferred from context at the time of use - so we use the same
     *   approach.
     *
     *   Pass an argument list consisting of ResolveInfo lists - that is,
     *   pass one argument per noun slot in the verb, and make each
     *   argument a list of ResolveInfo objects.  In other words, you call
     *   this just as you would setPronoun(), except you can pass more than
     *   one list argument.
     *
     *   We'll store the multiple objects as antecedents.  When we need to
     *   resolve a future singular pronoun, we'll figure out which of the
     *   multiple antecedents is the most logical choice in the context of
     *   the pronoun's usage.
     */
    setPronounMulti([args])
    {
        local lst, subLst;
        local gotThem;

        /*
         *   If there's a plural list, it's 'them'.  Arbitrarily use only
         *   the first plural list if there's more than one.
         */
        if ((lst = args.valWhich({x: x.length() > 1})) != nil)
        {
            /* set 'them' to the plural list */
            setPronoun(lst);

            /* note that we had a clear 'them' */
            gotThem = true;
        }

        /* from now on, consider only the sublists with exactly one item */
        args = args.subset({x: x.length() == 1});

        /* get a list of the singular items from the lists */
        lst = args.mapAll({x: x[1].obj_});

        /*
         *   Set 'it' to all of the items that can match 'it'; do likewise
         *   with 'him' and 'her'.  If there are no objects that can match
         *   a given pronoun, leave that pronoun unchanged.  
         */
        if ((subLst = lst.subset({x: x.canMatchIt})).length() > 0)
            setIt(subLst);
        if ((subLst = lst.subset({x: x.canMatchHim})).length() > 0)
            setHim(subLst);
        if ((subLst = lst.subset({x: x.canMatchHer})).length() > 0)
            setHer(subLst);

        /*
         *   set 'them' to the potential 'them' matches, if we didn't
         *   already find a clear plural list
         */
        if (!gotThem
            && (subLst = lst.subset({x: x.canMatchThem})).length() > 0)
            setThem(subLst);
    }

    /*
     *   Set a pronoun antecedent to the given ResolveInfo list, for the
     *   specified type of pronoun.  We don't have to worry about setting
     *   other types of pronouns to this antecedent - we specifically want
     *   to set the given pronoun type.  This is language-dependent
     *   because we still have to figure out the number (i.e. singular or
     *   plural) of the pronoun type.
     */
    setPronounByType(typ, lst)
    {
        /* check for singular or plural pronouns */
        if (typ == PronounThem)
        {
            /* it's plural - set a list antecedent */
            setPronounAntecedent(typ, lst.mapAll({x: x.obj_}));
        }
        else
        {
            /* it's singular - set an individual antecedent */
            setPronounAntecedent(typ, lst[1].obj_);
        }
    }

    /*
     *   Set a pronoun antecedent to the given simulation object (usually
     *   an object descended from Thing).
     */
    setPronounObj(obj)
    {
        /*
         *   Actually use the object's "identity object" as the antecedent
         *   rather than the object itself.  In some cases, we use multiple
         *   program objects to represent what appears to be a single
         *   object in the game; in these cases, the internal program
         *   objects all point to the "real" object as their identity
         *   object.  Whenever we're manipulating one of these internal
         *   program objects, we want to make sure that its the
         *   player-visible object - the identity object - that appears as
         *   the antecedent for subsequent references.
         */
        obj = obj.getIdentityObject();

        /*
         *   Set the appropriate pronoun antecedent, depending on the
         *   object's gender.
         *
         *   Note that we'll set an object to be the antecedent for both
         *   'him' and 'her' if the object has both masculine and feminine
         *   usage.
         */

        /* check for masculine usage */
        if (obj.canMatchHim || obj.maleSynFlag) // maleSynFlag added
        {
            setHim(obj);
            obj.maleSynFlag = nil; // Testphase this line instead of the block below
        }
        /* check for feminine usage */
        if (obj.canMatchHer || obj.femaleSynFlag) // femaleSynFlag added
        {
            setHer(obj);
            obj.femaleSynFlag = nil; // Testphase this line instead of the block below
        }

        /* check for neuter usage */
        if (obj.canMatchIt || obj.neuterSynFlag) // neuterSynFlag added
        {
            setIt(obj);
            obj.neuterSynFlag = nil; // Testphase this line instead of the block below
        }

        /* check for third-person plural usage */
        if (obj.canMatchThem || obj.pluralSynFlag) // pluralSynFlag added
        {
            setHer([obj]); //change to setHer instead of setThem "sie" = "sie"
            //setThem([obj]); 
            obj.pluralSynFlag = nil; // Testphase this line instead of the block below
        }
    }

    /* set a possessive anaphor */
    setPossAnaphorObj(obj)
    {
        /* check for each type of usage */
        if (obj.canMatchHim)
            possAnaphorTable[PronounHim] = obj;
        if (obj.canMatchHer)
            possAnaphorTable[PronounHer] = obj;
        if (obj.canMatchIt)
            possAnaphorTable[PronounIt] = obj;
        if (obj.canMatchThem)
            possAnaphorTable[PronounThem] = [obj];
    }
    
    actorInPrep = 'auf' // -- German: We might sit on somebody, not in somebody
;

/* ------------------------------------------------------------------------ */
/*
 *   Give the postures some additional attributes
 */

modify standing
    msgVerbI = '{steht} auf' 
    msgVerbT = '{steht}'

    msgVerbIPlural = '{steht plural} auf'  
    msgVerbTPlural = '{steht plural}'

    participle = 'stehend'
;

modify sitting
    msgVerbI = '{sitzt} auf'
    msgVerbT = '{sitzt}'

    msgVerbIPlural = '{sitzt plural} auf'  
    msgVerbTPlural = '{sitzt plural}'

    participle = 'sitzend'
;

modify lying
    msgVerbI = '{liegt} auf'
    msgVerbT = '{liegt}'

    msgVerbIPlural = '{liegt plural} auf'  
    msgVerbTPlural = '{liegt plural}'

    participle = 'liegend'
;

/* ------------------------------------------------------------------------ */
/*
 *   For our various topic suggestion types, we can infer the full name
 *   from the short name fairly easily.
 */
modify SuggestedAskTopic
    fullName = ('{den targetActor/ihn} nach ' + name + ' fragen')
;

modify SuggestedTellTopic
    fullName = ('{dem targetActor/ihm} von ' + name + ' erzählen')
;

modify SuggestedAskForTopic
    fullName = ('{den targetActor/ihn} um ' + name + ' bitten')
;

modify SuggestedGiveTopic
    fullName = ('{dem targetActor/ihm} ' + name + ' geben')
;

modify SuggestedShowTopic
    fullName = ('{dem targetActor/ihn} ' + name + ' zeigen')
;

modify SuggestedYesTopic
    name = 'ja'
    fullName = 'ja sagen'
;

modify SuggestedNoTopic
    name = 'nein'
    fullName = 'nein sagen'
;

/* ------------------------------------------------------------------------ */
/*
 *   Provide custom processing of the player input for matching
 *   SpecialTopic patterns.  When we're trying to match a player's command
 *   to a set of active special topics, we'll run the input through this
 *   processing to produce the string that we actually match against the
 *   special topics.
 *
 *   First, we'll remove any punctuation marks.  This ensures that we'll
 *   still match a special topic, for example, if the player puts a period
 *   or a question mark at the end of the command.
 *
 *   Second, if the user's input starts with "A" or "T" (the super-short
 *   forms of the ASK ABOUT and TELL ABOUT commands), remove the "A" or "T"
 *   and keep the rest of the input.  Some users might think that special
 *   topic suggestions are meant as ask/tell topics, so they might
 *   instinctively try these as A/T commands.
 *
 *   Users *probably* won't be tempted to do the same thing with the full
 *   forms of the commands (e.g., ASK BOB ABOUT APOLOGIZE, TELL BOB ABOUT
 *   EXPLAIN).  It's more a matter of habit of using A or T for interaction
 *   that would tempt a user to phrase a special topic this way; once
 *   you're typing out the full form of the command, it generally won't be
 *   grammatical, as special topics generally contain the sense of a verb
 *   in their phrasing.
 */
modify specialTopicPreParser
    processInputStr(str)
    {
        /*
         *   remove most punctuation from the string - we generally want to
         *   ignore these, as we mostly just want to match keywords
         */
        str = rexReplace(punctPat, str, '', ReplaceAll);

        /* if it starts with "A" or "T", strip off the leading verb */
        if (rexMatch(aOrTPat, str) != nil)
            str = rexGroup(1)[3];

        /* return the processed result */
        return str;
    }

    /* pattern for string starting with "A" or "T" verbs */
    aOrTPat = static new RexPattern(
        '<nocase><space>*[at]<space>+(<^space>.*)$')

    /* pattern to eliminate punctuation marks from the string */
    punctPat = static new RexPattern('[.?!,;:]');
;

/*
 *   For SpecialTopic matches, treat some strings as "weak": if the user's
 *   input consists of just one of these weak strings and nothing else,
 *   don't match the topic.
 */
modify SpecialTopic
    matchPreParse(str, procStr)
    {
        /* if it's one of our 'weak' strings, don't match */
        if (rexMatch(weakPat, str) != nil)
            return nil;

        /* it's not a weak string, so match as usual */
        return inherited(str, procStr);
    }

    /*
     *   Our "weak" strings - 'i', 'l', 'look': these are weak because a
     *   user typing one of these strings by itself is probably actually
     *   trying to enter the command of the same name, rather than entering
     *   a special topic.  These come up in cases where the special topic
     *   is something like "say I don't know" or "tell him you'll look into
     *   it".
     */
    weakPat = static new RexPattern('<nocase><space>*(i|l|schau)<space>*$')
;

/* ------------------------------------------------------------------------ */
/*
 *   English-specific Traveler changes
 */
modify Traveler
    /*
     *   Get my location's name, from the PC's perspective, for describing
     *   my arrival to or departure from my current location.  We'll
     *   simply return our location's destName, or "the area" if it
     *   doesn't have one.
     */
    travelerLocName()
    {
        /* get our location's name from the PC's perspective */
        local nm = location.getDestName(gPlayerChar, gPlayerChar.location);
            if (!location.isProperName) {
            if (location.isHim)
                nm = 'den '+ nm;
            if (location.isHer)
                nm = 'die '+ nm;       
            if (location.isPlural)
                nm = 'die '+ nm;
            if (!location.isHim && !location.isHer && !location.isPlural)
                nm = 'das '+ nm;
        }
        /* if there's a name, return it; otherwise, use "the area" */
        return (nm.length() > 4 ? nm : 'den Ort');
    }

    denTravelerLocName()
    {
        /* get our location's name from the PC's perspective */
        local nm = location.getDestName(gPlayerChar, gPlayerChar.location);

        /* if there's a name, return it; otherwise, use "the area" */
        return (nm.length() > 4 ? nm : 'den Ort');
    }
    
    demTravelerLocName()
    {
        /* get our location's name from the PC's perspective */
        withCaseDative;
        local nm = location.getDestName(gPlayerChar, gPlayerChar.location);

        withCaseAccusative;
        /* if there's a name, return it; otherwise, use "the area" */
        return (nm.length() > 4 ? nm : 'dem Ort');
    }
    
    /*
     *   Get my "remote" location name, from the PC's perspective.  This
     *   returns my location name, but only if my location is remote from
     *   the PC's perspective - that is, my location has to be outside of
     *   the PC's top-level room.  If we're within the PC's top-level
     *   room, we'll simply return an empty string.
     */
    travelerRemoteLocName()
    {
        /*
         *   if my location is outside of the PC's outermost room, we're
         *   remote, so return my location name; otherwise, we're local,
         *   so we don't need a remote name at all
         */
        if (isIn(gPlayerChar.getOutermostRoom()))
            return 'den Ort';
        else
            return travelerLocName;
    }
    
    denTravelerRemoteLocName()
    {
        /*
         *   if my location is outside of the PC's outermost room, we're
         *   remote, so return my location name; otherwise, we're local,
         *   so we don't need a remote name at all
         */
        if (isIn(gPlayerChar.getOutermostRoom()))
            return 'den Ort';
        else
            return denTravelerLocName;
    }
    
    demTravelerRemoteLocName()
    {
        /*
         *   if my location is outside of the PC's outermost room, we're
         *   remote, so return my location name; otherwise, we're local,
         *   so we don't need a remote name at all
         */
        if (isIn(gPlayerChar.getOutermostRoom()))
            return 'dem Ort';
        else
            return demTravelerLocName;
    }
    
;

/* ------------------------------------------------------------------------ */
/*
 *   English-specific Vehicle changes
 */
modify Vehicle
    /*
     *   Display the name of the traveler, for use in an arrival or
     *   departure message.
     */
    travelerName(arriving)
    {
        /*
         *   By default, start with the indefinite name if we're arriving,
         *   or the definite name if we're leaving.
         *
         *   If we're leaving, presumably they've seen us before, since we
         *   were already in the room to start with.  Since we've been
         *   seen before, the definite is appropriate.
         *
         *   If we're arriving, even if we're not being seen for the first
         *   time, we haven't been seen yet in this place around this
         *   time, so the indefinite is appropriate.
         */
        say(arriving ? einName : derName);

        /* show the list of actors aboard */
        aboardVehicleListerObj.showList(
            libGlobal.playerChar, nil, allContents(), 0, 0,
            libGlobal.playerChar.visibleInfoTable(), nil);
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   English-specific PushTraveler changes
 */
modify PushTraveler
    /*
     *   When an actor is pushing an object from one room to another, show
     *   its name with an additional clause indicating the object being
     *   moved along with us.
     */
    travelerName(arriving)
    {
        "<<gPlayerChar.hasSeen(self) ? derName : einName>>,
        <<obj_.denNameObj>> vor sich her schiebend,";
    }
;

// ******
// -- German specific modifications based on special grammar rules
// ******

modify PathPassage
    /* treat "take path" the same as "enter path" or "go through path" */
    dobjFor(Take) maybeRemapTo(
        (gAction.getEnteredVerbPhrase() == 'nimm (dobj)'
         || gAction.getEnteredVerbPhrase() == 'nehm (dobj)' ), TravelVia, self)

    dobjFor(Enter)
    {
        verify() { logicalRank(50, 'betret pfad'); }
    }
    dobjFor(GoThrough)
    {
        verify() { logicalRank(50, 'betret pfad'); }
    }
;

modify OnOffControl
    //  ##### treat "stell onoffcontrol ab" the same as "schalt onoffcontrol ab" #####
    dobjFor(Drop) maybeRemapTo(
        (gAction.getEnteredVerbPhrase() == 'stell (dobj) ab' 
         || gAction.getEnteredVerbPhrase() == 'stelle (dobj) ab'), TurnOff, self)
;

modify Thing
    
    // ##################################################
    // ## we remap PlugIn as TakeAction, unless the we ##
    // ## have an object of Attachable class           ##
    // ##################################################

    dobjFor(PlugIn) maybeRemapTo (!self.ofKind(Attachable), Take, self) 
    
    // #####################################################
    // ## we remap PlugInto as PutInAction, overridden by ##
    // ## remapping in Attachable class                   ##
    // #####################################################
    
    dobjFor(PlugInto) remapTo (PutIn, self, IndirectObject)
    
;

modify AskConnector
    /*
     *   This is the noun phrase we'll use when asking disambiguation
     *   questions for this travel connector: "Which *one* do you want to
     *   enter..."
     */
    travelObjsPhrase = '' // ##### German: we have no which 'one' #####
;

/* ------------------------------------------------------------------------ */
/*
 *   German-specific changes for various nested room types.
 */
modify BasicChair
    /* by default, one sits *on* a chair */
    objInPrep = 'auf'
    actorInPrep = 'auf'
    actorOutOfPrep = 'von' //here: (von dem Stuhl steigen)
;

modify BasicPlatform
    /* by default, one stands *on* a platform */
    objInPrep = 'auf'
    actorInPrep = 'auf'
    actorOutOfPrep = 'von' //here: (von dem Vorsprung steigen)
;

modify Booth
    /* by default, one is *in* a booth */
    objInPrep = 'in'
    actorInPrep = 'in'
    actorOutOfPrep = 'aus' //here: (aus der Telefonzelle steigen)
;

/* ------------------------------------------------------------------------ */
/*
 *   Language modifications for Matchstick
 */
modify Matchstick

    /* "light match" means "burn match" */
    dobjFor(Light) asDobjFor(Burn)
;

/*
 *   Match state objects.  We show "lit" as the state for a lit match,
 *   nothing for an unlit match.
 */
matchStateLit: ThingState 'angezündet'
    stateTokens = ['an','angezündet']
;
matchStateUnlit: ThingState
    stateTokens = ['aus','unangezündet']
;


/* ------------------------------------------------------------------------ */
/*
 *   English-specific modifications for Room.
 */
modify Room
    /*
     *   The ordinary 'name' property is used the same way it's used for
     *   any other object, to refer to the room when it shows up in
     *   library messages and the like: "You can't take the hallway."
     *
     *   By default, we derive the name from the roomName by converting
     *   the roomName to lower case.  Virtually every room will need a
     *   custom room name setting, since the room name is used mostly as a
     *   title for the room, and good titles are hard to generate
     *   mechanically.  Many times, converting the roomName to lower case
     *   will produce a decent name to use in messages: "Ice Cave" gives
     *   us "You can't eat the ice cave."  However, games will want to
     *   customize the ordinary name separately in many cases, because the
     *   elliptical, title-like format of the room name doesn't always
     *   translate well to an object name: "West of Statue" gives us the
     *   unworkable "You can't eat the west of statue"; better to make the
     *   ordinary name something like "plaza".  Note also that some rooms
     *   have proper names that want to preserve their capitalization in
     *   the ordinary name: "You can't eat the Hall of the Ancient Kings."
     *   These cases need to be customized as well.
     */
    name = (roomName) // ##### without To lower ... #####

    /*
     *   The "destination name" of the room.  This is primarily intended
     *   for use in showing exit listings, to describe the destination of
     *   a travel connector leading away from our current location, if the
     *   destination is known to the player character.  We also use this
     *   as the default source of the name in similar contexts, such as
     *   when we can see this room from another room connected by a sense
     *   connector.
     *
     *   The destination name usually mirrors the room name, but we use
     *   the name in prepositional phrases involving the room ("east, to
     *   the alley"), so this name should include a leading article
     *   (usually definite - "the") unless the name is proper ("east, to
     *   Dinsley Plaza").  So, by default, we simply use the "theName" of
     *   the room.  In many cases, it's better to specify a custom
     *   destName, because this name is used when the PC is outside of the
     *   room, and thus can benefit from a more detailed description than
     *   we'd normally use for the basic name.  For example, the ordinary
     *   name might simply be something like "hallway", but since we want
     *   to be clear about exactly which hallway we're talking about when
     *   we're elsewhere, we might want to use a destName like "the
     *   basement hallway" or "the hallway outside the operating room".
     */
    // ##### depends on current case ... #####
    destName = (curcase.isDat ? demName : curcase.isAkk ? denName : curcase.isGen ? desName : derName)
      
    /*
     *   For top-level rooms, describe an object as being in the room by
     *   describing it as being in the room's nominal drop destination,
     *   since that's the nominal location for the objects directly in the
     *   room.  (In most cases, the nominal drop destination for a room is
     *   its floor.)
     *
     *   If the player character isn't in the same outermost room as this
     *   container, use our remote name instead of the nominal drop
     *   destination.  The nominal drop destination is usually something
     *   like the floor or the ground, so it's only suitable when we're in
     *   the same location as what we're describing.
     */
    childInName(childName)
    {
        /* if the PC isn't inside us, we're viewing this remotely */
        if (!gPlayerChar.isIn(self))
            return childInRemoteName(childName, gPlayerChar);
        else
            return getNominalDropDestination().childInName(childName);
    }
    childInNameWithOwner(chiName)
    {
        /* if the PC isn't inside us, we're viewing this remotely */
        if (!gPlayerChar.isIn(self))
            return inherited(chiName);
        else
            return getNominalDropDestination().childInNameWithOwner(chiName);
    }
    // -- new definitions in German
    isHim = nil
    isHer = nil
    isPlural = nil
    isYours = nil
;

/* ------------------------------------------------------------------------ */
/*
 *   German-specific modifications for the default room parts.
 */

modify Floor
    childInNameGen(childName, myName) { return childName + ' auf ' + myName; }
    objInPrep = 'auf'
    actorInPrep = 'auf'
    actorOutOfPrep = 'von dativ'
;

modify defaultFloor
    noun = 'fußboden' 'boden'
    name = 'Fußboden[-s]'
    isHim = true 
;

modify defaultGround
    noun = 'erdboden' 'boden' 'grund' 'untergrund'
    name = 'Boden[-s]'
    isHim = true 
;

modify DefaultWall noun='wand' plural='wände' name='Wand' isHer = true;
modify defaultCeiling noun='decke' 'dach[n]' name='Decke' isHer = true;
modify defaultNorthWall adjective='nördlich' noun='nordwand' name='Nordwand';
modify defaultSouthWall adjective='südlich' noun='südwand' name='Südwand';
modify defaultEastWall adjective='östlich' noun='ostwand' name='Ostwand';
modify defaultWestWall adjective='westlich' noun='westwand' name='Westwand';
modify defaultSky noun='himmel' name='Himmel[-s]' isHim = true;

/* ------------------------------------------------------------------------ */
/*
 *   The English-specific modifications for directions.
 */
modify Direction
    /* describe a traveler arriving from this direction */
    sayArriving(traveler)
    {
        /* show the generic arrival message */
        gLibMessages.sayArriving(traveler);
    }

    /* describe a traveler departing in this direction */
    sayDeparting(traveler)
    {
        /* show the generic departure message */
        gLibMessages.sayDeparting(traveler);
    }
;

/*
 *   The English-specific modifications for compass directions.
 */
modify CompassDirection
    /* describe a traveler arriving from this direction */
    sayArriving(traveler)
    {
        /* show the generic compass direction description */
        gLibMessages.sayArrivingDir(traveler, name);
    }

    /* describe a traveler departing in this direction */
    sayDeparting(traveler)
    {
        /* show the generic compass direction description */
        gLibMessages.sayDepartingDir(traveler, name);
    }
;

/*
 *   The English-specific definitions for the compass direction objects.
 *   In addition to modifying the direction objects to define the name of
 *   the direction, we add a 'directionName' grammar rule.
 */
#define DefineLangDir(root, dirNames, backPre) \
grammar directionName(root): dirNames: DirectionProd \
   dir = root##Direction \
; \
\
modify root##Direction \
   name = #@root \
   backToPrefix = backPre

DefineLangDir(north, 'norden' | 'n', 'zurück nach');
DefineLangDir(south, 'süden' | 's', 'zurück nach');
DefineLangDir(east, 'osten' | 'o', 'zurück nach');
DefineLangDir(west, 'westen' | 'w', 'zurück nach');
DefineLangDir(northeast, 'nordosten' | 'no', 'zurück nach');
DefineLangDir(northwest, 'nordwesten' | 'nw', 'zurück nach');
DefineLangDir(southeast, 'südosten' | 'so', 'zurück nach');
DefineLangDir(southwest, 'südwesten' | 'sw', 'zurück nach');
DefineLangDir(up, 'hoch' | 'h' | 'hinauf' | 'oben', 'zurück nach');
DefineLangDir(down, 'r' | 'hinunter' | 'unten' , 'zurück nach');
DefineLangDir(in, 'drinnen'|'hinein', 'zurück nach');
DefineLangDir(out, 'draußen'|'hinaus', 'zurück nach');

modify northDirection
    name = 'Norden'
    noun = 'norden'
    isHim = true
;

modify southDirection
    name = 'Süden'
    noun = 'süden'
    isHim = true
;

modify westDirection
    name = 'Westen'
    noun = 'westen'
    isHim = true
;

modify eastDirection
    name = 'Osten'
    noun = 'osten'
    isHim = true
;

modify northeastDirection
    name = 'Nordosten'
    noun = 'nordosten'
    isHim = true
;

modify northwestDirection
    name = 'Nordwesten'
    noun = 'nordwesten'
    isHim = true
;

modify southeastDirection
    name = 'Südosten'
    noun = 'südosten'
    isHim = true
;

modify southwestDirection
    name = 'Südwesten'
    noun = 'südwesten'
    isHim = true
;

modify upDirection
    name = 'hoch'
    destName = 'oben'
;

modify downDirection
    name = 'runter'
    destName = 'unten'
;

modify outDirection
    name = 'raus'
    destName = 'draußen' //GERMAN: DISPLAY outDirection as 'draußen'
;

modify inDirection
    name = 'rein'
    destName = 'drinnen' //GERMAN: DISPLAY in Direction as 'drinnen'
;


/*
 *   The English-specific shipboard direction modifications.  Certain of
 *   the ship directions have no natural descriptions for arrival and/or
 *   departure; for example, there's no good way to say "arriving from
 *   fore."  Others don't fit any regular pattern: "he goes aft" rather
 *   than "he departs to aft."  As a result, these are a bit irregular
 *   compared to the compass directions and so are individually defined
 *   below.
 */

DefineLangDir(port, 'backbord' | 'bb', 'zurück nach')
    sayArriving(trav)
        { gLibMessages.sayArrivingShipDir(trav, 'backbord'); }
    sayDeparting(trav)
        { gLibMessages.sayDepartingShipDir(trav, 'backbord'); }
;

DefineLangDir(starboard, 'steuerbord' | 'sb', 'zurück nach')
    sayArriving(trav)
        { gLibMessages.sayArrivingShipDir(trav, 'steuerbord'); }
    sayDeparting(trav)
        { gLibMessages.sayDepartingShipDir(trav, 'steuerbord'); }
;

DefineLangDir(aft, 'achtern' | 'hinten' | 'hi', 'zurück nach')
    sayArriving(trav) { gLibMessages.sayArrivingShipDir(trav, 'achtern'); }
    sayDeparting(trav) { gLibMessages.sayDepartingAft(trav); }
;

DefineLangDir(fore, 'vorn' | 'vorwärts' | 'vo', 'zurück nach')
    sayArriving(trav) { gLibMessages.sayArrivingShipDir(trav, 'vorne'); }
    sayDeparting(trav) { gLibMessages.sayDepartingFore(trav); }
;

modify portDirection
   name = 'Backbord'
;

modify starboardDirection
   name = 'Steuerbord'
;

modify aftDirection
   name = 'hinten'
;

modify foreDirection
   name = 'vorne'
;


/* ------------------------------------------------------------------------ */
/*
 *   Some helper routines for the library messages.
 */
class MessageHelper: object
    /*
     *   Show a list of objects for a disambiguation query.  If
     *   'showIndefCounts' is true, we'll show the number of equivalent
     *   items for each equivalent item; otherwise, we'll just show an
     *   indefinite noun phrase for each equivalent item.
     */
    askDisambigList(matchList, fullMatchList, showIndefCounts, dist)
    {
        /* show each item */
        for (local i = 1, local len = matchList.length() ; i <= len ; ++i)
        {
            local equivCnt;
            local obj;

            /* get the current object */
            obj = matchList[i].obj_;
            /*
             *   if this isn't the first, add a comma; if this is the
             *   last, add an "or" as well
              */
            if (i == len)
                " oder ";
            else if (i != 1)
                ", ";

            /*
             *   Check to see if more than one equivalent of this item
             *   appears in the full list.
             */
            for (equivCnt = 0, local j = 1,
                 local fullLen = fullMatchList.length() ; j <= fullLen ; ++j)
            {
                /*
                 *   if this item is equivalent for the purposes of the
                 *   current distinguisher, count it
                 */
                if (!dist.canDistinguish(obj, fullMatchList[j].obj_))
                {
                    /* it's equivalent - count it */
                    ++equivCnt;
                }
            }

            /* show this item with the appropriate article */
            if (equivCnt > 1)
            {
                /*
                 *   we have multiple equivalents - show either with an
                 *   indefinite article or with a count, depending on the
                 *   flags the caller provided
                 */
                if (showIndefCounts)
                {
                    /* a count is desired for each equivalent group */
                    say(dist.countName(obj, equivCnt));
                }
                else
                {
                    /* no counts desired - show with an indefinite article */
                    say(dist.einenName(obj)); //VORHER dist.einenName(obj) ?!?
                }
            }
            else
            {
                /* there's only one - show with a definite article */
                say(dist.denName(obj));
            }
        }
    }

    /*
     *   For a TAction result, select the short-form or long-form message,
     *   according to the disambiguation status of the action.  This is for
     *   the ultra-terse default messages, such as "Taken" or "Dropped",
     *   that sometimes need more descriptive variations.
     *   
     *   If there was no disambiguation involved, we'll use the short
     *   version of the message.
     *   
     *   If there was unclear disambiguation involved (meaning that there
     *   was more than one logical object matching a noun phrase, but the
     *   parser was able to decide based on likelihood rankings), we'll
     *   still use the short version, because we assume that the parser
     *   will have generated a parenthetical announcement to point out its
     *   choice.
     *   
     *   If there was clear disambiguation involved (meaning that more than
     *   one in-scope object matched a noun phrase, but there was only one
     *   choice that passed the logicalness tests), AND the announcement
     *   mode (in gameMain.ambigAnnounceMode) is DescribeClear, we'll
     *   choose the long-form message.  
     */
    shortTMsg(short, long)
    {
        /* check the disambiguation flags and the announcement mode */
        if ((gAction.getDobjFlags() & (ClearDisambig | AlwaysAnnounce))
            == ClearDisambig
            && gAction.getDobjCount() == 1
            && gameMain.ambigAnnounceMode == DescribeClear)
        {
            /* clear disambig and DescribeClear mode - use the long message */
            return long;
        }
        else
        {
            /* in other cases, use the short message */
            return short;
        }
    }

    /*
     *   For a TIAction result, select the short-form or long-form message.
     *   This works just like shortTIMsg(), but takes into account both the
     *   direct and indirect objects. 
     */
    shortTIMsg(short, long)
    {
        /* check the disambiguation flags and the announcement mode */
        if (((gAction.getDobjFlags() & (ClearDisambig | AlwaysAnnounce))
             == ClearDisambig
             || (gAction.getIobjFlags() & (ClearDisambig | AlwaysAnnounce))
             == ClearDisambig)
            && gAction.getDobjCount() == 1
            && gAction.getIobjCount() == 1
            && gameMain.ambigAnnounceMode == DescribeClear)
        {
            /* clear disambig and DescribeClear mode - use the long message */
            return long;
        }
        else
        {
            /* in other cases, use the short message */
            return short;
        }
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Custom base resolver
 */
modify Resolver
    /*
     *   Get the default in-scope object list for a given pronoun.  We'll
     *   look for a unique object in scope that matches the desired
     *   pronoun, and return a ResolveInfo list if we find one.  If there
     *   aren't any objects in scope that match the pronoun, or multiple
     *   objects are in scope, there's no default.
     */
    getPronounDefault(typ, np)
    {
        local map = [PronounHim, &canMatchHim,
                     PronounHer, &canMatchHer,
                     PronounIt, &canMatchIt];
        local idx = map.indexOf(typ);
        local filterProp = (idx != nil ? map[idx + 1] : nil);
        local lst;

        /* if we couldn't find a filter for the pronoun, ignore it */
        if (filterProp == nil)
            return [];

        /*
         *   filter the list of all possible defaults to those that match
         *   the given pronoun
         */
        lst = getAllDefaults.subset({x: x.obj_.(filterProp)});

        /*
         *   if the list contains exactly one element, then there's a
         *   unique default; otherwise, there's either nothing here that
         *   matches the pronoun or the pronoun is ambiguous, so there's
         *   no default
         */
        if (lst.length() == 1)
        {
            /*
             *   we have a unique object, so they must be referring to it;
             *   because this is just a guess, though, mark it as vague
             */
            lst[1].flags_ |= UnclearDisambig;

            /* return the list */
            return lst;
        }
        else
        {
            /*
             *   the pronoun doesn't have a unique in-scope referent, so
             *   we can't guess what they mean
             */
            return [];
        }
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Custom interactive resolver.  This is used for responses to
 *   disambiguation questions and prompts for missing noun phrases.
 */
modify InteractiveResolver
    /*
     *   Resolve a pronoun antecedent.  We'll resolve a third-person
     *   singular pronoun to the target actor if the target actor matches
     *   in gender, and the target actor isn't the PC.  This allows
     *   exchanges like this:
     *
     *.  >bob, examine
     *.  What do you want Bob to look at?
     *.
     *.  >his book
     *
     *   In the above exchange, we'll treat "his" as referring to Bob, the
     *   target actor of the action, because we have referred to Bob in
     *   the partial command (the "BOB, EXAMINE") that triggered the
     *   interactive question.
     */
    resolvePronounAntecedent(typ, np, results, poss)
    {
        local lst;

        /* try resolving with the target actor as the antecedent */
        if ((lst = resolvePronounAsTargetActor(typ)) != nil)
            return lst;

        /* use the inherited result */
        return inherited(typ, np, results, poss);
    }

    /*
     *   Get the reflexive third-person pronoun binding (himself, herself,
     *   itself, themselves).  If the target actor isn't the PC, and the
     *   gender of the pronoun matches, we'll consider this as referring
     *   to the target actor.  This allows exchanges of this form:
     *
     *.  >bob, examine
     *.  What do you want Bob to examine?
     *.
     *.  >himself
     */
    getReflexiveBinding(typ)
    {
        local lst;

        /* try resolving with the target actor as the antecedent */
        if ((lst = resolvePronounAsTargetActor(typ)) != nil)
            return lst;

        /* use the inherited result */
        return inherited(typ);
    }

    /*
     *   Try matching the given pronoun type to the target actor.  If it
     *   matches in gender, and the target actor isn't the PC, we'll
     *   return a resolve list consisting of the target actor.  If we
     *   don't have a match, we'll return nil.
     */
    resolvePronounAsTargetActor(typ)
    {
        /*
         *   if the target actor isn't the player character, and the
         *   target actor can match the given pronoun type, resolve the
         *   pronoun as the target actor
         */
        if (actor_.canMatchPronounType(typ) && !actor_.isPlayerChar())
        {
            /* the match is the target actor */
            return [new ResolveInfo(actor_, 0, nil)];
        }

        /* we didn't match it */
        return nil;
    }
;

/*
 *   Custom disambiguation resolver.
 */
modify DisambigResolver
    /*
     *   Perform special resolution on pronouns used in interactive
     *   responses.  If the pronoun is HIM or HER, then look through the
     *   list of possible matches for a matching gendered object, and use
     *   it as the result if we find one.  If we find more than one, then
     *   use the default handling instead, treating the pronoun as
     *   referring back to the simple antecedent previously set.
     */
    resolvePronounAntecedent(typ, np, results, poss)
    {
        /* if it's a non-possessive HIM or HER, use our special handling */
        if (!poss && typ is in (PronounHim, PronounHer))
        {
            local prop;
            local sub;

            /* get the gender indicator property for the pronoun */
            prop = (typ == PronounHim ? &canMatchHim : &canMatchHer);

            /*
             *   Scan through the match list to find the objects that
             *   match the gender of the pronoun.  Note that if the player
             *   character isn't referred to in the third person, we'll
             *   ignore the player character for the purposes of matching
             *   this pronoun - if we're calling the PC 'you', then we
             *   wouldn't expect the player to refer to the PC as 'him' or
             *   'her'.
             */
            sub = matchList.subset({x: x.obj_.(prop)});

            /* if the list has a single entry, then use it as the match */
            if (sub.length() == 1)
                return sub;

            /*
             *   if it has more than one entry, it's still ambiguous, but
             *   we might have narrowed it down, so throw a
             *   still-ambiguous exception and let the interactive
             *   disambiguation ask for further clarification
             */
            results.ambiguousNounPhrase(nil, ResolveAsker, 'one',
                                        sub, matchList, matchList,
                                        1, self);
            return [];
        }

        /*
         *   if we get this far, it means we didn't use our special
         *   handling, so use the inherited behavior
         */
        return inherited(typ, np, results, poss);
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Distinguisher customizations for German.
 *   
 *   Each distinguisher must provide a method that gets the name of an item
 *   for a disamgiguation query.  Since these are inherently
 *   language-specific, they're defined here.  
 */

/*
 *   The null distinguisher tells objects apart based strictly on the name
 *   string.  When we list objects, we simply show the basic name - since
 *   we can tell apart our objects based on the base name, there's no need
 *   to resort to other names.  
 */
modify nullDistinguisher
    /* we can tell objects apart if they have different base names */
    canDistinguish(a, b) { return a.name != b.name; }

    name(obj) { return obj.name; }

    einenName(obj) { return obj.einenName; }
    einemName(obj) { return obj.einemName; }

    denName(obj) { return obj.denName; }
    demName(obj) { return obj.demName; }
    countName(obj, cnt) { return obj.countName(cnt); }
;

/*
 *   The basic distinguisher can tell apart objects that are not "basic
 *   equivalents" of one another.  Thus, we need make no distinctions when
 *   listing objects apart from showing their names.  
 */
modify basicDistinguisher
    name(obj) { return obj.disambigName; }

    einenName(obj) { return obj.einenName; }
    einemName(obj) { return obj.einemName; }

    denName(obj) { return obj.denDisambigName; }
    demName(obj) { return obj.demDisambigName; }
    countName(obj, cnt) { return obj.countDisambigName(cnt); }
;

/*
 *   The ownership distinguisher tells objects apart based on who "owns"
 *   them, so it shows the owner or location name when listing the object. 
 */
modify ownershipDistinguisher
    einenName(obj) { return obj.einenNameOwnerLoc(true); }
    einemName(obj) { return obj.einemNameOwnerLoc(true); }

    denName(obj) { return obj.denNameOwnerLoc(true); }
    demName(obj) { return obj.demNameOwnerLoc(true); }
    countName(obj, cnt) { return obj.countNameOwnerLoc(cnt, true); }

    /* note that we're prompting based on this distinguisher */
    notePrompt(lst)
    {
        /*
         *   notify each object that we're referring to it by
         *   owner/location in a disambiguation prompt
         */
        foreach (local cur in lst)
            cur.obj_.notePromptByOwnerLoc(true);
    }
;

/*
 *   The location distinguisher tells objects apart based on their
 *   containers, so it shows the location name when listing the object. 
 */
modify locationDistinguisher
    einenName(obj) { return obj.einenNameOwnerLoc(nil); }
    einemName(obj) { return obj.einemNameOwnerLoc(nil); }

    denName(obj) { return obj.denNameOwnerLoc(nil); }
    demName(obj) { return obj.demNameOwnerLoc(nil); }
    countName(obj, cnt) { return obj.countNameOwnerLoc(cnt, nil); }

    /* note that we're prompting based on this distinguisher */
    notePrompt(lst)
    {
        /* notify the objects of their use in a disambiguation prompt */
        foreach (local cur in lst)
            cur.obj_.notePromptByOwnerLoc(nil);
    }
;

/*
 *   The lit/unlit distinguisher tells apart objects based on whether
 *   they're lit or unlit, so we list objects as lit or unlit explicitly.  
 */
modify litUnlitDistinguisher
    name(obj) { return obj.nameLit; }

    einenName(obj) {return obj.einenNameLit;}
    einemName(obj) {return obj.einemNameLit;}

    denName(obj) {return obj.denNameLit;}
    demName(obj) {return obj.demNameLit;}
    countName(obj, cnt) { return obj.denPluralNameLit; }
;

/* ------------------------------------------------------------------------ */
/*
 *   Enligh-specific light source modifications
 */
modify LightSource
    /* provide lit/unlit names for litUnlitDistinguisher */
    nameLit = ((isLit ? 'leuchtend[^] ' : 'erloschen[^] ') + name)

    // ##### indirect article #####
    einenNameLit() {
        return einenNameFrom((isLit ? 'leuchtend[^] ' : 'erloschen[^] ') + name);
    }
    einemNameLit() {
        return einemNameFrom((isLit ? 'leuchtend[^] ' : 'erloschen[^] ') + name);
    }

    // ##### direct article #####
    denNameLit() {
        return denNameFrom((isLit ? 'leuchtend[^] ' : 'erloschen[^] ') + name);
    }
    demNameLit() {
        return demNameFrom((isLit ? 'leuchtend[^] ' : 'erloschen[^] ') + name);
    }
    
    // ##### plural #####
    pluralNameLit = ((isLit ? 'lit ' : 'unlit ') + pluralName)
    denPluralNameLit() {
        return denPluralNameFrom((isLit ? 'leuchtend[^] ' : 'erloschen[^] ') + name);
    }
    /*
     *   Allow 'lit' and 'unlit' as adjectives - but even though we define
     *   these as our adjectives in the dictionary, we'll only accept the
     *   one appropriate for our current state, thanks to our state
     *   objects.
     */
    adjective = 'leuchtend' 'erloschen' 'brennend' 'ausgeblasen' 'angezündet'
;

/*
 *   Light source list states.  An illuminated light source shows its
 *   status as "providing light"; an unlit light source shows no extra
 *   status.
 */
lightSourceStateOn: ThingState 'Licht spendend'
    stateTokens = ['brennend','leuchtend','angezündet']
;
lightSourceStateOff: ThingState
    stateTokens = ['erloschen','ausgeblasen']
;

/* ------------------------------------------------------------------------ */
/*
 *   Wearable states - a wearable item can be either worn or not worn.
 */

/* "worn" */
wornState: ThingState 'angezogen'
    /*
     *   In listings of worn items, don't bother mentioning our 'worn'
     *   status, as the entire list consists of items being worn - it
     *   would be redundant to point out that the items in a list of items
     *   being worn are being worn.
     */
    wornName(lst) { return nil; }
;

/*
 *   "Unworn" state.  Don't bother mentioning the status of an unworn item,
 *   since this is the default for everything.  
 */
unwornState: ThingState;


/* ------------------------------------------------------------------------ */
/*
 *   Typographical effects output filter.  This filter looks for certain
 *   sequences in the text and converts them to typographical equivalents.
 *   Authors could simply write the HTML for the typographical markups in
 *   the first place, but it's easier to write the typewriter-like
 *   sequences and let this filter convert to HTML.
 *
 *   We perform the following conversions:
 *
 *   '---' -> &zwnbsp;&mdash;
 *.  '--' -> &zwnbsp;&ndash;
 *.  sentence-ending punctuation -> same + &ensp;
 *
 *   Since this routine is called so frequently, we hard-code the
 *   replacement strings, rather than using properties, for slightly faster
 *   performance.  Since this routine is so simple, games that want to
 *   customize the replacement style should simply replace this entire
 *   routine with a new routine that applies the customizations.
 *
 *   Note that we define this filter in the English-specific part of the
 *   library, because it seems almost certain that each language will want
 *   to customize it for local conventions.
 */
typographicalOutputFilter: OutputFilter
    filterText(ostr, val)
    {
        /*
         *   Look for sentence-ending punctuation, and put an 'en' space
         *   after each occurrence.  Recognize ends of sentences even if we
         *   have closing quotes, parentheses, or other grouping characters
         *   following the punctuation.  Do this before the hyphen
         *   substitutions so that we can look for ordinary hyphens rather
         *   than all of the expanded versions.
         */
        val = rexReplace(eosPattern, val, '%1\u2002', ReplaceAll);

        /* undo any abbreviations we mistook for sentence endings */
        val = rexReplace(abbrevPat, val, '%1. ', ReplaceAll);

        /*
         *   Replace dashes with typographical hyphens.  Three hyphens in a
         *   row become an em-dash, and two in a row become an en-dash.
         *   Note that we look for the three-hyphen sequence first, because
         *   if we did it the other way around, we'd incorrectly find the
         *   first two hyphens of each '---' sequence and replace them with
         *   an en-dash, causing us to miss the '---' sequences entirely.
         *
         *   We put a no-break marker (\uFEFF) just before each hyphen, and
         *   an okay-to-break marker (\u200B) just after, to ensure that we
         *   won't have a line break between the preceding text and the
         *   hyphen, and to indicate that a line break is specifically
         *   allowed if needed to the right of the hyphen.
         */
        val = val.findReplace(['---', '--'],
                              ['\uFEFF&mdash;\u200B', '\uFEFF&ndash;\u200B']);

        /* return the result */
        return val;
    }

    /*
     *   The end-of-sentence pattern.  This looks a bit complicated, but
     *   all we're looking for is a period, exclamation point, or question
     *   mark, optionally followed by any number of closing group marks
     *   (right parentheses or square brackets, closing HTML tags, or
     *   double or single quotes in either straight or curly styles), all
     *   followed by an ordinary space.
     *
     *   If a lower-case letter follows the space, though, we won't
     *   consider it a sentence ending.  This applies most commonly after
     *   quoted passages ending with what would normally be sentence-ending
     *   punctuation: "'Who are you?' he asked."  In these cases, the
     *   enclosing sentence isn't ending, so we don't want the extra space.
     *   We can tell the enclosing sentence isn't ending because a
     *   non-capital letter follows.
     *
     *   Note that we specifically look only for ordinary spaces.  Any
     *   sentence-ending punctuation that's followed by a quoted space or
     *   any typographical space overrides this substitution.
     */
    eosPattern = static new RexPattern(
        '<case>'
        + '('
        +   '[.!?]'
        +   '('
        +     '<rparen|rsquare|dquote|squote|\u2019|\u201D>'
        +     '|<langle><^rangle>*<rangle>'
        +   ')*'
        + ')'
        + ' +(?![-a-z])'
        )

    /* pattern for abbreviations that were mistaken for sentence endings */
    abbrevPat = static new RexPattern(
        '<nocase>%<(' + abbreviations + ')<dot>\u2002')

    /* 
     *   Common abbreviations.  These are excluded from being treated as
     *   sentence endings when they appear with a trailing period.
     *   
     *   Note that abbrevPat must be rebuilt manually if you change this on
     *   the fly - abbrevPat is static, so it picks up the initial value of
     *   this property at start-up, and doesn't re-evaluate it while the
     *   game is running.  
     */
    abbreviations = 'mr|mrs|ms|dr|prof'
;

/* ------------------------------------------------------------------------ */
/*
 *   The German-specific message builder.
 */
langMessageBuilder: MessageBuilder

    /*
     *   The English message substitution parameter table.
     *
     *   Note that we specify two additional elements for each table entry
     *   beyond the standard language-independent complement:
     *
     *   info[4] = reflexive property - this is the property to invoke
     *   when the parameter is used reflexively (in other words, its
     *   target object is the same as the most recent target object used
     *   in the nominative case).  If this is nil, the parameter has no
     *   reflexive form.
     *
     *   info[5] = true if this is a nominative usage, nil if not.  We use
     *   this to determine which target objects are used in the nominative
     *   case, so that we can remember those objects for subsequent
     *   reflexive usages.
     */
    paramList_ =
    [

        // -- German: german placeholder for "mesaage parameter substitutions"

        ['der/er', &derName, nil, nil, true],
        ['die/sie', &derName, nil, nil, true],
        ['des/dessen', &desName, nil, nil, nil],
        ['dem/ihm', &demName, nil, &itReflexiveDat, nil],
        ['der/ihr', &demName, nil, &itReflexiveDat, nil],
        ['den/ihn', &denName, nil, &itReflexive, nil],
        
        // -- German: german verbs for "mesaage parameter substitutions"
        
        ['ist', &verbZuSein, 'verb', nil, nil],
        ['kann', &verbZuKann, 'verb', nil, nil],
        ['hat', &verbZuHaben, 'verb', nil, nil],
        ['scheint', &verbZuScheinen, 'verb', nil, nil],
        ['erscheint', &verbZuErscheinen, 'verb', nil, nil],
        ['bezweckt', &verbZuBezwecken, 'verb', nil, nil],
        ['gefaellt', &verbZuGefallen, 'verb', nil, nil],
        ['bekommt', &verbZuBekommen, 'verb', nil, nil],
        ['sieht', &verbZuSehen, 'verb', nil, nil],
        ['hoert', &verbZuHoeren, 'verb', nil, nil],
        ['spricht', &verbZuSprechen, 'verb', nil, nil],
        ['betritt', &verbZuBetreten, 'verb', nil, nil],
        ['bemerkt', &verbZuBemerken, 'verb', nil, nil],
        ['sagt', &verbZuSagen, 'verb', nil, nil],
        ['antwortet', &verbZuAntworten, 'verb', nil, nil],
        ['muss', &verbZuMuessen, 'verb', nil, nil],
        ['riecht', &verbZuRiechen, 'verb', nil, nil],
        ['nimmt', &verbZuNehmen, 'verb', nil, nil],
        ['gibt', &verbZuGeben, 'verb', nil, nil],
        ['faellt', &verbZuFallen, 'verb', nil, nil],
        ['will', &verbZuWollen, 'verb', nil, nil],
        ['befindet', &verbZuBefinden, 'verb', nil, nil],
        ['zieht', &verbZuZiehen, 'verb', nil, nil],
        ['drueckt', &verbZuDruecken, 'verb', nil, nil],
        ['brennt', &verbZuBrennen, 'verb', nil, nil],
        ['schliesst', &verbZuSchliessen, 'verb', nil, nil],
        ['geht', &verbZuGehen, 'verb', nil, nil],
        ['vergeht', &verbZuVergehen, 'verb', nil, nil],
        ['fuehrt', &verbZuFuehren, 'verb', nil, nil],
        ['weiss', &verbZuWissen, 'verb', nil, nil],
        ['schreit', &verbZuSchreien, 'verb', nil, nil],
        ['springt', &verbZuSpringen, 'verb', nil, nil],
        ['schiebt', &verbZuSchieben, 'verb', nil, nil],
        ['passt', &verbZuPassen, 'verb', nil, nil],
        ['steht', &verbZuStehen, 'verb', nil, nil],
        ['liegt', &verbZuLiegen, 'verb', nil, nil],
        ['sitzt', &verbZuSitzen, 'verb', nil, nil],
        ['trifft', &verbZuTreffen, 'verb', nil, nil],
        ['faengt', &verbZuFangen, 'verb', nil, nil],
        ['enthaelt', &verbZuEnthalten, 'verb', nil, nil],
        ['entscheidet', &verbZuEntscheiden, 'verb', nil, nil],
        ['fragt', &verbZuFragen, 'verb', nil, nil],
        ['verlaesst', &verbZuVerlassen, 'verb', nil, nil],
        ['kommt', &verbZuKommen, 'verb', nil, nil],
        ['wird', &verbZuWerden, 'verb', nil, nil],
        ['laesst', &verbZuLassen, 'verb', nil, nil],
        ['koennt', &verbZuKannKon, 'verb', nil, nil],
        ['wuerde-waere', &verbWuerdeWaere, 'verb', nil, nil],
        ['moechte-soll', &verbMoechteSoll, 'verb', nil, nil],
        ['weigert', &verbZuWeigern, 'verb', nil, nil],
        ['bringt', &verbZuBringen, 'verb', nil, nil],
        ['folgt', &verbZuFolgen, 'verb', nil, nil],
        ['zeigt', &verbZuZeigen, 'verb', nil, nil],
        ['macht', &verbZuMachen, 'verb', nil, nil],
        ['isst', &verbZuEssen, 'verb', nil, nil],
        ['schaltet', &verbZuSchalten, 'verb', nil, nil],
        ['passiert', &verbZuPassieren, 'verb', nil, nil],
        ['zuendet', &verbZuZuenden, 'verb', nil, nil],
        ['loest', &verbZuLoesen, 'verb', nil, nil],
        ['braucht', &verbZuBrauchen, 'verb', nil, nil],
        ['legt', &verbZuLegen, 'verb', nil, nil],
        ['haengt', &verbZuHaengen, 'verb', nil, nil],
        ['probiert', &verbZuProbieren, 'verb', nil, nil],
        ['benoetigt', &verbZuBenoetigen, 'verb', nil, nil],
        ['oeffnet', &verbZuOeffnen, 'verb', nil, nil],
        ['wartet', &verbZuWarten, 'verb', nil, nil],
        ['versucht', &verbZuVersuchen, 'verb', nil, nil],
        ['stellt', &verbZuStellen, 'verb', nil, nil],
        ['loescht', &verbZuLoeschen, 'verb', nil, nil],
        ['verbindet', &verbZuVerbinden, 'verb', nil, nil],
        ['fuehlt', &verbZuFuehlen, 'verb', nil, nil],
        ['schmeckt', &verbZuSchmecken, 'verb', nil, nil],
        
        ['ein/eine', &einName, nil, nil, true],
        ['einer/er', &itNom, nil, nil, true],
        ['eines/einer', &einesName, nil, nil, nil],
        ['einem/einer', &einemName, nil, nil, nil],
        ['einem/ihm', &einemName, nil, nil, nil],
        ['einen/eine', &einenName, nil, nil, nil],
        ['einen/ihn', &einenName, nil, nil, nil],
        ['es/er ist', &esIstContraction, nil, nil, true],
        
        ['kein/keine', &keinName, nil, nil, true],
        ['keines/keiner', &keinesName, nil, nil, nil],
        ['keinem/keiner', &keinemName, nil, nil, nil],
        ['keinen/keine', &keinenName, nil, nil, nil],
        
        ['er/es', &itNom, nil, nil, true],
        ['er/sie', &itNom, nil, nil, true],
        
        ['ihn/sie', &itAkk, nil, nil, nil],
        ['ihm/ihr', &itDat, nil, nil, nil],
        
        ['dich', &itAkk, nil, &itReflexive, nil],
        ['dir', &itDat, nil, &itReflexiveDat, nil],
        
        ['dich/sich', &itReflexiveWithoutSelf, nil, nil, nil],
        ['dir/sich', &itReflexiveDatWithoutSelf, nil, nil, nil],

        ['du/er', &derName, 'actor', nil, true],
        
        ['es/ihn', &itObj, nil, &itReflexive, nil],
        ['welcher/welche', &whichObj, nil, nil, true],
        
        ['dichselbst', &itReflexive, 'actor', nil, nil],
        ['dirselbst', &itReflexiveDat, 'actor', nil, nil],
        
        ['sich', &itReflexiveWithoutSelf, nil, nil, nil],
        ['sichselbst', &itReflexive, nil, nil, nil],
        
        ['der', &dArt, nil, nil, nil],
        ['die', &dArt, nil, nil, nil],
        ['das', &dArt, nil, nil, nil],

        ['dein', &deinPossAdj, nil, nil, nil],
        ['deine', &deinePossAdj, nil, nil, nil],
        ['deiner', &deinerPossAdj, nil, nil, nil],
        ['deines', &deinesPossAdj, nil, nil, nil],
        ['deinen', &deinenPossAdj, nil, nil, nil],
        ['deinem', &deinemPossAdj, nil, nil, nil],
        
        /* default preposition for standing in/on something */
        
        ['auf', &actorInName, nil, nil, nil],
        ['aufdem', &actorInName, nil, nil, nil],
        ['in', &actorInName, nil, nil, nil],
        ['indem', &actorInName, nil, nil, nil],
        ['ausdem', &actorOutOfName, nil, nil, nil],
        ['vondem', &actorOutOfName, nil, nil, nil],
        ['aufden', &actorIntoName, nil, nil, nil],
        ['inden', &actorIntoName, nil, nil, nil],
        
        /*
         *   The special invisible subject marker - this can be used to
         *   mark the subject in sentences that vary from the
         *   subject-verb-object structure that most English sentences
         *   take.  The usual SVO structure allows the message builder to
         *   see the subject first in most sentences naturally, but in
         *   unusual sentence forms it is sometimes useful to be able to
         *   mark the subject explicitly.  This doesn't actually result in
         *   any output; it's purely for marking the subject for our
         *   internal book-keeping.
         *
         *   (The main reason the message builder wants to know the subject
         *   in the first place is so that it can use a reflexive pronoun
         *   if the same object ends up being used as a direct or indirect
         *   object: "you can't open yourself" rather than "you can't open
         *   you.")
         */
        ['subj', &dummyName, nil, nil, true],
        
        // #################################################################################
        // ## These are for the participle used in perfect, pluperfect and future1 and 2  ##
        // ## {*}  normal usage at the end of a sentence like "Du bist im Stall gewesen"  ## 
        // ## {!*} changes partciple and verb in side sentences like: "Hans hat den Stuhl ##
        // ##       nicht nehmen können, solange du ihn in Beschlag *genommen hast*.      ##
        // ## {-*} verb and partizip as single word: "Du hast den Ofen *angeschaltet*."   ##
        // #################################################################################
        
        ['*', &dummyVerb, nil, nil, nil],
        ['-*', &dummyPartWithoutBlank, nil, nil, nil],
        ['!*', &dummyPart, nil, nil, nil],
        ['+*', &setPartLong, nil, nil, nil],
        ['**', &printPartLong, nil, nil, nil]
    ]

    /*
     *   Add a hook to the generateMessage method, which we use to
     *   pre-process the source string before expanding the substitution
     *   parameters.
     */
    generateMessage(orig) { return inherited(processOrig(orig)); }

    /*
     *   Pre-process a source string containing substitution parameters,
     *   before generating the expanded message from it.
     *
     *   We use this hook to implement the special tense-switching syntax
     *   {<present>|<past>}.  Although it superficially looks like an
     *   ordinary substitution parameter, we actually can't use the normal
     *   parameter substitution framework for that, because we want to
     *   allow the <present> and <past> substrings themselves to contain
     *   substitution parameters, and the normal framework doesn't allow
     *   for recursive substitution.
     *
     *   We simply replace every sequence of the form {<present>|<past>}
     *   with either <present> or <past>, depending on the current
     *   narrative tense.  We then substitute braces for square brackets in
     *   the resulting string.  This allows treating every bracketed tag
     *   inside the tense-switching sequence as a regular substitution
     *   parameter.
     *
     *   For example, the sequence "{take[s]|took}" appearing in the
     *   message string would be replaced with "take{s}" if the current
     *   narrative tense is present, and would be replaced with "took" if
     *   the current narrative tense is past.  The string "take{s}", if
     *   selected, would in turn be expanded to either "take" or "takes",
     *   depending on the grammatical person of the subject, as per the
     *   regular substitution mechanism.
     */
    processOrig(str)
    {
        local idx = 1;
        local len;
        local match;
        local replStr;

        /*
         *   Keep searching the string until we run out of character
         *   sequences with a special meaning (specifically, we look for
         *   substrings enclosed in braces, and stuttered opening braces).
         */
        for (;;)
        {
            /*
             *   Find the next special sequence.
             */
            match = rexSearch(patSpecial, str, idx);

            /*
             *   If there are no more special sequence, we're done
             *   pre-processing the string.
             */
            if (match == nil) break;

            /*
             *   Remember the starting index and length of the special
             *   sequence.
             */
            idx = match[1];
            len = match[2];

            /*
             *   Check if this special sequence matches our tense-switching
             *   syntax.
             */
            if (nil == rexMatch(patTenseSwitching, str, idx))
            {
                /*
                 *   It doesn't, so forget about it and continue searching
                 *   from the end of this special sequence.
                 */
                idx += len;
                continue;
            }

            /*
             *   Extract either the first or the second embedded string,
             *   depending on the current narrative tense.
             */
            
            // ########## TIME SELECTOR LETS US CHOOSE {<WORD TO USE IN PRESENT TENSE>|<OTHER TENSES>} ###########
            match = rexGroup(timeSelector(1, 2));
            replStr = match[3];

            /*
             *   Convert all square brackets to braces in the extracted
             *   string.
             */
            replStr = replStr.findReplace('[', '{', ReplaceAll);
            replStr = replStr.findReplace(']', '}', ReplaceAll);

            /*
             *   In the original string, replace the tense-switching
             *   sequence with the extracted string.
             */
            str = str.substr(1, idx - 1) + replStr + str.substr(idx + len);

            /*
             *   Move the index at the end of the substituted string.
             */
            idx += match[2];
        }

        /*
         *   We're done - return the result.
         */
        return str;
    }

    /*
     *   Pre-compiled regular expression pattern matching any sequence with
     *   a special meaning in a message string.
     *
     *   We match either a stuttered opening brace, or a single opening
     *   brace followed by any sequence of characters that doesn't contain
     *   a closing brace followed by a closing brace.
     */
    patSpecial = static new RexPattern
        ('<lbrace><lbrace>|<lbrace>(?!<lbrace>)((?:<^rbrace>)*)<rbrace>')

    /*
     *   Pre-compiled regular expression pattern matching our special
     *   tense-switching syntax.
     *
     *   We match a single opening brace, followed by any sequence of
     *   characters that doesn't contain a closing brace or a vertical bar,
     *   followed by a vertical bar, followed by any sequence of characters
     *   that doesn't contain a closing brace or a vertical bar, followed
     *   by a closing brace.
     */
    patTenseSwitching = static new RexPattern
    (
        '<lbrace>(?!<lbrace>)((?:<^rbrace|vbar>)*)<vbar>'
                          + '((?:<^rbrace|vbar>)*)<rbrace>'
    )

    /*
     *   The most recent target object used in the nominative case.  We
     *   note this so that we can supply reflexive mappings when the same
     *   object is re-used in the objective case.  This allows us to map
     *   things like "you can't take you" to the better-sounding "you
     *   can't take yourself".
     */
    lastSubject_ = nil

    // -- we test for our last verb
    lastVerb_ = nil
    
    /* the parameter name of the last subject ('dobj', 'actor', etc) */
    lastSubjectName_ = nil

    /*
     *   Get the target object property mapping.  If the target object is
     *   the same as the most recent subject object (i.e., the last object
     *   used in the nominative case), and this parameter has a reflexive
     *   form property, we'll return the reflexive form property.
     *   Otherwise, we'll return the standard property mapping.
     *
     *   Also, if there was an exclamation mark at the end of any word in
     *   the tag, we'll return a property returning a fixed-tense form of
     *   the property for the tag.
     */
    
    // ###############################################################
    // ## GTADS replaces this routine from output.t because we need ##
    // ## a reference to the current subj for our verb forms        ##
    // ###############################################################
    
    execute()
    {
        /* create a lookup table for our parameter names */
        paramTable_ = new LookupTable();

        /* add each element of our list to the table */
        foreach (local cur in paramList_)
            paramTable_[cur[1]] = cur;

        /* create a lookup table for our global names */
        nameTable_ = new LookupTable();

        /* 
         *   Add an entry for 'actor', which resolves to gActor if there is
         *   a gActor when evaluated, or the current player character if
         *   not.  Note that using a function ensures that we evaluate the
         *   current gActor or gPlayerChar each time we need the 'actor'
         *   value.  
         */
        nameTable_['actor'] = {: gActor != nil ? gActor : gPlayerChar };
        nameTable_['verb'] = {: lastSubject_ != nil ? lastSubject_ : gActor != nil ? gActor : gPlayerChar};
    }

    getTargetProp(targetObj, paramObj, info)
    {
        local ret;

        /*
         *   If this target object matches the last subject, and we have a
         *   reflexive rendering, return the property for the reflexive
         *   rendering.
         *
         *   Only use the reflexive rendering if the parameter name is
         *   different - if the parameter name is the same, then presumably
         *   the message will have been written with a reflexive pronoun or
         *   not, exactly as the author wants it.  When the author knows
         *   going in that these two objects are structurally the same,
         *   they want the exact usage they wrote.
         */

        if (targetObj == lastSubject_
            && paramObj != lastSubjectName_
            && info[4] != nil)
        {
            /* use the reflexive rendering */
            ret = info[4];
        }
        else
        {
            /* no special handling; inherit the default handling */
            ret = inherited(targetObj, paramObj, info);
        }

        /* if this is a nominative usage, note it as the last subject */
        if (info[5])
        {
            lastSubject_ = targetObj;
            lastSubjectName_ = paramObj;
        }
        
        /*
         *   If there was an exclamation mark at the end of any word in the
         *   parameter string (which we remember via the fixedTenseProp_
         *   property), store the original target property in
         *   fixedTenseProp_ and use &propWithPresentMessageBuilder_ as the
         *   target property instead.  propWithPresentMessageBuilder_ acts
         *   as a wrapper for the original target property, which it
         *   invokes after temporarily switching to the present tense.
         */
        if (fixedTenseProp_)
        {
            fixedTenseProp_ = ret;
            ret = &propWithPresentMessageBuilder_;
        }

        /* return the result */
        return ret;
    }

    /* end-of-sentence match pattern */
    patEndOfSentence = static new RexPattern('[.;:!?]<^alphanum>')

    /*
     *   Process result text.
     */
    processResult(txt)
    {
        /*
         *   If the text contains any sentence-ending punctuation, reset
         *   our internal memory of the subject of the sentence.  We
         *   consider the sentence to end with a period, semicolon, colon,
         *   question mark, or exclamation point followed by anything
         *   other than an alpha-numeric.  (We require the secondary
         *   character so that we don't confuse things like "3:00" or
         *   "7.5" to contain sentence-ending punctuation.)
         */
    
        if (rexSearch(patEndOfSentence, txt) != nil)
        {
            /*
             *   we have a sentence ending in this run of text, so any
             *   saved subject object will no longer apply after this text
             *   - forget our subject object
             */
            lastSubject_ = nil;
            lastSubjectName_ = nil;
            // ##### we reset our participle #####
            verbHelper.lastVerb = 'undefined';
        }

        /* return the inherited processing */
        return inherited(txt);
    }

    /* some pre-compiled search patterns we use a lot */
    patIdObjSlashIdApostS = static new RexPattern(
        '(<^space>+)(<space>+<^space>+)\'s(/<^space>+)$')
    patIdObjApostS = static new RexPattern(
        '(?!<^space>+\'s<space>)(<^space>+)(<space>+<^space>+)\'s$')
    patParamWithExclam = static new RexPattern('.*(!)(?:<space>.*|/.*|$)')
    patSSlashLetterEd = static new RexPattern(
        's/(<alpha>ed)$|(<alpha>ed)/s$')

    /*
     *   Rewrite a parameter string for a language-specific syntax
     *   extension.
     *
     *   For English, we'll handle the possessive apostrophe-s suffix
     *   specially, by allowing the apostrophe-s to be appended to the
     *   target object name.  If we find an apostrophe-s on the target
     *   object name, we'll move it to the preceding identifier name:
     *
     *   the dobj's -> the's dobj
     *.  the dobj's/he -> the's dobj/he
     *.  he/the dobj's -> he/the's dobj
     *
     *   We also use this method to check for the presence of an
     *   exclamation mark at the end of any word in the parameter string
     *   (triggering the fixed-tense handling), and to detect a parameter
     *   string matching the {s/?ed} syntax, where ? is any letter, and
     *   rewrite it literally as 's/?ed' literally.
     */
    langRewriteParam(paramStr)
    {
        /*
         *   Check for an exclamation mark at the end of any word in the
         *   parameter string, and remember the result of the test.
         */
        local exclam = rexMatch(patParamWithExclam, paramStr);
        fixedTenseProp_ = exclam;

        /*
         *   Remove the exclamation mark, if any.
         */
        if (exclam)
        {
            local exclamInd = rexGroup(1)[1];
            paramStr = paramStr.substr(1, exclamInd - 1)
                       + paramStr.substr(exclamInd + 1);
        }

        /* look for "id obj's" and "id1 obj's/id2" */
        if (rexMatch(patIdObjSlashIdApostS, paramStr) != nil)
        {
            /* rewrite with the "'s" moved to the preceding parameter name */
            paramStr = rexGroup(1)[3] + '\'s'
                       + rexGroup(2)[3] + rexGroup(3)[3];
        }
        else if (rexMatch(patIdObjApostS, paramStr) != nil)
        {
            /* rewrite with the "'s" moved to the preceding parameter name */
            paramStr = rexGroup(1)[3] + '\'s' + rexGroup(2)[3];
        }

        /*
         *   Check if this parameter matches the {s/?ed} or {?ed/s} syntax.
         */
        if (rexMatch(patSSlashLetterEd, paramStr))
        {
            /*
             *   It does - remember the past verb ending, and rewrite the
             *   parameter literally as 's/?ed'.
             */
            pastEnding_ = rexGroup(1)[3];
            paramStr = 's/?ed';
        }

        /* return our (possibly modified) result */
        return paramStr;
    }

    /*
     *   This property is used to temporarily store the past-tense ending
     *   of a verb to be displayed by Thing.verbEndingSMessageBuilder_.
     *   It's for internal use only; game authors shouldn't have any reason
     *   to access it directly.
     */
    pastEnding_ = nil

    /*
     *   This property is used to temporarily store either a boolean value
     *   indicating whether the last encountered parameter string had an
     *   exclamation mark at the end of any word, or a property to be
     *   invoked by Thing.propWithPresentMessageBuilder_.  This field is
     *   for internal use only; authors shouldn't have any reason to access
     *   it directly.
     */
    fixedTenseProp_ = nil
;

// ####################################################
// ## this callback function is from 2.0 on obsolete ##
// ####################################################

/* ------------------------------------------------------------------------ */
/*
 *   Temporarily override the current narrative tense and invoke a callback
 *   function.
 */
withTense(usePastTense, callback)
{
    /*
     *   Remember the old value of the usePastTense flag.
     */
    local oldUsePastTense = gameMain.usePastTense;
    /*
     *   Set the new value.
     */
    gameMain.usePastTense = usePastTense;
    /*
     *   Invoke the callback (remembering the return value) and restore the
     *   usePastTense flag on our way out.
     */
    local ret;
    try { ret = callback(); }
    finally { gameMain.usePastTense = oldUsePastTense; }
    /*
     *   Return the result.
     */
    return ret;
}


/* ------------------------------------------------------------------------ */
/*
 *   Functions for spelling out numbers.  These functions take a numeric
 *   value as input, and return a string with the number spelled out as
 *   words in English.  For example, given the number 52, we'd return a
 *   string like 'fifty-two'.
 *
 *   These functions obviously have language-specific implementations.
 *   Note also that even their interfaces might vary by language.  Some
 *   languages might need additional information in the interface; for
 *   example, some languages might need to know the grammatical context
 *   (such as part of speech, case, or gender) of the result.
 *
 *   Note that some of the spellIntXxx flags might not be meaningful in all
 *   languages, because most of the flags are by their very nature
 *   associated with language-specific idioms.  Translations are free to
 *   ignore flags that indicate variations with no local equivalent, and to
 *   add their own language-specific flags as needed.
 */

/*
 *   Spell out an integer number in words.  Returns a string with the
 *   spelled-out number.
 *
 *   Note that this simple version of the function uses the default
 *   options.  If you want to specify non-default options with the
 *   SpellIntXxx flags, you can call spellIntExt().
 */
spellInt(val)
{
    return spellIntExt(val, 0);
}

// -- spell 'eins' for an object

spellOneFrom(obj) {
    return (obj.isHim? 'einer' : obj.isHer? 'eine' : 'eines');
}

/*
 *   Spell out an integer number in words, but only if it's below the given
 *   threshold.  It's often awkward in prose to spell out large numbers,
 *   but exactly what constitutes a large number depends on context, so
 *   this routine lets the caller specify the threshold.
 *   
 *   If the absolute value of val is less than (not equal to) the threshold
 *   value, we'll return a string with the number spelled out.  If the
 *   absolute value is greater than or equal to the threshold value, we'll
 *   return a string representing the number in decimal digits.  
 */
spellIntBelow(val, threshold)
{
    return spellIntBelowExt(val, threshold, 0, 0);
}

/*
 *   Spell out an integer number in words if it's below a threshold, using
 *   the spellIntXxx flags given in spellFlags to control the spelled-out
 *   format, and using the DigitFormatXxx flags in digitFlags to control
 *   the digit format.  
 */
spellIntBelowExt(val, threshold, spellFlags, digitFlags)
{
    local absval;

    /* compute the absolute value */
    absval = (val < 0 ? -val : val);

    /* check the value to see whether to spell it or write it as digits */
    if (absval < threshold)
    {
        /* it's below the threshold - spell it out in words */
        return spellIntExt(val, spellFlags);
    }
    else
    {
        /* it's not below the threshold - write it as digits */
        return intToDecimal(val, digitFlags);
    }
}

/*
 *   Format a number as a string of decimal digits.  The DigitFormatXxx
 *   flags specify how the number is to be formatted.`
 */
intToDecimal(val, flags)
{
    local str;
    local sep;

    /* perform the basic conversion */
    str = toString(val);

    /* add group separators as needed */
    if ((flags & DigitFormatGroupComma) != 0)
    {
        /* explicitly use a comma as a separator */
        sep = ',';
    }
    else if ((flags & DigitFormatGroupPeriod) != 0)
    {
        /* explicitly use a period as a separator */
        sep = '.';
    }
    else if ((flags & DigitFormatGroupSep) != 0)
    {
        /* use the current languageGlobals separator */
        sep = languageGlobals.digitGroupSeparator;
    }
    else
    {
        /* no separator */
        sep = nil;
    }

    /* if there's a separator, add it in */
    if (sep != nil)
    {
        local i;
        local len;

        /*
         *   Insert the separator before each group of three digits.
         *   Start at the right end of the string and work left: peel off
         *   the last three digits and insert a comma.  Then, move back
         *   four characters through the string - another three-digit
         *   group, plus the comma we inserted - and repeat.  Keep going
         *   until the amount we'd want to peel off the end is as long or
         *   longer than the entire remaining string.
         */
        for (i = 3, len = str.length() ; len > i ; i += 4)
        {
            /* insert this comma */
            str = str.substr(1, len - i) + sep + str.substr(len - i + 1);

            /* note the new length */
            len = str.length();
        }
    }

    /* return the result */
    return str;
}

/*
 *   Spell out an integer number - "extended" interface with flags.  The
 *   "flags" argument is a (bitwise-OR'd) combination of SpellIntXxx
 *   values, specifying the desired format of the result.
 */
spellIntExt(val, flags)
{
    local str;
    local trailingSpace;
    local needAnd;
    local powers = [1000000000, 'billion',
                    1000000,    'million',
                    1000,       'tausend',
                    100,        'hundert'];

    /* start with an empty string */
    str = '';
    trailingSpace = nil;
    needAnd = nil;
    local tens = ''; //Deutsch für Zehner
    local ones = ''; //Deutsch für Einer
   
    /* if it's zero, it's a special case */
    if (val == 0)
        return 'null';

    /*
     *   if the number is negative, note it in the string, and use the
     *   absolute value
     */
    if (val < 0)
    {
        str = 'minus ';
        val = -val;
    }
    
    /* do each named power of ten */
    for (local i = 1 ; val >= 100 && i <= powers.length() ; i += 2)
    {
        /*
         *   if we're in teen-hundreds mode, do the teen-hundreds - this
         *   only works for values from 1,100 to 9,999, since a number like
         *   12,000 doesn't work this way - 'one hundred twenty hundred' is
         *   no good 
         */
        if ((flags & SpellIntTeenHundreds) != 0
            && val >= 1100 && val < 10000)
        {
            /* if desired, add a comma if there was a prior power group */
            if (needAnd && (flags & SpellIntCommas) != 0)
                str = str.substr(1, str.length() - 1) + ', ';

            /* spell it out as a number of hundreds */
            str += spellIntExt(val / 100, flags) + ' hundert';

            /* take off the hundreds */
            val %= 100;

            /* note the trailing space */
            trailingSpace = true;

            /* we have something to put an 'and' after, if desired */
            needAnd = true;

            /*
             *   whatever's left is below 100 now, so there's no need to
             *   keep scanning the big powers of ten
             */
            break;
        }

        /* if we have something in this power range, apply it */
        if (val >= powers[i])
        {
            /* if desired, add a comma if there was a prior power group */
            if (needAnd && (flags & SpellIntCommas) != 0)
                str = str.substr(1, str.length() - 1) + ', ';

            // -- German: check if we have a real 'eins' or we have a 'einhundert ...'
            if (spellIntExt(val / powers[i], flags) == 'eins' && i > 4)
                str += 'ein' + + powers[i+1];
            // -- German: or do we have a 'einemillion ...'
            else if (spellIntExt(val / powers[i], flags) == 'eins')
                str += 'eine' + + powers[i+1];
            /* add the number of multiples of this power and the power name */
            else 
                str += spellIntExt(val / powers[i], flags) + powers[i+1];
            
            // -- German: If we have two millions and above it should be 'zweimillionen'
            if (i == 3 && val > 1999999)
                str += 'en';

            // -- German: If we have two billions and above it should be 'zweibillionen'
            if (i == 4 && val > 1999999999)
                str += 'en';
            
            /* take it out of the remaining value */
            val %= powers[i];

            /*
             *   note that we have a trailing space in the string (all of
             *   the power-of-ten names have a trailing space, to make it
             *   easy to tack on the remainder of the value)
             */
            trailingSpace = true;

            /* we have something to put an 'and' after, if one is desired */
            needAnd = true;
        }
    }

    /*
     *   if we have anything left, and we have written something so far,
     *   and the caller wanted an 'and' before the tens part, add the
     *   'and'
     */
    if ((flags & SpellIntAndTens) != 0
        && needAnd
        && val != 0)
    {
        /* add the 'and' */
        str += 'und';
        trailingSpace = true;
    }

    /* do the tens */
    if (val >= 20)
    {
        /* anything above the teens is nice and regular */
        
        if ((val%10) == 0)
            str += ['zwanzig', 'dreißig', 'vierzig', 'fünfzig', 'sechzig',
                'siebzig', 'achtzig', 'neunzig'][val/10 - 1];
        else
            tens = ['zwanzig', 'dreißig', 'vierzig', 'fünfzig', 'sechzig',
                'siebzig', 'achtzig', 'neunzig'][val/10 - 1];
        
        val %= 10;

        /* if it's non-zero, we'll add the units, so add a hyphen */
        // -- German: if (val != 0)
        // str += 'und' - z.B. bei Bartimäus hatte zwanzig-zwei Münzen bei sich

        /* we no longer have a trailing space in the string */
        trailingSpace = nil;
    }
    else if (val >= 10)
    {
        /* we have a teen */
        str += ['zehn', 'elf', 'zwölf', 'dreizehn', 'vierzehn',
                'fünzehn', 'sechzehn', 'siebzehn', 'achtzehn',
                'neunzehn'][val - 9];

        /* we've finished with the number */
        val = 0;

        /* there's no trailing space */
        trailingSpace = nil;
    }

    /* if we have a units value, add it */
    if (val != 0)
    {
        /* add the units name */
        if (tens == '') {
            str += ['eins', 'zwei', 'drei', 'vier', 'fünf',
                'sechs', 'sieben', 'acht', 'neun'][val];
        }
        else
        {
            // -- German: we use ones + tens as placeholder and skip them
            // -- to turn "zwanzig-zwei" into "zweiundzwanzig"
            
            ones = ['ein', 'zwei', 'drei', 'vier', 'fünf',
                'sechs', 'sieben', 'acht', 'neun'][val];
            str += ones;
            str += 'und'; 
            str += tens;
        }
        
        /* we have no trailing space now */
        trailingSpace = nil;
    }

    /* if there's a trailing space, remove it */
    if (trailingSpace)
        str = str.substr(1, str.length() - 1);

    /* return the string */
    return str;
}

/*
 *   Return a string giving the numeric ordinal representation of a number:
 *   1st, 2nd, 3rd, 4th, etc.  
 */
intOrdinal(n)
{
    local s;

    /* start by getting the string form of the number */
    s = toString(n);

    /* now add the appropriate suffix */
    // -- German: this is quite easy in german, we have only 't'/
    return s + 't';
}


/*
 *   Return a string giving a fully spelled-out ordinal form of a number:
 *   first, second, third, etc.
 */
spellIntOrdinal(n)
{
    return spellIntOrdinalExt(n, 0);
}

/*
 *   Return a string giving a fully spelled-out ordinal form of a number:
 *   first, second, third, etc.  This form takes the same flag values as
 *   spellIntExt().
 */
spellIntOrdinalExt(n, flags)
{
    local s;

    /* get the spelled-out form of the number itself */
    s = spellIntExt(n, flags);

    /*
     *   If the number ends in 'one', change the ending to 'first'; 'two'
     *   becomes 'second'; 'three' becomes 'third'; 'five' becomes
     *   'fifth'; 'eight' becomes 'eighth'; 'nine' becomes 'ninth'.  If
     *   the number ends in 'y', change the 'y' to 'ieth'.  'Zero' becomes
     *   'zeroeth'.  For everything else, just add 'th' to the spelled-out
     *   name
     */
    if (s == 'eins')
        return 'erst';
    else if (s == 'drei')
        return 'dritt';
    else if (n > 19)
        return s + 'st';
    else
        return s + 't';
}

/* ------------------------------------------------------------------------ */
/*
 *   Parse a spelled-out number.  This is essentially the reverse of
 *   spellInt() and related functions: we take a string that contains a
 *   spelled-out number and return the integer value.  This uses the
 *   command parser's spelled-out number rules, so we can parse anything
 *   that would be recognized as a number in a command.
 *
 *   If the string contains numerals, we'll treat it as a number in digit
 *   format: for example, if it contains '789', we'll return 789.
 *
 *   If the string doesn't parse as a number, we return nil.
 */
parseInt(str)
{
    try
    {
        /* tokenize the string */
        local toks = cmdTokenizer.tokenize(str);

        /* parse it */
        return parseIntTokens(toks);
    }
    catch (Exception exc)
    {
        /*
         *   on any exception, just return nil to indicate that we couldn't
         *   parse the string as a number
         */
        return nil;
    }
}

/*
 *   Parse a spelled-out number that's given as a token list (as returned
 *   from Tokenizer.tokenize).  If we can successfully parse the token list
 *   as a number, we'll return the integer value.  If not, we'll return
 *   nil.
 */
parseIntTokens(toks)
{
    try
    {
        /*
         *   if the first token contains digits, treat it as a numeric
         *   string value rather than a spelled-out number
         */
        if (toks.length() != 0
            && rexMatch('<digit>+', getTokOrig(toks[1])) != nil)
            return toInteger(getTokOrig(toks[1]));

        /* parse it using the spelledNumber production */
        local lst = spelledNumber.parseTokens(toks, cmdDict);

        /*
         *   if we got a match, return the integer value; if not, it's not
         *   parseable as a number, so return nil
         */
        return (lst.length() != 0 ? lst[1].getval() : nil);
    }
    catch (Exception exc)
    {
        /*
         *   on any exception, just return nil to indicate that it's not
         *   parseable as a number
         */
        return nil;
    }
}


/* ------------------------------------------------------------------------ */
/*
 *   Additional token types for German (DE).
 */

/* special "apostrophe-s" token */
enum token tokApostropheS;

/* special apostrophe token for plural possessives ("the smiths' house") */
enum token tokPluralApostrophe;

/* special abbreviation-period token */
enum token tokAbbrPeriod;

/* special "#nnn" numeric token */
enum token tokPoundInt;

// ##### we add a StringPreParser for spelled numbers ... #####

extractNumbers : StringPreParser
    doParsing(str, which) {
        infinitive.reset();
        local first;
        local second;
        local nm; // a million number
        local nt; // a thousand number
        local nh; // a hundred number
        
        // ################################################################
        // ## it is common to write numbers without spaces like          ##
        // ## 'zweihundertmillionenvierhundertvierundfünfzigtausend'     ##
        // ## This would cause over 50 phrases for the tokenizer, so we  ##
        // ## add spaces between million(en) und tausend. The result is: ##
        // ## 'zweihundert millionen vierhundertvierundfünfzig tausend'  ##
        // ## These smaller parts can be handled by the standard phrases ##
        // ## in the tokenizer                                           ##
        // ################################################################
        
        nm = rexMatch('<nocase>(.*)million(.*)', str);
        if (nm != nil) {
            first = rexGroup(1)[3];
            second = rexGroup(2)[3];
            if (!first.endsWith(' ') && first.length() > 0)
                first = first + ' ';
            if (rexMatch('<nocase>en(.*)', second))
                second = 'en ' + second.substr(3, second.length());
            if (rexMatch('<nocase>und(.*)', second))
                second = 'und ' + second.substr(4, second.length());      
            else if (!second.startsWith(' ') && second.length() > 0 &&!second.startsWith('en'))
                second = ' ' + second;
            str = first + 'million' + second;
        }
        nt = rexMatch('<nocase>(.*)tausend(.*)', str);
        if (nt != nil) {
            first = rexGroup(1)[3];
            second = rexGroup(2)[3];
            if (!first.endsWith(' ') && first.length() > 0)
                first = first + ' ';
            if (rexMatch('<nocase>und(.*)', second))
                second = 'und ' + second.substr(4, second.length());  
            if (!second.startsWith(' ') && second.length() > 0)
                second = ' ' + second;
            str = first + 'tausend' + second;
        }
        nh = rexMatch('<nocase>(.*)hundert(.*)', str);
        if (nh != nil) {
            first = rexGroup(1)[3];
            second = rexGroup(2)[3];
            if (!first.endsWith(' ') && first.length() > 0)
                first = first + ' ';
            if (rexMatch('<nocase>und(.*)', second))
                second = 'und ' + second.substr(4, second.length());  
            if (!second.startsWith(' ') && second.length() > 0)
                second = ' ' + second;
            str = first + 'hundert' + second;
        }
        return str;
    }
;

// ##### German infinitve counter: #####

infinitive: object
    count = 0
    add() {
        self.count += 1;
    }
    reset() {
        self.count = 0;
    }
;

/*   ##########################################################################
 *   ## Command tokenizer for German (DE).  Other language modules should    ##
 *   ## provide their own tokenizers to allow for differences in punctuation ##
 *   ## and other lexical elements.                                          ##
 *   ##########################################################################
 */  

cmdTokenizer: Tokenizer
    rules_ = static
    [
        /* skip whitespace */
        ['whitespace', new RexPattern('<Space>+'), nil, &tokCvtSkip, nil],

        /* certain punctuation marks */
        ['punctuation', new RexPattern('[.,;:?!]'), tokPunct, nil, nil],

        /*
         *   We have a special rule for spelled-out numbers from 21 to 99:
         *   when we see a 'tens' word followed by a hyphen followed by a
         *   digits word, we'll pull out the tens word, the hyphen, and
         *   the digits word as separate tokens.
         */

        // ##### German spelled number pattern #####
        ['spelled number',
         new RexPattern('<NoCase>(ein|zwei|drei|vier|fünf|sechs|sieben|acht|neun)'
                        + 'und'
                        + '(zwanzig|dreißig|vierzig|fünfzig|sechzig|siebzig|'
                        + 'achtzig|neunzig)'
                        + '(?!<AlphaNum>)'),
         tokWord, &tokCvtSpelledNumber, nil],
        
        // ##### Spelled hundreds "einhundert" #####
        
        ['spelled number hundred',
         new RexPattern('<NoCase>(ein|zwei|drei|vier|fünf|sechs|sieben|acht|neun)'
                        + 'hundert'
                        + '(?!<AlphaNum>)'),
         tokWord, &tokCvtSpelledNumberHundred, nil],
        
        // ##### Spelled number hundred number "einhundertzwei" #####
        
        ['spelled number hundred number',
         new RexPattern('<NoCase>(ein|zwei|drei|vier|fünf|sechs|sieben|acht|neun)'
                        + 'hundert'
                        + '(eins|zwei|drei|vier|fünf|sechs|sieben|acht|neun|zehn|elf
                            |zwölf|dreizehn|vierzehn|fünfzehn|sechzehn|siebzehn|achtzehn
                            |neunzehn)'
                        + '(?!<AlphaNum>)'),
         tokWord, &tokCvtSpelledNumberHundredNumber, nil],

        // ##### Spelled number hundred number and number "einhundertdreiundzwanzig" #####
        
        ['spelled number hundred number and number',
         new RexPattern('<NoCase>(ein|zwei|drei|vier|fünf|sechs|sieben|acht|neun)'
                        + 'hundert'
                        + '(ein|zwei|drei|vier|fünf|sechs|sieben|acht|neun)'
                        + 'und'
                        + '(zwanzig|dreißig|vierzig|fünfzig|sechzig|siebzig|'
                        + 'achtzig|neunzig)'
                        + '(?!<AlphaNum>)'),
         tokWord, &tokCvtSpelledNumberHundredNumberAndNumber, nil],
        
        /*
         *   Initials.  We'll look for strings of three or two initials,
         *   set off by periods but without spaces.  We'll look for
         *   three-letter initials first ("G.H.W. Billfold"), then
         *   two-letter initials ("X.Y. Zed"), so that we find the longest
         *   sequence that's actually in the dictionary.  Note that we
         *   don't have a separate rule for individual initials, since
         *   we'll pick that up with the regular abbreviated word rule
         *   below.
         *
         *   Some games could conceivably extend this to allow strings of
         *   initials of four letters or longer, but in practice people
         *   tend to elide the periods in longer sets of initials, so that
         *   the initials become an acronym, and thus would fit the
         *   ordinary word token rule.
         */
        ['three initials',
         new RexPattern('<alpha><period><alpha><period><alpha><period>'),
         tokWord, &tokCvtAbbr, &acceptAbbrTok],

        ['two initials',
         new RexPattern('<alpha><period><alpha><period>'),
         tokWord, &tokCvtAbbr, &acceptAbbrTok],

        /*
         *   Abbbreviated word - this is a word that ends in a period,
         *   such as "Mr.".  This rule comes before the ordinary word rule
         *   because we will only consider the period to be part of the
         *   word (and not a separate token) if the entire string
         *   including the period is in the main vocabulary dictionary.
         */
        ['abbreviation',
         new RexPattern('<Alpha|-><AlphaNum|-|squote>*<period>'),
         tokWord, &tokCvtAbbr, &acceptAbbrTok],

        /*
         *   A word ending in an apostrophe-s.  We parse this as two
         *   separate tokens: one for the word and one for the
         *   apostrophe-s.
         */
        ['apostrophe-s word',
         new RexPattern('<Alpha|-|&><AlphaNum|-|&|squote>*<squote>[sS]'),
         tokWord, &tokCvtApostropheS, nil],
       		
        /*
         *   A plural word ending in an apostrophe.  We parse this as two
         *   separate tokens: one for the word and one for the apostrophe. 
         */
        ['plural possessive word',
         new RexPattern('<Alpha|-|&><AlphaNum|-|&|squote>*<squote>'
                        + '(?!<AlphaNum>)'),
         tokWord, &tokCvtPluralApostrophe, nil],

        /*
         *   Words - note that we convert everything to lower-case.  A word
         *   must start with an alphabetic character, a hyphen, or an
         *   ampersand; after the initial character, a word can contain
         *   alphabetics, digits, hyphens, ampersands, and apostrophes.
         */		   

		// tokCvtEnding behandelt das Abschneiden der Endungen

        ['word',
         new RexPattern('<Alpha|-|&><AlphaNum|-|&|squote>*'),
         tokWord, &tokCvtEnding, nil],
        
        /* an abbreviation word starting with a number */
        ['abbreviation with initial digit',
         new RexPattern('<Digit>(?=<AlphaNum|-|&|squote>*<Alpha|-|&|squote>)'
                        + '<AlphaNum|-|&|squote>*<period>'),
         tokWord, &tokCvtAbbr, &acceptAbbrTok],

        /*
         *   A word can start with a number, as long as there's something
         *   other than numbers in the string - if it's all numbers, we
         *   want to treat it as a numeric token.
         */
        ['word with initial digit',
         new RexPattern('<Digit>(?=<AlphaNum|-|&|squote>*<Alpha|-|&|squote>)'
                        + '<AlphaNum|-|&|squote>*'), tokWord, nil, nil],

        /* strings with ASCII "straight" quotes */
        ['string ascii-quote',
         new RexPattern('<min>([`\'"])(.*)%1(?!<AlphaNum>)'),
         tokString, nil, nil],

        /* some people like to use single quotes like `this' */
        ['string back-quote',
         new RexPattern('<min>`(.*)\'(?!<AlphaNum>)'), tokString, nil, nil],

        /* strings with Latin-1 curly quotes (single and double) */
        ['string curly single-quote',
         new RexPattern('<min>\u2018(.*)\u2019'), tokString, nil, nil],
        ['string curly double-quote',
         new RexPattern('<min>\u201C(.*)\u201D'), tokString, nil, nil],

        /*
         *   unterminated string - if we didn't just match a terminated
         *   string, but we have what looks like the start of a string,
         *   match to the end of the line
         */
        ['string unterminated',
         new RexPattern('([`\'"\u2018\u201C](.*)'), tokString, nil, nil],

        /* integer numbers */
        ['integer', new RexPattern('[0-9]+'), tokInt, nil, nil],

        /* numbers with a '#' preceding */
        ['integer with #',
         new RexPattern('#[0-9]+'), tokPoundInt, nil, nil]
    ]

    /*
     *   Handle an apostrophe-s word.  We'll return this as two separate
     *   tokens: one for the word preceding the apostrophe-s, and one for
     *   the apostrophe-s itself.
     */
    tokCvtApostropheS(txt, typ, toks)
    {
        local w;
        local s;

        /*
         *   pull out the part up to but not including the apostrophe, and
         *   pull out the apostrophe-s part
         */
        w = txt.substr(1, txt.length() - 2);
        s = txt.substr(txt.length() - 1);

        /* add the part before the apostrophe as the main token type */
        toks.append([w, typ, w]);

        /* add the apostrophe-s as a separate special token */
        toks.append([s, tokApostropheS, s]);
    }

    /*
     *   Handle a plural apostrophe word ("the smiths' house").  We'll
     *   return this as two tokens: one for the plural word, and one for
     *   the apostrophe. 
     */		   

    tokCvtPluralApostrophe(txt, typ, toks)
    {
        local w;
        local s;

        /*
         *   pull out the part up to but not including the apostrophe, and
         *   separately pull out the apostrophe 
         */
        w = txt.substr(1, txt.length() - 1);
        s = txt.substr(-1);

        /* add the part before the apostrophe as the main token type */

        toks.append([w, typ, w]);

        /* add the apostrophe-s as a separate special token */
        toks.append([s, tokPluralApostrophe, s]);
    }

    // #####################################
    // ## truncate every word to its root ##
    // ## when an unknown word is found   ##
    // #####################################

    tokCvtEnding(txt, typ, toks)
    {
        local w;
        local s;
        local temp;
        local len;
        local testVocab;
        local cvtFlag = nil;
        local apostFlag = nil;

        // ###################################################
        // ## we store the original value in orig - when we ##
        // ## have an unknown word, we set txt back to orig ##
        // ###################################################
        
        local orig = txt;
        temp = txt.toLower;
        
        len = temp.length();
        testVocab = cmdDict.isWordDefined(temp);
        w = temp; // ##### new string with corrected Umlauts #####
        
        // ###################################################################
        // ## replace Tokens mechanism: replace all compressed prepositions ##
        // ## like durchs = durch / ins = in / aufs = auf etc ... the       ##
        // ## author must not(!) define the follwing tokens as a vocabulary ##
        // ## word, because this would break our replacement mechanism ...  ##
        // ###################################################################
        
        if (testVocab == nil) { // ##### precond: we've found an unknown word ... #####
            
            local tokTest = tokHelper.checkForValidTokens(w);
            if (tokTest != w && tokTest != 'undefined') {
                w = tokTest;
                temp = w;
                //cvtFlag = true;
            }        
        }
              
        // ##### check whether we have a noun or an adjective or infinitive #####
        if (testVocab == nil && len > 3 && cvtFlag == nil)
        {
            // ##### Genitiv-s as in 'Mariels Gesicht' #####
            if (temp.endsWith('s') == true)
            {
                s = temp.substr(1, temp.length() - 1);
                if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
                {
                    w = s;
                    // ##### we add an apostrophe-S and want to interpret it as a possessive phrase #####
                    apostFlag = true;
                    cvtFlag = true;
                }
            }
            // -- ##### ending -es #####
            if (temp.endsWith('es') == true)
            {
                s = temp.substr(1, temp.length() - 2);
                if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
                {
                    w = s;
                    cvtFlag = true;
                }
            }
            // ##### ending -er #####
            if (temp.endsWith('er') == true && cvtFlag == nil)
            {
                s = temp.substr(1, temp.length() - 2);
                if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
                {
                    w = s;
                    cvtFlag = true;
                }
            }
            // ##### ending -en #####
            if (txt.endsWith('en') == true && cvtFlag == nil)
            {
                s = temp.substr(1, temp.length() - 2);
                if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
                {
                    w = s;
                    cvtFlag = true;
                }
            }
            // ##### ending -em #####
            if (txt.endsWith('em') == true && cvtFlag == nil)
            {
                s = temp.substr(1, temp.length() - 2);
                if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
                {
                    w = s;
                    cvtFlag = true;
                }
            }
            // ##### ending -e (for verbs)e.g. nehme = nehm #####
            if (txt.endsWith('e') == true && cvtFlag == nil)
            {
                s = temp.substr(1, temp.length() - 1);
                if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
                {
                    w = s;
                    cvtFlag = true;
                }
            }
            // ##### ending -n #####
            if (txt.endsWith('n') == true && cvtFlag == nil)
            {
                s = temp.substr(1, temp.length() - 1);
                if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
                {
                    w = s;
                    cvtFlag = true;
                }
            }
        }
        // ##### we test whether we were successfull #####
        if (!cmdDict.isWordDefined(w) && w != '')
            w = orig;
        
        if (w != '') // ##### if we have an infinitive verb form, do not add any token #####
            toks.append([w, typ, orig]);    // ##### else add the original token #####
        
        // ##### if we have an apostFlag (Genitive) add apostrophe-s and handle it as possessive phrase ... #####
        // ##### we do not store the apostrophe-s in the origin part of the token tok[3] #####
        if (apostFlag)
            toks.append(['&rsquos', tokApostropheS, '']);
    }
    
    /*
     *   Handle a spelled-out hyphenated number from 21 to 99.  We'll
     *   return this as three separate tokens: a word for the tens name, a
     *   word for the hyphen, and a word for the units name.
     */
    tokCvtSpelledNumber(txt, typ, toks)
    {
        /* parse the number into its three parts with a regular expression */
        rexMatch(patAlphaDashAlpha, txt);
                
        /* add the part before the hyphen */
        toks.append([rexGroup(1)[3], typ, rexGroup(1)[3]]);

        /* add the hyphen */
        toks.append(['und', typ, 'und']);

        /* add the part after the hyphen */
        toks.append([rexGroup(2)[3], typ, rexGroup(2)[3]]);
    }
    patAlphaDashAlpha = static new RexPattern('(<alpha>+)und(<alpha>+)')

    // ##### handle out a spelled number and hundred as in 'zweihundert' #####
    
    tokCvtSpelledNumberHundred(txt, typ, toks)
    {
        local w;
        local s;

        /*
         *   pull out the part up to 'hundert', and
         *   pull out the 'hundert'
         */
        w = txt.substr(1, txt.length() - 7);
        s = txt.substr(txt.length() - 6);

        /* add the part before the apostrophe as the main token type */
        toks.append([w, typ, w]);

        /* add the apostrophe-s as a separate special token */
        toks.append([s, tokApostropheS, s]);
    }

    // ##### handle out a spelled number and hundred and number as in 'zweihundertvier' #####
    
    tokCvtSpelledNumberHundredNumber(txt, typ, toks)
    {
        /* parse the number into its three parts with a regular expression */
        rexMatch(patAlphaHundredAlpha, txt);

        /* add the part before the hyphen */
        toks.append([rexGroup(1)[3], typ, rexGroup(1)[3]]);

        /* add the hyphen */
        toks.append(['hundert', typ, 'hundert']);

        /* add the part after the hyphen */
        toks.append([rexGroup(2)[3], typ, rexGroup(2)[3]]);
    }
    patAlphaHundredAlpha = static new RexPattern('(<alpha>+)hundert(<alpha>+)')

    // ##### handle out a spelled number and hundred and number and number as in 'zweihundertvierundfünfzig' #####
    
    tokCvtSpelledNumberHundredNumberAndNumber(txt, typ, toks)
    {
        /* parse the number into its three parts with a regular expression */
        rexMatch(patAlphaHundredAlphaAndAlpha, txt);

        /* add the part before the hyphen */
        toks.append([rexGroup(1)[3], typ, rexGroup(1)[3]]);

        /* add the hyphen */
        toks.append(['hundert', typ, 'hundert']);

        /* add the part after the hyphen */
        toks.append([rexGroup(2)[3], typ, rexGroup(2)[3]]);
        
        /* add the hyphen */
        toks.append(['und', typ, 'und']);

        /* add the part after the hyphen */
        toks.append([rexGroup(3)[3], typ, rexGroup(3)[3]]);
    }
    patAlphaHundredAlphaAndAlpha = static new RexPattern('(<alpha>+)hundert(<alpha>+)und(<alpha>+)')
    
    /*
     *   Check to see if we want to accept an abbreviated token - this is
     *   a token that ends in a period, which we use for abbreviated words
     *   like "Mr." or "Ave."  We'll accept the token only if it appears
     *   as given - including the period - in the dictionary.  Note that
     *   we ignore truncated matches, since the only way we'll accept a
     *   period in a word token is as the last character; there is thus no
     *   way that a token ending in a period could be a truncation of any
     *   longer valid token.
     */
    acceptAbbrTok(txt)
    {
        /* look up the word, filtering out truncated results */
        return cmdDict.isWordDefined(
            txt, {result: (result & StrCompTrunc) == 0});
    }

    /*
     *   Process an abbreviated token.
     *
     *   When we find an abbreviation, we'll enter it with the abbreviated
     *   word minus the trailing period, plus the period as a separate
     *   token.  We'll mark the period as an "abbreviation period" so that
     *   grammar rules will be able to consider treating it as an
     *   abbreviation -- but since it's also a regular period, grammar
     *   rules that treat periods as regular punctuation will also be able
     *   to try to match the result.  This will ensure that we try it both
     *   ways - as abbreviation and as a word with punctuation - and pick
     *   the one that gives us the best result.
     */
    tokCvtAbbr(txt, typ, toks)
    {
        local w;

        /* add the part before the period as the ordinary token */
        w = txt.substr(1, txt.length() - 1);
        toks.append([w, typ, w]);

        /* add the token for the "abbreviation period" */
        toks.append(['.', tokAbbrPeriod, '.']);
    }

    /*
     *   Given a list of token strings, rebuild the original input string.
     *   We can't recover the exact input string, because the tokenization
     *   process throws away whitespace information, but we can at least
     *   come up with something that will display cleanly and produce the
     *   same results when run through the tokenizer.
     */
    buildOrigText(toks)
    {
        local str;

        /* start with an empty string */
        str = '';

        /* concatenate each token in the list */
        for (local i = 1, local len = toks.length() ; i <= len ; ++i)
        {
            /* add the current token to the string */
            str += getTokOrig(toks[i]);

            /*
             *   if this looks like a hyphenated number that we picked
             *   apart into two tokens, put it back together without
             *   spaces
             */
            if (i + 2 <= len
                && rexMatch(patSpelledUnits, getTokVal(toks[i])) != nil
                && getTokVal(toks[i+1]) == 'und' // -- in german UND instead of '-'
                && rexMatch(patSpelledTens, getTokVal(toks[i+2])) != nil)
            {
                /*
                 *   it's a hyphenated number, all right - put the three
                 *   tokens back together without any intervening spaces,
                 *   so ['twenty', '-', 'one'] turns into 'twenty-one'
                 */
                str += getTokOrig(toks[i+1]) + getTokOrig(toks[i+2]);

                /* skip ahead by the two extra tokens we're adding */
                i += 2;
            }
            else if (i + 1 <= len
                     && getTokType(toks[i]) == tokWord
                     && getTokType(toks[i+1]) is in
                        (tokApostropheS, tokPluralApostrophe))
            {
                /*
                 *   it's a word followed by an apostrophe-s token - these
                 *   are appended together without any intervening spaces
                 */
                str += getTokOrig(toks[i+1]);

                /* skip the extra token we added */
                ++i;
            }

            /*
             *   If another token follows, and the next token isn't a
             *   punctuation mark, and the previous token wasn't an open
             *   paren, add a space before the next token.
             */
            if (i != len
                && rexMatch(patPunct, getTokVal(toks[i+1])) == nil
                && getTokVal(toks[i]) != '(')
                str += ' ';
        }

        /* return the result string */
        return str;
    }

    /* some pre-compiled regular expressions */
    patSpelledTens = static new RexPattern(
        '<nocase>zwanzig|dreißig|vierzig|fünfzig|sechzig|siebzig|achtzig|neunzig')
    patSpelledUnits = static new RexPattern(
        '<nocase>(ein|eins)|zwei|drei|vier|fünf|sechs|sieben|acht|neun')
    patPunct = static new RexPattern('[.,;:?!]')
;


/* ------------------------------------------------------------------------ */
/*
 *   Grammar Rules
 */

/*
 *   Command with explicit target actor.  When a command starts with an
 *   actor's name followed by a comma followed by a verb, we take it as
 *   being directed to the actor.
 */
grammar firstCommandPhrase(withActor):
    singleNounOnly->actor_ ',' commandPhrase->cmd_
    : FirstCommandProdWithActor

    /* "execute" the target actor phrase */
    execActorPhrase(issuingActor)
    {
        /* flag that the actor's being addressed in the second person */
        resolvedActor_.commandReferralPerson = SecondPerson;
    }
;

grammar firstCommandPhrase(askTellActorTo):
    ('a' | 't' | 'bitt' | 'sag' | 'befehl' ) singleNounOnly->actor_
    (':'|',') commandPhrase->cmd_
    : FirstCommandProdWithActor

    /* "execute" the target actor phrase */
    execActorPhrase(issuingActor)
    {
        /*
         *   Since our phrasing is TELL <ACTOR> TO <DO SOMETHING>, the
         *   actor clearly becomes the antecedent for a subsequent
         *   pronoun.  For example, in TELL BOB TO READ HIS BOOK, the word
         *   HIS pretty clearly refers back to BOB.
         */
        if (resolvedActor_ != nil)
        {
            /* set the possessive anaphor object to the actor */
            resolvedActor_.setPossAnaphorObj(resolvedActor_);

            /* flag that the actor's being addressed in the third person */
            resolvedActor_.commandReferralPerson = ThirdPerson;

            /*
             *   in subsequent commands carried out by the issuer, the
             *   target actor is now the pronoun antecedent (for example:
             *   after TELL BOB TO GO NORTH, the command FOLLOW HIM means
             *   to follow Bob)
             */
            issuingActor.setPronounObj(resolvedActor_);
        }
    }
;

/*
 *   An actor-targeted command with a bad command phrase.  This is used as
 *   a fallback if we fail to match anything on the first attempt at
 *   parsing the first command on a line.  The point is to at least detect
 *   the target actor phrase, if that much is valid, so that we better
 *   customize error messages for the rest of the command.  
 */
grammar actorBadCommandPhrase(main):
    singleNounOnly->actor_ ',' miscWordList
    | ('a' | 't' | 'bitt' | 'sag' | 'befehl' ) singleNounOnly->actor_ 
    (':'|',') miscWordList
    : FirstCommandProdWithActor

    /* to resolve nouns, we merely resolve the actor */
    resolveNouns(issuingActor, targetActor, results)
    {
        /* resolve the underlying actor phrase */
        return actor_.resolveNouns(getResolver(issuingActor), results);
    }
;


/*
 *   Command-only conjunctions.  These words and groups of words can
 *   separate commands from one another, and can't be used to separate noun
 *   phrases in a noun list.  
 */
grammar commandOnlyConjunction(sentenceEnding):
    '.'
    | '!'
    | '.' 'dann'
    | '!' 'dann'
    : BasicProd

    /* these conjunctions end the sentence */
    isEndOfSentence() { return true; }
;

grammar commandOnlyConjunction(nonSentenceEnding):
    'dann'
    | 'und' 'dann'
    | ',' 'dann'
    | ',' 'und' 'dann'
    | ';'
    : BasicProd

    /* these conjunctions do not end a sentence */
    isEndOfSentence() { return nil; }
;


/*
 *   Command-or-noun conjunctions.  These words and groups of words can be
 *   used to separate commands from one another, and can also be used to
 *   separate noun phrases in a noun list.
 */
grammar commandOrNounConjunction(main):
    ','
    | 'und'
    | ',' 'und'
    : BasicProd

    /* these do not end a sentence */
    isEndOfSentence() { return nil; }
;

/*
 *   Noun conjunctions.  These words and groups of words can be used to
 *   separate noun phrases from one another.  Note that these do not need
 *   to be exclusive to noun phrases - these can occur as command
 *   conjunctions as well; this list is separated from
 *   commandOrNounConjunction in case there are conjunctions that can never
 *   be used as command conjunctions, since such conjunctions, which can
 *   appear here, would not appear in commandOrNounConjunctions.  
 */
grammar nounConjunction(main):
    ','
    | 'und'
    | ',' 'und'
    : BasicProd

    /* these conjunctions do not end a sentence */
    isEndOfSentence() { return nil; }
;

/* ------------------------------------------------------------------------ */
/*
 *   Noun list: one or more noun phrases connected with conjunctions.  This
 *   kind of noun list can end in a terminal noun phrase.
 *   
 *   Note that a single noun phrase is a valid noun list, since a list can
 *   simply be a list of one.  The separate production nounMultiList can be
 *   used when multiple noun phrases are required.  
 */

/*
 *   a noun list can consist of a single terminal noun phrase
 */
grammar nounList(terminal): terminalNounPhrase->np_ : NounListProd
    resolveNouns(resolver, results)
    {
        /* resolve the underlying noun phrase */
        return np_.resolveNouns(resolver, results);
    }
;

/*
 *   a noun list can consist of a list of a single complete (non-terminal)
 *   noun phrase
 */
grammar nounList(nonTerminal): completeNounPhrase->np_ : NounListProd
    resolveNouns(resolver, results)
    {
        /* resolve the underlying noun phrase */
        return np_.resolveNouns(resolver, results);
    }
;

/*
 *   a noun list can consist of a list with two or more entries
 */
grammar nounList(list): nounMultiList->lst_ : NounListProd
    resolveNouns(resolver, results)
    {
        /* resolve the underlying list */
        return lst_.resolveNouns(resolver, results);
    }
;

/*
 *   An empty noun list is one with no words at all.  This is matched when
 *   a command requires a noun list but the player doesn't include one;
 *   this construct has "badness" because we only want to match it when we
 *   have no choice.
 */
grammar nounList(empty): [badness 500] : EmptyNounPhraseProd
    responseProd = nounList
;

/* ------------------------------------------------------------------------ */
/*
 *   Noun Multi List: two or more noun phrases connected by conjunctions.
 *   This is almost the same as the basic nounList production, but this
 *   type of production requires at least two noun phrases, whereas the
 *   basic nounList production more generally defines its list as any
 *   number - including one - of noun phrases.
 */

/*
 *   a multi list can consist of a noun multi- list plus a terminal noun
 *   phrase, separated by a conjunction
 */
grammar nounMultiList(multi):
    nounMultiList->lst_ nounConjunction terminalNounPhrase->np_
    : NounListProd
    resolveNouns(resolver, results)
    {
        /* return a list of all of the objects from both underlying lists */
        return np_.resolveNouns(resolver, results)
            + lst_.resolveNouns(resolver, results);
    }
;

/*
 *   a multi list can consist of a non-terminal multi list
 */
grammar nounMultiList(nonterminal): nonTerminalNounMultiList->lst_
    : NounListProd
    resolveNouns(resolver, results)
    {
        /* resolve the underlying list */
        return lst_.resolveNouns(resolver, results);
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   A non-terminal noun multi list is a noun list made up of at least two
 *   non-terminal noun phrases, connected by conjunctions.
 *
 *   This is almost the same as the regular non-terminal noun list
 *   production, but this production requires two or more underlying noun
 *   phrases, whereas the basic non-terminal noun list matches any number
 *   of underlying phrases, including one.
 */

/*
 *   a non-terminal multi-list can consist of a pair of complete noun
 *   phrases separated by a conjunction
 */
grammar nonTerminalNounMultiList(pair):
    completeNounPhrase->np1_ nounConjunction completeNounPhrase->np2_
    : NounListProd
    resolveNouns(resolver, results)
    {
        /* return the combination of the two underlying noun phrases */
        return np1_.resolveNouns(resolver, results)
            + np2_.resolveNouns(resolver, results);
    }
;

/*
 *   a non-terminal multi-list can consist of another non-terminal
 *   multi-list plus a complete noun phrase, connected by a conjunction
 */
grammar nonTerminalNounMultiList(multi):
    nonTerminalNounMultiList->lst_ nounConjunction completeNounPhrase->np_
    : NounListProd
    resolveNouns(resolver, results)
    {
        /* return the combination of the sublist and the noun phrase */
        return lst_.resolveNouns(resolver, results)
            + np_.resolveNouns(resolver, results);
    }
;


/* ------------------------------------------------------------------------ */
/*
 *   "Except" list.  This is a noun list that can contain anything that's
 *   in a regular noun list plus some things that only make sense as
 *   exceptions, such as possessive nouns (e.g., "mine").
 */

grammar exceptList(single): exceptNounPhrase->np_ : ExceptListProd
    resolveNouns(resolver, results)
    {
        return np_.resolveNouns(resolver, results);
    }
;

grammar exceptList(list):
    exceptNounPhrase->np_ nounConjunction exceptList->lst_
    : ExceptListProd
    resolveNouns(resolver, results)
    {
        /* return a list consisting of all of our objects */
        return np_.resolveNouns(resolver, results)
            + lst_.resolveNouns(resolver, results);
    }
;

/*
 *   An "except" noun phrase is a normal "complete" noun phrase or a
 *   possessive noun phrase that doesn't explicitly qualify another phrase
 *   (for example, "all the coins but bob's" - the "bob's" is just a
 *   possessive noun phrase without another noun phrase attached, since it
 *   implicitly qualifies "the coins").
 */
grammar exceptNounPhrase(singleComplete): completeNounPhraseWithoutAll->np_
    : ExceptListProd
    resolveNouns(resolver, results)
    {
        return np_.resolveNouns(resolver, results);
    }
;

grammar exceptNounPhrase(singlePossessive): possessiveNounPhrase->poss_
    : ButPossessiveProd
;


/* ------------------------------------------------------------------------ */
/*
 *   A single noun is sometimes required where, structurally, a list is not
 *   allowed.  Single nouns should not be used to prohibit lists where
 *   there is no structural reason for the prohibition - these should be
 *   used only where it doesn't make sense to use a list structurally.  
 */
grammar singleNoun(normal): singleNounOnly->np_ : LayeredNounPhraseProd
;

/*
 *   An empty single noun is one with no words at all.  This is matched
 *   when a command requires a noun list but the player doesn't include
 *   one; this construct has "badness" because we only want to match it
 *   when we have no choice.
 */
grammar singleNoun(empty): [badness 500] : EmptyNounPhraseProd
    /* use a nil responseProd, so that we get the phrasing from the action */
    responseProd = nil

    /* the fallback responseProd, if we can't get one from the action */
    fallbackResponseProd = singleNoun
;

/*
 *   A user could attempt to use a noun list with more than one entry (a
 *   "multi list") where a single noun is required.  This is not a
 *   grammatical error, so we accept it grammatically; however, for
 *   disambiguation purposes we score it lower than a singleNoun production
 *   with only one noun phrase, and if we try to resolve it, we'll fail
 *   with an error.  
 */
grammar singleNoun(multiple): nounMultiList->np_ : SingleNounWithListProd
;


/*
 *   A *structural* single noun phrase.  This production is for use where a
 *   single noun phrase (not a list of nouns) is required grammatically.
 */
grammar singleNounOnly(main):
    terminalNounPhrase->np_
    | completeNounPhrase->np_
    : SingleNounProd
;

/* ------------------------------------------------------------------------ */
/*
 *   Prepositionally modified single noun phrases.  These can be used in
 *   indirect object responses, so allow for interactions like this:
 *   
 *   >unlock door
 *.  What do you want to unlock it with?
 *   
 *   >with the key
 *   
 *   The entire notion of prepositionally qualified noun phrases in
 *   interactive indirect object responses is specific to English, so this
 *   is implemented in the English module only.  However, the general
 *   notion of specialized responses to interactive indirect object queries
 *   is handled in the language-independent library in some cases, in such
 *   a way that the language-specific library can customize the behavior -
 *   see TIAction.askIobjResponseProd.  
 */
class PrepSingleNounProd: SingleNounProd
    resolveNouns(resolver, results)
    {
        return np_.resolveNouns(resolver, results);
    }

    /* 
     *   If the response starts with a preposition, it's pretty clearly a
     *   response to the special query rather than a new command. 
     */
    isSpecialResponseMatch()
    {
        return (np_ != nil && np_.firstTokenIndex > 1);
    }
;

/*
 *   Same thing for a Topic phrase
 */
class PrepSingleTopicProd: TopicProd
    resolveNouns(resolver, results)
    {
        return np_.resolveNouns(resolver, results);
    }
;

// ############################################
// ## German grammar definitions             ##
// ## we define adequate german prepositions ##
// ############################################

grammar inSingleNoun(main):
     singleNoun->np_ | 'in' singleNoun->np_
    : PrepSingleNounProd
;

grammar umSingleNoun(main):
     singleNoun->np_ | 'um' singleNoun->np_
    : PrepSingleNounProd
;

grammar nachSingleNoun(main):
     singleNoun->np_ | 'nach' singleNoun->np_
    : PrepSingleNounProd
;

grammar zuSingleNoun(main):
     singleNoun->np_ | 'zu' singleNoun->np_
    : PrepSingleNounProd
;

grammar ueberSingleNoun(main):
     singleNoun->np_ | 'über' singleNoun->np_
    : PrepSingleNounProd
;

grammar durchSingleNoun(main):
     singleNoun->np_ | 'durch' singleNoun->np_
    : PrepSingleNounProd
;

grammar vonSingleNoun(main):
     singleNoun->np_ | 'von' singleNoun->np_
    : PrepSingleNounProd
;

grammar aufSingleNoun(main):
     singleNoun->np_ | 'auf' singleNoun->np_
    : PrepSingleNounProd
;

grammar unterSingleNoun(main):
     singleNoun->np_ | 'unter' singleNoun->np_
    : PrepSingleNounProd
;

grammar hinterSingleNoun(main):
     singleNoun->np_ | 'hinter' singleNoun->np_
    : PrepSingleNounProd
;

grammar ausSingleNoun(main):
     singleNoun->np_ | 'aus' singleNoun->np_
    : PrepSingleNounProd
;

grammar mitSingleNoun(main):
     singleNoun->np_ | 'mit' singleNoun->np_
    : PrepSingleNounProd
;

grammar anSingleNoun(main):
     singleNoun->np_ | 'an' singleNoun->np_
    : PrepSingleNounProd
;

// ##### and the topic phrases ... #####

grammar aboutTopicPhrase(main):
   topicPhrase->np_ | ('von'|'nach'|'über'|'um') topicPhrase->np_
   : PrepSingleTopicProd
;

/* ------------------------------------------------------------------------ */
/*
 *   Complete noun phrase - this is a fully-qualified noun phrase that
 *   cannot be modified with articles, quantifiers, or anything else.  This
 *   is the highest-level individual noun phrase.  
 */

grammar completeNounPhrase(main):
    completeNounPhraseWithAll->np_ | completeNounPhraseWithoutAll->np_
    : LayeredNounPhraseProd
;

/*
 *   Slightly better than a purely miscellaneous word list is a pair of
 *   otherwise valid noun phrases connected by a preposition that's
 *   commonly used in command phrases.  This will match commands where the
 *   user has assumed a command with a prepositional structure that doesn't
 *   exist among the defined commands.  Since we have badness, we'll be
 *   ignored any time there's a valid command syntax with the same
 *   prepositional structure.
 */
grammar completeNounPhrase(miscPrep):
    [badness 100] completeNounPhrase->np1_
        ('in'|'um'|'nach'|'zu'|'über'
         |'durch'|'von'|'auf'|'unter'
         |'hinter'|'aus'|'mit'|'an')
        completeNounPhrase->np2_
    : NounPhraseProd
    resolveNouns(resolver, results)
    {
        /* note that we have an invalid prepositional phrase structure */
        results.noteBadPrep();

        /* resolve the underlying noun phrases, for scoring purposes */
        np1_.resolveNouns(resolver, results);
        np2_.resolveNouns(resolver, results);

        /* return nothing */
        return [];
    }
;


/*
 *   A qualified noun phrase can, all by itself, be a full noun phrase
 */
grammar completeNounPhraseWithoutAll(qualified): qualifiedNounPhrase->np_
    : LayeredNounPhraseProd
;

/*
 *   Pronoun rules.  A pronoun is a complete noun phrase; it does not allow
 *   further qualification.  
 */
grammar completeNounPhraseWithoutAll(it):   'es' | 'ihm' : ItProd;      // ##### German neuter singular
grammar completeNounPhraseWithoutAll(them): 'ihnen' : ThemProd;         // ##### German plural
grammar completeNounPhraseWithoutAll(him):  'ihn' | 'ihm' : HimProd;    // ##### German male singular
grammar completeNounPhraseWithoutAll(her):  'sie' | 'ihr' : HerProd;    // ##### German female singular

/*
 *   Reflexive second-person pronoun, for things like "bob, look at
 *   yourself"
 */
grammar completeNounPhraseWithoutAll(yourself):
    'dich'|'dir'|'dich' 'selbst'|'dir' 'selbst'|'mich'|'mir'|'mich' 'selbst'
    |'mir' 'selbst' : YouProd
;

/*
 *   Reflexive third-person pronouns.  We accept these in places such as
 *   the indirect object of a two-object verb.
 */
grammar completeNounPhraseWithoutAll(itself): 'ihr' 'selbst'
    |'ihm selbst' : ItselfProd // -- German we have also third person style
    /* check agreement of our binding */
    checkAgreement(lst)
    {
        /* the result is required to be singular and ungendered */
        return (lst.length() == 1 && lst[1].obj_.canMatchIt);
    }
;

grammar completeNounPhraseWithoutAll(themselves):
    'ihnen' 'selbst'|'sie' 'selbst' : ThemselvesProd

    /* check agreement of our binding */
    checkAgreement(lst)
    {
        /*
         *   For 'themselves', allow anything; we could balk at this
         *   matching a single object that isn't a mass noun, but that
         *   would be overly picky, and it would probably reject at least
         *   a few things that really ought to be acceptable.  Besides,
         *   'them' is the closest thing English has to a singular
         *   gender-neutral pronoun, and some people intentionally use it
         *   as such.
         */
        return true;
    }
;

grammar completeNounPhraseWithoutAll(himself): 'ihn' 'selbst'
    |'ihm' 'selbst' : HimselfProd
    /* check agreement of our binding */
    checkAgreement(lst)
    {
        /* the result is required to be singular and masculine */
        return (lst.length() == 1 && lst[1].obj_.canMatchHim);
    }
;

grammar completeNounPhraseWithoutAll(herself): 'sie' 'selbst'
    |'ihr' 'selbst' : HerselfProd
    /* check agreement of our binding */
    checkAgreement(lst)
    {
        /* the result is required to be singular and feminine */
        return (lst.length() == 1 && lst[1].obj_.canMatchHer);
    }
;

/*
 *   First-person pronoun, for referring to the speaker: "bob, look at me"
 */
grammar completeNounPhraseWithoutAll(me): 'mir' | 'mich' | 'mich' 'selbst'
    | 'mir' 'selbst' : MeProd;

/*
 *   "All" and "all but".
 *   
 *   "All" is a "complete" noun phrase, because there's nothing else needed
 *   to make it a noun phrase.  We make this a special kind of complete
 *   noun phrase because 'all' is not acceptable as a complete noun phrase
 *   in some contexts where any of the other complete noun phrases are
 *   acceptable.
 *   
 *   "All but" is a "terminal" noun phrase - this is a special kind of
 *   complete noun phrase that cannot be followed by another noun phrase
 *   with "and".  "All but" is terminal because we want any and's that
 *   follow it to be part of the exception list, so that we interpret "take
 *   all but a and b" as excluding a and b, not as excluding a but then
 *   including b as a separate list.  
 */
grammar completeNounPhraseWithAll(main):
    'alles'|'alle'
    : EverythingProd
;

grammar terminalNounPhrase(allBut):
    ('alle'|'alles') ('außer'|'aber' 'nicht')
        exceptList->except_
    : EverythingButProd
;

/*
 *   Plural phrase with an exclusion list.  This is a terminal noun phrase
 *   because it ends in an exclusion list.
 */
grammar terminalNounPhrase(pluralExcept):
    (qualifiedPluralNounPhrase->np_ | detPluralNounPhrase->np_)
    ('außer'|'aber' 'nicht') exceptList->except_
    : ListButProd
;

/*
 *   Qualified singular with an exception
 */
grammar terminalNounPhrase(anyBut):
    ('eines'|'eine'|'einen'|'einem') nounPhrase->np_
    ('außer' | 'aber' 'nicht') exceptList->except_
    : IndefiniteNounButProd
;

/* ------------------------------------------------------------------------ */
/*
 *   A qualified noun phrase is a noun phrase with an optional set of
 *   qualifiers: a definite or indefinite article, a quantifier, words such
 *   as 'any' and 'all', possessives, and locational specifiers ("the box
 *   on the table").
 *
 *   Without qualification, a definite article is implicit, so we read
 *   "take box" as equivalent to "take the box."
 *
 *   Grammar rule instantiations in language-specific modules should set
 *   property np_ to the underlying noun phrase match tree.
 */

/*
 *   A qualified noun phrase can be either singular or plural.  The number
 *   is a feature of the overall phrase; the phrase might consist of
 *   subphrases of different numbers (for example, "bob's coins" is plural
 *   even though it contains a singular subphrase, "bob"; and "one of the
 *   coins" is singular, even though its subphrase "coins" is plural).
 */
grammar qualifiedNounPhrase(main):
    qualifiedSingularNounPhrase->np_
    | qualifiedPluralNounPhrase->np_
    : LayeredNounPhraseProd
;

/* ------------------------------------------------------------------------ */
/*
 *   Singular qualified noun phrase.
 */

/*
 *   A singular qualified noun phrase with an implicit or explicit definite
 *   article.  If there is no article, a definite article is implied (we
 *   interpret "take box" as though it were "take the box").
 */
grammar qualifiedSingularNounPhrase(definite):
    (|'den'|'des'|'die'|'das'|'dem'|'der') indetSingularNounPhrase->np_
    : DefiniteNounProd
;

/*
 *   A singular qualified noun phrase with an explicit indefinite article.
 */
grammar qualifiedSingularNounPhrase(indefinite):
    ('ein'|'eins'|'1'|'eine'|'einen'|'eines'|'einem'
     |'einer') indetSingularNounPhrase->np_
    : IndefiniteNounProd
;

/*
 *   A singular qualified noun phrase with an explicit arbitrary
 *   determiner.
 */
grammar qualifiedSingularNounPhrase(arbitrary):
    ('irgendein'|'irgendeine'|'irgendeines'|'irgendeins'|'irgendeinen'
     |'irgendeinem') indetSingularNounPhrase->np_
    : ArbitraryNounProd
;

/*
 *   A singular qualified noun phrase with a possessive adjective.
 */
grammar qualifiedSingularNounPhrase(possessive):
    possessiveAdjPhrase->poss_ indetSingularNounPhrase->np_
    : PossessiveNounProd
;

// We want the parser to understand "Gesicht des Mannes" as a possessive phrase

grammar qualifiedSingularNounPhrase(possessive2):
    (|'den'|'des'|'die'|'das'|'dem'|'der') indetSingularNounPhrase->np_ ('der'|'des') indetSingularNounPhrase->poss_ (tokApostropheS->apost_ | tokPluralApostrophe->apost_ |)
    : PossessiveNounProd
;

grammar qualifiedSingularNounPhrase(possessive3):
    (|'den'|'des'|'die'|'das'|'dem'|'der') indetSingularNounPhrase->np_ 'von' indetSingularNounPhrase->poss_
    : PossessiveNounProd
;

grammar qualifiedSingularNounPhrase(possessive4):
    (|'den'|'des'|'die'|'das'|'dem'|'der') indetSingularNounPhrase->np_ 'von' ('dem'|'den'|'der') indetSingularNounPhrase->poss_
    : PossessiveNounProd
;

/*
 *   A singular qualified noun phrase that arbitrarily selects from a
 *   plural set.  This is singular, even though the underlying noun phrase
 *   is plural, because we're explicitly selecting one item.
 */
grammar qualifiedSingularNounPhrase(anyPlural):
    ('irgendein'|'irgendeine'|'irgendeines'|'irgendeins'|'irgendeinen'
     |'irgendeinem'|'ein'|'eins'|'1'|'eine'|'einen'|'eines'|'einem'
     |'einer') (|'von') explicitDetPluralNounPhrase->np_
    : ArbitraryNounProd
;

/*
 *   A singular object specified only by its containment, with a definite
 *   article.
 */
grammar qualifiedSingularNounPhrase(theOneIn):
    ('die'|'den'|'der'|'dem'|'des'|'das'|) ('der'|'die'|'das') 'sich' ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('befindet'|'befand')
    | ('die'|'den'|'der'|'dem'|'des'|'das'|) ('der'|'die'|'das') ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('ist'|'war')
    | ('die'|'den'|'der'|'dem'|'des'|'das') ('in'|'auf'|'an'|'von')
    completeNounPhraseWithoutAll->cont_ 
    : VagueContainerDefiniteNounPhraseProd

    /*
     *   our main phrase is simply 'one' (so disambiguation prompts will
     *   read "which one do you mean...")
     */
    mainPhraseText = 'davon'
;

/*
 *   A singular object specified only by its containment, with an
 *   indefinite article.
 */
grammar qualifiedSingularNounPhrase(anyOneIn):
    ('einen'|'eine'|'einer'|'einem'|'eines') ('der'|'die'|'das') 'sich' ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('befindet'|'befinden'|'befand'|'befanden')
    | ('irgendeinen'|'irgendeine'|'irgendeiner'|'irgendeinem'|'irgendeines') 
    ('der'|'die'|'das') 'sich' ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('befindet'|'befinden'|'befand'|'befanden')
    | ('einen'|'eine'|'einer'|'einem'|'eines') ('der'|'die'|'das') ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('ist'|'war'|'sind'|'waren')    
    | ('irgendeinen'|'irgendeine'|'irgendeiner'|'irgendeinem'|'irgendeines') 
    ('der'|'die'|'das') ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('ist'|'war'|'sind'|'waren') 
    | ('einen'|'eine'|'einer'|'einem'|'eines') ('in'|'auf'|'an'|'von')
    completeNounPhraseWithoutAll->cont_ 
    | ('irgendeinen'|'irgendeine'|'irgendeiner'|'irgendeinem'|'irgendeines') 
    ('in'|'auf'|'an'|'von')
    completeNounPhraseWithoutAll->cont_ 
    : VagueContainerIndefiniteNounPhraseProd
;

/* ------------------------------------------------------------------------ */
/*
 *   An "indeterminate" singular noun phrase is a noun phrase without any
 *   determiner.  A determiner is a phrase that specifies the phrase's
 *   number and indicates whether or not it refers to a specific object,
 *   and if so fixes which object it refers to; determiners include
 *   articles ("the", "a") and possessives.
 *
 *   Note that an indeterminate phrase is NOT necessarily an indefinite
 *   phrase.  In fact, in most cases, we assume a definite usage when the
 *   determiner is omitted: we take TAKE BOX as meaning TAKE THE BOX.  This
 *   is more or less the natural way an English speaker would interpret
 *   this ill-formed phrasing, but even more than that, it's the
 *   Adventurese convention, taking into account that most players enter
 *   commands telegraphically and are accustomed to noun phrases being
 *   definite by default.
 */

/* an indetermine noun phrase can be a simple noun phrase */
grammar indetSingularNounPhrase(basic):
    nounPhrase->np_
    : LayeredNounPhraseProd
;

/*
 *   An indetermine noun phrase can specify a location for the object(s).
 *   The location must be a singular noun phrase, but can itself be a fully
 *   qualified noun phrase (so it can have possessives, articles, and
 *   locational qualifiers of its own).
 *   
 *   Note that we take 'that are' even though the noun phrase is singular,
 *   because what we consider a singular noun phrase can have plural usage
 *   ("scissors", for example).  
 */
grammar indetSingularNounPhrase(locational):
    //[badness 200]
    nounPhrase->np_
    ('der'|'die'|'das')
    ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('ist'|'war'|'sind'|'waren')
    | nounPhrase->np_ ('der'|'die'|'das') 'sich'
    ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('befindet'|'befinden'|'befand'|'befanden')
    : ContainerNounPhraseProd
;

/* ------------------------------------------------------------------------ */
/*
 *   Plural qualified noun phrase.
 */

/*
 *   A simple unqualified plural phrase with determiner.  Since this form
 *   of plural phrase doesn't have any additional syntax that makes it an
 *   unambiguous plural, we can only accept an actual plural for the
 *   underlying phrase here - we can't accept an adjective phrase.
 */
grammar qualifiedPluralNounPhrase(determiner):
    ('alle'|) detPluralOnlyNounPhrase->np_
    : LayeredNounPhraseProd
;

/* plural phrase qualified with a number and optional "any" */
grammar qualifiedPluralNounPhrase(anyNum):
    ('alle' | ) numberPhrase->quant_ indetPluralNounPhrase->np_
    | ('alle' | ) numberPhrase->quant_ 'von' explicitDetPluralNounPhrase->np_
    : QuantifiedPluralProd
;

/* plural phrase qualified with a number and "all" */
grammar qualifiedPluralNounPhrase(allNum):
    'alle' numberPhrase->quant_ indetPluralNounPhrase->np_
    | 'alle' numberPhrase->quant_ 'von' explicitDetPluralNounPhrase->np_
    : ExactQuantifiedPluralProd
;

/* plural phrase qualified with "both" */
grammar qualifiedPluralNounPhrase(both):
    'beide' detPluralNounPhrase->np_
    //| 'both' 'of' explicitDetPluralNounPhrase->np_
    : BothPluralProd
;

/* plural phrase qualified with "all" */
grammar qualifiedPluralNounPhrase(all):
    'alle' detPluralNounPhrase->np_
    | 'alle' 'von' explicitDetPluralNounPhrase->np_
    : AllPluralProd
;

/* vague plural phrase with location specified */
grammar qualifiedPluralNounPhrase(theOnesIn):
    'alle' 'die' 'sich' ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('befinden'|'befanden')
    | 'alle' 'die' ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('sind'|'waren')
    : AllInContainerNounPhraseProd
;

/* ------------------------------------------------------------------------ */
/*
 *   A plural noun phrase with a determiner.  The determiner can be
 *   explicit (such as an article or possessive) or it can implied (the
 *   implied determiner is the definite article, so "take boxes" is
 *   understood as "take the boxes").
 */
grammar detPluralNounPhrase(main):
    indetPluralNounPhrase->np_ | explicitDetPluralNounPhrase->np_
    : LayeredNounPhraseProd
;

/* ------------------------------------------------------------------------ */
/*
 *   A determiner plural phrase with an explicit underlying plural (i.e.,
 *   excluding adjective phrases with no explicitly plural words).
 */
grammar detPluralOnlyNounPhrase(main):
    implicitDetPluralOnlyNounPhrase->np_
    | explicitDetPluralOnlyNounPhrase->np_
    : LayeredNounPhraseProd
;

/*
 *   An implicit determiner plural phrase is an indeterminate plural phrase
 *   without any extra determiner - i.e., the determiner is implicit.
 *   We'll treat this the same way we do a plural explicitly determined
 *   with a definite article, since this is the most natural interpretation
 *   in English.
 *
 *   (This might seem like a pointless extra layer in the grammar, but it's
 *   necessary for the resolution process to have a layer that explicitly
 *   declares the phrase to be determined, even though the determiner is
 *   implied in the structure.  This extra layer is important because it
 *   explicitly calls results.noteMatches(), which is needed for rankings
 *   and the like.)
 */
grammar implicitDetPluralOnlyNounPhrase(main):
    indetPluralOnlyNounPhrase->np_
    : DefinitePluralProd
;

/* ------------------------------------------------------------------------ */
/*
 *   A plural noun phrase with an explicit determiner.
 */

/* a plural noun phrase with a definite article */
grammar explicitDetPluralNounPhrase(definite):
    ('die'|'den'|'der') indetPluralNounPhrase->np_
    : DefinitePluralProd
;

/* a plural noun phrase with a definite article and a number */
grammar explicitDetPluralNounPhrase(definiteNumber):
    ('die'|'den'|'der') numberPhrase->quant_ indetPluralNounPhrase->np_
    : ExactQuantifiedPluralProd
;

/* a plural noun phrase with a possessive */
grammar explicitDetPluralNounPhrase(possessive):
    possessiveAdjPhrase->poss_ indetPluralNounPhrase->np_
    : PossessivePluralProd
;

/* a plural noun phrase with a possessive and a number */
grammar explicitDetPluralNounPhrase(possessiveNumber):
    possessiveAdjPhrase->poss_ numberPhrase->quant_
    indetPluralNounPhrase->np_
    : ExactQuantifiedPossessivePluralProd
;

/* ------------------------------------------------------------------------ */
/*
 *   A plural noun phrase with an explicit determiner and only an
 *   explicitly plural underlying phrase.
 */
grammar explicitDetPluralOnlyNounPhrase(definite):
    ('die'|'den') indetPluralOnlyNounPhrase->np_
    : AllPluralProd
;

grammar explicitDetPluralOnlyNounPhrase(definiteNumber):
    ('die'|'den') numberPhrase->quant_ indetPluralNounPhrase->np_
    : ExactQuantifiedPluralProd
;

grammar explicitDetPluralOnlyNounPhrase(possessive):
    possessiveAdjPhrase->poss_ indetPluralOnlyNounPhrase->np_
    : PossessivePluralProd
;

grammar explicitDetPluralOnlyNounPhrase(possessiveNumber):
    possessiveAdjPhrase->poss_ numberPhrase->quant_
    indetPluralNounPhrase->np_
    : ExactQuantifiedPossessivePluralProd
;


/* ------------------------------------------------------------------------ */
/*
 *   An indeterminate plural noun phrase.
 *
 *   For the basic indeterminate plural phrase, allow an adjective phrase
 *   anywhere a plural phrase is allowed; this makes possible the
 *   short-hand of omitting a plural word when the plural number is
 *   unambiguous from context.
 */

/* a simple plural noun phrase */
grammar indetPluralNounPhrase(basic):
    pluralPhrase->np_ | adjPhrase->np_
    : LayeredNounPhraseProd
;

/*
 *   A plural noun phrase with a locational qualifier.  Note that even
 *   though the overall phrase is plural (and so the main underlying noun
 *   phrase is plural), the location phrase itself must always be singular.
 */
grammar indetPluralNounPhrase(locational):
    (pluralPhrase->np_ | adjPhrase->np_) ('die'| ) ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('sind'|'waren'|)
    (pluralPhrase->np_ | adjPhrase->np_) 'die' 'sich' ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('befinden'|'befanden')
    : ContainerNounPhraseProd
;

/*
 *   An indetermine plural noun phrase with only explicit plural phrases.
 */
grammar indetPluralOnlyNounPhrase(basic):
    pluralPhrase->np_
    : LayeredNounPhraseProd
;

grammar indetPluralOnlyNounPhrase(locational):
    pluralPhrase->np_ ('die'| ) ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('sind'|'waren'|)
    pluralPhrase->np_ 'die' 'sich' ('in'|'auf'|'an')
    completeNounPhraseWithoutAll->cont_ ('befinden'|'befanden')
    : ContainerNounPhraseProd
;

/* ------------------------------------------------------------------------ */
/*
 *   Noun Phrase.  This is the basic noun phrase, which serves as a
 *   building block for complete noun phrases.  This type of noun phrase
 *   can be qualified with articles, quantifiers, and possessives, and can
 *   be used to construct possessives via the addition of "'s" at the end
 *   of the phrase.
 *   
 *   In most cases, custom noun phrase rules should be added to this
 *   production, as long as qualification (with numbers, articles, and
 *   possessives) is allowed.  For a custom noun phrase rule that cannot be
 *   qualified, a completeNounPhrase rule should be added instead.  
 */
grammar nounPhrase(main): compoundNounPhrase->np_
    : LayeredNounPhraseProd
;

/*
 *   Plural phrase.  This is the basic plural phrase, and corresponds to
 *   the basic nounPhrase for plural forms.
 */
grammar pluralPhrase(main): compoundPluralPhrase->np_
    : LayeredNounPhraseProd
;

/* ------------------------------------------------------------------------ */
/*
 *   Compound noun phrase.  This is one or more noun phrases connected with
 *   'of', as in "piece of paper".  The part after the 'of' is another
 *   compound noun phrase.
 *   
 *   Note that this general rule does not allow the noun phrase after the
 *   'of' to be qualified with an article or number, except that we make an
 *   exception to allow a definite article.  Other cases ("a piece of four
 *   papers") do not generally make sense, so we won't attempt to support
 *   them; instead, games can add as special cases new nounPhrase rules for
 *   specific literal sequences where more complex grammar is necessary.  
 */
grammar compoundNounPhrase(simple): simpleNounPhrase->np_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        return np_.getVocabMatchList(resolver, results, extraFlags);
    }
    getAdjustedTokens()
    {
        return np_.getAdjustedTokens();
    }
;

// We leave the original phrase intact, as the author might want to talk
// to the 'Prince of Wales'

grammar compoundNounPhrase(of):
    simpleNounPhrase->np1_ 'of'->of_ compoundNounPhrase->np2_
    | simpleNounPhrase->np1_ 'of'->of_ 'the'->the_ compoundNounPhrase->np2_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst1;
        local lst2;

        /* resolve the two underlying lists */
        lst1 = np1_.getVocabMatchList(resolver, results, extraFlags);
        lst2 = np2_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   the result is the intersection of the two lists, since we
         *   want the list of objects with all of the underlying
         *   vocabulary words
         */
        return intersectNounLists(lst1, lst2);
    }
    getAdjustedTokens()
    {
        local ofLst;

        /* generate the 'of the' list from the original words */
        if (the_ == nil)
            ofLst = [of_, &miscWord];
        else
            ofLst = [of_, &miscWord, the_, &miscWord];

        /* return the full list */
        return np1_.getAdjustedTokens() + ofLst + np2_.getAdjustedTokens();
    }
;

// This phrase handles objects like 'Baron von Richthofen' or
// even 'Walther von der Vogelweide'

grammar compoundNounPhrase(von):
    simpleNounPhrase->np1_ 'von'->of_ compoundNounPhrase->np2_
    | simpleNounPhrase->np1_ 'von'->of_ 'der'->the_ compoundNounPhrase->np2_
    | simpleNounPhrase->np1_ 'von'->of_ 'den'->the_ compoundNounPhrase->np2_
    | simpleNounPhrase->np1_ 'von'->of_ 'dem'->the_ compoundNounPhrase->np2_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst1;
        local lst2;

        /* resolve the two underlying lists */
        lst1 = np1_.getVocabMatchList(resolver, results, extraFlags);
        lst2 = np2_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   the result is the intersection of the two lists, since we
         *   want the list of objects with all of the underlying
         *   vocabulary words
         */
        return intersectNounLists(lst1, lst2);
    }
    getAdjustedTokens()
    {
        local ofLst;

        /* generate the 'of the' list from the original words */
        if (the_ == nil)
            ofLst = [of_, &miscWord];
        else
            ofLst = [of_, &miscWord, the_, &miscWord];

        /* return the full list */
        return np1_.getAdjustedTokens() + ofLst + np2_.getAdjustedTokens();
    }
;

// This phrase handles objects like 'Ludwig der Zweite'

grammar compoundNounPhrase(der):
    simpleNounPhrase->np1_ 'der'->of_ compoundNounPhrase->np2_
    | simpleNounPhrase->np1_ 'die'->of_ compoundNounPhrase->np2_
    | simpleNounPhrase->np1_ 'das'->of_ compoundNounPhrase->np2_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst1;
        local lst2;

        /* resolve the two underlying lists */
        lst1 = np1_.getVocabMatchList(resolver, results, extraFlags);
        lst2 = np2_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   the result is the intersection of the two lists, since we
         *   want the list of objects with all of the underlying
         *   vocabulary words
         */
        return intersectNounLists(lst1, lst2);
    }
    getAdjustedTokens()
    {
        local ofLst;

        /* generate the 'of the' list from the original words */
        ofLst = [of_, &miscWord];

        /* return the full list */
        return np1_.getAdjustedTokens() + ofLst + np2_.getAdjustedTokens();
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Compound plural phrase - same as a compound noun phrase, but involving
 *   a plural part before the 'of'.  
 */

/*
 *   just a single plural phrase
 */
grammar compoundPluralPhrase(simple): simplePluralPhrase->np_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        return np_.getVocabMatchList(resolver, results, extraFlags);
    }
    getAdjustedTokens()
    {
        return np_.getAdjustedTokens();
    }
;

// We leave the original phrase intact, as the author might want to talk
// to the 'Earls of Wales'

/*
 *   <plural-phrase> of <noun-phrase>
 */
grammar compoundPluralPhrase(of):
    simplePluralPhrase->np1_ 'of'->of_ compoundNounPhrase->np2_
    | simplePluralPhrase->np1_ 'of'->of_ 'the'->the_ compoundNounPhrase->np2_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst1;
        local lst2;

        /* resolve the two underlying lists */
        lst1 = np1_.getVocabMatchList(resolver, results, extraFlags);
        lst2 = np2_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   the result is the intersection of the two lists, since we
         *   want the list of objects with all of the underlying
         *   vocabulary words
         */
        return intersectNounLists(lst1, lst2);
    }
    getAdjustedTokens()
    {
        local ofLst;

        /* generate the 'of the' list from the original words */
        if (the_ == nil)
            ofLst = [of_, &miscWord];
        else
            ofLst = [of_, &miscWord, the_, &miscWord];

        /* return the full list */
        return np1_.getAdjustedTokens() + ofLst + np2_.getAdjustedTokens();
    }
;

// This phrase handles plural objects like 'Völker von Mittelerde' 

grammar compoundPluralPhrase(von):
    simplePluralPhrase->np1_ 'von'->of_ compoundNounPhrase->np2_
    | simplePluralPhrase->np1_ 'von'->of_ 'der'->the_ compoundNounPhrase->np2_
    | simplePluralPhrase->np1_ 'von'->of_ 'den'->the_ compoundNounPhrase->np2_
    | simplePluralPhrase->np1_ 'von'->of_ 'dem'->the_ compoundNounPhrase->np2_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst1;
        local lst2;

        /* resolve the two underlying lists */
        lst1 = np1_.getVocabMatchList(resolver, results, extraFlags);
        lst2 = np2_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   the result is the intersection of the two lists, since we
         *   want the list of objects with all of the underlying
         *   vocabulary words
         */
        return intersectNounLists(lst1, lst2);
    }
    getAdjustedTokens()
    {
        local ofLst;

        /* generate the 'of the' list from the original words */
        if (the_ == nil)
            ofLst = [of_, &miscWord];
        else
            ofLst = [of_, &miscWord, the_, &miscWord];

        /* return the full list */
        return np1_.getAdjustedTokens() + ofLst + np2_.getAdjustedTokens();
    }
;

// This phrase handles objects like 'Abgeordnete der Marsianer'

grammar compoundPluralPhrase(der):
    simplePluralPhrase->np1_ 'der'->of_ compoundNounPhrase->np2_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst1;
        local lst2;

        /* resolve the two underlying lists */
        lst1 = np1_.getVocabMatchList(resolver, results, extraFlags);
        lst2 = np2_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   the result is the intersection of the two lists, since we
         *   want the list of objects with all of the underlying
         *   vocabulary words
         */
        return intersectNounLists(lst1, lst2);
    }
    getAdjustedTokens()
    {
        local ofLst;

        /* generate the 'of the' list from the original words */
        ofLst = [of_, &miscWord];

        /* return the full list */
        return np1_.getAdjustedTokens() + ofLst + np2_.getAdjustedTokens();
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Simple noun phrase.  This is the most basic noun phrase, which is
 *   simply a noun, optionally preceded by one or more adjectives.
 */

/*
 *   just a noun
 */
grammar simpleNounPhrase(noun): nounWord->noun_ : NounPhraseWithVocab
    /* generate a list of my resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        return noun_.getVocabMatchList(resolver, results, extraFlags);
    }
    getAdjustedTokens()
    {
        return noun_.getAdjustedTokens();
    }
;

/*
 *   <adjective> <simple-noun-phrase> (this allows any number of adjectives
 *   to be applied) 
 */
grammar simpleNounPhrase(adjNP): adjWord->adj_ simpleNounPhrase->np_
    : NounPhraseWithVocab

    /* generate a list of my resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        /*
         *   return the list of objects in scope matching our adjective
         *   plus the list from the underlying noun phrase
         */
        return intersectNounLists(
            adj_.getVocabMatchList(resolver, results, extraFlags),
            np_.getVocabMatchList(resolver, results, extraFlags));
    }
    getAdjustedTokens()
    {
        return adj_.getAdjustedTokens() + np_.getAdjustedTokens();
    }
;

/*
 *   A simple noun phrase can also include a number or a quoted string
 *   before or after a noun.  A number can be spelled out or written with
 *   numerals; we consider both forms equivalent in meaning.
 *   
 *   A number in this type of usage is grammatically equivalent to an
 *   adjective - it's not meant to quantify the rest of the noun phrase,
 *   but rather is simply an adjective-like modifier.  For example, an
 *   elevator's control panel might have a set of numbered buttons which we
 *   want to refer to as "button 1," "button 2," and so on.  It is
 *   frequently the case that numeric adjectives are equally at home before
 *   or after their noun: "push 3 button" or "push button 3".  In addition,
 *   we accept a number by itself as a lone adjective, as in "push 3".  
 */

/*
 *   just a numeric/string adjective (for things like "push 3", "push #3",
 *   'push "G"')
 */
grammar simpleNounPhrase(number): literalAdjPhrase->adj_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /*
         *   note that this counts as an adjective-ending phrase, since we
         *   don't have a noun involved
         */
        results.noteAdjEnding();

        /* pass through to the underlying literal adjective phrase */
        local lst = adj_.getVocabMatchList(resolver, results,
                                           extraFlags | EndsWithAdj);

        /* if in global scope, also try a noun interpretation */
        if (resolver.isGlobalScope)
            lst = adj_.addNounMatchList(lst, resolver, results, extraFlags);

        /* return the result */
        return lst;
    }
    getAdjustedTokens()
    {
        /* pass through to the underlying literal adjective phrase */
        return adj_.getAdjustedTokens();
    }
;

/*
 *   <literal-adjective> <noun> (for things like "board 44 bus" or 'push
 *   "G" button')
 */
grammar simpleNounPhrase(numberAndNoun):
    literalAdjPhrase->adj_ nounWord->noun_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local nounList;
        local adjList;

        /* get the list of objects matching the rest of the noun phrase */
        nounList = noun_.getVocabMatchList(resolver, results, extraFlags);

        /* get the list of objects matching the literal adjective */
        adjList = adj_.getVocabMatchList(resolver, results, extraFlags);

        /* intersect the two lists and return the results */
        return intersectNounLists(nounList, adjList);
    }
    getAdjustedTokens()
    {
        return adj_.getAdjustedTokens() + noun_.getAdjustedTokens();
    }
;

/*
 *   <noun> <literal-adjective> (for things like "press button 3" or 'put
 *   tab "A" in slot "B"')
 */
grammar simpleNounPhrase(nounAndNumber):
    nounWord->noun_ literalAdjPhrase->adj_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local nounList;
        local adjList;

        /* get the list of objects matching the rest of the noun phrase */
        nounList = noun_.getVocabMatchList(resolver, results, extraFlags);

        /* get the literal adjective matches */
        adjList = adj_.getVocabMatchList(resolver, results, extraFlags);

        /* intersect the two lists and return the results */
        return intersectNounLists(nounList, adjList);
    }
    getAdjustedTokens()
    {
        return noun_.getAdjustedTokens() + adj_.getAdjustedTokens();
    }
;

/*
 *   A simple noun phrase can also end in an adjective, which allows
 *   players to refer to objects using only their unique adjectives rather
 *   than their full names, which is sometimes more convenient: just "take
 *   gold" rather than "take gold key."
 *   
 *   When a particular phrase can be interpreted as either ending in an
 *   adjective or ending in a noun, we will always take the noun-ending
 *   interpretation - in such cases, the adjective-ending interpretation is
 *   probably a weak binding.  For example, "take pizza" almost certainly
 *   refers to the pizza itself when "pizza" and "pizza box" are both
 *   present, but it can also refer just to the box when no pizza is
 *   present.
 *   
 *   Equivalent to a noun phrase ending in an adjective is a noun phrase
 *   ending with an adjective followed by "one," as in "the red one."  
 */
grammar simpleNounPhrase(adj): adjWord->adj_ : NounPhraseWithVocab
    /* generate a list of my resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* note in the results that we end in an adjective */
        results.noteAdjEnding();

        /* generate a list of objects matching the adjective */
        local lst = adj_.getVocabMatchList(
            resolver, results, extraFlags | EndsWithAdj);

        /* if in global scope, also try a noun interpretation */
        if (resolver.isGlobalScope)
            lst = adj_.addNounMatchList(lst, resolver, results, extraFlags);

        /* return the result */
        return lst;
    }
    getAdjustedTokens()
    {
        /* return the adjusted token list for the adjective */
        return adj_.getAdjustedTokens();
    }
;

grammar simpleNounPhrase(adjAndOne): adjective->adj_ 'davon'
    : NounPhraseWithVocab
    /* generate a list of my resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        /*
         *   This isn't exactly an adjective ending, but consider it as
         *   such anyway, since we're not matching 'one' to a vocabulary
         *   word - we're just using it as a grammatical marker that we're
         *   not providing a real noun.  If there's another match for
         *   which 'one' is a noun, that one is definitely preferred to
         *   this one; the adj-ending marking will ensure that we choose
         *   the other one.
         */
        results.noteAdjEnding();

        /* generate a list of objects matching the adjective */
        return getWordMatches(adj_, &adjective, resolver,
                              extraFlags | EndsWithAdj, VocabTruncated);
    }
    getAdjustedTokens()
    {
        return [adj_, &adjective];
    }
;

/*
 *   In the worst case, a simple noun phrase can be constructed from
 *   arbitrary words that don't appear in our dictionary.
 */
grammar simpleNounPhrase(misc):
    [badness 200] miscWordList->lst_ : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* get the match list from the underlying list */
        local lst = lst_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   If there are no matches, note in the results that we have an
         *   arbitrary word list.  Note that we do this only if there are
         *   no matches, because we might match non-dictionary words to an
         *   object with a wildcard in its vocabulary words, in which case
         *   this is a valid, matching phrase after all.
         */
        if (lst == nil || lst.length() == 0)
            results.noteMiscWordList(lst_.getOrigText());

        /* return the match list */
        return lst;
    }
    getAdjustedTokens()
    {
        return lst_.getAdjustedTokens();
    }
;

/*
 *   If the command has qualifiers but omits everything else, we can have
 *   an empty simple noun phrase.
 */
grammar simpleNounPhrase(empty): [badness 600] : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* we have an empty noun phrase */
        return results.emptyNounPhrase(resolver);
    }
    getAdjustedTokens()
    {
        return [];
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   An AdjPhraseWithVocab is an English-specific subclass of
 *   NounPhraseWithVocab, specifically for noun phrases that contain
 *   entirely adjectives.  
 */
class AdjPhraseWithVocab: NounPhraseWithVocab
    /* the property for the adjective literal - this is usually adj_ */
    adjVocabProp = &adj_

    /* 
     *   Add the vocabulary matches that we'd get if we were treating our
     *   adjective as a noun.  This combines the noun interpretation with a
     *   list of matches we got for the adjective version.  
     */
    addNounMatchList(lst, resolver, results, extraFlags)
    {
        /* get the word matches with a noun interpretation of our adjective */
        local nLst = getWordMatches(
            self.(adjVocabProp), &noun, resolver, extraFlags, VocabTruncated);

        /* combine the lists and return the result */
        return combineWordMatches(lst, nLst);
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   A "literal adjective" phrase is a number or string used as an
 *   adjective.
 */
grammar literalAdjPhrase(number):
    numberPhrase->num_ | poundNumberPhrase->num_
    : AdjPhraseWithVocab

    adj_ = (num_.getStrVal())
    getVocabMatchList(resolver, results, extraFlags)
    {
        local numList;

        /*
         *   get the list of objects matching the numeral form of the
         *   number as an adjective
         */
        numList = getWordMatches(num_.getStrVal(), &adjective,
                                 resolver, extraFlags, VocabTruncated);

        /* add the list of objects matching the special '#' wildcard */
        numList += getWordMatches('#', &adjective, resolver,
                                  extraFlags, VocabTruncated);

        /* return the combined lists */
        return numList;
    }
    getAdjustedTokens()
    {
        return [num_.getStrVal(), &adjective];
    }
;

grammar literalAdjPhrase(string): quotedStringPhrase->str_
    : AdjPhraseWithVocab

    adj_ = (str_.getStringText().toLower())
    getVocabMatchList(resolver, results, extraFlags)
    {
        local strList;
        local wLst;

        /*
         *   get the list of objects matching the string with the quotes
         *   removed
         */
        strList = getWordMatches(str_.getStringText().toLower(),
                                 &literalAdjective,
                                 resolver, extraFlags, VocabTruncated);

        /* add the list of objects matching the literal-adjective wildcard */
        wLst = getWordMatches('\u0001', &literalAdjective, resolver,
                              extraFlags, VocabTruncated);
        strList = combineWordMatches(strList, wLst);

        /* return the combined lists */
        return strList;
    }
    getAdjustedTokens()
    {
        return [str_.getStringText().toLower(), &adjective];
    }
;

/*
 *   In many cases, we might want to write what is semantically a literal
 *   string qualifier without the quotes.  For example, we might want to
 *   refer to an elevator button that's labeled "G" as simply "button G",
 *   without any quotes around the "G".  To accommodate these cases, we
 *   provide the literalAdjective part-of-speech.  We'll match these parts
 *   of speech the same way we'd match them if they were quoted.
 */
grammar literalAdjPhrase(literalAdj): literalAdjective->adj_
    : AdjPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst;

        /* get a list of objects in scope matching our literal adjective */
        lst = getWordMatches(adj_, &literalAdjective, resolver,
                             extraFlags, VocabTruncated);

        /* if the scope is global, also include ordinary adjective matches */
        if (resolver.isGlobalScope)
        {
            /* get the ordinary adjective bindings */
            local aLst = getWordMatches(adj_, &adjective, resolver,
                                        extraFlags, VocabTruncated);

            /* global scope - combine the lists */
            lst = combineWordMatches(lst, aLst);
        }

        /* return the result */
        return lst;
    }
    getAdjustedTokens()
    {
        return [adj_, &literalAdjective];
    }
;


/* ------------------------------------------------------------------------ */
/*
 *   A noun word.  This can be either a simple 'noun' vocabulary word, or
 *   it can be an abbreviated noun with a trailing abbreviation period.
 */
class NounWordProd: NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local w;
        local nLst;

        /* get our word text */
        w = getNounText();

        /* get the list of matches as nouns */
        nLst = getWordMatches(w, &noun, resolver, extraFlags, VocabTruncated);
        /*
         *   If the resolver indicates that we're in a "global" scope,
         *   *also* include any additional matches as adjectives.
         *
         *   Normally, when we're operating in limited, local scopes, we
         *   use the structure of the phrasing to determine whether to
         *   match a noun or adjective; if we have a match for a given word
         *   as a noun, we'll treat it only as a noun.  This allows us to
         *   take PIZZA to refer to the pizza (for which 'pizza' is defined
         *   as a noun) rather than to the PIZZA BOX (for which 'pizza' is
         *   a mere adjective) when both are in scope.  It's obvious which
         *   the player means in such cases, so we can be smart about
         *   choosing the stronger match.
         *
         *   In cases of global scope, though, it's much harder to guess
         *   about the player's intentions.  When the player types PIZZA,
         *   they might be thinking of the box even though there's a pizza
         *   somewhere else in the game.  Since the two objects might be in
         *   entirely different locations, both out of view, we can't
         *   assume that one or the other is more likely on the basis of
         *   which is closer to the player's senses.  So, it's better to
         *   allow both to match for now, and decide later, based on the
         *   context of the command, which was actually meant.
         */
        if (resolver.isGlobalScope)
        {
            /* get the list of matching adjectives */
            local aLst = getWordMatches(w, &adjective, resolver,
                                        extraFlags, VocabTruncated);

            /* combine it with the noun list */
            nLst = combineWordMatches(nLst, aLst);
        }

        /* return the match list */
        return nLst;
    }
    getAdjustedTokens()
    {
        /* the noun includes the period as part of the literal text */
        return [getNounText(), &noun];
    }

    /* the actual text of the noun to match to the dictionary */
    getNounText() { return noun_; }
;

// ##### new MALE SYN WORD PROD #####

class MaleSynWordProd: NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local w;
        local i;
        local j;
        local nLst;
        local match;
        local check;

        /* get our word text */
        w = getNounText();

        /* get the list of matches as nouns */
        nLst = getWordMatches(w, &maleSyn, resolver, extraFlags, VocabTruncated);
        
        if (nLst.length() > 0)
        {
            for (i = 1; i <= nLst.length(); i++)
            {
                match = getNounText();
                check = cmdDict.findWord(match, &maleSyn);
                for (j = 1; j <= check.length(); j = j + 2) //2 Addieren, weil Liste 2 Einträge hat (Objekt an 1. Stelle)
                {
                    check[j].maleSynFlag = true;
                }
            }

        }
            
        /*
         *   If the resolver indicates that we're in a "global" scope,
         *   *also* include any additional matches as adjectives.
         *
         *   Normally, when we're operating in limited, local scopes, we
         *   use the structure of the phrasing to determine whether to
         *   match a noun or adjective; if we have a match for a given word
         *   as a noun, we'll treat it only as a noun.  This allows us to
         *   take PIZZA to refer to the pizza (for which 'pizza' is defined
         *   as a noun) rather than to the PIZZA BOX (for which 'pizza' is
         *   a mere adjective) when both are in scope.  It's obvious which
         *   the player means in such cases, so we can be smart about
         *   choosing the stronger match.
         *
         *   In cases of global scope, though, it's much harder to guess
         *   about the player's intentions.  When the player types PIZZA,
         *   they might be thinking of the box even though there's a pizza
         *   somewhere else in the game.  Since the two objects might be in
         *   entirely different locations, both out of view, we can't
         *   assume that one or the other is more likely on the basis of
         *   which is closer to the player's senses.  So, it's better to
         *   allow both to match for now, and decide later, based on the
         *   context of the command, which was actually meant.
         */
        if (resolver.isGlobalScope)
        {
            /* get the list of matching adjectives */
            local aLst = getWordMatches(w, &adjective, resolver,
                                        extraFlags, VocabTruncated);

            /* combine it with the noun list */
            nLst = combineWordMatches(nLst, aLst);
        }

        /* return the match list */
        return nLst;
    }
    getAdjustedTokens()
    {
        /* the noun includes the period as part of the literal text */
        return [getNounText(), &maleSyn];
    }

    /* the actual text of the noun to match to the dictionary */
    getNounText() { return noun_; }
;

// ##### new FEMALE SYN WORD PROD #####

class FemaleSynWordProd: NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local w;
        local i;
        local j;
        local nLst;
        local match;
        local check;

        /* get our word text */
        w = getNounText();

        /* get the list of matches as nouns */
        nLst = getWordMatches(w, &femaleSyn, resolver, extraFlags, VocabTruncated);
        
        if (nLst.length() > 0)
        {
            for (i = 1; i <= nLst.length(); i++)
            {
                match = getNounText();
                check = cmdDict.findWord(match, &femaleSyn);
                for (j = 1; j <= check.length(); j = j + 2) //2 Addieren, weil Liste 2 Einträge hat (Objekt an 1. Stelle)
                {
                    check[j].femaleSynFlag = true;
                }
            }

        }
            
        if (resolver.isGlobalScope)
        {
            /* get the list of matching adjectives */
            local aLst = getWordMatches(w, &adjective, resolver,
                                        extraFlags, VocabTruncated);

            /* combine it with the noun list */
            nLst = combineWordMatches(nLst, aLst);
        }

        /* return the match list */
        return nLst;
    }
    getAdjustedTokens()
    {
        /* the noun includes the period as part of the literal text */
        return [getNounText(), &femaleSyn];
    }

    /* the actual text of the noun to match to the dictionary */
    getNounText() { return noun_; }
;

// -- ##### new NEUTER SYN WORD PROD #####

class NeuterSynWordProd: NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local w;
        local i;
        local j;
        local nLst;
        local match;
        local check;

        /* get our word text */
        w = getNounText();

        /* get the list of matches as nouns */
        nLst = getWordMatches(w, &neuterSyn, resolver, extraFlags, VocabTruncated);
        
        if (nLst.length() > 0)
        {
            // "... Neuter Syn found ...";
            for (i = 1; i <= nLst.length(); i++)
            {
                match = getNounText();
                check = cmdDict.findWord(match, &neuterSyn);
                for (j = 1; j <= check.length(); j = j + 2) //2 Addieren, weil Liste 2 Einträge hat (Objekt an 1. Stelle)
                {
                    check[j].neuterSynFlag = true;
                }
            }

        }

        if (resolver.isGlobalScope)
        {
            /* get the list of matching adjectives */
            local aLst = getWordMatches(w, &adjective, resolver,
                                        extraFlags, VocabTruncated);

            /* combine it with the noun list */
            nLst = combineWordMatches(nLst, aLst);
        }

        /* return the match list */
        return nLst;
    }
    getAdjustedTokens()
    {
        /* the noun includes the period as part of the literal text */
        return [getNounText(), &neuterSyn];
    }

    /* the actual text of the noun to match to the dictionary */
    getNounText() { return noun_; }
;

// ##### new PLURAL SYN WORD PROD #####

class PluralSynWordProd: NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        local w;
        local i;
        local j;
        local nLst;
        local match;
        local check;

        /* get our word text */
        w = getNounText();

        /* get the list of matches as nouns */
        nLst = getWordMatches(w, &pluralSyn, resolver, extraFlags, VocabTruncated);
        
        if (nLst.length() > 0)
        {
            //"... Plural Syn found ...";
            for (i = 1; i <= nLst.length(); i++)
            {
                match = getNounText();
                check = cmdDict.findWord(match, &pluralSyn);
                for (j = 1; j <= check.length(); j = j + 2) //2 Addieren, weil Liste 2 Einträge hat (Objekt an 1. Stelle)
                {
                    check[j].pluralSynFlag = true;
                }
            }
        }
            
        if (resolver.isGlobalScope)
        {
            /* get the list of matching adjectives */
            local aLst = getWordMatches(w, &adjective, resolver,
                                        extraFlags, VocabTruncated);

            /* combine it with the noun list */
            nLst = combineWordMatches(nLst, aLst);
        }

        /* return the match list */
        return nLst;
    }
    getAdjustedTokens()
    {
        /* the noun includes the period as part of the literal text */
        return [getNounText(), &pluralSyn];
    }

    /* the actual text of the noun to match to the dictionary */
    getNounText() { return noun_; }
;

// ######################################################
// ## GRAMMAR RULES FOR ALL SYNONYMS (Changing gender) ##
// ######################################################

grammar nounWord(maleSyn): maleSyn->noun_ : MaleSynWordProd
;
grammar nounWord(femaleSyn): femaleSyn->noun_ : FemaleSynWordProd
;
grammar nounWord(neuterSyn): neuterSyn->noun_ : NeuterSynWordProd
;
grammar nounWord(pluralSyn): pluralSyn->noun_ : PluralSynWordProd
;

grammar nounWord(noun): noun->noun_ : NounWordProd
;

grammar nounWord(nounAbbr): noun->noun_ tokAbbrPeriod->period_
    : NounWordProd

    /*
     *   for dictionary matching purposes, include the text of our noun
     *   with the period attached - the period is part of the dictionary
     *   entry for an abbreviated word
     */
    getNounText() { return noun_ + period_; }
;

/* ------------------------------------------------------------------------ */
/*
 *   An adjective word.  This can be either a simple 'adjective' vocabulary
 *   word, or it can be an 'adjApostS' vocabulary word plus a 's token.  
 */
grammar adjWord(adj): adjective->adj_ : AdjPhraseWithVocab
    /* generate a list of resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* return a list of objects in scope matching our adjective */
        return getWordMatches(adj_, &adjective, resolver,
                              extraFlags, VocabTruncated);
    }
    getAdjustedTokens()
    {
        return [adj_, &adjective];
    }
;

grammar adjWord(adjApostS): adjApostS->adj_ tokApostropheS->apost_
    : AdjPhraseWithVocab
    /* generate a list of resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* return a list of objects in scope matching our adjective */
        return getWordMatches(adj_, &adjApostS, resolver,
                              extraFlags, VocabTruncated);
    }
    getAdjustedTokens()
    {
        return [adj_, &adjApostS];
    }
;

grammar adjWord(adjAbbr): adjective->adj_ tokAbbrPeriod->period_
    : AdjPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /*
         *   return the list matching our adjective *with* the period
         *   attached; the period is part of the dictionary entry for an
         *   abbreviated word
         */
        return getWordMatches(adj_ + period_, &adjective, resolver,
                              extraFlags, VocabTruncated);
    }
    getAdjustedTokens()
    {
        /* the adjective includes the period as part of the literal text */
        return [adj_ + period_, &adjective];
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Possessive phrase.  This is a noun phrase expressing ownership of
 *   another object.
 *   
 *   Note that all possessive phrases that can possibly be ambiguous must
 *   define getOrigMainText() to return the "main noun phrase" text.  In
 *   English, this means that we must omit any "'s" suffix.  This is needed
 *   only when the phrase can be ambiguous, so pronouns don't need it since
 *   they are inherently unambiguous.  
 */
grammar possessiveAdjPhrase(its): ('ihr'|'ihre'|'ihren'|'ihrem') : ItsAdjProd
    /* we only agree with a singular ungendered noun */
    checkAnaphorAgreement(lst)
        { return lst.length() == 1 && lst[1].obj_.canMatchIt; }
;
grammar possessiveAdjPhrase(his): ('sein'|'seine'|'seinen'|'seinem') : HisAdjProd
    /* we only agree with a singular masculine noun */
    checkAnaphorAgreement(lst)
        { return lst.length() == 1 && lst[1].obj_.canMatchHim; }
;
grammar possessiveAdjPhrase(her): ('ihr'|'ihre'|'ihren'|'ihrem') : HerAdjProd
    /* we only agree with a singular feminine noun */
    checkAnaphorAgreement(lst)
        { return lst.length() == 1 && lst[1].obj_.canMatchHer; }
;
grammar possessiveAdjPhrase(their): ('ihre'|'ihre'|'ihren'|'ihrem') : TheirAdjProd
    /* we only agree with a single noun that has plural usage */
    checkAnaphorAgreement(lst)
        { return lst.length() == 1 && lst[1].obj_.isPlural; }
;
grammar possessiveAdjPhrase(your): ('dein'|'deine'|'deinen'|'deinem') : YourAdjProd 
    /* we are non-anaphoric */
    checkAnaphorAgreement(lst) { return nil; }
;
grammar possessiveAdjPhrase(my): ('mein'|'meine'|'meinen'|'meinem') : MyAdjProd 
    /* we are non-anaphoric */
    checkAnaphorAgreement(lst) { return nil; }
;

// ################################################################################
// Note that in German we have Klaus' Schuhe also in any singular possessive phrase
// which has an owner's name ending in 's'
// ################################################################################

grammar possessiveAdjPhrase(npApostropheS):
    ('den'|'die'|'das'| ) nounPhrase->np_ 
        (tokApostropheS->apost_ | tokPluralApostrophe->apost_) : LayeredNounPhraseProd

    /* get the original text without the "'s" suffix */
    getOrigMainText()
    {
        /* return just the basic noun phrase part */
        return np_.getOrigText();
    }
;

grammar possessiveAdjPhrase(ppApostropheS):
    ('den'|'die'|'das'| ) pluralPhrase->np_ 
       (tokApostropheS->apost_ | tokPluralApostrophe->apost_)
    : LayeredNounPhraseProd

    /* get the original text without the "'s" suffix */
    getOrigMainText()
    {
        /* return just the basic noun phrase part */
        return np_.getOrigText();
    }

    resolveNouns(resolver, results)
    {
        /* note that we have a plural phrase, structurally speaking */
        results.notePlural();

        /* inherit the default handling */
        return inherited(resolver, results);
    }

    /* the possessive phrase is plural */
    isPluralPossessive = true
;

/*
 *   Possessive noun phrases.  These are similar to possessive phrases, but
 *   are stand-alone phrases that can act as nouns rather than as
 *   qualifiers for other noun phrases.  For example, for a first-person
 *   player character, "mine" would be a possessive noun phrase referring
 *   to an object owned by the player character.
 *   
 *   Note that many of the words used for possessive nouns are the same as
 *   for possessive adjectives - for example "his" is the same in either
 *   case, as are "'s" words.  However, we make the distinction internally
 *   because the two have different grammatical uses, and some of the words
 *   do differ ("her" vs "hers", for example).  
 */
grammar possessiveNounPhrase(its): 'sein' | 'seine' | 'seinen' | 'seinem': ItsNounProd;
grammar possessiveNounPhrase(his): 'sein' | 'seine' | 'seinen' | 'seinem': HisNounProd;
grammar possessiveNounPhrase(hers): 'ihr'| 'ihre' | 'ihren' | 'ihrem': HersNounProd;
grammar possessiveNounPhrase(theirs): 'ihre' | 'ihre' | 'ihren' | 'ihrem': TheirsNounProd;
grammar possessiveNounPhrase(yours): 'dein' | 'deine' | 'deinen' | 'deinem':  YoursNounProd;
grammar possessiveNounPhrase(mine): 'mein' | 'meine' | 'meinen' | 'meinem':  MineNounProd;

grammar possessiveNounPhrase(npApostropheS):
    ('den'|'die'|'das'| )
    (nounPhrase->np_ (tokApostropheS->apost_ | tokPluralApostrophe->apost_)
     | pluralPhrase->np (tokApostropheS->apost_ | tokPluralApostrophe->apost_))
    : LayeredNounPhraseProd

    /* get the original text without the "'s" suffix */
    getOrigMainText()
    {
        /* return just the basic noun phrase part */
        return np_.getOrigText();
    }
;

// #################################
// Meinst du Jane's oder Jim's Nase?
// >die von Jim
// #################################

grammar possessiveNounPhrase(fromNp):
    ('den'|'die'|'das') ('von'|'an') nounPhrase->np_ 
        : LayeredNounPhraseProd

    /* get the original text without the "'s" suffix */
    getOrigMainText()
    {
        /* return just the basic noun phrase part */
        return np_.getOrigText();
    }
;

// ########################################
// Meinst du den schönen Hut des Müllmanns? 
// >den des Müllmanns
// ########################################

grammar possessiveNounPhrase(desNp):
    ('den'|'die'|'das'|) ('der'|'des') nounPhrase->np_ (tokApostropheS->apost_ | tokPluralApostrophe->apost_)
        : LayeredNounPhraseProd

    /* get the original text without the "'s" suffix */
    getOrigMainText()
    {
        /* return just the basic noun phrase part */
        return np_.getOrigText();
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Simple plural phrase.  This is the most basic plural phrase, which is
 *   simply a plural noun, optionally preceded by one or more adjectives.
 *   
 *   (English doesn't have any sort of adjective declension in number, so
 *   there's no need to distinguish between plural and singular adjectives;
 *   this equivalent rule in languages with adjective-noun agreement in
 *   number would use plural adjectives here as well as plural nouns.)  
 */
grammar simplePluralPhrase(plural): plural->plural_ : NounPhraseWithVocab
    /* generate a list of my resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        local lst;

        /* get the list of matching plurals */
        lst = getWordMatches(plural_, &plural, resolver,
                             extraFlags, PluralTruncated);

        /* get the list of matching 'noun' definitions */
        local nLst = getWordMatches(plural_, &noun, resolver,
                                    extraFlags, VocabTruncated);

        /* get the combined list */
        local comboLst = combineWordMatches(lst, nLst);

        /*
         *   If we're in global scope, add in the matches for just plain
         *   'noun' properties as well.  This is important because we'll
         *   sometimes want to define a word that's actually a plural
         *   usage (in terms of the real-world English) under the 'noun'
         *   property.  This occurs particularly when a single game-world
         *   object represents a multiplicity of real-world objects.  When
         *   the scope is global, it's hard to anticipate all of the
         *   possible interactions with vocabulary along these lines, so
         *   it's easiest just to include the 'noun' matches.
         */
        if (resolver.isGlobalScope)
        {
            /* keep the combined list */
            lst = comboLst;
        }
        else if (comboLst.length() > lst.length())
        {
            /*
             *   ordinary scope, so don't include the noun matches; but
             *   since we found extra items to add, at least mark the
             *   plural matches as potentially ambiguous
             */
            lst.forEach({x: x.flags_ |= UnclearDisambig});
        }

        /* return the result list */
        return lst;
    }
    getAdjustedTokens()
    {
        return [plural_, &plural];
    }
;

grammar simplePluralPhrase(adj): adjWord->adj_ simplePluralPhrase->np_ :
    NounPhraseWithVocab

    /* resolve my object list */
    getVocabMatchList(resolver, results, extraFlags)
    {
        /*
         *   return the list of objects in scope matching our adjective
         *   plus the list from the underlying noun phrase
         */
        return intersectNounLists(
            adj_.getVocabMatchList(resolver, results, extraFlags),
            np_.getVocabMatchList(resolver, results, extraFlags));
    }
    getAdjustedTokens()
    {
        return adj_.getAdjustedTokens() + np_.getAdjustedTokens();
    }
;

grammar simplePluralPhrase(poundNum):
    poundNumberPhrase->num_ simplePluralPhrase->np_
    : NounPhraseWithVocab

    /* resolve my object list */
    getVocabMatchList(resolver, results, extraFlags)
    {
        local baseList;
        local numList;

        /* get the base list for the rest of the phrase */
        baseList = np_.getVocabMatchList(resolver, results, extraFlags);

        /* get the numeric matches, including numeric wildcards */
        numList = getWordMatches(num_.getStrVal(), &adjective,
                                 resolver, extraFlags, VocabTruncated)
                  + getWordMatches('#', &adjective,
                                   resolver, extraFlags, VocabTruncated);

        /* return the intersection of the lists */
        return intersectNounLists(numList, baseList);
    }
    getAdjustedTokens()
    {
        return [num_.getStrVal(), &adjective] + np_.getAdjustedTokens();
    }
;

/*
 *   If the command has qualifiers that require a plural, but omits
 *   everything else, we can have an empty simple noun phrase.
 */
grammar simplePluralPhrase(empty): [badness 600] : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* we have an empty noun phrase */
        return results.emptyNounPhrase(resolver);
    }
    getAdjustedTokens()
    {
        return [];
    }
;

/*
 *   A simple plural phrase can match unknown words as a last resort.
 */
grammar simplePluralPhrase(misc):
    [badness 300] miscWordList->lst_ : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* get the match list from the underlying list */
        local lst = lst_.getVocabMatchList(resolver, results, extraFlags);

        /*
         *   if there are no matches, note in the results that we have an
         *   arbitrary word list that doesn't correspond to any object
         */
        if (lst == nil || lst.length() == 0)
            results.noteMiscWordList(lst_.getOrigText());

        /* return the vocabulary match list */
        return lst;
    }
    getAdjustedTokens()
    {
        return lst_.getAdjustedTokens();
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   An "adjective phrase" is a phrase made entirely of adjectives.
 */
grammar adjPhrase(adj): adjective->adj_ : AdjPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* note the adjective ending */
        results.noteAdjEnding();

        /* return the match list */
        local lst = getWordMatches(adj_, &adjective, resolver,
                                   extraFlags | EndsWithAdj, VocabTruncated);

        /* if in global scope, also try a noun interpretation */
        if (resolver.isGlobalScope)
            lst = addNounMatchList(lst, resolver, results, extraFlags);

        /* return the result */
        return lst;
    }

    getAdjustedTokens()
    {
        return [adj_, &adjective];
    }
;

grammar adjPhrase(adjAdj): adjective->adj_ adjPhrase->ap_
    : NounPhraseWithVocab
    /* generate a list of my resolved objects */
    getVocabMatchList(resolver, results, extraFlags)
    {
        /*
         *   return the list of objects in scope matching our adjective
         *   plus the list from the underlying adjective phrase
         */
        return intersectWordMatches(
            adj_, &adjective, resolver, extraFlags, VocabTruncated,
            ap_.getVocabMatchList(resolver, results, extraFlags));
    }
    getAdjustedTokens()
    {
        return [adj_, &adjective] + ap_.getAdjustedTokens();
    }
;


/* ------------------------------------------------------------------------ */
/*
 *   A "topic" is a special type of noun phrase used in commands like "ask
 *   <actor> about <topic>."  We define a topic as simply an ordinary
 *   single-noun phrase.  We distinguish this in the grammar to allow games
 *   to add special syntax for these.  
 */
grammar topicPhrase(main): singleNoun->np_ : TopicProd
;

/*
 *   Explicitly match a miscellaneous word list as a topic.
 *
 *   This might seem redundant with the ordinary topicPhrase that accepts a
 *   singleNoun, because singleNoun can match a miscellaneous word list.
 *   The difference is that singleNoun only matches a miscWordList with a
 *   "badness" value, whereas we match a miscWordList here without any
 *   badness.  We want to be more tolerant of unrecognized input in topic
 *   phrases than in ordinary noun phrases, because it's in the nature of
 *   topic phrases to go outside of what's implemented directly in the
 *   simulation model.  At a grammatical level, we don't want to treat
 *   topic phrases that we can resolve to the simulation model any
 *   differently than we treat those we can't resolve, so we must add this
 *   rule to eliminate the badness that singleNoun associated with a
 *   miscWordList match.
 *
 *   Note that we do prefer resolvable noun phrase matches to miscWordList
 *   matches, but we handle this preference with the resolver's scoring
 *   mechanism rather than with badness.
 */
grammar topicPhrase(misc): miscWordList->np_ : TopicProd
   resolveNouns(resolver, results)
   {
       /* note in the results that we have an arbitrary word list */
       results.noteMiscWordList(np_.getOrigText());

       /* inherit the default TopicProd behavior */
       return inherited(resolver, results);
   }
;

/* ------------------------------------------------------------------------ */
/*
 *   A "quoted string" phrase is a literal enclosed in single or double
 *   quotes.
 *
 *   Note that this is a separate production from literalPhrase.  This
 *   production can be used when *only* a quoted string is allowed.  The
 *   literalPhrase production allows both quoted and unquoted text.
 */
grammar quotedStringPhrase(main): tokString->str_ : LiteralProd
    /*
     *   get my string, with the quotes trimmed off (so we return simply
     *   the contents of the string)
     */
    getStringText() { return stripQuotesFrom(str_); }
;

/*
 *   Service routine: strip quotes from a *possibly* quoted string.  If the
 *   string starts with a quote, we'll remove the open quote.  If it starts
 *   with a quote and it ends with a corresponding close quote, we'll
 *   remove that as well.  
 */
stripQuotesFrom(str)
{
    local hasOpen;
    local hasClose;

    /* presume we won't find open or close quotes */
    hasOpen = hasClose = nil;

    /*
     *   Check for quotes.  We'll accept regular ASCII "straight" single
     *   or double quotes, as well as Latin-1 curly single or double
     *   quotes.  The curly quotes must be used in their normal
     */
    if (str.startsWith('\'') || str.startsWith('"'))
    {
        /* single or double quote - check for a matching close quote */
        hasOpen = true;
        hasClose = (str.length() > 2 && str.endsWith(str.substr(1, 1)));
    }
    else if (str.startsWith('`'))
    {
        /* single in-slanted quote - check for either type of close */
        hasOpen = true;
        hasClose = (str.length() > 2
                    && (str.endsWith('`') || str.endsWith('\'')));
    }
    else if (str.startsWith('\u201C'))
    {
        /* it's a curly double quote */
        hasOpen = true;
        hasClose = str.endsWith('\u201D');
    }
    else if (str.startsWith('\u2018'))
    {
        /* it's a curly single quote */
        hasOpen = true;
        hasClose = str.endsWith('\u2019');
    }

    /* trim off the quotes */
    if (hasOpen)
    {
        if (hasClose)
            str = str.substr(2, str.length() - 2);
        else
            str = str.substr(2);
    }

    /* return the modified text */
    return str;
}

/* ------------------------------------------------------------------------ */
/*
 *   A "literal" is essentially any phrase.  This can include a quoted
 *   string, a number, or any set of word tokens.
 */
grammar literalPhrase(string): quotedStringPhrase->str_ : LiteralProd
    getLiteralText(results, action, which)
    {
        /* get the text from our underlying quoted string */
        return str_.getStringText();
    }

    getTentativeLiteralText()
    {
        /*
         *   our result will never change, so our tentative text is the
         *   same as our regular literal text
         */
        return str_.getStringText();
    }

    resolveLiteral(results)
    {
        /* flag the literal text */
        results.noteLiteral(str_.getOrigText());
    }
;

grammar literalPhrase(miscList): miscWordList->misc_ : LiteralProd
    getLiteralText(results, action, which)
    {
        /* get my original text */
        local txt = misc_.getOrigText();

        /*
         *   if our underlying miscWordList has only one token, strip
         *   quotes, in case that token is a quoted string token
         */
        if (misc_.getOrigTokenList().length() == 1)
            txt = stripQuotesFrom(txt);

        /* return the text */
        return txt;
    }

    getTentativeLiteralText()
    {
        /* our regular text is permanent, so simply use it now */
        return misc_.getOrigText();
    }

    resolveLiteral(results)
    {
        /*
         *   note the length of our literal phrase - when we have a choice
         *   of interpretations, we prefer to choose shorter literal
         *   phrases, since this means that we'll have more of our tokens
         *   being fully interpreted rather than bunched into an
         *   uninterpreted literal
         */
        results.noteLiteral(misc_.getOrigText());
    }
;

/*
 *   In case we have a verb grammar rule that calls for a literal phrase,
 *   but the player enters a command with nothing in that slot, match an
 *   empty token list as a last resort.  Since this phrasing has a badness,
 *   we won't match it unless we don't have any better structural match.
 */
grammar literalPhrase(empty): [badness 400]: EmptyLiteralPhraseProd
    resolveLiteral(results) { }
;

/* ------------------------------------------------------------------------ */
/*
 *   An miscellaneous word list is a list of one or more words of any kind:
 *   any word, any integer, or any apostrophe-S token will do.  Note that
 *   known and unknown words can be mixed in an unknown word list; we care
 *   only that the list is made up of tokWord, tokInt, tokApostropheS,
 *   and/or abbreviation-period tokens.
 *
 *   Note that this kind of phrase is often used with a 'badness' value.
 *   However, we don't assign any badness here, because a miscellaneous
 *   word list might be perfectly valid in some contexts; instead, any
 *   productions that include a misc word list should specify badness as
 *   desired.
 */
grammar miscWordList(wordOrNumber):
    tokWord->txt_ | tokInt->txt_ | tokApostropheS->txt_
    | tokPluralApostrophe->txt_
    | tokPoundInt->txt_ | tokString->txt_ | tokAbbrPeriod->txt_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* we don't match anything directly with our vocabulary */
        return [];
    }
    getAdjustedTokens()
    {
        /* our token type is the special miscellaneous word type */
        return [txt_, &miscWord];
    }
;

grammar miscWordList(list):
    (tokWord->txt_ | tokInt->txt_ | tokApostropheS->txt_
     | tokPluralApostrophe->txt_ | tokAbbrPeriod->txt_
     | tokPoundInt->txt_ | tokString->txt_) miscWordList->lst_
    : NounPhraseWithVocab
    getVocabMatchList(resolver, results, extraFlags)
    {
        /* we don't match anything directly with our vocabulary */
        return [];
    }
    getAdjustedTokens()
    {
        /* our token type is the special miscellaneous word type */
        return [txt_, &miscWord] + lst_.getAdjustedTokens();
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   A main disambiguation phrase consists of a disambiguation phrase,
 *   optionally terminated with a period.
 */
grammar mainDisambigPhrase(main):
    disambigPhrase->dp_
    | disambigPhrase->dp_ '.'
    : BasicProd
    resolveNouns(resolver, results)
    {
        return dp_.resolveNouns(resolver, results);
    }
    getResponseList() { return dp_.getResponseList(); }
;

/*
 *   A "disambiguation phrase" is a phrase that answers a disambiguation
 *   question ("which book do you mean...").
 *   
 *   A disambiguation question can be answered with several types of
 *   syntax:
 *   
 *.  all/everything/all of them
 *.  both/both of them
 *.  any/any of them
 *.  <disambig list>
 *.  the <ordinal list> ones
 *.  the former/the latter
 *   
 *   Note that we assign non-zero badness to all of the ordinal
 *   interpretations, so that we will take an actual vocabulary
 *   interpretation instead of an ordinal interpretation whenever possible.
 *   For example, if an object's name is actually "the third button," this
 *   will give us greater affinity for using "third" as an adjective than
 *   as an ordinal in our own list.  
 */
grammar disambigPhrase(all):
    'alle' | 'alle' 'davon' : DisambigProd
    resolveNouns(resolver, results)
    {
        /* they want everything we proposed - return the whole list */
        return removeAmbigFlags(resolver.getAll(self));
    }

    /* there's only me in the response list */
    getResponseList() { return [self]; }
;

grammar disambigPhrase(both): 'beide' | 'beide' 'davon' : DisambigProd
    resolveNouns(resolver, results)
    {
        /*
         *   they want two items - return the whole list (if it has more
         *   than two items, we'll simply act as though they wanted all of
         *   them)
         */
        return removeAmbigFlags(resolver.getAll(self));
    }

    /* there's only me in the response list */
    getResponseList() { return [self]; }
;

grammar disambigPhrase(any): 'irgendein' | 'irgendeins' 'davon' | 'irgendein' 'davon' : DisambigProd
    resolveNouns(resolver, results)
    {
        local lst;

        /* they want any item - arbitrarily pick the first one */
        lst = resolver.matchList.sublist(1, 1);

        /*
         *   add the "unclear disambiguation" flag to the item we picked,
         *   to indicate that the selection was arbitrary
         */
        if (lst.length() > 0)
            lst[1].flags_ |= UnclearDisambig;

        /* return the result */
        return lst;
    }

    /* there's only me in the response list */
    getResponseList() { return [self]; }
;

grammar disambigPhrase(list): disambigList->lst_ : DisambigProd
    resolveNouns(resolver, results)
    {
        return removeAmbigFlags(lst_.resolveNouns(resolver, results));
    }

    /* there's only me in the response list */
    getResponseList() { return lst_.getResponseList(); }
;

grammar disambigPhrase(ordinalList):
    disambigOrdinalList->lst_ 'davon'
    | ('den'|'die'|'das') disambigOrdinalList->lst_ 'davon'
    : DisambigProd

    resolveNouns(resolver, results)
    {
        /* return the list with the ambiguity flags removed */
        return removeAmbigFlags(lst_.resolveNouns(resolver, results));
    }

    /* the response list consists of my single ordinal list item */
    getResponseList() { return [lst_]; }
;

/*
 *   A disambig list consists of one or more disambig list items, connected
 *   by noun phrase conjunctions.  
 */
grammar disambigList(single): disambigListItem->item_ : DisambigProd
    resolveNouns(resolver, results)
    {
        return item_.resolveNouns(resolver, results);
    }

    /* the response list consists of my single item */
    getResponseList() { return [item_]; }
;

grammar disambigList(list):
    disambigListItem->item_ commandOrNounConjunction disambigList->lst_
    : DisambigProd

    resolveNouns(resolver, results)
    {
        return item_.resolveNouns(resolver, results)
            + lst_.resolveNouns(resolver, results);
    }

    /* my response list consists of each of our list items */
    getResponseList() { return [item_] + lst_.getResponseList(); }
;

/*
 *   Base class for ordinal disambiguation items
 */
class DisambigOrdProd: DisambigProd
    resolveNouns(resolver, results)
    {
        /* note the ordinal match */
        results.noteDisambigOrdinal();

        /* select the result by the ordinal */
        return selectByOrdinal(ord_, resolver, results);
    }

    selectByOrdinal(ordTok, resolver, results)
    {
        local idx;
        local matchList = resolver.ordinalMatchList;

        /*
         *   look up the meaning of the ordinal word (note that we assume
         *   that each ordinalWord is unique, since we only create one of
         *   each)
         */
        idx = cmdDict.findWord(ordTok, &ordinalWord)[1].numval;

        /*
         *   if it's the special value -1, it indicates that we should
         *   select the *last* item in the list
         */
        if (idx == -1)
            idx = matchList.length();

        /* if it's outside the limits of the match list, it's an error */
        if (idx > matchList.length())
        {
            /* note the problem */
            results.noteOrdinalOutOfRange(ordTok);

            /* no results */
            return [];
        }

        /* return the selected item as a one-item list */
        return matchList.sublist(idx, 1);
    }
;

/*
 *   A disambig vocab production is the base class for disambiguation
 *   phrases that involve vocabulary words.
 */
class DisambigVocabProd: DisambigProd
;

/*
 *   A disambig list item consists of:
 *
 *.  first/second/etc
 *.  the first/second/etc
 *.  first one/second one/etc
 *.  the first one/the second one/etc
 *.  <compound noun phrase>
 *.  possessive
 */

grammar disambigListItem(ordinal):
    ordinalWord->ord_
    | 'den' ordinalWord->ord_ (|'davon')
    | 'die' ordinalWord->ord_ (|'davon')
    | 'das' ordinalWord->ord_ (|'davon')
    | 'dem' ordinalWord->ord_ (|'davon')
    | 'der' ordinalWord->ord_ (|'davon')
    : DisambigOrdProd
;

grammar disambigListItem(noun):
    completeNounPhraseWithoutAll->np_
    | terminalNounPhrase->np_
    : DisambigVocabProd
    resolveNouns(resolver, results)
    {
        /* get the matches for the underlying noun phrase */
        local lst = np_.resolveNouns(resolver, results);

        /* note the matches */
        results.noteMatches(lst);

        /* return the match list */
        return lst;
    }
;

grammar disambigListItem(plural):
    pluralPhrase->np_
    : DisambigVocabProd
    resolveNouns(resolver, results)
    {
        local lst;

        /*
         *   get the underlying match list; since we explicitly have a
         *   plural, the result doesn't need to be unique, so simply
         *   return everything we find
         */
        lst = np_.resolveNouns(resolver, results);

        /*
         *   if we didn't get anything, it's an error; otherwise, take
         *   everything, since we explicitly wanted a plural usage
         */
        if (lst.length() == 0)
            results.noMatch(resolver.getAction(), np_.getOrigText());
        else
            results.noteMatches(lst);

        /* return the list */
        return lst;
    }
;

grammar disambigListItem(possessive): possessiveNounPhrase->poss_
    : DisambigPossessiveProd
;

/*
 *   A disambig ordinal list consists of two or more ordinal words
 *   separated by noun phrase conjunctions.  Note that there is a minimum
 *   of two entries in the list.
 */
grammar disambigOrdinalList(tail):
    ordinalWord->ord1_ ('und' | ',') ordinalWord->ord2_ : DisambigOrdProd
    resolveNouns(resolver, results)
    {
        /* note the pair of ordinal matches */
        results.noteDisambigOrdinal();
        results.noteDisambigOrdinal();

        /* combine the selections of our two ordinals */
        return selectByOrdinal(ord1_, resolver, results)
            + selectByOrdinal(ord2_, resolver, results);
    }
;

grammar disambigOrdinalList(head):
    ordinalWord->ord_ ('und' | ',') disambigOrdinalList->lst_
    : DisambigOrdProd
    resolveNouns(resolver, results)
    {
        /* note the ordinal match */
        results.noteDisambigOrdinal();

        /* combine the selections of our ordinal and the sublist */
        return selectByOrdinal(ord_, resolver, results)
            + lst_.resolveNouns(resolver, results);
    }
;


/* ------------------------------------------------------------------------ */
/*
 *   Ordinal words.  We define a limited set of these, since we only use
 *   them in a few special contexts where it would be unreasonable to need
 *   even as many as define here.
 */
#define defOrdinal(str, val) object ordinalWord=#@str numval=val

defOrdinal(erster, 1);
defOrdinal(erst, 1);
defOrdinal(zweit, 2);
defOrdinal(dritt, 3);
defOrdinal(viert, 4);
object ordinalWord='fünft' numval=5;
defOrdinal(sechst, 6);
defOrdinal(siebt, 7);
defOrdinal(acht, 8);
defOrdinal(neunt, 9);
defOrdinal(zehnt, 10);
defOrdinal(elft, 11);
object ordinalWord='zwölft' numval=12;
defOrdinal(dreizehnt, 13);
defOrdinal(vierzehnt, 14);
object ordinalWord='fünfzehnt' numval=15;
defOrdinal(sechszehnt, 16);
defOrdinal(siebzehnt, 17);
defOrdinal(achtzehnt, 18);
defOrdinal(neunzehnt, 19);
defOrdinal(zwanzigst, 20);

/*
 *   the special 'last' ordinal - the value -1 is special to indicate the
 *   last item in a list
 */
defOrdinal(letzt, -1);
defOrdinal(letzter, -1);


/* ------------------------------------------------------------------------ */
/*
 *   A numeric production.  These can be either spelled-out numbers (such
 *   as "fifty-seven") or numbers entered in digit form (as in "57").
 */
class NumberProd: BasicProd
    /* get the numeric (integer) value */
    getval() { return 0; }

    /*
     *   Get the string version of the numeric value.  This should return
     *   a string, but the string should be in digit form.  If the
     *   original entry was in digit form, then the original entry should
     *   be returned; otherwise, a string should be constructed from the
     *   integer value.  By default, we'll do the latter.
     */
    getStrVal() { return toString(getval()); }
;

/*
 *   A quantifier is simply a number, entered with numerals or spelled out.
 */
grammar numberPhrase(digits): tokInt->num_ : NumberProd
    /* get the numeric value */
    getval() { return toInteger(num_); }

    /*
     *   get the string version of the numeric value - since the token was
     *   an integer to start with, return the actual integer value
     */
    getStrVal() { return num_; }
;

grammar numberPhrase(spelled): spelledNumber->num_ : NumberProd
    /* get the numeric value */
    getval() { return num_.getval(); }
;

/*
 *   A number phrase preceded by a pound sign.  We distinguish this kind of
 *   number phrase from plain numbers, since this kind has a somewhat more
 *   limited set of valid contexts.  
 */
grammar poundNumberPhrase(main): tokPoundInt->num_ : NumberProd
    /*
     *   get the numeric value - a tokPoundInt token has a pound sign
     *   followed by digits, so the numeric value is the value of the
     *   substring following the '#' sign
     */
    getval() { return toInteger(num_.substr(2)); }

    /*
     *   get the string value - we have a number token following the '#',
     *   so simply return the part after the '#'
     */
    getStrVal() { return num_.substr(2); }
;


/*
 *   Number literals.  We'll define a set of special objects for numbers:
 *   each object defines a number and a value for the number.
 */
#define defDigit(num, val) object digitWord=#@num numval=val
#define defTeen(num, val)  object teenWord=#@num numval=val
#define defTens(num, val)  object tensWord=#@num numval=val

defDigit(ein, 1);
defDigit(eins, 1);
defDigit(eine, 1);
defDigit(zwei, 2);
defDigit(drei, 3);
defDigit(vier, 4);
object digitWord='fünf' numval=5;
defDigit(sechs, 6);
defDigit(sieben, 7);
defDigit(acht, 8);
defDigit(neun, 9);
defTeen(zehn, 10);
defTeen(elf, 11);
object digitWord='zwölf' numval=12;
defTeen(dreizehn, 13);
defTeen(vierzehn, 14);
object digitWord='fünfzehn' numval=15;
defTeen(sechzehn, 16);
defTeen(siebzehn, 17);
defTeen(achtzehn, 18);
defTeen(neunzehn, 19);
defTens(zwanzig, 20);
object digitWord='dreißig' numval=30;
defTens(vierzig, 40);
object digitWord='fünfzig' numval=50;
defTens(sechzig, 60);
defTens(siebzig, 70);
defTens(achtzig, 80);
defTens(neunzig, 90);

grammar spelledSmallNumber(digit): digitWord->num_ : NumberProd
    getval()
    {
        /*
         *   Look up the units word - there should be only one in the
         *   dictionary, since these are our special words.  Return the
         *   object's numeric value property 'numval', which gives the
         *   number for the name.
         */
        return cmdDict.findWord(num_, &digitWord)[1].numval;
    }
;

grammar spelledSmallNumber(teen): teenWord->num_ : NumberProd
    getval()
    {
        /* look up the dictionary word for the number */
        return cmdDict.findWord(num_, &teenWord)[1].numval;
    }
;

grammar spelledSmallNumber(tens): tensWord->num_ : NumberProd
    getval()
    {
        /* look up the dictionary word for the number */
        return cmdDict.findWord(num_, &tensWord)[1].numval;
    }
;

grammar spelledSmallNumber(tensAndUnits):
    digitWord->units_ 'und'->sep_ tensWord->tens_ //German: we have units in first place: 'zweiundzwanzig'
    : NumberProd
    getval()
    {
        /* look up the words, and add up the values */
        return cmdDict.findWord(tens_, &tensWord)[1].numval
            + cmdDict.findWord(units_, &digitWord)[1].numval;
    }
;

grammar spelledSmallNumber(zero): 'null' : NumberProd
    getval() { return 0; }
;

grammar spelledHundred(small): spelledSmallNumber->num_ : NumberProd
    getval() { return num_.getval(); }
;

grammar spelledHundred(hundreds): spelledSmallNumber->hun_ 'hundert'
    : NumberProd
    getval() { return hun_.getval() * 100; }
;

grammar spelledHundred(hundredsPlusNum):
    spelledSmallNumber->hun_ 'hundert' spelledSmallNumber->num_
    : NumberProd
    getval() { return hun_.getval() * 100 + num_.getval(); }
;

// -- German: new grammar rules for hundreds

grammar spelledHundred(hundredsAndSmall):
    spelledHundred->hun_ 'hundert' 'und' spelledSmallNumber->num_
    : NumberProd
    getval() { return hun_.getval() * 100 + num_.getval(); }
;

grammar spelledHundred(hundredAndSmall):
    'hundert' 'und' spelledSmallNumber->num_
    : NumberProd
    getval() { return 100 + num_.getval(); }
;

grammar spelledHundred(hundredSmall):
    'hundert' spelledSmallNumber->num_
    : NumberProd
    getval() { return 100 + num_.getval(); }
;

// -- end new grammar rules for hundreds

grammar spelledHundred(hundred): 'hundert' : NumberProd
    getval() { return 100; }
;

grammar spelledThousand(thousands): spelledHundred->thou_ 'tausend'
    : NumberProd
    getval() { return thou_.getval() * 1000; }
;

grammar spelledThousand(thousandsPlus):
    spelledHundred->thou_ 'tausend' spelledHundred->num_
    : NumberProd
    getval() { return thou_.getval() * 1000 + num_.getval(); }
;

grammar spelledThousand(thousandsAndSmall):
    spelledHundred->thou_ 'tausend' 'und' spelledSmallNumber->num_
    : NumberProd
    getval() { return thou_.getval() * 1000 + num_.getval(); }
;

// -- German: new grammar rules for thousands

grammar spelledThousand(thousandAndSmall):
    'tausend' 'und' spelledSmallNumber->num_
    : NumberProd
    getval() { return 1000 + num_.getval(); }
;

grammar spelledThousand(thousandSmall):
    'tausend' spelledSmallNumber->num_
    : NumberProd
    getval() { return 1000 + num_.getval(); }
;

// -- end new grammar rules for thousands

grammar spelledThousand(thousand): 'tausend' : NumberProd
    getval() { return 1000; }
;

grammar spelledMillion(millions): spelledHundred->mil_ ('million'|'millionen')
    : NumberProd
    getval() { return mil_.getval() * 1000000; }
;

grammar spelledMillion(millionsPlus):
    spelledHundred->mil_ ('million'|'millionen')
    (spelledThousand->nxt_ | spelledHundred->nxt_)
    : NumberProd
    getval() { return mil_.getval() * 1000000 + nxt_.getval(); }
;

grammar spelledMillion(aMillion): 'eine' 'million' : NumberProd
    getval() { return 1000000; }
;

grammar spelledMillion(aMillionAndSmall):
    'eine' 'million' 'and' spelledSmallNumber->num_
    : NumberProd
    getval() { return 1000000 + num_.getval(); }
;

grammar spelledMillion(millionsAndSmall):
    spelledHundred->mil_ ('million'|'millionen') 'und' spelledSmallNumber->num_
    : NumberProd
    getval() { return mil_.getval() * 1000000 + num_.getval(); }
;

grammar spelledNumber(main):
    spelledHundred->num_
    | spelledThousand->num_
    | spelledMillion->num_
    : NumberProd
    getval() { return num_.getval(); }
;


/* ------------------------------------------------------------------------ */
/*
 *   "OOPS" command syntax
 */
grammar oopsCommand(main):
    oopsPhrase->oops_ | oopsPhrase->oops_ '.' : BasicProd
    getNewTokens() { return oops_.getNewTokens(); }
;

grammar oopsPhrase(main):
    ('ups' | 'äh' | 'oops') miscWordList->lst_
    | ('ups' | 'äh' | 'oops') ',' miscWordList->lst_
    : BasicProd
    getNewTokens() { return lst_.getOrigTokenList(); }
;

grammar oopsPhrase(missing):
    'oops' | 'ups' | 'äh'
    : BasicProd
    getNewTokens() { return nil; }
;

/* ------------------------------------------------------------------------ */
/*
 *   finishGame options.  We provide descriptions and keywords for the
 *   option objects here, because these are inherently language-specific.
 *   
 *   Note that we provide hyperlinks for our descriptions when possible.
 *   When we're in plain text mode, we can't show links, so we'll instead
 *   show an alternate form with the single-letter response highlighted in
 *   the text.  We don't highlight the single-letter response in the
 *   hyperlinked version because (a) if the user wants a shortcut, they can
 *   simply click the hyperlink, and (b) most UI's that show hyperlinks
 *   show a distinctive appearance for the hyperlink itself, so adding even
 *   more highlighting within the hyperlink starts to look awfully busy.  
 */
modify finishOptionQuit
    desc = "die Geschichte <<aHrefAlt('verlassen', 'VERLASSEN', '<b>Q</b>UIT', 'Die Geschichte verlassen')>>"
    responseKeyword = 'verlassen'
    responseChar = 'q'
;

modify finishOptionRestore
    desc = "einen gespeicherten Stand <<aHrefAlt('laden', 'LADEN', '<b>L</b>ADEN',
            'Einen gespeicherten Stand laden')>> "
    responseKeyword = 'laden'
    responseChar = 'l'
;

modify finishOptionRestart
    desc = "einen <<aHrefAlt('neustart', 'NEUSTART', '<b>N</b>EUSTART',
            'Die Geschichte von vorn beginnen')>> "
    responseKeyword = 'neustart'
    responseChar = 'n'
;

modify finishOptionUndo
    desc = "den letzten Zug <<aHrefAlt('zurück', 'ZURÜCK', '<b>Z</b>URÜCK',
            'Den letzten Zug zurück nehmen')>> nehmen "
    responseKeyword = 'zurück'
    responseChar = 'z'
;

modify finishOptionCredits
    desc = "die <<aHrefAlt('credits', 'CREDITS', '<b>C</b>REDITS',
            'Credits ansehen')>> ansehen"
    responseKeyword = 'credits'
    responseChar = 'c'
;

modify finishOptionFullScore
    desc = "die vollen <<aHrefAlt('punkte', 'PUNKTE',
            '<b>P</b>UNKTE', 'Punkte anzeigen')>> anzeigen"
    responseKeyword = 'punkte'
    responseChar = 'p'
;

modify finishOptionAmusing
    desc = "einige amüsante <<aHrefAlt('dinge', 'DINGE', '<b>D</b>INGE',
            'Erfahre amüsante Dinge')>> erfahren"
    responseKeyword = 'amusing'
    responseChar = 'd'
;

modify restoreOptionStartOver
    desc = "einen <<aHrefAlt('start', 'START', '<b>S</b>TART',
            'Starte wieder von vorne')>> von vorne wagen"
    responseKeyword = 'start'
    responseChar = 's'
;

modify restoreOptionRestoreAnother
    desc = "<<aHrefAlt('laden', 'LADEN', '<b>L</b>ADEN',
            'einen gespeicherten Stand laden')>> einen anderen gespeicherten Stand"
;

/* ------------------------------------------------------------------------ */
/*
 *   Context for Action.getVerbPhrase().  This keeps track of pronoun
 *   antecedents in cases where we're stringing together a series of verb
 *   phrases.
 */
class GetVerbPhraseContext: object
    /* get the objective form of an object, using a pronoun as appropriate */
    objNameObj(obj)
    {
        /*
         *   if it's the pronoun antecedent, use the pronoun form;
         *   otherwise, use the full name
         */
        if (obj == pronounObj) {
            if (curcase.d_flag)
                return obj.itDat; //correct case for phrases like: (erst ihn nehmen)
            else
                return obj.itAkk;
        }
        // return obj.itObj + 'fyghrd' ;
        else
        {
            if (curcase.d_flag)
                return obj.demNameObj; //correct case for phrases like: (erst den Apfel nehmen)
            else
                return obj.denNameObj;
        }
    }

    /* are we showing the given object pronomially? */
    isObjPronoun(obj) { return (obj == pronounObj); }

    /* set the pronoun antecedent */
    setPronounObj(obj) { pronounObj = obj; }

    /* the pronoun antecedent */
    pronounObj = nil
;

/*
 *   Default getVerbPhrase context.  This can be used when no other context
 *   is needed.  This context instance has no state - it doesn't track any
 *   antecedents.  
 */
defaultGetVerbPhraseContext: GetVerbPhraseContext
    /* we don't remember any antecedents */
    setPronounObj(obj) { }
;

/* ------------------------------------------------------------------------ */
/*
 *   Implicit action context.  This is passed to the message methods that
 *   generate implicit action announcements, to indicate the context in
 *   which the message is to be used.
 */
class ImplicitAnnouncementContext: object
    /*
     *   Should we use the infinitive form of the verb, or the participle
     *   form for generating the announcement?  By default, use use the
     *   participle form: "(first OPENING THE BOX)".
     */
    useInfPhrase = nil //DEFINIERT OB DER INFINITIV ODER PARTIZIP TEIL DES VERBS VERW. WIRD

    /* is this message going in a list? */
    isInList = nil

    /*
     *   Are we in a sublist of 'just trying' or 'just asking' messages?
     *   (We can only have sublist groupings one level deep, so we don't
     *   need to worry about what kind of sublist we're in.)
     */
    isInSublist = nil

    /* our getVerbPhrase context - by default, don't use one */
    getVerbCtx = nil

    /* generate the announcement message given the action description */
    buildImplicitAnnouncement(txt)
    {
        /* if we're not in a list, make it a full, stand-alone message */
        if (!isInList)
            txt = '<./p0>\n<.assume>erst ' + txt + '<./assume>\n';

        /* return the result */
        return txt;
    }
;

/* the standard implicit action announcement context */
standardImpCtx: ImplicitAnnouncementContext;

/* the "just trying" implicit action announcement context */
tryingImpCtx: ImplicitAnnouncementContext
    /*
     *   The action was merely attempted, so use the infinitive phrase in
     *   the announcement: "(first trying to OPEN THE BOX)".
     */
    useInfPhrase = true // DEFINIERT OB DER INFINITIV ODER PARTIZIP TEIL DES VERBS VERW. WIRD

    /* build the announcement */
    buildImplicitAnnouncement(txt)
    {
        /*
         *   If we're not in a list of 'trying' messages, add the 'trying'
         *   prefix message to the action description.  This isn't
         *   necessary if we're in a 'trying' list, since the list itself
         *   will have the 'trying' part.
         */
        if (!isInSublist)
            txt = 'versuchen, ' + txt;

        /* now build the message into the full text as usual */
        return inherited(txt);
    }
;

/*
 *   The "asking question" implicit action announcement context.  By
 *   default, we generate the message exactly the same way we do for the
 *   'trying' case.
 */
askingImpCtx: tryingImpCtx;

/*
 *   A class for messages appearing in a list.  Within a list, we want to
 *   keep track of the last direct object, so that we can refer to it with
 *   a pronoun later in the list.
 */
class ListImpCtx: ImplicitAnnouncementContext, GetVerbPhraseContext
    /*
     *   Set the appropriate base context for the given implicit action
     *   announcement report (an ImplicitActionAnnouncement object).
     */
    setBaseCtx(ctx)
    {
        /*
         *   if this is a failed attempt, use a 'trying' context;
         *   otherwise, use a standard context
         */
        if (ctx.justTrying)
            baseCtx = tryingImpCtx;
        else if (ctx.justAsking)
            baseCtx = askingImpCtx;
        else
            baseCtx = standardImpCtx;
    }

    /* we're in a list */
    isInList = true

    /* we are our own getVerbPhrase context */
    getVerbCtx = (self)

    /* delegate the phrase format to our underlying announcement context */
    useInfPhrase = (delegated baseCtx)

    /* build the announcement using our underlying context */
    buildImplicitAnnouncement(txt) { return delegated baseCtx(txt); }

    /* our base context - we delegate some unoverridden behavior to this */
    baseCtx = nil
;

/* ------------------------------------------------------------------------ */
/*
 *   Language-specific Action modifications.
 */
modify Action
    /*
     *   In the English grammar, all 'predicate' grammar definitions
     *   (which are usually made via the VerbRule macro) are associated
     *   with Action match tree objects; in fact, each 'predicate' grammar
     *   match tree is the specific Action subclass associated with the
     *   grammar for the predicate.  This means that the Action associated
     *   with a grammar match is simply the grammar match object itself.
     *   Hence, we can resolve the action for a 'predicate' match simply
     *   by returning the match itself: it is the Action as well as the
     *   grammar match.
     *
     *   This approach ('grammar predicate' matches are based on Action
     *   subclasses) works well for languages like English that encode the
     *   role of each phrase in the word order of the sentence.
     *
     *   Languages that encode phrase roles using case markers or other
     *   devices tend to be freer with word order.  As a result,
     *   'predicate' grammars for such languages should generally not
     *   attempt to capture all possible word orderings for a given
     *   action, but should instead take the complementary approach of
     *   capturing the possible overall sentence structures independently
     *   of verb phrases, and plug in a verb phrase as a component, just
     *   like noun phrases plug into the English grammar.  In these cases,
     *   the match objects will NOT be Action subclasses; the Action
     *   objects will instead be buried down deeper in the match tree.
     *   Hence, resolveAction() must be defined on whatever class is used
     *   to construct 'predicate' grammar matches, instead of on Action,
     *   since Action will not be a 'predicate' match.
     */
    resolveAction(issuingActor, targetActor) { return self; }

    /*
     *   Return the interrogative pronoun for a missing object in one of
     *   our object roles.  In most cases, this is simply "what", but for
     *   some actions, "whom" is more appropriate (for example, the direct
     *   object of "ask" is implicitly a person, so "whom" is most
     *   appropriate for this role).
     */
    whatObj(which)
    {
        /* intransitive verbs have no objects, so there's nothing to show */
    }

    /*
     *   Translate an interrogative word for whatObj.  If the word is
     *   'whom', translate to the library message for 'whom'; this allows
     *   authors to use 'who' rather than 'whom' as the objective form of
     *   'who', which sounds less stuffy to many people.
     */
    whatTranslate(txt)
    {
        /*
         *   if it's 'whom', translate to the library message for 'whom';
         *   otherwise, just show the word as is
         */
        return (txt == 'wen' && txt == 'wem' ? gLibMessages.whomPronoun : txt);
    }

    /*
     *   Return a string with the appropriate pronoun (objective form) for
     *   a list of object matches, with the given resolved cardinality.
     *   This list is a list of ResolveInfo objects.
     */
    objListPronoun(objList) // ##### "womit soll bartimäus -> in ihm graben?" #####
    {
        local himCnt, herCnt, themCnt;
        local FirstPersonCnt, SecondPersonCnt, FourthPersonCnt, FifthPersonCnt, SixthPersonCnt;
        local resolvedNumber;

        /* if there's no object list at all, just use 'it' */
        if (objList == nil || objList == [])
            return 'das';

        /* note the number of objects in the resolved list */
        resolvedNumber = objList.length();

        /*
         *   In the tentatively resolved object list, we might have hidden
         *   away ambiguous matches.  Expand those back into the list so
         *   we have the full list of in-scope matches.
         */
        foreach (local cur in objList)
        {
            /*
             *   if this one has hidden ambiguous objects, add the hidden
             *   objects back into our list
             */
            if (cur.extraObjects != nil)
                objList += cur.extraObjects;
        }

        /*
         *   if the desired cardinality is plural and the object list has
         *   more than one object, simply say 'them'
         */
        if (objList.length() > 1 && resolvedNumber > 1)
            return 'sie';

        if (objList == [dummyTentativeInfo])
            return 'so etwas';
        
        /*
         *   singular cardinality - count masculine and feminine objects,
         *   and count the referral persons
         */
        himCnt = herCnt = themCnt = 0;
        FirstPersonCnt = SecondPersonCnt = FourthPersonCnt = FifthPersonCnt = SixthPersonCnt = 0;
        foreach (local cur in objList)
        {
            /* if it's masculine, count it */
            if (cur.obj_.isHim)
                ++himCnt;

            /* if it's feminine, count it */
            if (cur.obj_.isHer)
                ++herCnt;

            /* if it has plural usage, count it */
            if (cur.obj_.isPlural)
                ++themCnt;

            /* if it's first person usage, count it */
            if (cur.obj_.referralPerson == FirstPerson)
                ++FirstPersonCnt;

            /* if it's second person usage, count it */
            if (cur.obj_.referralPerson == SecondPerson)
                ++SecondPersonCnt;
        
            /* if it's fourth person usage, count it */
            if (cur.obj_.referralPerson == FourthPerson)
                ++FourthPersonCnt;
            
            /* if it's fifth person usage, count it */
            if (cur.obj_.referralPerson == FifthPerson)
                ++FifthPersonCnt;
            
            /* if it's sixth person usage, count it */
            if (cur.obj_.referralPerson == SixthPerson)
                ++SixthPersonCnt;
        
        }

        /*
         *   if they all have plural usage, show "them"; if they're all of
         *   one gender, show "him" or "her" as appropriate; if they're
         *   all neuter, show "it"; otherwise, show "them"
         */

        if (themCnt == objList.length())
            return (curcase.d_flag ? 'ihnen' : 'sie');
        else if (FirstPersonCnt == objList.length())
            return (gameMain.useCapitalizedAdress ? '\^' : '') + (curcase.d_flag ? 'mir' : 'mich');
        else if (SecondPersonCnt == objList.length())
            return (gameMain.useCapitalizedAdress ? '\^' : '') + (curcase.d_flag ? 'dir' : 'dich');
        else if (FourthPersonCnt == objList.length())
            return (gameMain.useCapitalizedAdress ? '\^' : '') + (curcase.d_flag ? 'uns' : 'uns');
        else if (FifthPersonCnt == objList.length())
            return (gameMain.useCapitalizedAdress ? '\^' : '') + (curcase.d_flag ? 'euch' : 'euch');
        else if (SixthPersonCnt == objList.length())
            return (gameMain.useCapitalizedAdress ? '\^' : '') + (curcase.d_flag ? 'ihnen' : 'ihnen');
        else if (himCnt == objList.length() && herCnt == 0)
            return (curcase.d_flag ? 'ihm' : 'ihn'); 
        else if (herCnt == objList.length() && himCnt == 0)
            return (curcase.d_flag ? 'ihr' : 'sie');
        else if (herCnt == 0 && himCnt == 0)
            return (curcase.d_flag ? 'ihm' : 'es');
        else
            return (curcase.d_flag ? 'ihnen' : 'sie');
    }

    /*
     *   Announce a default object used with this action.
     *
     *   'resolvedAllObjects' indicates where we are in the command
     *   processing: this is true if we've already resolved all of the
     *   other objects in the command, nil if not.  We use this
     *   information to get the phrasing right according to the situation.
     */
    announceDefaultObject(obj, whichObj, resolvedAllObjects)
    {
        /*
         *   the basic action class takes no objects, so there can be no
         *   default announcement
         */
        return '';
    }

    /*
     *   Announce all defaulted objects in the action.  By default, we
     *   show nothing.
     */
    announceAllDefaultObjects(allResolved) { }

    /*
     *   Return a phrase describing the action performed implicitly, as a
     *   participle phrase.  'ctx' is an ImplicitAnnouncementContext object
     *   describing the context in which we're generating the phrase.
     *
     *   This comes in two forms: if the context indicates we're only
     *   attempting the action, we'll return an infinitive phrase ("open
     *   the box") for use in a larger participle phrase describing the
     *   attempt ("trying to...").  Otherwise, we'll be describing the
     *   action as actually having been performed, so we'll return a
     *   present participle phrase ("opening the box").
     */
    getImplicitPhrase(ctx)
    {
        /*
         *   Get the phrase.  Use the infinitive or participle form, as
         *   indicated in the context.
         */
        return getVerbPhrase(ctx.useInfPhrase, ctx.getVerbCtx);
    }

    /*
     *   Get the infinitive form of the action.  We are NOT to include the
     *   infinitive complementizer (i.e., "to") as part of the result,
     *   since the complementizer isn't used in all contexts in which we
     *   might want to use the infinitive; for example, we don't want a
     *   "to" in phrases involving an auxiliary verb, such as "he can open
     *   the box."
     */
    getInfPhrase()
    {
        /* return the verb phrase in infinitive form */
        return getVerbPhrase(true, nil);
    }

    /*
     *   Get the root infinitive form of our verb phrase as part of a
     *   question in which one of the verb's objects is the "unknown" of
     *   the interrogative.  'which' is one of the role markers
     *   (DirectObject, IndirectObject, etc), indicating which object is
     *   the subject of the interrogative.
     *
     *   For example, for the verb UNLOCK <dobj> WITH <iobj>, if the
     *   unknown is the direct object, the phrase we'd return would be
     *   "unlock": this would plug into contexts such as "what do you want
     *   to unlock."  If the indirect object is the unknown for the same
     *   verb, the phrase would be "unlock it with", which would plug in as
     *   "what do you want to unlock it with".
     *
     *   Note that we are NOT to include the infinitive complementizer
     *   (i.e., "to") as part of the phrase we generate, since the
     *   complementizer isn't used in some contexts where the infinitive
     *   conjugation is needed (for example, "what should I <infinitive>").
     */
    getQuestionInf(which)
    {
        /*
         *   for a verb without objects, this is the same as the basic
         *   infinitive
         */
        return getInfPhrase();
    }

    /*
     *   Get a string describing the full action in present participle
     *   form, using the current command objects: "taking the watch",
     *   "putting the book on the shelf"
     */
    getParticiplePhrase()
    {
        /* return the verb phrase in participle form */
        return getVerbPhrase(nil, nil);
    }

    /*
     *   Get the full verb phrase in either infinitive or participle
     *   format.  This is a common handler for getInfinitivePhrase() and
     *   getParticiplePhrase().
     *
     *   'ctx' is a GetVerbPhraseContext object, which lets us keep track
     *   of antecedents when we're stringing together multiple verb
     *   phrases.  'ctx' can be nil if the verb phrase is being used in
     *   isolation.
     */
    getVerbPhrase(inf, ctx)
    {
        /*
         *   parse the verbPhrase into the parts before and after the
         *   slash, and any additional text following the slash part
         */
        //rexMatch('(.*)/(<alphanum|-|squote>+)(.*)', verbPhrase);
        rexMatch('(.*)/(.*)', verbPhrase);
        
        /* return the appropriate parts */
        if (!inf) // vorher (inf), ÄNDERUNG ZUM TESTEN BEI (erst aufstehen)
        {
            /*
             *   infinitive - we want the part before the slash, plus the
             *   extra prepositions (or whatever) after the switched part
             */
            return rexGroup(2)[3];
        }
        else
        {
            /* participle - it's the part after the slash */
            return rexGroup(1)[3];
        }
    }

    /*
     *   Show the "noMatch" library message.  For most verbs, we use the
     *   basic "you can't see that here".  Verbs that are mostly used with
     *   intangible objects, such as LISTEN TO and SMELL, might want to
     *   override this to use a less visually-oriented message.
     */
    noMatch(msgObj, actor, txt) { msgObj.noMatchCannotSee(actor, txt); }

    /*
     *   Verb flags - these are used to control certain aspects of verb
     *   formatting.  By default, we have no special flags.
     */
    verbFlags = 0

    /* add a space prefix/suffix to a string if the string is non-empty */
    spPrefix(str) { return (str == '' ? str : ' ' + str); }
    spSuffix(str) { return (str == '' ? str : str + ' '); }
;

/*
 *   English-specific additions for single-object verbs.
 */
modify TAction
    /* return an interrogative word for an object of the action */
    whatObj(which)
    {
        /*
         *   Show the interrogative for our direct object - this is the
         *   last word enclosed in parentheses in our verbPhrase string.
         */
        rexSearch('<lparen>.*?(<alpha>+)<rparen>', verbPhrase);
        return whatTranslate(rexGroup(1)[3]);
    }

    /* announce a default object used with this action */
    announceDefaultObject(obj, whichObj, resolvedAllObjects)
    {
        local prep;
        local verb;
        local nm;

        /*
         *   get any direct object preposition - this is the part inside
         *   the "(what)" specifier parens, excluding the last word
         */
        rexSearch('<lparen>(.*<space>+)?<alpha>+<rparen>', verbPhrase);
        prep = (rexGroup(1) == nil ? '' : rexGroup(1)[3]);

        // ##### "(den Stuhl verlassen)" #####
        
        rexSearch('(.*)/(.*?)<space>+'
                  + '<lparen>(.*?)<space>*?<alpha>+<rparen>',
                  verbPhrase);
        verb = rexGroup(2)[3];
       
        obj.getAnnouncementDistinguisher(gActor.scopeList());
        
        nm = obj.denName;

        if (prep.endsWith('dativ '))
        {
            prep = prep.substr(1 ,prep.length() - 6);
            nm = obj.demName;
        }
        
        if (prep.endsWith('dativ'))
        {
            prep = prep.substr(1 ,prep.length() - 5);
            nm = obj.demName;
        }
        
        /* do any verb-specific adjustment of the preposition */
        if (prep != nil)
            prep = adjustDefaultObjectPrep(prep, obj);
       
        // ################################################
        // ## check again, if the prep has a dative flag ##
        // ## If true, set dative and go on like above   ##
        // ################################################
        
        if (prep.endsWith('dativ '))
        {
            prep = prep.substr(1 ,prep.length() - 6);
            nm = obj.demName;
        }
        
        if (prep.endsWith('dativ'))
        {
            prep = prep.substr(1 ,prep.length() - 5);
            nm = obj.demName;
        }        
        
        /* show the preposition (if any) and the object */
        return (prep == '' ? nm + ' ' + verb : prep + nm + ' ' + verb);
    }

    /*
     *   Adjust the preposition.  In some cases, the verb will want to vary
     *   the preposition according to the object.  This method can return a
     *   custom preposition in place of the one in the verbPhrase.  By
     *   default, we just use the fixed preposition from the verbPhrase,
     *   which is passed in to us in 'prep'.  
     */
    adjustDefaultObjectPrep(prep, obj) { return prep; }

    /* announce all defaulted objects */
    announceAllDefaultObjects(allResolved)
    {
        /* announce a defaulted direct object if appropriate */
        maybeAnnounceDefaultObject(dobjList_, DirectObject, allResolved);
    }

    /* show the verb's basic infinitive form for an interrogative */
    getQuestionInf(which)
    {
        /*
         *   Show the present-tense verb form (removing the participle
         *   part - the "/xxxing" part).  Include any prepositions
         *   attached to the verb itself or to the direct object (inside
         *   the "(what)" parens).
         */
        rexSearch('(.*)/<alphanum|-|squote>+(.*?)<space>+'
                  + '<lparen>(.*?)<space>*?<alpha>+<rparen>',
                  verbPhrase);
        return rexGroup(1)[3] + spPrefix(rexGroup(2)[3])
            + spPrefix(rexGroup(3)[3]);
    }
    
    // ################################################################
    // ## TACTION: parser questions - part 1: "WOMIT WODURCH ETC ... ##
    // ################################################################
    
    getQuestionWord(which)
    {
        local dprep;
        local ddativ;
        /*
         *   Show the present-tense verb form (removing the participle
         *   part - the "/xxxing" part).  Include any prepositions
         *   attached to the verb itself or to the direct object (inside
         *   the "(what)" parens).
         */
        rexSearch('(.*)/<alphanum|-|squote>+(.*)<space>+'
                  + '<lparen>(.*?)<space>*?<alpha>+<rparen>',
                  verbPhrase);
        dprep = rexGroup(3)[3];
        dprep = dprep.toLower();
        ddativ = nil;
        
        // ##### replace aus|von depending on the kind of dobj #####
        if (dprep.startsWith('aus|von')) {
            local obj = getDobj();
            if (obj.ofKind(Container))
                dprep = dprep.findReplace('aus|von', 'aus', ReplaceAll);
            else
                dprep = dprep.findReplace('aus|von', 'von', ReplaceAll);
        }
        
        // ##### looking for dative flag ... #####
        if (dprep.endsWith('dativ'))
        {
            dprep = dprep.substr(1 ,dprep.length() - 5);
            ddativ = true;
        }
        
        if (dprep.endsWith(' '))
        {
            dprep = dprep.substr(1 ,dprep.length() - 1);
        }     
        
        if (dprep == '')
            return whatObj(which);
        if (dprep == 'in' && !ddativ)
            return 'Wore' + dprep;
        else if (dprep.startsWith('i') || dprep.startsWith('a') || dprep.startsWith('o')
            || dprep.startsWith('e') || dprep.startsWith('u') || dprep.startsWith('ü')
            || dprep.startsWith('ö') || dprep.startsWith('ä'))
            return 'Wor' + dprep;
         else
            return 'Wo' + dprep;
    }
    
    // ################################################################
    // ## part 2: extracting the verb                                ##
    // ## we write the infinitve form first : "zu geben/geben (was)" ## 
    // ################################################################
    
    getQuestionVerb(which)
    {
        /*
         *   Show the present-tense verb form (removing the participle
         *   part - the "/xxxing" part).  Include any prepositions
         *   attached to the verb itself or to the direct object (inside
         *   the "(what)" parens).
         */
        // -- modified
        rexSearch('(.*)/(.*?)<space>+'
                  + '<lparen>(.*?)<space>*?<alpha>+<rparen>',
                  verbPhrase);
        return rexGroup(2)[3];
    }
    
    // #################################
    // ## return nullstring           ##
    // ## else look into TIACTION ... ##
    // #################################
    
    getQuestionObject(which)
    {
        return '';
    }
    
    /* get the verb phrase in infinitive or participle form */
    getVerbPhrase(inf, ctx)
    {
        local dobj;
        local dobjText;
        local dobjIsPronoun;
        local ret;

        /* use the default pronoun context if one wasn't supplied */
        if (ctx == nil)
            ctx = defaultGetVerbPhraseContext;

        /* get the direct object */
        dobj = getDobj();
        
        /* note if it's a pronoun */
        dobjIsPronoun = ctx.isObjPronoun(dobj);

        /* get the direct object name */
        dobjText = ctx.objNameObj(dobj);

        /* get the phrasing */
        ret = getVerbPhrase1(inf, verbPhrase, dobjText, dobjIsPronoun);

        /* set the pronoun antecedent to my direct object */
        ctx.setPronounObj(dobj);

        /* return the result */
        return ret;
    }

    /*
     *   Given the text of the direct object phrase, build the verb phrase
     *   for a one-object verb.  This is a class method that can be used by
     *   other kinds of verbs (i.e., non-TActions) that use phrasing like a
     *   single object.
     *
     *   'inf' is a flag indicating whether to use the infinitive form
     *   (true) or the present participle form (nil); 'vp' is the
     *   verbPhrase string; 'dobjText' is the direct object phrase's text;
     *   and 'dobjIsPronoun' is true if the dobj text is rendered as a
     *   pronoun.
     */
    getVerbPhrase1(inf, vp, dobjText, dobjIsPronoun)
    {
        local ret;
        local dprep;
        local vcomp;
        local dcase;
        local dobj;

        dcase = nil;
        
        /*
         *   parse the verbPhrase: pick out the 'infinitive/participle'
         *   part, the complementizer part up to the '(what)' direct
         *   object placeholder, and any preposition within the '(what)'
         *   specifier
         */
        rexMatch('(.*)/(.*) '
                 + '<lparen>(.*?)<space>*?<alpha>+<rparen>(.*)',
                 vp);
        
        /* start off with the infinitive or participle, as desired */
        if (inf)
            ret = rexGroup(1)[3];
        else
            ret = rexGroup(2)[3];

        /* get the prepositional complementizer */
        vcomp = '';

        /* get the direct object preposition */
        dprep = rexGroup(3)[3];

        // -- German: replace aus|von depending on the kind of dobj  
        if (dprep.startsWith('aus|von')) {
            local obj = getDobj();
            if (obj.ofKind(Container))
                dprep = dprep.findReplace('aus|von', 'aus', ReplaceAll);
            else
                dprep = dprep.findReplace('aus|von', 'von', ReplaceAll);
        }
        
        // German: If we have a dative flag ... cut it off and set dcase
        if (dprep.endsWith('dativ'))
        {
            dcase = true;
            dprep = dprep.substr(1 ,dprep.length() - 5);
        }
        if (dprep.endsWith(' '))
        {
            dprep = dprep.substr(1 ,dprep.length() - 1);
        }
        
        /* do any verb-specific adjustment of the preposition */
        if (dprep != nil)
            dprep = adjustDefaultObjectPrep(dprep, getDobj());

        /*
         *   if the direct object is not a pronoun, put the complementizer
         *   BEFORE the direct object (the 'up' in "PICKING UP THE BOX")
         */
        
        if (dcase == true)
        {
            dobj = getDobj();
            dobjText = dobj.demName;
        }
        else
        {
            dobj = getDobj();
            dobjText = dobj.denName;
        }
             
        /* add the direct object, using the pronoun form if applicable */
        
        // ############################################################################
        // ## 1object 2verb: (erst den apfel nehmen) or (erst in die Dusche steigen) ##
        // ############################################################################
        
        if (!inf) 
            ret += spPrefix(vcomp); 

        /* add the direct object preposition */
        ret = spPrefix(dprep) + ' ' + dobjText + ' ' + ret;
        
        /*
         *   if there's any suffix following the direct object
         *   placeholder, add it at the end of the phrase
         */
        
        ret += rexGroup(4)[3];
        
        /* return the complete phrase string */
        return ret;
    }
;

/*
 *   English-specific additions for two-object verbs.
 */
modify TIAction
    /*
     *   Flag: omit the indirect object in a query for a missing direct
     *   object.  For many verbs, if we already know the indirect object
     *   and we need to ask for the direct object, the query sounds best
     *   when it includes the indirect object: "what do you want to put in
     *   it?"  or "what do you want to take from it?".  This is the
     *   default phrasing.
     *
     *   However, the corresponding query for some verbs sounds weird:
     *   "what do you want to dig in with it?" or "whom do you want to ask
     *   about it?".  For such actions, this property should be set to
     *   true to indicate that the indirect object should be omitted from
     *   the queries, which will change the phrasing to "what do you want
     *   to dig in", "whom do you want to ask", and so on.
     */
    omitIobjInDobjQuery = nil

    /*
     *   For VerbRules: does this verb rule have a prepositional or
     *   structural phrasing of the direct and indirect object slots?  That
     *   is, are the object slots determined by a prepositional marker, or
     *   purely by word order?  For most English verbs with two objects,
     *   the indirect object is marked by a preposition: GIVE BOOK TO BOB,
     *   PUT BOOK IN BOX.  There are a few English verbs that don't include
     *   any prespositional markers for the objects, though, and assign the
     *   noun phrase roles purely by the word order: GIVE BOB BOOK, SHOW
     *   BOB BOOK, THROW BOB BOOK.  We define these phrasings with separate
     *   verb rules, which we mark with this property.
     *
     *   We use this in ranking verb matches.  Non-prepositional verb
     *   structures are especially prone to matching where they shouldn't,
     *   because we can often find a way to pick out words to fill the
     *   slots in the absence of any marker words.  For example, GIVE GREEN
     *   BOOK could be interpreted as GIVE BOOK TO GREEN, where GREEN is
     *   assumed to be an adjective-ending noun phrase; but the player
     *   probably means to give the green book to someone who they assumed
     *   would be filled in as a default.  So, whenever we find an
     *   interpretation that involves a non-prespositional phrasing, we'll
     *   use this flag to know we should be suspicious of it and try
     *   alternative phrasing first.
     *
     *   Most two-object verbs in English use prepositional markers, so
     *   we'll set this as the default.  Individual VerbRules that use
     *   purely structural phrasing should override this.
     */
    isPrepositionalPhrasing = true

    /* resolve noun phrases */
    resolveNouns(issuingActor, targetActor, results)
    {
        /*
         *   If we're a non-prepositional phrasing, it means that we have
         *   the VERB IOBJ DOBJ word ordering (as in GIVE BOB BOX or THROW
         *   BOB COIN).  For grammar match ranking purposes, give these
         *   phrasings a lower match probability when the dobj phrase
         *   doesn't have a clear qualifier.  If the dobj phrase starts
         *   with 'the' or a qualifier word like that (GIVE BOB THE BOX),
         *   then it's pretty clear that the structural phrasing is right
         *   after all; but if there's no qualifier, we could reading too
         *   much into the word order.  We could have something like GIVE
         *   GREEN BOX, where we *could* treat this as two objects, but we
         *   could just as well have a missing indirect object phrase.
         */
        if (!isPrepositionalPhrasing)
        {
            /*
             *   If the direct object phrase starts with 'a', 'an', 'the',
             *   'some', or 'any', the grammar is pretty clearly a good
             *   match for the non-prepositional phrasing.  Otherwise, it's
             *   suspect, so rank it accordingly.
             */
            if (rexMatch('(ein|einen|eine|einem|das|den|dem|der)<space>',
                         dobjMatch.getOrigText()) == nil)
            {
                /* note this as weak phrasing level 100 */
                results.noteWeakPhrasing(100);
            }
        }

        /* inherit the base handling */
        inherited(issuingActor, targetActor, results);
    }

    /* get the interrogative for one of our objects */
    whatObj(which)
    {
        switch (which)
        {
        case DirectObject:
            /*
             *   the direct object interrogative is the first word in
             *   parentheses in our verbPhrase string
             */
            rexSearch('<lparen>.*?(<alpha>+)<rparen>', verbPhrase);
            break;

        case IndirectObject:
            /*
             *   the indirect object interrogative is the second
             *   parenthesized word in our verbPhrase string
             */
            rexSearch('<rparen>.*<lparen>.*?(<alpha>+)<rparen>', verbPhrase);
            break;
        }

        /* show the group match */
        return whatTranslate(rexGroup(1)[3]);
    }

    /* announce a default object used with this action */
    announceDefaultObject(obj, whichObj, resolvedAllObjects)
    {
        local verb;
        local prep;
        local distName;       // ##### new local var for distName #####
        curcase.d_flag = nil; // ##### set dative flag to NIL     #####
        
        /* presume we won't have a verb or preposition */
        verb = '';
        prep = '';

        /*
         *   Check the full phrasing - if we're showing the direct object,
         *   but an indirect object was supplied, use the verb's
         *   participle form ("asking bob") in the default string, since
         *   we must clarify that we're not tagging the default string on
         *   to the command line.  Don't include the participle form if we
         *   don't know all the objects yet, since in this case we are in
         *   fact tagging the default string onto the command so far, as
         *   there's nothing else in the command to get in the way.
         */
        if (whichObj == IndirectObject && resolvedAllObjects) //VORHER == directObject 
        
        // #####################################################
        // ## we place the verb in the indirect object phrase ##
        // ## (die Banane)                                    ##
        // ## (dem Affen geben)                               ##
        // #####################################################
            
        {
            /*
             *   extract the verb's participle form (including any
             *   complementizer phrase)
             */
            rexSearch('/(<^lparen>+) <lparen>', verbPhrase);
            verb = rexGroup(1)[3];
        }

        /* get the preposition to use, if any */
        switch(whichObj)
        {
        case DirectObject:
            /* use the preposition in the first "(what)" phrase */
            rexSearch('<lparen>(.*?)<space>*<alpha>+<rparen>', verbPhrase);
            prep = rexGroup(1)[3];
            
            // -- German: replace aus|von depending on the kind of dobj  
            if (prep.startsWith('aus|von')) {
                local obj = getDobj();
                if (obj.ofKind(Container))
                    prep = prep.findReplace('aus|von', 'aus', ReplaceAll);
                else
                    prep = prep.findReplace('aus|von', 'von', ReplaceAll);
            }
            
            break;

        case IndirectObject:
            /* use the preposition in the second "(what)" phrase */
            rexSearch('<rparen>.*<lparen>(.*?)<space>*<alpha>+<rparen>',
                      verbPhrase);
            prep = rexGroup(1)[3];
            
            // -- German: replace aus|von depending on the kind of dobj  
            if (prep.startsWith('aus|von')) {
                local obj = getIobj();
                if (obj.ofKind(Container))
                    prep = prep.findReplace('aus|von', 'aus', ReplaceAll);
                else
                    prep = prep.findReplace('aus|von', 'von', ReplaceAll);
            }
            
            break;
        }
        
        if (prep.endsWith('dativ'))
        {
            curcase.d_flag = true;
            prep = prep.substr(1 ,prep.length() - 5);
        }

        if (prep.endsWith(' '))
        {
            prep = prep.substr(1 ,prep.length() - 1);
        }
        
        // ##### obj.getAnnouncementDistinguisher(); old in 3.0.18 #####
        obj.getAnnouncementDistinguisher(gActor.scopeList()); 
        
        if (curcase.d_flag)
            distName = obj.demName;
        else
            distName = obj.denName;
            
        /* build and return the complete phrase */
        if (verb == '')
            return spSuffix(prep) + distName; // ##### place verb at end #####
        else
            return spSuffix(prep) + spSuffix(distName) + verb; // ##### place verb at end #####
    }

    /* announce all defaulted objects */
    announceAllDefaultObjects(allResolved)
    {
        /* announce a defaulted direct object if appropriate */
        maybeAnnounceDefaultObject(dobjList_, DirectObject, allResolved);

        /* announce a defaulted indirect object if appropriate */
        maybeAnnounceDefaultObject(iobjList_, IndirectObject, allResolved);
    }

    /* show the verb's basic infinitive form for an interrogative */
    getQuestionInf(which)
    {
        local ret;
        local vcomp;
        local dprep;
        local iprep;
        local pro;

        /*
         *   Our verb phrase can one of three formats, depending on which
         *   object role we're asking about (the part in <angle brackets>
         *   is the part we're responsible for generating).  In these
         *   formats, 'verb' is the verb infinitive; 'comp' is the
         *   complementizer, if any (e.g., the 'up' in 'pick up'); 'dprep'
         *   is the direct object preposition (the 'in' in 'dig in x with
         *   y'); and 'iprep' is the indirect object preposition (the
         *   'with' in 'dig in x with y').
         *
         *   asking for dobj: verb vcomp dprep iprep it ('what do you want
         *   to <open with it>?', '<dig in with it>', '<look up in it>').
         *
         *   asking for dobj, but suppressing the iobj part: verb vcomp
         *   dprep ('what do you want to <turn>?', '<look up>?', '<dig
         *   in>')
         *
         *   asking for iobj: verb dprep it vcomp iprep ('what do you want
         *   to <open it with>', '<dig in it with>', '<look it up in>'
         */

        /* parse the verbPhrase into its component parts */
        rexMatch('(.*)/<alphanum|-|squote>+(?:<space>+(<^lparen>*))?'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>',
                 verbPhrase);
        
        /* pull out the verb */
        ret = rexGroup(1)[3];

        /* pull out the verb complementizer */
        vcomp = (rexGroup(2) == nil ? '' : rexGroup(2)[3]);

        /* pull out the direct and indirect object prepositions */
        dprep = rexGroup(3)[3];
        iprep = rexGroup(4)[3];

        /* get the pronoun for the other object phrase */
        pro = getOtherMessageObjectPronoun(which);

        /* check what we're asking about */
        if (which == DirectObject)
        {
            /* add the <vcomp dprep> part in all cases */
            ret += spPrefix(vcomp) + spPrefix(dprep);

            /* add the <iprep it> part if we want the indirect object part */
            if (!omitIobjInDobjQuery && pro != nil)
                ret += spPrefix(iprep) + ' ' + pro;
        }
        else
        {
            /* add the <dprep it> part if appropriate */
            if (pro != nil)
                ret += spPrefix(dprep) + ' ' + pro;

            /* add the <vcomp iprep> part */
            ret += spPrefix(vcomp) + spPrefix(iprep);
        }

        /* return the result */
        return ret;
    }
    
    // ########################################################
    // ## TIACTION                                           ##
    // ## parser questions - part 1: "WOMIT WODURCH ETC ..." ##
    // ########################################################
    
    getQuestionWord(which)
    {
        // -- "... TIACTION ..."; -> uncomment for testing
        local dprep;
        local iprep;
        local ddativ;
        local idativ;
        /*
         *   Show the present-tense verb form (removing the participle
         *   part - the "/xxxing" part).  Include any prepositions
         *   attached to the verb itself or to the direct object (inside
         *   the "(what)" parens).
         */
        rexMatch('(.*)/<alphanum|-|squote>+(?:<space>+(<^lparen>*))?'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>',
                 verbPhrase);
        dprep = rexGroup(3)[3];
        dprep = dprep.toLower();
        iprep = rexGroup(4)[3];
        iprep = iprep.toLower();
        ddativ = nil;
        idativ = nil;
        
        if (which == DirectObject)
        {
            
            // ##### German: replace aus|von depending on the kind of dobj #####
            if (dprep.startsWith('aus|von')) {
                local obj = getDobj();
                if (obj.ofKind(Container))
                    dprep = dprep.findReplace('aus|von', 'aus', ReplaceAll);
                else
                    dprep = dprep.findReplace('aus|von', 'von', ReplaceAll);
            }
            
            // ##### looking for dative flag ... #####
            if (dprep.endsWith('dativ'))
            {
                dprep = dprep.substr(1 ,dprep.length() - 5);
                ddativ = true;
            }
        
            if (dprep.endsWith(' '))
            {
                dprep = dprep.substr(1 ,dprep.length() - 1);
            }     
        
            if (dprep == '')
                return whatObj(which);
            if (dprep == 'in' && !ddativ)
                return 'Wore' + dprep;
            else if (dprep.startsWith('i') || dprep.startsWith('a') || dprep.startsWith('o')
                || dprep.startsWith('e') || dprep.startsWith('u') || dprep.startsWith('ü')
                || dprep.startsWith('ö') || dprep.startsWith('ä'))
                return 'Wor' + dprep;
            else
                return 'Wo' + dprep;
        }
        // ##### do we have an indirect object ? #####
        
        else
        {
            
            // ##### German: replace aus|von depending on the kind of dobj #####
            if (iprep.startsWith('aus|von')) {
                local obj = getIobj();
                if (obj.ofKind(Container))
                    iprep = iprep.findReplace('aus|von', 'aus', ReplaceAll);
                else
                    iprep = iprep.findReplace('aus|von', 'von', ReplaceAll);
            }
            
            // ##### checking for dative flag ... #####
            if (iprep.endsWith('dativ'))
            {
                iprep = iprep.substr(1 ,iprep.length() - 5);
                idativ = true;
            }
        
            if (iprep.endsWith(' '))
            {
                iprep = iprep.substr(1 ,iprep.length() - 1);
            }     
        
            if (iprep == '')
                return whatObj(which);
            if (iprep == 'in' && !idativ)
                return 'Wore' + iprep;
            else if (iprep.startsWith('i') || iprep.startsWith('a') || iprep.startsWith('o')
                || iprep.startsWith('e') || iprep.startsWith('u') || iprep.startsWith('ü')
                || iprep.startsWith('ö') || iprep.startsWith('ä'))
                return 'Wor' + iprep;
            else
                return 'Wo' + iprep;
        }        

    }
    
    // ################################################
    // ## German: modified version of getQuestionInf ##
    // ## "WOMIT WILLST DU IN DEM BEET GRABEN?"      ##
    // ## "WORIN WILLST DU MIT DEM SPATEN GRABEN?"   ##
    // ################################################
    
    getQuestionObject(which)
    {
        local ret;
        local vcomp;
        local dprep;
        local iprep;
        local pro;
        local icase;
        local dcase;

        /*
         *   Our verb phrase can one of three formats, depending on which
         *   object role we're asking about (the part in <angle brackets>
         *   is the part we're responsible for generating).  In these
         *   formats, 'verb' is the verb infinitive; 'comp' is the
         *   complementizer, if any (e.g., the 'up' in 'pick up'); 'dprep'
         *   is the direct object preposition (the 'in' in 'dig in x with
         *   y'); and 'iprep' is the indirect object preposition (the
         *   'with' in 'dig in x with y').
         *
         *   asking for dobj: verb vcomp dprep iprep it ('what do you want
         *   to <open with it>?', '<dig in with it>', '<look up in it>').
         *
         *   asking for dobj, but suppressing the iobj part: verb vcomp
         *   dprep ('what do you want to <turn>?', '<look up>?', '<dig
         *   in>')
         *
         *   asking for iobj: verb dprep it vcomp iprep ('what do you want
         *   to <open it with>', '<dig in it with>', '<look it up in>'
         */

        /* parse the verbPhrase into its component parts */
        rexMatch('(.*)/<alphanum|-|squote>+(?:<space>+(<^lparen>*))?'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>',
                 verbPhrase);

        /* pull out the verb*/
        ret = '';
        /* pull out the verb complementizer */
        vcomp = (rexGroup(2) == nil ? '' : rexGroup(2)[3]);

        // ##### set dcase and icase flags to NIL #####
        icase = nil;
        dcase = nil;
        /* pull out the direct and indirect object prepositions */
        dprep = rexGroup(3)[3];
        iprep = rexGroup(4)[3];

        curcase.d_flag = nil;
        
        // ##### replace aus|von depending on the kind of dobj #####
        if (dprep.startsWith('aus|von')) {
            local obj = getDobj();
            if (obj.ofKind(Container))
                dprep = dprep.findReplace('aus|von', 'aus', ReplaceAll);
            else
                dprep = dprep.findReplace('aus|von', 'von', ReplaceAll);
        }
        
        // ##### set dcase and icase flags if dativ token ... #####
        if (dprep.endsWith('dativ'))
        {
            dcase = true;
            dprep = dprep.substr(1 ,dprep.length() - 5);
        }
        // ##### cut dative token, if there is one #####
        if (dprep.endsWith(' '))
        {
            dprep = dprep.substr(1 ,dprep.length() - 1);
        }
        
        // ##### German: replace aus|von depending on the kind of dobj #####
        if (iprep.startsWith('aus|von')) {
            local obj = getIobj();
            if (obj.ofKind(Container))
                iprep = iprep.findReplace('aus|von', 'aus', ReplaceAll);
            else
                iprep = iprep.findReplace('aus|von', 'von', ReplaceAll);
        }
        
        // ##### cut blank if there is one #####
        if (iprep.endsWith('dativ'))
        {
            icase = true;
            iprep = iprep.substr(1 ,iprep.length() - 5);
        }        
        // ##### cut dative token, if there is one #####
        if (iprep.endsWith(' '))
        {
            iprep = iprep.substr(1 ,iprep.length() - 1);
        }   
        // ##### cut blank if there is one #####
        // ##### decide whether dativ token is active #####
        if (which == DirectObject && icase == true)
            curcase.d_flag = true;
        if (which == IndirectObject && dcase == true)
            curcase.d_flag = true;
        
        /* get the pronoun for the other object phrase */
        pro = getOtherMessageObjectPronoun(which);

        /* check what we're asking about */
        if (which == DirectObject)
        {
            /* add the <vcomp dprep> part in all cases */
            ret += spPrefix(vcomp) + spPrefix(dprep);

            /* add the <iprep it> part if we want the indirect object part */
            if (!omitIobjInDobjQuery && pro != nil)
                ret += spPrefix(iprep) + ' ' + pro + ' ';
        }
        else
        {
            /* add the <dprep it> part if appropriate */
            if (pro != nil)
                ret += spPrefix(dprep) + ' ' + pro + ' ';

            /* add the <vcomp iprep> part */
            ret += spPrefix(vcomp);
        }

        /* return the result */
        return ret;
   }
    
    /*
     *   Get the pronoun for the message object in the given role.
     */
    getOtherMessageObjectPronoun(which)
    {
        local lst;

        /*
         *   Get the resolution list (or tentative resolution list) for the
         *   *other* object, since we want to show a pronoun representing
         *   the other object.  If we don't have a fully-resolved list for
         *   the other object, use the tentative resolution list, which
         *   we're guaranteed to have by the time we start resolving
         *   anything (and thus by the time we need to ask for objects).
         */
        lst = (which == DirectObject ? iobjList_ : dobjList_);
        if (lst == nil || lst == [])
            lst = (which == DirectObject
                   ? tentativeIobj_ : tentativeDobj_);

        /* if we found an object list, use the pronoun for the list */
        if (lst != nil && lst != [])
        {
            /* we got a list - return a suitable pronoun for this list */
            return objListPronoun(lst);
        }
        else
        {
            /* there's no object list, so there's no pronoun */
            return nil;
        }
    }

    /* get the verb phrase in infinitive or participle form */
    getVerbPhrase(inf, ctx)
    {
        local dobj, dobjText, dobjIsPronoun;
        local iobj, iobjText;
        local ret;

        /* use the default context if one wasn't supplied */
        if (ctx == nil)
            ctx = defaultGetVerbPhraseContext;

        /* get the direct object information */
        dobj = getDobj();
        dobjText = ctx.objNameObj(dobj);
        dobjIsPronoun = ctx.isObjPronoun(dobj);

        /* get the indirect object information */
        iobj = getIobj();
        iobjText = (iobj != nil ? ctx.objNameObj(iobj) : nil);

        /* get the phrasing */
        ret = getVerbPhrase2(inf, verbPhrase,
                             dobjText, dobjIsPronoun, iobjText);

        /*
         *   Set the antecedent for the next verb phrase.  Our direct
         *   object is normally the antecedent; however, if the indirect
         *   object matches the current antecedent, keep the current
         *   antecedent, so that 'it' (or whatever) remains the same for
         *   the next verb phrase.
         */
        if (ctx.pronounObj != iobj)
            ctx.setPronounObj(dobj);

        /* return the result */
        return ret;
    }

    /*
     *   Get the verb phrase for a two-object (dobj + iobj) phrasing.  This
     *   is a class method, so that it can be reused by unrelated (i.e.,
     *   non-TIAction) classes that also use two-object syntax but with
     *   other internal structures.  This is the two-object equivalent of
     *   TAction.getVerbPhrase1().
     */
    getVerbPhrase2(inf, vp, dobjText, dobjIsPronoun, iobjText)
    {
        local ret;
        local vcomp;
        local dprep, iprep;
        local dcase, icase;
        local dobj, iobj;
        
        dcase = nil;
        icase = nil;

        /* parse the verbPhrase into its component parts */
        rexMatch('(.*)/(.*)'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>',
                 vp);

        local verbInf = rexGroup(1)[3];
        local verb = rexGroup(2)[3];
        
        /* start off with the infinitive or participle, as desired */
        ret = ''; // ##### first set ret to '' #####

        /* get the complementizer */
        vcomp = '';

        /* get the direct and indirect object prepositions */
        dprep = rexGroup(3)[3];
        iprep = rexGroup(4)[3];

        // ##### replace aus|von depending on the kind of dobj #####
        if (dprep.startsWith('aus|von')) {
            local obj = getDobj();
            if (obj.ofKind(Container))
                dprep = dprep.findReplace('aus|von', 'aus', ReplaceAll);
            else
                dprep = dprep.findReplace('aus|von', 'von', ReplaceAll);
        }
        
        // ##### If we have a dative flag ... cut it off and set dcase #####
        if (dprep.endsWith('dativ'))
        {
            dcase = true;
            dprep = dprep.substr(1 ,dprep.length() - 5);
        }
        if (dprep.endsWith(' '))
        {
            dprep = dprep.substr(1 ,dprep.length() - 1);
        }
        
        // ##### replace aus|von depending on the kind of iobj #####
        if (iprep.startsWith('aus|von')) {
            local obj = getIobj();
            if (obj.ofKind(Container))
                iprep = iprep.findReplace('aus|von', 'aus', ReplaceAll);
            else
                iprep = iprep.findReplace('aus|von', 'von', ReplaceAll);
        }
        
        // ##### If we have a dative flag ... cut it off and set icase #####   
        if (iprep.endsWith('dativ'))
        {
            icase = true;
            iprep = iprep.substr(1 ,iprep.length() - 5);
        }        
        // ##### cut blank if there is one #####
        if (iprep.endsWith(' '))
        {
            iprep = iprep.substr(1 ,iprep.length() - 1);
        } 
        
        /*
         *   add the complementizer BEFORE the direct object, if the
         *   direct object is being shown as a full name ("PICK UP BOX")
         */
        if (!dobjIsPronoun)
            ret += spPrefix(vcomp);

        /*
         *   add the direct object and its preposition, using a pronoun if
         *   applicable
         */
        
        if (dcase == true)
        {
            dobj = getDobj();
            dobjText = dobj.demName;
        }
        ret += spPrefix(dprep) + ' ' + dobjText;

        /*
         *   add the complementizer AFTER the direct object, if the direct
         *   object is shown as a pronoun ("PICK IT UP")
         */
        if (dobjIsPronoun)
            ret += spPrefix(vcomp);

        if (icase == true)
        {
            iobj = getIobj();
            if (iobj != nil)
                iobjText = iobj.demName;
        }
        /* if we have an indirect object, add it with its preposition */
        if (iobjText != nil)
            ret += spPrefix(iprep) + ' ' + iobjText;
      
        if (inf)
            ret+= ' ' + verbInf;
        else
            ret += ' ' + verb;
        
        /* return the result phrase */
        
        return ret;
    }
;

/*
 *   English-specific additions for verbs taking a literal phrase as the
 *   sole object.
 */
modify LiteralAction
    /* provide a base verbPhrase, in case an instance leaves it out */
    verbPhrase = 'zu tun/tun (was)'

    /* get an interrogative word for an object of the action */
    whatObj(which)
    {
        /* use the same processing as TAction */
        return delegated TAction(which);
    }

    getVerbPhrase(inf, ctx)
    {
        /* handle this as though the literal were a direct object phrase */
        return TAction.getVerbPhrase1(inf, verbPhrase, gLiteral, nil);
    }

    getQuestionInf(which)
    {
        /* use the same handling as for a regular one-object action */
        return delegated TAction(which);
    }

    getQuestionWord(which)
    {
        /* use the same handling as for a regular one-object action */
        return delegated TAction(which);
    }
    
;

/*
 *   English-specific additions for verbs of a direct object and a literal
 *   phrase.
 */
modify LiteralTAction
    announceDefaultObject(obj, whichObj, resolvedAllObjects)
    {
        /*
         *   Use the same handling as for a regular two-object action.  We
         *   can only default the actual object in this kind of verb; the
         *   actual object always fills the DirectObject slot, but in
         *   message generation it might use a different slot, so use the
         *   message generation slot here.
         */
        return delegated TIAction(obj, whichMessageObject,
                                  resolvedAllObjects);
    }

    whatObj(which)
    {
        /* use the same handling we use for a regular two-object action */
        return delegated TIAction(which);
    }

    getQuestionObject(which)
    {
        /* use the same handling we use for a regular two-object action */
        return delegated TIAction(which);
    }
        
    getQuestionInf(which)
    {
        /*
         *   use the same handling as for a two-object action (but note
         *   that we override getMessageObjectPronoun(), which will affect
         *   the way we present the verb infinitive in some cases)
         */
        return delegated TIAction(which);
    }

    getQuestionWord(which)
    {
        /* use the same handling as for a regular one-object action */
        return delegated TIAction(which);
    }
    
    /*
     *   When we want to show a verb infinitive phrase that involves a
     *   pronoun for the literal phrase, refer to the literal as 'that'
     *   rather than 'it' or anything else.
     */
    getOtherMessageObjectPronoun(which)
    {
        /*
         *   If we're asking about the literal phrase, then the other
         *   pronoun is for the resolved object: so, return the pronoun
         *   for the direct object phrase, because we *always* store the
         *   non-literal in the direct object slot, regardless of the
         *   actual phrasing of the action.
         *
         *   If we're asking about the resolved object (i.e., not the
         *   literal phrase), then return 'that' as the pronoun for the
         *   literal phrase.
         */
        if (which == whichMessageLiteral)
        {
            /*
             *   we're asking about the literal, so the other pronoun is
             *   for the resolved object, which is always in the direct
             *   object slot (so the 'other' slot is effectively the
             *   indirect object)
             */
            return delegated TIAction(IndirectObject);
        }
        else
        {
            /*
             *   We're asking about the resolved object, so the other
             *   pronoun is for the literal phrase: always use 'that' to
             *   refer to the literal phrase.
             */
            return 'das';
        }
    }

    getVerbPhrase(inf, ctx)
    {
        local dobj, dobjText, dobjIsPronoun;
        local litText;
        local ret;

        /* use the default context if one wasn't supplied */
        if (ctx == nil)
            ctx = defaultGetVerbPhraseContext;

        /* get the direct object information */
        dobj = getDobj();
        dobjText = ctx.objNameObj(dobj);
        dobjIsPronoun = ctx.isObjPronoun(dobj);

        /* get our literal text */
        litText = gLiteral;

        /*
         *   Use the standard two-object phrasing.  The order of the
         *   phrasing depends on whether our literal phrase is in the
         *   direct or indirect object slot.
         */
        if (whichMessageLiteral == DirectObject)
            ret = TIAction.getVerbPhrase2(inf, verbPhrase,
                                          litText, nil, dobjText);
        else
            ret = TIAction.getVerbPhrase2(inf, verbPhrase,
                                          dobjText, dobjIsPronoun, litText);

        /* use the direct object as the antecedent for the next phrase */
        ctx.setPronounObj(dobj);

        /* return the result */
        return ret;
    }
;

/*
 *   English-specific additions for verbs taking a topic phrase as the sole
 *   object.  
 */
modify TopicAction
    /* get an interrogative word for an object of the action */
    whatObj(which)
    {
        /* use the same processing as TAction */
        return delegated TAction(which);
    }

    getVerbPhrase(inf, ctx)
    {
        /* handle this as though the topic text were a direct object phrase */
        return TAction.getVerbPhrase1(
            inf, verbPhrase, getTopic().getTopicText().toLower(), nil);
    }

    getQuestionInf(which)
    {
        /* use the same handling as for a regular one-object action */
        return delegated TAction(which);
    }
	 
    getQuestionWord(which)
    {
        /* use the same handling as for a regular one-object action */
        return delegated TAction(which);
    }

;

/*
 *   English-specific additions for verbs with topic phrases.
 */
modify TopicTAction
    announceDefaultObject(obj, whichObj, resolvedAllObjects)
    {
        /*
         *   Use the same handling as for a regular two-object action.  We
         *   can only default the actual object in this kind of verb; the
         *   actual object always fills the DirectObject slot, but in
         *   message generation it might use a different slot, so use the
         *   message generation slot here.
         */
        return delegated TIAction(obj, whichMessageObject,
                                  resolvedAllObjects);
    }

    whatObj(which)
    {
        /* use the same handling we use for a regular two-object action */
        return delegated TIAction(which);
    }

    getQuestionInf(which)
    {
        /* use the same handling as for a regular two-object action */
        return delegated TIAction(which);
    }

    getOtherMessageObjectPronoun(which)
    {
        /*
         *   If we're asking about the topic, then the other pronoun is
         *   for the resolved object, which is always in the direct object
         *   slot.  If we're asking about the resolved object, then return
         *   a pronoun for the topic.
         */
        if (which == whichMessageTopic)
        {
            /*
             *   we want the pronoun for the resolved object, which is
             *   always in the direct object slot (so the 'other' slot is
             *   effectively the indirect object)
             */
            return delegated TIAction(IndirectObject);
        }
        else
        {
            /* return a generic pronoun for the topic */
            return 'so etwas';
        }
    }

    getVerbPhrase(inf, ctx)
    {
        local dobj, dobjText, dobjIsPronoun;
        local topicText;
        local ret;

        /* use the default context if one wasn't supplied */
        if (ctx == nil)
            ctx = defaultGetVerbPhraseContext;

        /* get the direct object information */
        dobj = getDobj();
        dobjText = ctx.objNameObj(dobj);
        dobjIsPronoun = ctx.isObjPronoun(dobj);

        /* get our topic phrase */
        topicText = getTopic().getTopicText().toLower();

        /*
         *   Use the standard two-object phrasing.  The order of the
         *   phrasing depends on whether our topic phrase is in the direct
         *   or indirect object slot.
         */
        if (whichMessageTopic == DirectObject)
            ret = TIAction.getVerbPhrase2(inf, verbPhrase,
                                          topicText, nil, dobjText);
        else
            ret = TIAction.getVerbPhrase2(inf, verbPhrase,
                                          dobjText, dobjIsPronoun, topicText);

        /* use the direct object as the antecedent for the next phrase */
        ctx.setPronounObj(dobj);

        /* return the result */
        return ret;
    }	  

    getQuestionWord(which)
    {
        local dprep;
        local iprep;
        local ddativ;
        local idativ;
        /*
         *   Show the present-tense verb form (removing the participle
         *   part - the "/xxxing" part).  Include any prepositions
         *   attached to the verb itself or to the direct object (inside
         *   the "(what)" parens).
         */
        rexMatch('(.*)/<alphanum|-|squote>+(?:<space>+(<^lparen>*))?'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>'
                 + '<space>+<lparen>(.*?)<space>*<alpha>+<rparen>',
                 verbPhrase);
        dprep = rexGroup(3)[3];
        dprep = dprep.toLower();
        iprep = rexGroup(4)[3];
        iprep = iprep.toLower();
        ddativ = nil;
        idativ = nil;
        
        if (which == DirectObject)
        {
            
            // ##### replace aus|von depending on the kind of dobj #####
            if (dprep.startsWith('aus|von')) {
                local obj = getDobj();
                if (obj.ofKind(Container))
                    dprep = dprep.findReplace('aus|von', 'aus', ReplaceAll);
                else
                    dprep = dprep.findReplace('aus|von', 'von', ReplaceAll);
            }
            
            // ##### cut dativ token if there is one ... #####
            if (dprep.endsWith('dativ'))
            {
                dprep = dprep.substr(1 ,dprep.length() - 5);
                ddativ = true;
            }
        
            if (dprep.endsWith(' '))
            {
                dprep = dprep.substr(1 ,dprep.length() - 1);
            }     
        
            if (dprep == '')
                return whatObj(which);
            if (dprep == 'in' && !ddativ)
                return 'Wore' + dprep;
            else if (dprep.startsWith('i') || dprep.startsWith('a') || dprep.startsWith('o')
                || dprep.startsWith('e') || dprep.startsWith('u') || dprep.startsWith('ü')
                || dprep.startsWith('ö') || dprep.startsWith('ä'))
                return 'Wor' + dprep;
            else
                return 'Wo' + dprep;
        }
        // ##### do we have a topic object? #####
        else
        {
            
            // ##### replace aus|von depending on the kind of dobj #####
            if (iprep.startsWith('aus|von')) {
                local obj = getIobj();
                if (obj.ofKind(Container))
                    iprep = iprep.findReplace('aus|von', 'aus', ReplaceAll);
                else
                    iprep = iprep.findReplace('aus|von', 'von', ReplaceAll);
            }
            
            // ##### check for dative flag ... #####
            if (iprep.endsWith('dativ'))
            {
                iprep = iprep.substr(1 ,iprep.length() - 5);
                idativ = true;
            }
        
            if (iprep.endsWith(' '))
            {
                iprep = iprep.substr(1 ,iprep.length() - 1);
            }     
        
            if (iprep == '')
                return whatObj(which);
            if (iprep == 'in' && !idativ)
                return 'Wore' + iprep;
            else if (iprep.startsWith('i') || iprep.startsWith('a') || iprep.startsWith('o')
                || iprep.startsWith('e') || iprep.startsWith('u') || iprep.startsWith('ü')
                || iprep.startsWith('ö') || iprep.startsWith('ä'))
                return 'Wor' + iprep;
            else
                return 'Wo' + iprep;
        }        
    }
;

// #############################################
// ## VERB RULES modified for German language ##
// #############################################

/* ------------------------------------------------------------------------ */
/*
 *   Verbs.
 *
 *   The actual body of each of our verbs is defined in the main
 *   language-independent part of the library.  We only define the
 *   language-specific grammar rules here.
 */

// ##########
// TakeAction
// ##########

VerbRule(Nimm)
    verb('nimm','nehm','pack','greif') (|'dir') dobjList
    | verb('lies','nimm','nehm') dobjList prep('auf','mit')
    | verb('steck') 'dir' dobjList prep('ein') 
    : TakeAction
    verbPattern('zu nehmen/nehmen', '(was)')
;

// ##############
// TakeFromAction
// ##############

// ##### we say 'etwas AUS der Kiste nehmen', but 'etwas VON dem Tisch nehmen' #####
VerbRule(NimmVon)
    verb('nimm','nehm','pack','greif','entfern') dobjList prep('von','aus') singleIobj
    | verb('nimm','nehm','pack','greif') 'dir' dobjList prep('von','aus') singleIobj
    : TakeFromAction
    verbPattern('zu nehmen/nehmen', '(was) (aus|von dativ was)')
;

// ############
// RemoveAction
// ############

VerbRule(Entfern)
    verb('entfern') dobjList |
    verb('heb','zieh','reiß') dobjList prep('hinunter','hinaus') 
    : RemoveAction
    verbPattern('zu entfernen/entfernen', '(was)')
;

// ##########
// DropAction
// ##########

VerbRule(LegAb)
    verb('leg','lege','stell','stelle') dobjList prep('ab','hin','weg')
    | verb('lass') dobjList prep('fallen','hier')    
    : DropAction
    verbPattern('abzulegen/ablegen', '(was)')
;

// #############
// ExamineAction
// #############

VerbRule(Untersuch)
    verb('untersuch','betracht','schau','sieh','seh') dobjList
    | verb('schau','sieh','seh') dobjList prep('an')
    | ('u'|'x'|'b') dobjList
    : ExamineAction
    verbPattern('zu betrachten/betrachten', '(was)')
;

// ##########
// ReadAction
// ##########

VerbRule(Lies)
    verb('lies','les','studier','entziffer') dobjList
    : ReadAction
    verbPattern('zu lesen/lesen', '(was)')
;

// ############
// LookInAction
// ############

VerbRule(SchauIn)
    verb('such') 'in' dobjList
    | verb('schau','sieh','seh') 'in' dobjList (|'hinein') 
    : LookInAction
    verbPattern('zu schauen/schauen', '(in was)')
;

// ################
// LookVagueActions
// ################

// -- in German we have a common use of
// -- untersuche schrank .....
// -- schau hinein (whereas "hinein" refers to the last mentioned object)

DefineIAction(LookInVague)
    execAction() {
        if (gLastObj != nil)
            replaceAction(LookIn, gLastObj);
        else
            "Ich weiß nicht, worauf sich <q>hinein</q> bezieht. ";
    }    
;

DefineIAction(LookOutVague)
    execAction() {
        if (gLastObj != nil)
            replaceAction(LookIn, gLastObj);
        else
            "Ich weiß nicht, worauf sich <q>hinaus</q> bezieht. ";
    }    
;

DefineIAction(LookThroughVague)
    execAction() {
        if (gLastObj != nil)
            replaceAction(LookThrough, gLastObj);
        else
            "Ich weiß nicht, worauf sich <q>hindurch</q> bezieht. ";
    }    
;

DefineIAction(LookUnderVague)
    execAction() {
        if (gLastObj != nil)
            replaceAction(LookUnder, gLastObj);
        else
            "Ich weiß nicht, worauf sich <q>darunter</q> bezieht. ";
    }    
;

DefineIAction(LookBehindVague)
    execAction() {
        if (gLastObj != nil)
            replaceAction(LookBehind, gLastObj);
        else
            "Ich weiß nicht, worauf sich <q>dahinter</q> bezieht. ";
    }
;

VerbRule(SchauHinein)
    ('schau'|'sieh'|'seh') 'hinein'
    : LookInVagueAction
    verbPhrase = 'hineinzuschauen/hineinschauen'
;

VerbRule(SchauHinaus)
    ('schau'|'sieh'|'seh') 'hinaus'
    : LookOutVagueAction
    verbPhrase = 'hinauszuschauen/hinausschauen' 
;

VerbRule(SchauHindurch)
    ('schau'|'sieh'|'seh') 'hindurch'
    : LookThroughVagueAction
    verbPhrase = 'hindurchzuschauen/hindurchschauen' 
;

VerbRule(SchauDarunter)
    ('schau'|'sieh'|'seh') 'darunter' 
    : LookUnderVagueAction
    verbPhrase = 'darunterzuschauen/darunterschauen' 
;

VerbRule(SchauDahinter)
    ('schau'|'sieh'|'seh') 'dahinter'
    : LookBehindVagueAction
    verbPhrase = 'dahinterzuschauen/dahinterschauen' 
;

// ###############
// -- SearchAction
// ###############

VerbRule(Durchsuch)
    verb('durchsuch','durchkämm','durchwühl') dobjList
    | verb('wühl') 'in' dobjList
    | verb('schau','sieh','seh') 'auf' dobjList
    : SearchAction
    verbPattern('zu durchsuchen/durchsuchen', '(was)')
;

// ####################
// -- LookThroughAction
// ####################

VerbRule(SchauDurch)
    verb('blick','blicke','schau','sieh','seh') ('durch'|'aus'|'zu') dobjList (|'hinaus')
    : LookThroughAction
    verbPattern('zu schauen/schauen', '(durch was)')
;

// ##################
// -- LookUnderAction
// ##################

VerbRule(SchauUnter)
    verb('blick','blicke','schau','sieh','seh','such','wühl') 'unter' dobjList (|'nach')
    | verb('blick','blicke','schau','sieh','seh','such','wühl') 'nach' 'unter' dobjList
    : LookUnderAction
    verbPattern('zu schauen/schauen', '(unter was)')
;

// ###################
// -- LookBehindAction
// ###################

VerbRule(SchauHinter)
    verb('blick','blicke','schau','sieh','seh','such','wühl') 'hinter' dobjList (|'nach')
    | verb('blick','blicke','schau','sieh','seh','such','wühl') 'nach' 'hinter' dobjList
    : LookBehindAction
    verbPattern('zu schauen/schauen', '(hinter was)')
;

// #############
// -- FeelAction
// #############

VerbRule(Fuehl)
    verb('berühr','fühl','tast','taste','betast','streif') dobjList
    | verb('fass','fühl') 'an' dobjList
    | verb('fass','fühl') dobjList 'an'
    : FeelAction
    verbPattern('zu berühren/berühren', '(was)')
;

// ##############
// -- TasteAction
// ##############

VerbRule(Schmeck)
    verb('schmeck','leck','probier') dobjList
    | verb('leck','schleck') 'an' dobjList
    : TasteAction
    verbPattern('zu schmecken/schmecken', '(was)')
;

// ##############
// -- SmellAction
// ##############

VerbRule(RiechAn)
    verb('riech','schnüffel','schnüffl','schnupper') dobjList
    | verb('riech','schnüffel','schnüffl','schnupper') 'an' dobjList
    : SmellAction
    verbPattern('zu riechen/riechen', '(an dativ was)')

    /*
     *   use the "not aware" version of the no-match message - the object
     *   of SMELL is often intangible, so the default "you can't see that"
     *   message is often incongruous for this verb
     */
    noMatch(msgObj, actor, txt) { msgObj.noMatchNotAware(actor, txt); }
;

// ######################
// -- SmellImplicitAction
// ######################

VerbRule(RiechImplizit)
    verb('riech','schnüffel','schnüffl','schnupper')
    : SmellImplicitAction
    verbPhrase = 'zu riechen/riechen'
;

// #################
// -- ListenToAction
// #################

VerbRule(HoerAn)
    verb('hör','horch') dobjList 'an'
    | verb('lausch') 'an' dobjList
    : ListenToAction
    verbPattern('zu hören/hören', '(an dativ was)')
    /*
     *   use the "not aware" version of the no-match message - the object
     *   of LISTEN TO is often intangible, so the default "you can't see
     *   that" message is often incongruous for this verb
     */
    noMatch(msgObj, actor, txt) { msgObj.noMatchNotAware(actor, txt); }
    defaultForRecursion = true
;

VerbRule(HoerZu)
    verb('hör') dobjList (|prep('zu'))
    | verb('horch','lausch') dobjList 
    : ListenToAction
    verbPhrase = 'zuzuhören/zuhören (dativ wem)'
    /*
     *   use the "not aware" version of the no-match message - the object
     *   of LISTEN TO is often intangible, so the default "you can't see
     *   that" message is often incongruous for this verb
     */
    noMatch(msgObj, actor, txt) { msgObj.noMatchNotAware(actor, txt); }
;
    
// ######################
// -- ListenImlicitAction
// ######################

VerbRule(HoerImplizit)
    verb('hör','lausch','horch')
    : ListenImplicitAction
    verbPhrase = 'zu hören/hören'
;

// ##############
// -- PutInAction
// ##############

VerbRule(LegIn)
    verb('leg','lege','platzier','pack','stell','stelle') dobjList 'in' singleIobj (|'hinein')
    : PutInAction
    verbPattern('zu legen/legen', '(was) (in was)')
    askIobjResponseProd = inSingleNoun
;

// ##############
// -- PutOnAction
// ##############

VerbRule(LegAuf)
    verb('leg','lege','platzier','pack','stell','stelle') dobjList 'auf' singleIobj
    : PutOnAction
    verbPattern('zu legen/legen', '(was) (auf was)')
    askIobjResponseProd = aufSingleNoun
;

// #################
// -- PutUnderAction
// #################

VerbRule(LegUnter)
    verb('leg','lege','platzier','pack','stell','stelle') dobjList 'unter' singleIobj    
    : PutUnderAction
    verbPattern('zu legen/legen', '(was) (unter was)')
    askIobjResponseProd = unterSingleNoun
;

// ##################
// -- PutBehindAction
// ##################

VerbRule(LegHinter)
    verb('leg','lege','platzier','pack','stell','stelle') dobjList 'hinter' singleIobj    
    : PutBehindAction
    verbPattern('zu legen/legen', '(was) (hinter was)')
    askIobjResponseProd = hinterSingleNoun
;

// ##############
// -- PutInAction
// ##############

VerbRule(LegInWas)
    [badness 500] 
    verb('leg','lege','platzier','pack','stell','stelle') dobjList    
    : PutInAction
    verbPattern('zu legen/legen', '(was) (in was)')
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new EmptyNounPhraseProd();
        iobjMatch.responseProd = inSingleNoun;
    }
;

// #############
// -- WearAction
// #############

VerbRule(ZiehAn)
    verb('trag') dobjList
    | verb('leg','lege','zieh') (|'dir') dobjList prep('an')
    | verb('setz','zieh') (|'dir') dobjList prep('auf')   
    | verb('steck') 'dir' dobjList prep('an')
    : WearAction
    verbPattern('anzuziehen/anziehen', '(was)')
;

// #############
// -- DoffAction
// #############

VerbRule(ZiehAus)
    verb('leg','lege','zieh','nimm','nehm','setz') dobjList prep('ab')
    | verb('zieh') dobjList prep('aus')
    : DoffAction
    verbPattern('auszuziehen/ausziehen', '(was)')
;

// #############
// -- KissAction
// #############

VerbRule(Kuess)
    verb('küss','knutsch') singleDobj
    : KissAction
    verbPattern('zu küssen/küssen', '(wen)')
;

// ###############
// -- AskForAction
// ###############

VerbRule(BitteUm)
    verb('bitt') singleDobj 'um' singleTopic
    | 'b' singleDobj 'um' singleTopic
    : AskForAction
    verbPhrase = (topicList_ != [] ? 'darum ': '' )+'zu bitten/'+(topicList_ != [] ? 'darum ': '' )+'bitten (wen) (um was)'
    omitIobjInDobjQuery = true
    askDobjResponseProd = singleNoun
    askIobjResponseProd = umSingleNoun
;

VerbRule(BittWenUm)
    verb('bitt') 'um' singleTopic
    | 'b' 'um' singleTopic
    : AskForAction
    verbPhrase = (topicList_ != [] ? 'darum ': '' )+'zu bitten/'+(topicList_ != [] ? 'darum ': '' )+'bitten (wen) (um was)'
    omitIobjInDobjQuery = true
    construct()
    {
        /* set up the empty direct object phrase */
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = singleNoun;
    }
;

// #################
// -- AskAboutAction
// #################

VerbRule(FragWas)
    verb('frag','befrag') singleDobj ('nach'|'über') singleTopic
    | 'f' singleDobj ('nach'|'über') singleTopic 
    : AskAboutAction
    verbPhrase = (topicList_ != [] ? 'danach ': '' )+'zu fragen/'+(topicList_ != [] ? 'danach ': '' )+'fragen (wen) (nach dativ was)'
    omitIobjInDobjQuery = true
    askDobjResponseProd = singleNoun
;

VerbRule(FragImplizit)
    verb('frag') 'nach' singleTopic
    | 'f' singleTopic

    : AskAboutAction
    verbPhrase = (topicList_ != [] ? 'danach ': '' )+'zu fragen/'+(topicList_ != [] ? 'danach ': '' )+'fragen (wen) (nach dativ was)'
    omitIobjInDobjQuery = true
    construct()
    {
        /* set up the empty direct object phrase */
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = singleNoun;
    }
;

VerbRule(FragNachWas)
    [badness 500] 
    verb('frag','befrag') singleDobj
    : AskAboutAction
    verbPhrase = (topicList_ != [] ? 'danach ': '' )+'zu fragen/'+(topicList_ != [] ? 'danach ': '' )+'fragen (wen) (nach dativ was)'
    askDobjResponseProd = singleNoun
    omitIobjInDobjQuery = true
    construct()
    {
        /* set up the empty topic phrase */
        topicMatch = new EmptyNounPhraseProd();
        topicMatch.responseProd = aboutTopicPhrase;
    }
;

// ##################
// -- TellAboutAction
// ##################

VerbRule(ErzaehlWas)
    verb('erzähl','bericht','berichte') singleDobj ('von'|'über') singleTopic
    | 'e' singleDobj ('von'|'über') singleTopic
    : TellAboutAction
    verbPhrase = (topicList_ != [] ? 'davon ': '' ) + 'zu erzählen/'+(topicList_ != [] ? 'davon ': '' )+'erzählen (dativ wem) (von dativ was)'
    askDobjResponseProd = singleNoun
    omitIobjInDobjQuery = true
;

VerbRule(ErzaehlImplizit)
    verb('erzähl','bericht','berichte') 'von' singleTopic
    | 'e' singleTopic
    : TellAboutAction
    verbPhrase = (topicList_ != [] ? 'davon ': '' ) + 'zu erzählen/'+(topicList_ != [] ? 'davon ': '' )+'erzählen (dativ wem) (von dativ was)'
    omitIobjInDobjQuery = true
    construct()
    {
        /* set up the empty direct object phrase */
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = singleNoun;
    }
;

VerbRule(ErzaehlVonWas)
    [badness 500] 
    verb('erzähl','bericht','berichte') singleDobj   
    : TellAboutAction
    verbPhrase = (topicList_ != [] ? 'davon ': '' ) + 'zu erzählen/'+(topicList_ != [] ? 'davon ': '' )+'erzählen (dativ wem) (von dativ was)'
    askDobjResponseProd = singleNoun
    omitIobjInDobjQuery = true
    construct()
    {
        /* set up the empty topic phrase */
        topicMatch = new EmptyNounPhraseProd();
        topicMatch.responseProd = aboutTopicPhrase;
    }
;

// ###############
// -- TalkToAction
// ###############

VerbRule(RedMit)
    verb('red','sprich','sprech') 'mit' singleDobj 
    : TalkToAction
    verbPattern('zu reden/reden', '(mit dativ wem)')
    askDobjResponseProd = mitSingleNoun
;

VerbRule(SagHallo)
    verb('sag') 'hallo' 'zu' singleDobj
    | verb('sag') singleDobj 'hallo'
    : TalkToAction
    verbPattern('zu reden/reden', '(mit dativ wem)')
    askDobjResponseProd = mitSingleNoun
;

VerbRule(Gruess)
    verb('grüß') singleDobj
    | verb('begrüß') singleDobj
    : TalkToAction
    verbPattern('zu grüßen/grüßen', '(wen)')
    askDobjResponseProd = singleNoun
;

VerbRule(RedMitWem)
    [badness 500] ('red' | 'sag')
    : TalkToAction
    verbPhrase = 'zu reden/reden (mit dativ wem)'
    askDobjResponseProd = mitSingleNoun
    construct()
    {
        /* set up the empty direct object phrase */
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = mitSingleNoun;
    }
;

VerbRule(Sprich)
    [badness 500] ('sprich' | 'sprech')
    : TalkToAction
    verbPhrase = 'zu sprechen/sprechen (mit dativ wem)'
    askDobjResponseProd = mitSingleNoun
    construct()
    {
        /* set up the empty direct object phrase */
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = mitSingleNoun;
    }
;

// ###############
// -- TopicsAction
// ###############

VerbRule(Themen)
    'thema' | 'themen'
    : TopicsAction
    verbPhrase = 'die Themen zu zeigen/die Themen zeigen'
;

// ##############
// -- HelloAction
// ##############

VerbRule(Hallo)
    ('sag' | ) ('hallo'|'hi'|'grüß' 'gott'|'servus')
    : HelloAction
    verbPhrase = 'zu grüßen/grüßen'
;

// ################
// -- GoodByeAction
// ################

VerbRule(Wiedersehen)
    ('sag' | ) ('auf' ('wiedersehn'|'wiederseh') | 'wiederseh' | 'wiedersehn' 
    | 'tschüss'| 'bye' | 'bis' 'bald')
    : GoodbyeAction
    verbPhrase = 'zu verabschieden/verabschieden'
;

// ############
// -- YesAction
// ############

VerbRule(Ja)
    'ja' | 'okay' | 'sag' 'ja' | 'in' 'ordnung' | 'jo'
    : YesAction
    verbPhrase = 'zu bejahen/bejahen'
;

// ###########
// -- NoAction
// ###########

VerbRule(Nein)
    'nein' | 'nee' | 'sag' 'nein' | 'nö' | 'nein' 'danke'
    : NoAction
    verbPhrase = 'zu verneinen/verneinen'
;

// #############
// -- YellAction
// #############

VerbRule(Schrei)
    verb('schrei','brüll','ruf','jaul')
    : YellAction
    verbPhrase = 'zu schreien/schreien'
;

// ###############
// -- GiveToAction
// ###############

VerbRule(GibWas)
    verb('gib','geb','übergeb','übergib') dobjList 'an' singleIobj
    : GiveToAction
    verbPattern('zu geben/geben', '(was) (dativ wem)')
    askIobjResponseProd = singleNoun
;

VerbRule(GibWas2)
    verb('gib','geb','übergeb','übergib','biet') singleIobj dobjList
    |'biet' singleIobj dobjList 'an'
    : GiveToAction
    verbPattern('zu geben/geben', '(was) (dativ wem)')
    askIobjResponseProd = singleNoun

    /* this is a non-prepositional phrasing */
    isPrepositionalPhrasing = nil
    preferredIobj = Actor
;

VerbRule(GibWasWem)
    verb('gib','geb','übergeb','übergib') dobjList
    : GiveToAction
    verbPattern('zu geben/geben', '(was) (dativ wem)')
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new ImpliedActorNounPhraseProd();
        iobjMatch.responseProd = singleNoun;
    }
;

VerbRule(BietWasWem)
    verb('biet') dobjList (|prep('an'))
    : GiveToAction
    verbPattern('anzubieten/anbieten', '(was) (dativ wem)')
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new ImpliedActorNounPhraseProd();
        iobjMatch.responseProd = singleNoun;
    }
;

// ###############
// -- ShowToAction
// ###############

VerbRule(ZeigWas)
    verb('zeig') dobjList singleIobj
    : ShowToAction
    verbPhrase = 'zu zeigen/zeigen (was) (dativ wem)'
    askIobjResponseProd = singleNoun
    
    /* this is a non-prepositional phrasing */
    isPrepositionalPhrasing = nil
    preferredIobj = Actor
;

VerbRule(ZeigWasWem)
    verb('zeig') dobjList
    : ShowToAction
    verbPhrase = 'zu zeigen/zeigen (was) (dativ wem)'
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new ImpliedActorNounPhraseProd();
        iobjMatch.responseProd = singleNoun;
    }
;

// ##############
// -- ThrowAction
// ##############

VerbRule(Wirf)
    verb('wirf','werf','schmeiß') dobjList (|'weg'|'fort')
    : ThrowAction
    verbPattern('zu werfen/werfen', '(was)')
;

// ################
// -- ThrowAtAction
// ################

VerbRule(WirfAuf)
    verb('werf','wirf','schmeiß') dobjList ('auf'|'in'|'gegen') singleIobj
    : ThrowAtAction
    verbPattern('zu werfen/werfen', '(was) (auf was)')
    askIobjResponseProd = aufSingleNoun
;

// ################
// -- ThrowToAction
// ################

VerbRule(WirfNach)
    verb('werf','wirf','schmeiß') dobjList 'nach' singleIobj
    : ThrowToAction
    verbPattern('zu werfen/werfen', '(was) (nach dativ was)')
    askIobjResponseProd = nachSingleNoun
;

// #################
// -- ThrowDirAction
// #################

VerbRule(WirfDir)
    verb('werf','wirf','schmeiß') dobjList ('nach' ('dem' | ) | ) singleDir
    : ThrowDirAction
    verbPhrase = ('zu werfen/werfen (was) nach' + dirMatch.dir.name)
;

/* a special rule for THROW DOWN <dobj> */
VerbRule(WirfDirUnten)
    verb('werf','wirf','schmeiß') dobjList ('hinunter')
    : ThrowDirAction
    verbPhrase = ('hinunterzuwerfen/hinunterwerfen (was)')
    /* the direction is fixed as 'down' for this phrasing */
    getDirection() { return downDirection; }
;

// ###############
// -- FollowAction
// ###############

VerbRule(Folg)
    verb('folg','verfolg','geh') singleDobj (|'nach'|'hinterher')
    : FollowAction
    verbPhrase = 'zu folgen/folgen (dativ wem)'
    askDobjResponseProd = singleNoun
;

// ###############
// -- AttackAction
// ###############

VerbRule(Attackier)
    verb('attackier','schlag','tret','box','hau','bekämpf','töt') singleDobj
    | verb('schlag','tret','box','hau') ('auf'|'gegen') singleDobj
    | verb('bring','leg','lege') singleDobj prep('um')
    | verb('greif') singleDobj prep('an')
    : AttackAction
    verbPattern('anzugreifen/angreifen','(wen)')
    askDobjResponseProd = singleNoun
;

// ###################
// -- AttackWithAction
// ###################

VerbRule(AttackWith)
    verb('attackier','schlag','tret','box','hau','bekämpf','töt') singleDobj 'mit' singleIobj
    | verb('schlag','tret','box','hau') ('auf'|'gegen') singleDobj 'mit' singleIobj
    | verb('bring','leg','lege') singleDobj 'mit' singleIobj prep('um')
    | verb('greif') singleDobj 'mit' singleIobj prep('an')
    : AttackWithAction
    verbPattern('anzugreifen/angreifen','(wen) (mit dativ was)')
    askDobjResponseProd = singleNoun
    askIobjResponseProd = mitSingleNoun
;

// ##############################################################
// -- mostly technical verbs, so we leave the english identifiers
// ##############################################################

VerbRule(Inventory)
    'i' | 'inv' | 'inventar' | 'inventar'
    | 'zeig' ('besitz'|'eigentum'|'inventar') (|'an')
    : InventoryAction
    verbPhrase = 'Inventar anzuzeigen/Inventar anzeigen'
;

VerbRule(InventoryTall)
    'i' 'schmal' | 'inventar' 'schmal' | 'inv' 'schmal'
    : InventoryTallAction
    verbPhrase = 'Inventar schmal anzuzeigen/Inventar schmal anzeigen'
;

VerbRule(InventoryWide)
    'i' 'weit' | 'inventar' 'weit' | 'inv' 'weit'
    : InventoryWideAction
    verbPhrase = 'Inventar weit anzuzeigen/Inventar weit anzeigen'
;

VerbRule(Wait)
    'z' | 'wart'
    : WaitAction
    verbPhrase = 'zu warten/warten'
;

VerbRule(Look)
    'schau' | ('schau'|'sieh'|'seh') ('dich'|'mich') 'um' | 'l' 
    : LookAction
    verbPhrase = 'umzuschauen/umschauen'
;

VerbRule(Quit)
    'quit' | 'q' | 'Ende' | 'schluss'
    : QuitAction
    verbPhrase = 'zu beenden/beenden'
;

VerbRule(Again)
    'again' | 'g' | 'nochmal' | 'nochmals'
    : AgainAction
    verbPhrase = 'den letzten Befehl zu wiederholen/den letzten Befehl wiederholen'
;

VerbRule(Footnote)
    ('fußnot'|'fussnot'|'not'|'note') singleNumber
    : FootnoteAction
    verbPhrase = 'eine Fußnote zu zeigen/eine Fußnote zeigen'
;

VerbRule(FootnotesFull)
    ('fußnot'|'fussnot'|'not'|'note') ('ganz' | 'voll')
    : FootnotesFullAction
    verbPhrase = 'alle Fußnoten zu zeigen/alle Fußnoten zeigen'
;

VerbRule(FootnotesMedium)
    ('fußnot'|'fussnot'|'not'|'note') 'mittel'
    : FootnotesMediumAction
    verbPhrase = 'neue Fußnoten zu zeigen/neue Fußnoten zeigen'
;

VerbRule(FootnotesOff)
    ('fußnot'|'fussnot'|'not'|'note') 'aus'
    : FootnotesOffAction
    verbPhrase = 'Fußnoten auszublenden/Fußnoten ausblenden'
;

VerbRule(FootnotesStatus)
    ('fußnot'|'fussnot'|'not'|'note')
    : FootnotesStatusAction
    verbPhrase = 'Fußnotenstatus zu zeigen/Fußnotenstatus zeigen';

VerbRule(TipsOn)
    ('tipps' | 'tipp' | 'hinweis') ('an'|'ein')
    : TipModeAction

    stat_ = true

    verbPhrase = 'Hinweise einzuschalten/Hinweise einschalten'
;

VerbRule(TipsOff)
    ('tipps' | 'tipp' | 'hinweis') ('off'|'aus')
    : TipModeAction

    stat_ = nil

    verbPhrase = 'Hinweise auszuschalten/Hinweise ausschalten'
;

VerbRule(Verbose)
    'verbose' | 'wortreich'
    : VerboseAction
    verbPhrase = 'in WORTREICHEN Modus zu wechseln/in WORTREICHEN Modus wechseln'
;

VerbRule(Terse)
    'terse' | 'brief' | 'kurz'
    : TerseAction
    verbPhrase = 'in KURZEN Modus zu wechseln/in KURZEN Modus wechseln'
;

VerbRule(Score)
    'score' | 'status' | 'punkt'
    : ScoreAction
    verbPhrase = 'Punkte zu zeigen/Punkte zeigen'
;

VerbRule(FullScore)
    'voll' | 'voll' 'punkt'
    : FullScoreAction
    verbPhrase = 'volle Punkte zu zeigen/volle Punkte zeigen'
;

VerbRule(Notify)
    'nachricht'
    : NotifyAction
    verbPhrase = 'zeigen/nachrichtenstatus zeigen'
;

VerbRule(NotifyOn)
    'nachricht' 'ein'
    : NotifyOnAction
    verbPhrase = 'Punktebenachrichtigung einzuschalten/Punktebenachrichtigung einschalten'
;

VerbRule(NotifyOff)
    'nachricht' 'aus'
    : NotifyOffAction
    verbPhrase = 'Punktebenachrichtigung auszuschalten/Punktebenachrichtigung ausschalten'
;

VerbRule(Save)
    'save' | 'speicher' | 'speichern'
    : SaveAction
    verbPhrase = 'zu speichern/speichern'
;

VerbRule(SaveString)
    ('save' | 'speicher' | 'speichern') quotedStringPhrase->fname_
    : SaveStringAction
    verbPhrase = 'zu speichern/speichern'
;

VerbRule(Restore)
    'restore' | 'lad' | 'lade'
    : RestoreAction
    verbPhrase = 'zu laden/laden'
;

VerbRule(RestoreString)
    ('restore' | 'lad' | 'lade' ) quotedStringPhrase->fname_
    : RestoreStringAction
    verbPhrase = 'zu laden/laden'
;

VerbRule(SaveDefaults)
    ('einstellung'|'standard'|'standards') ('speicher' | 'speichern')
    : SaveDefaultsAction
    verbPhrase = 'Standards zu speichern/Standards speichern'
;

VerbRule(RestoreDefaults)
    ('einstellung'|'standard'|'standards') 'lad'
    : RestoreDefaultsAction
    verbPhrase = 'Standards zu laden/Standards laden'
;

VerbRule(Restart)
    'restart' | 'neustart' | 'neu'
    : RestartAction
    verbPhrase = 'neuzustarten/neustarten'
;

VerbRule(Pause)
    'pause'
    : PauseAction
    verbPhrase = 'zu pausieren/pausieren'
;

VerbRule(Undo)
    'undo' | 'zurück' 
    : UndoAction
    verbPhrase = 'einen Zug zurück zu nehmen/einen Zug zurücknehmen'
;

VerbRule(Version)
    'version'
    : VersionAction
    verbPhrase = 'die Version zu zeigen/die Version zeigen'
;

VerbRule(Credits)
    'credits' | 'dank' | 'danksagung'
    : CreditsAction
    verbPhrase = 'die Credits zu zeigen/die Credits zeigen'
;

VerbRule(About)
    'about' | 'über' | 'info'
    : AboutAction
    verbPhrase = 'die Information zu zeigen/die Information zeigen'
;

VerbRule(Script)
    'script' | 'script' 'on' | 'skript' | 'skript' ('an'|'ein') | 'mitschrift'
    : ScriptAction 
    verbPhrase = 'das Skript zu starten/das Skript starten'
;

VerbRule(ScriptString)
    ('script' | 'skript' ) quotedStringPhrase->fname_
    : ScriptStringAction
    verbPhrase = 'das Skript zu starten/das Skript starten'
;

VerbRule(ScriptOff)
    'script' 'off' | 'skript' 'aus'
    : ScriptOffAction
    verbPhrase = 'das Skript zu beenden/das Skript beenden'
;

VerbRule(Record)
    'record' | 'record' 'on' | 'aufnahme' | 'aufnahme' ('an'|'ein')
    : RecordAction
    verbPhrase = 'die Befehlsaufzeichnung zu starten/die Befehlsaufzeichnung starten'
;

VerbRule(RecordString)
    ('record' | 'aufnahme') quotedStringPhrase->fname_
    : RecordStringAction
    verbPhrase = 'die Befehlsaufnahme zu starten/die Befehlsaufnahme starten'
;

VerbRule(RecordEvents)
    'record' 'events' | 'record' 'events' 'on' | 'ereignisaufnahme' | 'ereignisaufnahme' ('an'|'ein')
    : RecordEventsAction
    verbPhrase = 'die Ereignisaufnahme zu starten/die Ereignisaufnahme starten'
;

VerbRule(RecordEventsString)
    ('record' 'events'|'ereignisaufnahme') quotedStringPhrase->fname_
    : RecordEventsStringAction
    verbPhrase = 'die Ereignisaufnahme zu starten/die Ereignisaufnahme starten'
;

VerbRule(RecordOff)
    ('record' 'off' | 'aufnahme' 'aus')
    : RecordOffAction
    verbPhrase = 'die Befehlsaufnahme zu beenden/die Befehlsaufnahme beenden'
;

VerbRule(ReplayString)
    ('replay'|'aufnahme') ('quiet'->quiet_ |'still'->quiet_ | 'ohne' 'pause'->nonstop_ |'nonstop'->nonstop_ | )
        (quotedStringPhrase->fname_ | )
    : ReplayStringAction
    verbPhrase = 'die Befehlsaufzeichnung abzuspielen/die Befehlsaufzeichnung abspielen'

    /* set the appropriate option flags */
    scriptOptionFlags = ((quiet_ != nil ? ScriptFileQuiet : 0)
                         | (nonstop_ != nil ? ScriptFileNonstop : 0))
;

VerbRule(ReplayQuiet)
    'rq' (quotedStringPhrase->fname_ | )
    : ReplayStringAction

    scriptOptionFlags = ScriptFileQuiet
;

// ####################
// -- VagueTravelAction
// ####################

VerbRule(ReiseZiellos) ('spazier'|'geh') (|'umher'|'herum') : VagueTravelAction
    verbPhrase = 'zu gehen/gehen'
;

// ###############
// -- TravelAction
// ###############

VerbRule(Reise)
    ('spazier' | 'geh') (|'nach') singleDir | singleDir
    : TravelAction
    verbPhrase = ('nach ' + dirMatch.dir.name + ' zu gehen/nach ' + dirMatch.dir.name + ' gehen')
;

/*
 *   Create a TravelVia subclass merely so we can supply a verbPhrase.
 *   (The parser looks for subclasses of each specific Action class to find
 *   its verb phrase, since the language-specific Action definitions are
 *   always in the language module's 'grammar' subclasses.  We don't need
 *   an actual grammar rule, since this isn't an input-able verb, so we
 *   merely need to create a regular subclass in order for the verbPhrase
 *   to get found.)  
 */

class EnTravelVia: TravelViaAction
    verbPhrase = 'zu benutzen/benutzen (was)'
;

// #############
// -- PortAction
// #############

VerbRule(BackBord)
    ('spazier' | 'geh') 'nach' ('backbord' | 'bb')
    : PortAction
    dirMatch: DirectionProd { dir = portDirection }
    verbPhrase = 'nach Backbord zu gehen/nach Backbord gehen'
;

// ##################
// -- StarboardAction
// ##################

VerbRule(Steuerbord)
    ('spazier' | 'geh') 'nach' ('steuerbord' | 'sb')
    : StarboardAction
    dirMatch: DirectionProd { dir = starboardDirection }
    verbPhrase = 'nach Steuerbord zu gehen/nach Steuerbord gehen'
;

// ###########
// -- InAction
// ###########

VerbRule(Rein)
    'hinein' | 'drinnen'
    : InAction
    dirMatch: DirectionProd { dir = inDirection }
    verbPhrase = 'hineinzugehen/hineingehen'
;

// ############
// -- OutAction
// ############

VerbRule(Raus)
    'hinaus' | 'draußen'
    : OutAction
    dirMatch: DirectionProd { dir = outDirection }
    verbPhrase = 'hinauszugehen/hinausgehen (aus dativ was)'
;

// ##################
// -- GoThroughAction
// ##################

VerbRule(GehDurch)
    verb('geh','spazier','spring','kletter','steig','steige') 'durch' singleDobj
    : GoThroughAction
    verbPattern('zu gehen/gehen','(durch was)')
    askDobjResponseProd = durchSingleNoun
;

// ##############
// -- EnterAction
// ##############

VerbRule(Betret)
    verb('betret','betritt') singleDobj
    | verb('geh','tritt','tret') 'in' singleDobj (|'hinein')
    | 'in' singleDobj ('hinein'|)
    : EnterAction
    verbPattern('zu betreten/betreten','(was)')
    askDobjResponseProd = singleNoun
;

// ###############
// -- GoBackAction
// ###############

VerbRule(GehZurueck)
    ('geh' | 'kehr') 'zurück'
    : GoBackAction
    verbPhrase = 'zurück zu gehen/zurück gehen'
;

// ############
// -- DigAction
// ############

VerbRule(Grab)
    ('grab' | 'grab' 'in') singleDobj
    : DigAction
    verbPhrase = 'zu graben/graben (in dativ was)'
    askDobjResponseProd = inSingleNoun
;

// ################
// -- DigWithAction
// ################

VerbRule(GrabMit)
    ('grab' | 'grab' 'in') singleDobj 'mit' singleIobj
    | 'grab' 'mit' singleIobj 'in' singleDobj 
    : DigWithAction
    verbPhrase = 'zu graben/graben (in dativ was) (mit dativ was)'
    omitIobjInDobjQuery = true
    askDobjResponseProd = inSingleNoun
    askIobjResponseProd = mitSingleNoun
;

// #############
// -- JumpAction
// #############

VerbRule(Spring)
    'spring' | 'hüpf'
    : JumpAction
    verbPhrase = 'zu springen/springen'
;

// #################
// -- JumpOffIAction
// #################

VerbRule(SpringAb)
    verb('spring') prep('ab','hinunter')
    : JumpOffIAction
    verbPhrase = 'abzuspringen/abspringen'
;

// ################
// -- JumpOffAction
// ################

VerbRule(SpringVon)
    verb('spring') 'von' singleDobj (|'ab'|'hinunter')
    : JumpOffAction
    verbPhrase = 'zu springen/springen (von was)'
    askDobjResponseProd = singleNoun
;

// #################
// -- JumpOverAction
// #################

VerbRule(SpringUeber)
    verb('spring') 'über' singleDobj (|'hinüber')
    : JumpOverAction
    verbPhrase = 'zu springen/springen (über was)'
    askDobjResponseProd = ueberSingleNoun
;

// #############
// -- PushAction
// #############

VerbRule(Schieb)
    verb('drück','schieb','schubs') dobjList (|prep('an'))
    : PushAction
    verbPattern('zu schieben/schieben','(was)')
;

// #############
// -- PullAction
// #############

VerbRule(Zieh)
    verb('zieh') (|'an') dobjList
    : PullAction
    verbPhrase = 'zu ziehen/ziehen (was)'
;

// #############
// -- MoveAction
// #############

VerbRule(Beweg)
    verb('beweg') dobjList
    : MoveAction
    verbPhrase = 'zu bewegen/bewegen (was)'
;

// ###############
// -- MoveToAction
// ###############

VerbRule(BewegNach)
    verb('beweg','schieb','schubs') dobjList ('nach'|'unter'|'zu') singleIobj (|'hin')
    : MoveToAction
    verbPattern('zu bewegen/bewegen','(was) (zu dativ was)')
    askIobjResponseProd = zuSingleNoun
    omitIobjInDobjQuery = true
;

// #################
// -- MoveWithAction
// #################

VerbRule(BewegMit)
    verb('beweg','schieb','schubs') singleDobj 'mit' singleIobj
    : MoveWithAction
    verbPattern('zu bewegen/bewegen','(was) (mit dativ was)')
    askDobjResponseProd = singleNoun
    askIobjResponseProd = mitSingleNoun
    omitIobjInDobjQuery = true
;

// #############
// -- TurnAction
// #############

VerbRule(Dreh)
    verb('dreh','rotier','verdreh') dobjList
    : TurnAction 
    verbPattern('zu drehen/drehen','(was)')
;

// #################
// -- TurnWithAction
// #################

VerbRule(DrehMitWas)
    verb('dreh','rotier','verdreh') singleDobj 'mit' singleIobj
    : TurnWithAction
    verbPattern('zu drehen/drehen','(was) (mit dativ was)')
    askDobjResponseProd = singleNoun
    askIobjResponseProd = mitSingleNoun
;

// ###############
// -- TurnToAction
// ###############

VerbRule(DrehAufWas)
    verb('dreh','rotier','verdreh') singleDobj 'auf' singleLiteral
    : TurnToAction
    verbPattern('zu drehen/drehen','(was) (auf was)')
    askDobjResponseProd = singleNoun
    omitIobjInDobjQuery = true
;

// ############
// -- SetAction
// ############

VerbRule(StellEin)
    verb('stell','stelle') dobjList (|prep('ein'))
    : SetAction
    verbPattern('zu stellen/stellen','(was)')
;

// ##############
// -- SetToAction
// ##############

VerbRule(StellEinAuf)
    verb('stell','stelle') singleDobj 'auf' singleLiteral (|'ein')
    : SetToAction
    verbPattern('einzustellen/einstellen','(was) (auf was)')
    askDobjResponseProd = singleNoun
    omitIobjInDobjQuery = true
;

// ###############
// -- TypeOnAction
// ###############

VerbRule(TippAuf)
     'tipp' ('auf'|'in') singleDobj
    : TypeOnAction
    verbPhrase = 'zu tippen/tippen (auf dativ was)'
;

// ######################
// -- TypeLiteralOnAction
// ######################

VerbRule(TippTextAuf)
    verb('tipp') singleLiteral ('auf'|'in') singleDobj
    | verb('gib','geb') singleLiteral ('auf'|'in') singleDobj prep('ein')
    | verb('tipp','gib','geb') singleLiteral prep('ein') ('auf'|'in') singleDobj
    : TypeLiteralOnAction
    verbPattern('zu tippen/tippen','(was) (auf dativ was)')
    askDobjResponseProd = aufSingleNoun
;

VerbRule(TippTextAufWas)
    [badness 500] verb('tipp','gib','geb') singleLiteral
    : TypeLiteralOnAction
    verbPattern('zu tippen/tippen','(was) (auf dativ was)')
    construct()
    {
        // set up the empty direct object phrase 
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = aufSingleNoun;
    }
;

// ################
// -- ConsultAction
// ################

VerbRule(SchlagNachIn)
    verb('schlag') prep('nach') 'in' singleDobj
    | verb('schlag') 'in' singleDobj prep('nach')
    | verb('konsultier') singleDobj
    | verb('lies','les') (|prep('nach')) 'in' singleDobj
    | verb('lies','les') 'in' singleDobj (|prep('nach'))
    : ConsultAction
    verbPattern('nachzuschlagen/nachschlagen','(in dativ was)')
    askDobjResponseProd = singleNoun
;

// #####################
// -- ConsultAboutAction
// #####################

VerbRule(SchlagNachUeber)
    verb('schlag','lies','les') (|'über') singleTopic 'in' singleDobj prep('nach')
    | verb('schlag','lies','les') 'in' singleDobj (|'über') singleTopic prep('nach')
    | verb('konsultier') singleDobj ('nach'|'über'|'zu') singleTopic
    | verb('durchsuch','durchforst','durchkämm') singleDobj 'nach' singleTopic
    | verb('such','schau','sieh','seh') 'in' singleDobj (|'nach') singleTopic
    | verb('such','schau','sieh','seh') singleTopic 'in' singleDobj (|'nach') 
    : ConsultAboutAction
    verbPattern('nachzuschlagen/nachschlagen','(in dativ was) (was)')
    omitIobjInDobjQuery = true
    askDobjResponseProd = inSingleNoun
;

// #########################################
// -- ConsultAboutAction -- ConsultWhatAbout
// #########################################

VerbRule(SchlagNachWorin)
    verb('schlag','lies','les','schau','sieh','seh') singleTopic prep('nach')
    | verb('lies','les','such','find') (|'etwas') 'über' singleTopic
    | verb('such') 'nach' singleTopic
    : ConsultAboutAction
    verbPattern('nachzuschlagen/nachschlagen','(in dativ was) (was)')
    whichMessageTopic = DirectObject
    construct()
    {
        /* set up the empty direct object phrase */
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = inSingleNoun;
    }
;

// ###############
// -- SwitchAction
// ###############

VerbRule(SchaltUm)
    'schalt' dobjList (|'um')
    : SwitchAction
    verbPhrase = 'umzuschalten/umschalten (was)'
;

// #############
// -- FlipAction
// #############

VerbRule(DrehUm)
    verb('dreh') dobjList prep('um')
    verb('wend','wende') dobjList (|'um')
    : FlipAction
    verbPattern('umzudrehen/umdrehen','(was)')
    // -- we use this flag to mark this rule as the default rule
    // -- for missing obj queries
    defaultForRecursion = true
;

// ###############
// -- TurnOnAction
// ###############

VerbRule(SchaltEin)
    verb('schalt') dobjList prep('an','ein')
    | verb('stell','stelle','mach') dobjList prep('an')
    | verb('aktivier') dobjList
    : TurnOnAction
    verbPattern('einzuschalten/einschalten','(was)')
;

// ################
// -- TurnOffAction
// ################

VerbRule(SchaltAus)
    verb('stell','stelle','schalt','mach') dobjList prep('aus')
    | verb('deaktivier') dobjList
    : TurnOffAction
    verbPattern('auszuschalten/ausschalten','(was)')
;

// ##############
// -- LightAction
// ##############

VerbRule(ZuendAn)
    verb('zünd') dobjList prep('an')
    | verb('erhell','erleucht','entzünd','entfach','entflamm') dobjList
    : LightAction
    verbPattern('anzuzünden/anzünden','(was)')
;

// #############
// -- BurnAction
// #############

VerbRule(Verbrenn)
    'verbrenn' dobjList
    : BurnAction
    verbPhrase = 'zu verbrennen/verbrennen (was)'
;

// #################
// -- BurnWithAction
// #################

VerbRule(ZuendAnMit)
    verb('erhell','erleucht','entzünd','entfach','entflamm','verbrenn') singleDobj 'mit' singleIobj
    | verb('zünd') singleDobj 'mit' singleIobj prep('an')
    : BurnWithAction
    verbPattern('anzuzünden/anzünden','(was) (mit dativ was)')
    omitIobjInDobjQuery = true
    askDobjResponseProd = singleNoun
    askIobjResponseProd = mitSingleNoun

;

// ###################
// -- ExtinguishAction
// ###################

VerbRule(LoeschAus)
    verb('blas','lösch') dobjList prep('aus')
    : ExtinguishAction
    verbPattern('auszulöschen/auslöschen','(was)')
;

// ##############
// -- BreakAction
// ##############

VerbRule(Brech)
    verb('brech','brich','zerbrech','zerbrich','ruinier','zerstör') dobjList
    | verb('mach') dobjList prep('kaputt')
    : BreakAction
    verbPattern('zu brechen/brechen','(was)')
;

// ################
// -- CutWithAction
// ################

VerbRule(SchneidWomit)
    [badness 500] 
    verb('schneid','trenn','zerschneid') singleDobj (|prep('durch')|prep('ab'))
    | verb('durchtrenn') singleDobj
    : CutWithAction
    verbPattern('zu schneiden/schneiden','(was) (mit dativ was)')
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new EmptyNounPhraseProd();
        iobjMatch.responseProd = mitSingleNoun;
    }
;

VerbRule(SchneidMit)
    verb('schneid','trenn','zerschneid') singleDobj 'mit' singleIobj (|prep('durch','ab'))
    | verb('durchtrenn') singleDobj 'mit' singleIobj
    : CutWithAction
    verbPattern('zu schneiden/schneiden','(was) (mit dativ was)')
    askDobjResponseProd = singleNoun
    askIobjResponseProd = mitSingleNoun
;

// ############
// -- EatAction
// ############

VerbRule(Iss)
    verb('iss','ess','friss','fress','konsumier','verzehr') dobjList
    : EatAction
    verbPattern('zu essen/essen','(was)')

;

// ##############
// -- DrinkAction
// ##############

VerbRule(Trink)
    verb('trink','schluck') dobjList
    | verb('schluck') dobjList prep('hinunter')
    : DrinkAction
    verbPattern('zu trinken/trinken','(was)')
;

// #############
// -- PourAction
// #############

VerbRule(Entleer)
    verb('entleer') dobjList
    | verb('leer','schütt','schütte','gieß','kipp','kippe') dobjList (|prep('aus','weg'))
    : PourAction
    verbPattern('zu entleeren/entleeren','(was)')
;

// #################
// -- PourIntoAction
// #################

VerbRule(EntleerIn)
    verb('entleer','leer','schütt','schütte','gieß','kipp','kippe') dobjList 'in' singleIobj (|'hinein')
    : PourIntoAction
    verbPattern('zu entleeren/entleeren','(was) (in was)')
    askIobjResponseProd = inSingleNoun
;

// #################
// -- PourOntoAction
// #################

VerbRule(EntleerAuf)
    verb('entleer','leer','schütt','schütte','gieß','kipp','kippe') dobjList 'auf' singleIobj
    : PourOntoAction
    verbPattern('zu entleeren/entleeren','(was) (auf was)')
    askIobjResponseProd = aufSingleNoun
;

// ##############
// -- ClimbAction
// ##############

VerbRule(KletterAuf)
    'kletter' (|'auf') singleDobj
    : ClimbAction
    verbPattern('zu klettern/klettern','(auf was)')
    askDobjResponseProd = aufSingleNoun
    // -- we use this flag to mark this rule as the default rule
    // -- for missing obj queries
    defaultForRecursion = true
;

VerbRule(Erkletter)
    verb('erkletter','erklimm') singleDobj
    : ClimbAction
    verbPattern('zu erklettern/erklettern','(was)')
;

// ################
// -- ClimbUpAction
// ################

VerbRule(KletterHinauf)
    verb('kletter','steig','steige','geh') (|'an') singleDobj prep('hinauf','hoch')
    : ClimbUpAction
    verbPattern('hinaufzusteigen/hinaufsteigen','(was)')
    askDobjResponseProd = singleNoun
;

VerbRule(KletterHinaufAnWas)
    [badness 200] 'kletter' ('hinauf'|'hoch')
    : ClimbUpAction
    verbPhrase = 'hinaufzuklettern/hinaufklettern (was)'
    askDobjResponseProd = singleNoun
    construct()
    {
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = singleNoun;
    }
    // -- we use this flag to mark this rule as the default rule
    // -- for missing obj queries
    defaultForRecursion = true
;

VerbRule(SteigHinaufWas)
    [badness 200] ('steig'|'steige') ('hinauf'|'hoch')
    : ClimbUpAction
    verbPhrase = 'hinaufzusteigen/hinaufsteigen (was)'
    askDobjResponseProd = singleNoun
    construct()
    {
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = singleNoun;
    }
;

// ##################
// -- ClimbDownAction
// ##################

VerbRule(KletterHinunter)
    verb('kletter','steig','steige','geh') (|'an') singleDobj prep('hinunter')
    : ClimbDownAction
    verbPhrase = 'hinunterzusteigen/hinuntersteigen (was)'
    askDobjResponseProd = singleNoun
;

VerbRule(SteigHinunterWas)
    [badness 200] ('steig'|'steige') 'hinunter'
    : ClimbDownAction
    verbPhrase = 'hinunterzusteigen/hinuntersteigen (was)'
    askDobjResponseProd = singleNoun
    construct()
    {
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = singleNoun;
    }
    // -- we use this flag to mark this rule as the default rule
    // -- for missing obj queries
    defaultForRecursion = true
;

VerbRule(KletterHinunterWas)
    [badness 200] 'kletter' 'hinunter'
    : ClimbDownAction
    verbPhrase = 'hinunterzusteigen/hinuntersteigen (was)'
    askDobjResponseProd = singleNoun
    construct()
    {
        dobjMatch = new EmptyNounPhraseProd();
        dobjMatch.responseProd = singleNoun;
    }
;

// ##############
// -- CleanAction
// ##############

VerbRule(Reinig)
    verb('reinig','kehr','kehre','feg','säuber') dobjList
    | verb('mach') dobjList prep('sauber')
    : CleanAction
    verbPattern('zu reinigen/reinigen','(was)')
;

// ##################
// -- CleanWithAction
// ##################

VerbRule(ReinigMit)
    verb('reinig','kehr','kehre','feg','säuber') dobjList 'mit' singleIobj
    | verb('mach') dobjList prep('sauber') 'mit' singleIobj 
    | verb('mach') dobjList 'mit' singleIobj prep('sauber')
    : CleanWithAction
    verbPattern('zu reinigen/reinigen','(was) (mit dativ was)')
    askIobjResponseProd = mitSingleNoun
    omitIobjInDobjQuery = true
;

// #################
// -- AttachToAction
// #################

VerbRule(BefestigAn)
    verb('verbind') dobjList 'mit' singleIobj
    | verb('bind','binde','befestig') dobjList prep('an') singleIobj
    | verb('mach') dobjList 'an' singleIobj prep('fest')
    : AttachToAction
    askIobjResponseProd = anSingleNoun
    verbPattern('zu befestigen/befestigen','(was) (an dativ was)')
    // -- we use this flag to mark this rule as the default rule
    // -- for missing obj queries
    defaultForRecursion = true
;

VerbRule(VerbindeMit)
    verb('verbind') dobjList 'mit' singleIobj
    : AttachToAction
    askIobjResponseProd = mitSingleNoun
    verbPattern('zu verbinden/verbinden','(was) (mit dativ was)')
;

VerbRule(BefestigAnWas)
    [badness 500] verb('befestig') dobjList
    | verb('mach','bind','binde') dobjList (|prep('fest'))
    : AttachToAction
    verbPattern('zu befestigen/befestigen','(was) (an dativ was)')
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new EmptyNounPhraseProd();
        iobjMatch.responseProd = anSingleNoun;
    }
    // -- we use this flag to mark this rule as the default rule
    // -- for missing obj queries
    defaultForRecursion = true
;

VerbRule(VerbindeMitWas)
    [badness 500] verb('verbind') dobjList
    : AttachToAction
    verbPattern('zu binden/binden','(was) (mit dativ was)')
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new EmptyNounPhraseProd();
        iobjMatch.responseProd = anSingleNoun;
    }
;

// ###################
// -- DetachFromAction
// ###################

VerbRule(TrennAb)
    verb('lös','trenn','locker') dobjList 'von' singleIobj (|'ab')
    | verb('mach','bind','binde') dobjList 'von' singleIobj (|prep('ab','los'))
    : DetachFromAction
    verbPattern('zu trennen/trennen (was)','(von dativ was)') 
    askIobjResponseProd = vonSingleNoun
;

// ###############
// -- DetachAction
// ###############

VerbRule(Trenn)
    verb('lös','trenn','locker') dobjList (|'ab')
    | verb('mach','bind','binde') dobjList (|prep('ab','los'))
    : DetachAction
    verbPattern('zu trennen/trennen','(was)')
;

// #############
// -- OpenAction
// #############

VerbRule(Oeffne)
    verb('öffn') dobjList
    | verb('mach') dobjList prep('auf')
    : OpenAction
    verbPattern('zu öffnen/öffnen','(was)')
;

// ##############
// -- CloseAction
// ##############

VerbRule(Schliess)
    verb('schließ') dobjList
    | verb('mach') dobjList prep('zu')
    : CloseAction
    verbPattern('zu schließen/schließen','(was)')
;

// #############
// -- LockAction
// #############

VerbRule(SperrZu)
    verb('versperr','verschließ') dobjList
    | verb('sperr','schließ') dobjList prep('ab','zu') 
    : LockAction
    verbPattern('abzusperren/absperren','(was)')
;

// ###############
// -- UnlockAction
// ###############

VerbRule(SperrAuf)
    verb('sperr','schließ') dobjList prep('auf') 
    : UnlockAction
    verbPattern('aufzusperren/aufsperren','(was)')
;

// #################
// -- LockWithAction
// #################

VerbRule(SperrAbMit)
    verb('versperr','verschließ') singleDobj 'mit' singleIobj
    | verb('schließ') singleDobj 'mit' singleIobj prep('ab','zu')
    : LockWithAction
    verbPattern('abzusperren/absperren','(was) (mit dativ was)')
    omitIobjInDobjQuery = true
    askDobjResponseProd = singleNoun
    askIobjResponseProd = mitSingleNoun
;

// ###################
// -- UnlockWithAction
// ###################

VerbRule(SperrAufMit)
    verb('sperr','schließ') singleDobj 'mit' singleIobj prep('auf')
    | verb('öffn') singleDobj 'mit' singleIobj
    : UnlockWithAction
    verbPattern('aufzusperren/aufsperren','(was) (mit dativ was)')
    omitIobjInDobjQuery = true
    askDobjResponseProd = singleNoun
    askIobjResponseProd = mitSingleNoun
;

// ##############
// -- SitOnAction
// ##############

VerbRule(SetzDichAuf)
    (('sitz'|'sitze') | 'setz' ('dich'|'mich')) ('auf' | 'in')
        singleDobj ( | 'nieder'|'hin')
    : SitOnAction
    verbPhrase = 'zu sitzen/sitzen (auf dativ was)'
    askDobjResponseProd = singleNoun

    /* use the actorInPrep, if there's a direct object available */
    adjustDefaultObjectPrep(prep, obj)
        { return (obj != nil ? obj.actorInPrep + ' ' : prep); }
;

// ############
// -- SitAction
// ############

VerbRule(SetzDichHin)
    (('sitz'|'sitze') | 'setz' ('dich'|'mich')) (|'nieder'|'hin') 
    : SitAction
    verbPhrase = 'zu setzen/setzen'
;

// ##############
// -- LieOnAction
// ##############

VerbRule(LegDichAuf)
    (('lieg'|'liege')|('leg'|'lege')) ('dich'|'mich') ('auf'|'in') singleDobj ( | 'nieder'|'hin')
    | ('lieg'|'liege') ('auf'|'in') singleDobj
    : LieOnAction
    verbPhrase = 'zu legen/legen (auf was)'
    askDobjResponseProd = singleNoun

    /* use the actorInPrep, if there's a direct object available */
    adjustDefaultObjectPrep(prep, obj)
        { return (obj != nil ? obj.actorInPrep + ' ' : prep); }
;

// ############
// -- LieAction
// ############

VerbRule(LegDichHin)
    (('lieg'|'liege') | ('leg'|'lege') ('dich'|'mich')) ( | 'nieder'|'hin') 
    : LieAction
    verbPhrase = 'hinzulegen/hinlegen'
;

// ################
// -- StandOnAction
// ################

VerbRule(StellDichAuf)
    ('steh' | ('stell'|'stelle') ('dich'|'mich')) ('auf'|'in') singleDobj
    : StandOnAction
    verbPhrase = 'zu stellen/stellen (auf was)'
    askDobjResponseProd = singleNoun

    /* use the actorInPrep, if there's a direct object available */
    adjustDefaultObjectPrep(prep, obj)
        { return (obj != nil ? obj.actorInPrep + ' ' : prep); }
;

// ##############
// -- StandAction
// ##############

VerbRule(StellDichHin)
    'steh' | 'steh' 'auf' | ('stell'|'stelle') ('dich'|'mich') 'hin'
    : StandAction
    verbPhrase = 'aufzustehen/aufstehen'
;

// #################
// -- GetOutOfAction
// #################

VerbRule(Verlass)
    ('verlass' | 'geh' 'aus') singleDobj
    : GetOutOfAction
    verbPhrase = 'zu verlassen/verlassen (was)'
    askDobjResponseProd = singleNoun

    // -- we use this flag to mark this rule as the default rule
    // -- for missing obj queries
    defaultForRecursion = true
    
    /* use the actorOutOfPrep, if there's a direct object available */
    //adjustDefaultObjectPrep(prep, obj)
    //    { return (obj != nil ? obj.actorOutOfPrep + ' ' : prep); }
;

VerbRule(SteigAus)
    'kletter' 'aus' singleDobj (|'aus'|'hinaus')
    | ('steig'|'steige') 'aus' singleDobj (|'aus'|'hinaus')
    : GetOutOfAction
    verbPhrase = 'zu steigen/steigen (aus dativ was)'
    askDobjResponseProd = singleNoun
    
    adjustDefaultObjectPrep(prep, obj)
        { return (obj != nil ? obj.actorOutOfPrep + ' ' : prep); }
    
;

// #################
// -- GetOffOfAction
// #################

VerbRule(SteigAb)
    'geh' 'von' singleDobj 'hinunter'
    | ('steig'|'steige') 'von' singleDobj (|'ab'|'hinunter')
    : GetOffOfAction
    verbPhrase = 'zu steigen/steigen (von dativ was)'
    askDobjResponseProd = singleNoun

    adjustDefaultObjectPrep(prep, obj)
        { return (obj != nil ? obj.actorOutOfPrep + ' ' : prep); }

;

// ###############
// -- GetOutAction
// ###############

VerbRule(GehRaus)
    verb('komm','kletter') prep('hinunter','hinaus')
    : GetOutAction
    verbPhrase = 'hinauszukommen/hinauskommen'
;

// ##############
// -- BoardAction
// ##############

VerbRule(SteigIn)
    ('besteig'  
     | ('steig'|'steige') ( 'in' | 'ein' 'in' | 'auf')
     | 'geh' 'auf'
     | 'kletter' ('in'|'auf')
     | 'stell' ('dich'|'mich') 'in')
    singleDobj (|'ein'|'hinein'|'hinauf')
    : BoardAction
    verbPhrase = 'zu steigen/steigen (in was)'
    askDobjResponseProd = singleNoun
;

// ##############
// -- SleepAction
// ##############

VerbRule(Schlaf)
    verb('schlaf') (|prep('aus','ein')) 
    : SleepAction
    verbPhrase = 'zu schlafen/schlafen'
;

// #################
// -- PlugIntoAction
// #################

VerbRule(SteckIn)
    'steck' dobjList 'in' singleIobj (|'ein'|'hinein')
    : PlugIntoAction
    verbPhrase = 'zu stecken/stecken (was) (in was)'
    askIobjResponseProd = inSingleNoun
;

VerbRule(SteckInWas)
    [badness 500] verb('steck') dobjList prep('ein')
    : PlugIntoAction
    verbPattern('zu stecken/stecken','(was) (in was)')
    construct()
    {
        /* set up the empty indirect object phrase */
        iobjMatch = new EmptyNounPhraseProd();
        iobjMatch.responseProd = inSingleNoun;
    }
;

// ###############
// -- PlugInAction
// ###############

VerbRule(SteckEin)
    verb('steck') dobjList (|prep('ein'))
    : PlugInAction
    verbPhrase = 'einzustecken/einstecken (was)'
;

// ###################
// -- UnplugFromAction
// ###################

VerbRule(SteckAusVon)
    verb('lös','trenn') dobjList 'von' singleIobj (|prep('ab'))
    : UnplugFromAction
    verbPattern('zu trennen/trennen','(was) (von was)')
    askIobjResponseProd = vonSingleNoun
;

// #################
// -- UnplugInAction
// #################

VerbRule(SteckAus)
    verb('steck') dobjList prep('aus')
    : UnplugAction
    verbPhrase = 'auszustecken/ausstecken (was)'
;

// ##############
// -- ScrewAction
// ##############

VerbRule(SchraubZu)
    verb('schraub','schraube','dreh','zieh') dobjList prep('fest','zu')
    : ScrewAction
    verbPattern('zuzudrehen/zudrehen','(was)')
;

// ##################
// -- ScrewWithAction
// ##################

VerbRule(SchraubZuMit)
    verb('schraub','schraube','dreh','zieh') dobjList 'mit' singleIobj prep('fest','zu')
    : ScrewWithAction
    verbPattern('zuzudrehen/zudrehen (was)','(mit dativ was)')
    omitIobjInDobjQuery = true
    askIobjResponseProd = mitSingleNoun
;

// ################
// -- UnscrewAction
// ################

VerbRule(SchraubAuf)
    verb('schraub','schraube','dreh') dobjList prep('auf','locker','ab')
    : UnscrewAction
    verbPattern('aufzudrehen/aufdrehen','(was)')
;

// ####################
// -- UnscrewWithAction
// ####################

VerbRule(SchraubAufMit)
    verb('schraub','schraube','dreh') dobjList 'mit' singleIobj prep('auf','locker','ab')
    | verb('locker','lös') dobjList 'mit' singleIobj
    : UnscrewWithAction
    verbPattern('aufzudrehen/aufdrehen','(was) (mit dativ was)')
    omitIobjInDobjQuery = true
    askIobjResponseProd = mitSingleNoun
;

// ######################
// -- PushTravelDirAction
// ######################

VerbRule(SchiebNachDir)
    verb('schieb','zieh','beweg','stoß','schubs') singleDobj 'nach' singleDir
    : PushTravelDirAction
    verbPattern('zu schieben/schieben','(was) nach ' + dirMatch.dir.name)
;

// ##########################
// -- PushTravelThroughAction
// ##########################

VerbRule(SchiebDurch)
    verb('schieb','zieh','beweg','stoß','schubs') singleDobj
    'durch' singleIobj (|'hindurch'|'durch')
    : PushTravelThroughAction
    verbPattern('durchzuziehen/durchziehen','(was) (durch was)')
;

// ########################
// -- PushTravelEnterAction
// ########################

VerbRule(SchiebHinein)
    verb('schieb','zieh','beweg','stoß','schubs') singleDobj
    'in' singleIobj (|'hinein')
    : PushTravelEnterAction
    verbPattern('hineinzuziehen/hineinziehen','(was) (in was)')
;

// ###########################
// -- PushTravelGetOutOfAction
// ###########################

VerbRule(SchiebHinaus)
    verb('schieb','zieh','beweg','stoß','schubs') singleDobj
    'aus' singleIobj (|'hinaus')
    : PushTravelGetOutOfAction
    verbPattern('herauszuziehen/herausziehen','(was) (aus dativ was)')
;

// ##########################
// -- PushTravelClimbUpAction
// ##########################

VerbRule(SchiebHinauf)
    verb('schieb','zieh','beweg','stoß','schubs') singleDobj
    'auf' singleIobj (|'hinauf'|'hoch')
    : PushTravelClimbUpAction
    verbPattern('heraufzuziehen/heraufziehen','(was) (auf was)')
    omitIobjInDobjQuery = true
;

// ############################
// -- PushTravelClimbDownAction
// ############################

VerbRule(SchiebHinunter)
    verb('schieb','zieh','beweg','stoß','schubs') singleDobj
    'von' singleIobj (|'hinunter')
    : PushTravelClimbDownAction
    verbPattern('herunterzuziehen/herunterziehen','(was) (von was)')
;

// ##############
// -- ExitsAction
// ##############

VerbRule(Ausgang)
    'exits' | 'ausgäng' | 'ausgang'
    : ExitsAction
    verbPhrase = 'die Ausgänge zu zeigen/die Ausgänge zeigen'
;

VerbRule(AusgangModus)
    ('ausgäng'|'ausgang') ('an'->on_ | 'all'->on_ | 'ein'->on_
             | 'aus'->off_ | 'kein'->off_
             | ('status' ('zeile' | ) | 'statuszeile') 'raum'->on_
             | 'look'->on_ ('status' ('zeile' | ) | 'statuszeile')
             | 'status'->stat_ ('zeile' | ) | 'statuszeile'->stat_
             | 'raum'->look_)
    : ExitsModeAction
    verbPhrase = 'die Ausgänge anzuzeigen/die Ausgänge anzeigen'
;

VerbRule(HinweiseAus)
    'hinweis' 'aus'
    : HintsOffAction
    verbPhrase = 'Hinweise auszuschalten/Hinweise ausschalten'
;

VerbRule(Hinweise)
    'hinweis'
    : HintAction
    verbPhrase = 'Hinweise zu zeigen/Hinweise zeigen'
;

VerbRule(Ups)
    ('oops' | 'ups' | 'äh' ) singleLiteral
    : OopsAction
    verbPhrase = 'zu korrigieren/korrigieren (was)'
;

VerbRule(NurUps)
    ('oops' | 'ups' | 'äh' )
    : OopsIAction
    verbPhrase = 'zu korrigieren/korrigieren'
;

// ###############################
// -- German: debug verbs -- DEBUG
// ###############################

/* ------------------------------------------------------------------------ */
/*
 *   "debug" verb - special verb to break into the debugger.  We'll only
 *   compile this into the game if we're compiling a debug version to begin
 *   with, since a non-debug version can't be run under the debugger.  
 */

#ifdef __DEBUG

VerbRule(Debug)
    'debug'
    : DebugAction
    verbPhrase = 'zu debuggen/debuggen'
;

// ######################################
// -- German: debug verbs -- ACTION-DEBUG
// ######################################

#ifdef PARSER_DEBUG

modify libGlobal {
    actionDebugMode = nil
}

/*************************************************************************/
/* we call showAction from the replaced roomAfterAction() function below */
/*************************************************************************/

showAction()
{
    /* G-TADS */
    /* show the current action */
    "\n----------\n";
    "Grammar-Tag= *<b><<gAction.grammarTag>></b>* <<gDobj ? showDirectObject():''>> <<gIobj ? showIndirectObject():''>> ";
    "\n----------\n";
    /* G-TADS */
}

showDirectObject()
{
    "DirectObject =*<b><<gDobj.pureName>></b>*";
}

showIndirectObject()
{
    "IndirectObject =*<b><<gIobj.pureName>></b>*";
}

replace callRoomAfterAction(room)
{
    /* G-TADS */
    /* show the current action */
    if (libGlobal.actionDebugMode)
        showAction();
    /* G-TADS */
    
    /* first, call roomAfterAction on this room */
    room.roomAfterAction();

    /* next, call roomAfterAction on the room's containers */
    room.forEachContainer(callRoomAfterAction);
}
   
DefineIAction(ActionDebug)
    execAction()
    {
        local newMode;

        /* 
         *   get the mode - if the mode is explicitly stated in the
         *   command, use the stated new mode, otherwise invert the current
         *   mode 
         */
        newMode = (onOrOff_ == 'on'
                   ? true
                   : onOrOff_ == 'off'
                   ? nil
                   : !libGlobal.actionDebugMode);

        /* set the new mode */
        libGlobal.actionDebugMode = newMode;

        /* mention the change */
        "Action debugging is now
        <<libGlobal.actionDebugMode ? 'on' : 'off'>>.\n";
    }
;

grammar predicate(ActionDebug):
    'action-debug' 'on'->onOrOff_
    | 'action-debug' 'off'->onOrOff_
    | 'action-debug'
    : ActionDebugAction
;

#endif
    
// #################################
// -- German: debug verbs -- DECLINE
// #################################

VerbRule(Decline)
    'deklinier' singleDobj
    : DeclineAction
    verbPhrase = 'zu deklinieren/deklinieren (was)'
;

DefineTAction(Decline)
;

// Testing command which lets the author see, if he has correctly 
// defined the case and gender of an object
// e.g. >dekliniere tisch 

modify Thing
      
    dobjFor(Decline)
    {
        action() 
        {
            "Direkter Artikel: ";
            say(self.derNameObj);
            ", ";
            say(self.desNameObj);
            ", ";
            say(self.demNameObj);
            ", ";
            say(self.denNameObj);
            "\n";
            "Indirekter Artikel: ";
            say(self.einNameObj);
            ", ";
            say(self.einesNameObj);
            ", ";
            say(self.einemNameObj);
            ", ";
            say(self.einenNameObj);
            "\n";
        }
    }
;

// ############################################################################
// -- German: debug verbs -- GONEAR AND PURLOIN (SIMILAR TO INFORM) AND PRONOUN
// ############################################################################

/* The purpose of the everything object is to contain a list of all usable game objects 
   which can be used as a list of objects in scope for certain debugging verb. 
 Everything caches a list of all relevant objects the first time its lst method is called. */ 

everything : object 
  /* lst_ will contain the list of all relevant objects. We initialize it to  
    nil to show that the list is yet to be cached */ 
  lst_ = nil 
   
  /* The lst_ method checks whether the list of objects has been cached yet.  
   If so, it simply returns it; if not, it calls initLst to build it first  
   (and then returns it). */  

  lst() 
  { 
    if (lst_ == nil) 
      initLst(); 
    return lst_; 
  } 

  /* initLst loops through every game object and adds it to lst_, unless  
   it's a Topic, which we don't want included even in this universal scope.  
   */ 

  initLst() 
  { 
    lst_ = new Vector(50); 
    local obj = firstObj(); 
     while (obj != nil) 
     { 
        if(obj.ofKind(Thing)) 
            lst_.append(obj); 
        obj = nextObj(obj); 
     } 
     lst_ = lst_.toList(); 
  } 
; 

DefineIAction(Pronoun)
    execAction {
        local x = gPlayerChar.getPronounAntecedent(PronounIt);
        if (x!=nil)
            "Es: <<x.derName>>.\n";
        else
            "Es: nicht gesetzt.\n";
        local y = gPlayerChar.getPronounAntecedent(PronounHim);
        if (y!=nil)
            "Er: <<y.derName>>.\n";
        else
            "Er: nicht gesetzt.\n";
        local z = gPlayerChar.getPronounAntecedent(PronounHer);
        if (z!=nil) {
            if (!z.ofKind(List))
                "Sie: <<z.derName>>.\n";
            else {
                "Sie: ";
                foreach (local cur in z) {
                    "<<cur.derName>>. ";
                }   
                "\n";
            }
        }
        else
            "Sie: nicht gesetzt.\n";   
        local pl = gPlayerChar.getPronounAntecedent(PronounThem);
        if (pl!=nil) {
            if (!pl.ofKind(List))
                "Plural: <<pl.derName>>.\n";
            else {
                "Plural: ";
                foreach (local cur in pl) {
                    "<<cur.derName>>. ";
                }   
                "\n";
            }
        }
        else
            "Plural: nicht gesetzt.\n";  
    }
; 

VerbRule(Pronoun) 
  ('pronoun'|'pronomen')  
  :PronounAction 
  verbPhrase = 'Pronomen zu zeigen/Pronomen zeigen' 
; 

// #################################
// -- German: debug verbs -- PURLOIN
// #################################

DefineTAction(Purloin) 
    cacheScopeList() 
    {      
        scope_ = everything.lst();          
    }   
; 

VerbRule(Purloin) 
  ('purloin'|'pn') dobjList  
  :PurloinAction 
  verbPhrase = 'zu nehmen/nehmen (was)' 
; 

modify Thing 
    dobjFor(Purloin) 
    { 
        verify() 
        { 
            if(isHeldBy(gActor)) illogicalNow('{Du/er} {hat} {den dobj/ihn} bereits in der Hand. ');  
        } 
        check() {} 
        action 
        { 
            mainReport('{Der dobj/er} {faellt} in {deine} Hände.\n '); 
            self.moveInto(gActor); 
            if (!self.discovered)
                    self.discover();
        } 
    } 
; 

// ################################
// -- German: debug verbs -- GONEAR
// ################################

DefineTAction(Gonear) 
   cacheScopeList() 
     {      
       scope_ = everything.lst();          
     } 
; 

VerbRule(Gonear) 
  ('gonear'|'gn'|'go' 'near') singleDobj  
  :GonearAction 
  verbPhrase = 'zu gehen/gehen (hin was)' 
; 

modify Thing 
    dobjFor(Gonear) 
    { 
        verify() {} 
        check() {} 
        action() 
        { 
            local obj = getOutermostRoom(); 

            if(obj != nil) 
            { 
                 "{Du/er} {wird} wunderbarer Weise transportiert...</p>"; 
                 replaceAction(TravelVia, obj); 
            } 
            else 
                "{Du/er} {kann} nicht dorthin gehen. "; 
        } 
    }
    dobjFor(Message) {
        verify() {}
        action() {
            askForIobj(MessageWith);
        }
    }
    dobjFor(MessageWith) {
        verify() {}
    }
    iobjFor(MessageWith) {
        verify() {}
        action() {
            "Standard Messages mit {dem dobj/ihm} und {dem iobj/ihm}:\n\n
            cannotDoThatMessage: <q><b><<playerActionMessages.cannotDoThatMsg>></b></q>\n
            mustBeHoldingMsg(obj): <q><b><<playerActionMessages.mustBeHoldingMsg(gDobj)>></b></q>\n
            tooDarkMsg: <q><b><<playerActionMessages.tooDarkMsg>></b></q>\n
            mustBeVisibleMsg(obj): <q><b><<playerActionMessages.mustBeVisibleMsg(gDobj)>></b></q>\n
            heardButNotSeenMsg(obj): <q><b><<playerActionMessages.heardButNotSeenMsg(gDobj)>></b></q>\n
            smelledButNotSeenMsg(obj): <q><b><<playerActionMessages.smelledButNotSeenMsg(gDobj)>></b></q>\n
            cannotHearMsg(obj): <q><b><<playerActionMessages.cannotHearMsg(gDobj)>></b></q>\n
            cannotSmellMsg(obj): <q><b><<playerActionMessages.cannotSmellMsg(gDobj)>></b></q>\n
            cannotTasteMsg(obj): <q><b><<playerActionMessages.cannotTasteMsg(gDobj)>></b></q>\n
            cannotBeWearingMsg(obj): <q><b><<playerActionMessages.cannotBeWearingMsg(gDobj)>></b></q>\n
            mustBeEmptyMsg(obj): <q><b><<playerActionMessages.mustBeEmptyMsg(gDobj)>></b></q>\n
            mustBeOpenMsg(obj): <q><b><<playerActionMessages.mustBeOpenMsg(gDobj)>></b></q>\n
            mustBeClosedMsg(obj): <q><b><<playerActionMessages.mustBeClosedMsg(gDobj)>></b></q>\n
            mustBeUnlockedMsg(obj): <q><b><<playerActionMessages.mustBeUnlockedMsg(gDobj)>></b></q>\n
            noKeyNeededMsg: <q><b><<playerActionMessages.noKeyNeededMsg>></b></q>\n
            mustBeStandingMsg: <q><b><<playerActionMessages.mustBeStandingMsg>></b></q>\n
            mustSitOnMsg(obj): <q><b><<playerActionMessages.mustSitOnMsg(gDobj)>></b></q>\n
            mustLieOnMsg(obj): <q><b><<playerActionMessages.mustLieOnMsg(gDobj)>></b></q>\n
            mustGetOnMsg(obj): <q><b><<playerActionMessages.mustGetOnMsg(gDobj)>></b></q>\n
            mustBeInMsg(obj, loc): <q><b><<playerActionMessages.mustBeInMsg(gDobj,gIobj)>></b></q>\n
            mustBeCarryingMsg(obj, actor): <q><b><<playerActionMessages.mustBeCarryingMsg(gDobj,gIobj)>></b></q>\n
            decorationNotImportantMsg(obj): <q><b><<playerActionMessages.decorationNotImportantMsg(gDobj)>></b></q>\n
            unthingNotHereMsg(obj): <q><b><<playerActionMessages.unthingNotHereMsg(gDobj)>></b></q>\n
            tooDistantMsg(obj): <q><b><<playerActionMessages.tooDistantMsg(gDobj)>></b></q>\n
            notWithIntangibleMsg(obj): <q><b><<playerActionMessages.notWithIntangibleMsg(gDobj)>></b></q>\n
            notWithVaporousMsg(obj): <q><b><<playerActionMessages.notWithVaporousMsg(gDobj)>></b></q>\n
            lookInVaporousMsg(obj): <q><b><<playerActionMessages.lookInVaporousMsg(gDobj)>></b></q>\n
            cannotReachObjectMsg(obj): <q><b><<playerActionMessages.cannotReachObjectMsg(gDobj)>></b></q>\n
            cannotReachThroughMsg(obj, loc): <q><b><<playerActionMessages.cannotReachThroughMsg(gDobj,gIobj)>></b></q>\n
            thingDescMsg(obj): <q><b><<playerActionMessages.thingDescMsg(gDobj)>></b></q>\n
            thingSoundDescMsg(obj): <q><b><<playerActionMessages.thingSoundDescMsg(gDobj)>></b></q>\n
            thingSmellDescMsg(obj): <q><b><<playerActionMessages.thingSmellDescMsg(gDobj)>></b></q>\n
            npcDescMsg(obj): <q><b><<playerActionMessages.npcDescMsg(gDobj)>></b></q>\n
            nothingInsideMsg: <q><b><<playerActionMessages.nothingInsideMsg>></b></q>\n
            nothingUnderMsg: <q><b><<playerActionMessages.nothingUnderMsg>></b></q>\n
            nothingBehindMsg: <q><b><<playerActionMessages.nothingBehindMsg>></b></q>\n
            nothingThroughMsg: <q><b><<playerActionMessages.nothingThroughMsg>></b></q>\n
            cannotLookBehindMsg: <q><b><<playerActionMessages.cannotLookBehindMsg>></b></q>\n
            cannotLookUnderMsg: <q><b><<playerActionMessages.cannotLookUnderMsg>></b></q>\n
            cannotLookThroughMsg: <q><b><<playerActionMessages.cannotLookThroughMsg>></b></q>\n
            nothingThroughPassageMsg: <q><b><<playerActionMessages.nothingThroughPassageMsg>></b></q>\n
            nothingBeyondDoorMsg: <q><b><<playerActionMessages.nothingBeyondDoorMsg>></b></q>\n
            nothingToSmellMsg: <q><b><<playerActionMessages.nothingToSmellMsg>></b></q>\n
            nothingToHearMsg: <q><b><<playerActionMessages.nothingToHearMsg>></b></q>\n
            noiseSourceMsg(obj): <q><b><<playerActionMessages.noiseSourceMsg(gDobj)>></b></q>\n
            odorSourceMsg(obj): <q><b><<playerActionMessages.odorSourceMsg(gDobj)>></b></q>\n
            notWearableMsg: <q><b><<playerActionMessages.notWearableMsg>></b></q>\n
            notDoffableMsg: <q><b><<playerActionMessages.notDoffableMsg>></b></q>\n
            alreadyWearingMsg: <q><b><<playerActionMessages.alreadyWearingMsg>></b></q>\n
            okayWearMsg: <q><b><<playerActionMessages.okayWearMsg>></b></q>\n
            okayDoffMsg: <q><b><<playerActionMessages.okayDoffMsg>></b></q>\n
            okayOpenMsg: <q><b><<playerActionMessages.okayOpenMsg>></b></q>\n
            okayCloseMsg: <q><b><<playerActionMessages.okayCloseMsg>></b></q>\n
            okayLockMsg: <q><b><<playerActionMessages.okayLockMsg>></b></q>\n
            okayUnlockMsg: <q><b><<playerActionMessages.okayUnlockMsg>></b></q>\n
            cannotDigMsg: <q><b><<playerActionMessages.cannotDigMsg>></b></q>\n
            cannotDigWithMsg: <q><b><<playerActionMessages.cannotDigWithMsg>></b></q>\n
            alreadyHoldingMsg: <q><b><<playerActionMessages.alreadyHoldingMsg>></b></q>\n
            takingSelfMsg: <q><b><<playerActionMessages.takingSelfMsg>></b></q>\n
            notCarryingMsg: <q><b><<playerActionMessages.notCarryingMsg>></b></q>\n
            droppingSelfMsg: <q><b><<playerActionMessages.droppingSelfMsg>></b></q>\n
            puttingSelfMsg: <q><b><<playerActionMessages.puttingSelfMsg>></b></q>\n
            throwingSelfMsg: <q><b><<playerActionMessages.throwingSelfMsg>></b></q>\n
            alreadyPutInMsg: <q><b><<playerActionMessages.alreadyPutInMsg>></b></q>\n
            alreadyPutOnMsg: <q><b><<playerActionMessages.alreadyPutOnMsg>></b></q>\n
            alreadyPutUnderMsg: <q><b><<playerActionMessages.alreadyPutUnderMsg>></b></q>\n
            alreadyPutBehindMsg: <q><b><<playerActionMessages.alreadyPutBehindMsg>></b></q>\n
            cannotMoveFixtureMsg: <q><b><<playerActionMessages.cannotMoveFixtureMsg>></b></q>\n
            cannotTakeFixtureMsg: <q><b><<playerActionMessages.cannotTakeFixtureMsg>></b></q>\n
            cannotPutFixtureMsg: <q><b><<playerActionMessages.cannotPutFixtureMsg>></b></q>\n
            cannotTakeImmovableMsg: <q><b><<playerActionMessages.cannotTakeImmovableMsg>></b></q>\n
            cannotMoveImmovableMsg: <q><b><<playerActionMessages.cannotMoveImmovableMsg>></b></q>\n
            cannotPutImmovableMsg: <q><b><<playerActionMessages.cannotPutImmovableMsg>></b></q>\n
            cannotTakeHeavyMsg: <q><b><<playerActionMessages.cannotTakeHeavyMsg>></b></q>\n
            cannotMoveHeavyMsg: <q><b><<playerActionMessages.cannotMoveHeavyMsg>></b></q>\n
            cannotPutHeavyMsg: <q><b><<playerActionMessages.cannotPutHeavyMsg>></b></q>\n
            cannotMoveComponentMsg(loc): <q><b><<playerActionMessages.cannotMoveComponentMsg(gDobj)>></b></q>\n
            cannotTakeComponentMsg(loc): <q><b><<playerActionMessages.cannotTakeComponentMsg(gDobj)>></b></q>\n
            cannotPutComponentMsg(loc): <q><b><<playerActionMessages.cannotPutComponentMsg(gDobj)>></b></q>\n
            cannotTakePushableMsg: <q><b><<playerActionMessages.cannotTakePushableMsg>></b></q>\n
            cannotMovePushableMsg: <q><b><<playerActionMessages.cannotMovePushableMsg>></b></q>\n
            cannotPutPushableMsg: <q><b><<playerActionMessages.cannotPutPushableMsg>></b></q>\n
            cannotTakeLocationMsg: <q><b><<playerActionMessages.cannotTakeLocationMsg>></b></q>\n
            cannotRemoveHeldMsg: <q><b><<playerActionMessages.cannotRemoveHeldMsg>></b></q>\n
            okayTakeMsg: <q><b><<playerActionMessages.okayTakeMsg>></b></q>\n     
            okayDropMsg: <q><b><<playerActionMessages.okayDropMsg>></b></q>\n
            droppingObjMsg(dropobj): <q><b><<playerActionMessages.droppingObjMsg(gDobj)>></b></q>\n
            floorlessDropMsg(dropobj): <q><b><<playerActionMessages.floorlessDropMsg(gDobj)>></b></q>\n          
            okayPutInMsg: <q><b><<playerActionMessages.okayPutInMsg>></b></q>\n
            okayPutOnMsg: <q><b><<playerActionMessages.okayPutOnMsg>></b></q>\n
            okayPutUnderMsg: <q><b><<playerActionMessages.okayPutUnderMsg>></b></q>\n
            okayPutBehindMsg: <q><b><<playerActionMessages.okayPutBehindMsg>></b></q>\n
            cannotTakeActorMsg: <q><b><<playerActionMessages.cannotTakeActorMsg>></b></q>\n
            cannotMoveActorMsg: <q><b><<playerActionMessages.cannotMoveActorMsg>></b></q>\n
            cannotPutActorMsg: <q><b><<playerActionMessages.cannotPutActorMsg>></b></q>\n
            cannotTasteActorMsg: <q><b><<playerActionMessages.cannotTasteActorMsg>></b></q>\n
            cannotTakePersonMsg: <q><b><<playerActionMessages.cannotTakePersonMsg>></b></q>\n
            cannotMovePersonMsg: <q><b><<playerActionMessages.cannotMovePersonMsg>></b></q>\n
            cannotPutPersonMsg: <q><b><<playerActionMessages.cannotPutPersonMsg>></b></q>\n
            cannotTastePersonMsg: <q><b><<playerActionMessages.cannotTastePersonMsg>></b></q>\n
            cannotMoveThroughMsg(obj,obs): <q><b><<playerActionMessages.cannotMoveThroughMsg(gDobj,gIobj)>></b></q>\n
            cannotMoveThroughContainerMsg(obj,cont): <q><b><<playerActionMessages.cannotMoveThroughContainerMsg(gDobj,gIobj)>></b></q>\n
            cannotMoveThroughClosedMsg(obj,cont): <q><b><<playerActionMessages.cannotMoveThroughClosedMsg(gDobj,gIobj)>></b></q>\n
            cannotFitIntoOpeningMsg(obj,cont): <q><b><<playerActionMessages.cannotFitIntoOpeningMsg(gDobj,gIobj)>></b></q>\n
            cannotFitOutOfOpeningMsg(obj,cont): <q><b><<playerActionMessages.cannotFitOutOfOpeningMsg(gDobj,gIobj)>></b></q>\n
            cannotTouchThroughContainerMsg(obj,cont): <q><b><<playerActionMessages.cannotTouchThroughContainerMsg(gDobj,gIobj)>></b></q>\n
            cannotTouchThroughClosedMsg(obj,cont): <q><b><<playerActionMessages.cannotTouchThroughClosedMsg(gDobj,gIobj)>></b></q>\n        
            cannotReachIntoOpeningMsg(obj,cont): <q><b><<playerActionMessages.cannotReachIntoOpeningMsg(gDobj,gIobj)>></b></q>\n
            cannotReachOutOfOpeningMsg(obj,cont): <q><b><<playerActionMessages.cannotReachOutOfOpeningMsg(gDobj,gIobj)>></b></q>\n
            tooLargeForActorMsg(obj): <q><b><<playerActionMessages.tooLargeForActorMsg(gDobj)>></b></q>\n
            handsTooFullForMsg(obj): <q><b><<playerActionMessages.handsTooFullForMsg(gDobj)>></b></q>\n
            becomingTooLargeForActorMsg(obj): <q><b><<playerActionMessages.becomingTooLargeForActorMsg(gDobj)>></b></q>\n
            handsBecomingTooFullForMsg(obj): <q><b><<playerActionMessages.handsBecomingTooFullForMsg(gDobj)>></b></q>\n
            tooHeavyForActorMsg(obj): <q><b><<playerActionMessages.tooHeavyForActorMsg(gDobj)>></b></q>\n
            totalTooHeavyForMsg(obj): <q><b><<playerActionMessages.totalTooHeavyForMsg(gDobj)>></b></q>\n
            tooLargeForContainerMsg(obj,cont): <q><b><<playerActionMessages.tooLargeForContainerMsg(gDobj,gIobj)>></b></q>\n
            tooLargeForUndersideMsg(obj,cont): <q><b><<playerActionMessages.tooLargeForUndersideMsg(gDobj,gIobj)>></b></q>\n
            tooLargeForRearMsg(obj,cont): <q><b><<playerActionMessages.tooLargeForRearMsg(gDobj,gIobj)>></b></q>\n
            containerTooFullMsg(obj,cont): <q><b><<playerActionMessages.containerTooFullMsg(gDobj,gIobj)>></b></q>\n
            surfaceTooFullMsg(obj,cont): <q><b><<playerActionMessages.surfaceTooFullMsg(gDobj,gIobj)>></b></q>\n
            undersideTooFullMsg(obj,cont): <q><b><<playerActionMessages.undersideTooFullMsg(gDobj,gIobj)>></b></q>\n
            rearTooFullMsg(obj,cont): <q><b><<playerActionMessages.rearTooFullMsg(gDobj,gIobj)>></b></q>\n
            becomingTooLargeForContainerMsg(obj,cont): <q><b><<playerActionMessages.becomingTooLargeForContainerMsg(gDobj,gIobj)>></b></q>\n
            containerBecomingTooFullMsg(obj,cont): <q><b><<playerActionMessages.containerBecomingTooFullMsg(gDobj,gIobj)>></b></q>\n
            notAContainerMsg: <q><b><<playerActionMessages.notAContainerMsg>></b></q>\n
            notASurfaceMsg: <q><b><<playerActionMessages.notASurfaceMsg>></b></q>\n
            cannotPutUnderMsg: <q><b><<playerActionMessages.cannotPutUnderMsg>></b></q>\n            
            cannotPutBehindMsg: <q><b><<playerActionMessages.cannotPutBehindMsg>></b></q>\n
            cannotPutInSelfMsg: <q><b><<playerActionMessages.cannotPutInSelfMsg>></b></q>\n
            cannotPutOnSelfMsg: <q><b><<playerActionMessages.cannotPutOnSelfMsg>></b></q>\n
            cannotPutUnderSelfMsg: <q><b><<playerActionMessages.cannotPutUnderSelfMsg>></b></q>\n
            cannotPutBehindSelfMsg: <q><b><<playerActionMessages.cannotPutBehindSelfMsg>></b></q>\n
            cannotPutInRestrictedMsg: <q><b><<playerActionMessages.cannotPutInRestrictedMsg>></b></q>\n
            cannotPutOnRestrictedMsg: <q><b><<playerActionMessages.cannotPutOnRestrictedMsg>></b></q>\n
            cannotPutUnderRestrictedMsg: <q><b><<playerActionMessages.cannotPutUnderRestrictedMsg>></b></q>\n
            cannotPutBehindRestrictedMsg: <q><b><<playerActionMessages.cannotPutBehindRestrictedMsg>></b></q>\n
            cannotReturnToDispenserMsg: <q><b><<playerActionMessages.cannotReturnToDispenserMsg>></b></q>\n
            cannotPutInDispenserMsg: <q><b><<playerActionMessages.cannotPutInDispenserMsg>></b></q>\n
            objNotForKeyringMsg: <q><b><<playerActionMessages.objNotForKeyringMsg>></b></q>\n
            keyNotOnKeyringMsg: <q><b><<playerActionMessages.keyNotOnKeyringMsg>></b></q>\n
            keyNotDetachableMsg: <q><b><<playerActionMessages.keyNotDetachableMsg>></b></q>\n
            takenAndMovedToKeyringMsg(keyring): <q><b><<playerActionMessages.takenAndMovedToKeyringMsg(gDobj)>></b></q>\n
            movedKeyToKeyringMsg(keyring): <q><b><<playerActionMessages.movedKeyToKeyringMsg(gDobj)>></b></q>\n
            movedKeysToKeyringMsg(keyring,keys): <q><b><<playerActionMessages.movedKeysToKeyringMsg(gDobj,gIobj)>></b></q>\n
            circularlyInMsg(x,y): <q><b><<playerActionMessages.circularlyInMsg(gDobj,gIobj)>></b></q>\n
            circularlyOnMsg(x,y): <q><b><<playerActionMessages.circularlyOnMsg(gDobj,gIobj)>></b></q>\n
            circularlyUnderMsg(x,y): <q><b><<playerActionMessages.circularlyUnderMsg(gDobj,gIobj)>></b></q>\n
            circularlyBehindMsg(x,y): <q><b><<playerActionMessages.circularlyBehindMsg(gDobj,gIobj)>></b></q>\n
            takeFromNotInMsg: <q><b><<playerActionMessages.takeFromNotInMsg>></b></q>\n
            takeFromNotOnMsg: <q><b><<playerActionMessages.takeFromNotOnMsg>></b></q>\n
            takeFromNotUnderMsg: <q><b><<playerActionMessages.takeFromNotUnderMsg>></b></q>\n
            takeFromNotBehindMsg: <q><b><<playerActionMessages.takeFromNotBehindMsg>></b></q>\n
            takeFromNotInActorMsg: <q><b><<playerActionMessages.takeFromNotInActorMsg>></b></q>\n
            willNotLetGoMsg(holder,obj): <q><b><<playerActionMessages.willNotLetGoMsg(gDobj,gIobj)>></b></q>\n
            whereToGoMsg: <q><b><<playerActionMessages.whereToGoMsg>></b></q>\n
            cannotGoThatWayMsg: <q><b><<playerActionMessages.cannotGoThatWayMsg>></b></q>\n
            cannotGoThatWayInDarkMsg: <q><b><<playerActionMessages.cannotGoThatWayInDarkMsg>></b></q>\n
            cannotGoBackMsg: <q><b><<playerActionMessages.cannotGoBackMsg>></b></q>\n
            cannotDoFromHereMsg: <q><b><<playerActionMessages.cannotDoFromHereMsg>></b></q>\n
            cannotGoThroughClosedDoorMsg(door): <q><b><<playerActionMessages.cannotGoThroughClosedDoorMsg(gDobj)>></b></q>\n
            invalidStagingContainerMsg(cont,dest): <q><b><<playerActionMessages.invalidStagingContainerMsg(gDobj,gIobj)>></b></q>\n
            invalidStagingContainerActorMsg(cont,dest): <q><b><<playerActionMessages.invalidStagingContainerActorMsg(gDobj,gIobj)>></b></q>\n
            invalidStagingLocationMsg(dest): <q><b><<playerActionMessages.invalidStagingLocationMsg(gDobj)>></b></q>\n
            nestedRoomTooHighMsg(obj): <q><b><<playerActionMessages.nestedRoomTooHighMsg(gDobj)>></b></q>\n
            nestedRoomTooHighToExitMsg(obj): <q><b><<playerActionMessages.nestedRoomTooHighToExitMsg(gDobj)>></b></q>\n
            cannotDoFromMsg(obj): <q><b><<playerActionMessages.cannotDoFromMsg(gDobj)>></b></q>\n
            vehicleCannotDoFromMsg(obj): <q><b><<playerActionMessages.vehicleCannotDoFromMsg(gDobj)>></b></q>\n
            cannotGoThatWayInVehicleMsg(traveler): <q><b><<playerActionMessages.cannotGoThatWayInVehicleMsg(gDobj)>></b></q>\n
            cannotPushObjectThatWayMsg(obj): <q><b><<playerActionMessages.cannotPushObjectThatWayMsg(gDobj)>></b></q>\n
            cannotPushObjectNestedMsg(obj): <q><b><<playerActionMessages.cannotPushObjectNestedMsg(gDobj)>></b></q>\n
            cannotEnterExitOnlyMsg(obj): <q><b><<playerActionMessages.cannotEnterExitOnlyMsg(gDobj)>></b></q>\n
            mustOpenDoorMsg(obj): <q><b><<playerActionMessages.mustOpenDoorMsg(gDobj)>></b></q>\n
            doorClosesBehindMsg(obj): <q><b><<playerActionMessages.doorClosesBehindMsg(gDobj)>></b></q>\n
            stairwayNotUpMsg: <q><b><<playerActionMessages.stairwayNotUpMsg>></b></q>\n
            stairwayNotDownMsg: <q><b><<playerActionMessages.stairwayNotDownMsg>></b></q>\n
            sayHelloMsg: <q><b><<playerActionMessages.sayHelloMsg>></b></q>\n
            sayGoodbyeMsg: <q><b><<playerActionMessages.sayGoodbyeMsg>></b></q>\n
            sayYesMsg: <q><b><<playerActionMessages.sayYesMsg>></b></q>\n
            sayNoMsg: <q><b><<playerActionMessages.sayNoMsg>></b></q>\n
            addressingNoOneMsg: <q><b><<playerActionMessages.addressingNoOneMsg>></b></q>\n
            okayYellMsg: <q><b><<playerActionMessages.okayYellMsg>></b></q>\n
            okayJumpMsg: <q><b><<playerActionMessages.okayJumpMsg>></b></q>\n
            cannotJumpOverMsg: <q><b><<playerActionMessages.cannotJumpOverMsg>></b></q>\n
            cannotJumpOffMsg: <q><b><<playerActionMessages.cannotJumpOffMsg>></b></q>\n
            cannotJumpOffHereMsg: <q><b><<playerActionMessages.cannotJumpOffHereMsg>></b></q>\n
            cannotFindTopicMsg: <q><b><<playerActionMessages.cannotFindTopicMsg>></b></q>\n
            refuseCommand(targetActor,issuingActor): <q><b><<playerActionMessages.refuseCommand(gDobj,gIobj)>></b></q>\n
            notAddressableMsg(obj): <q><b><<playerActionMessages.notAddressableMsg(gDobj)>></b></q>\n
            noResponseFromMsg(other): <q><b><<playerActionMessages.noResponseFromMsg(gDobj)>></b></q>\n
            giveAlreadyHasMsg: <q><b><<playerActionMessages.giveAlreadyHasMsg>></b></q>\n
            cannotTalkToSelfMsg: <q><b><<playerActionMessages.cannotTalkToSelfMsg>></b></q>\n
            cannotAskSelfMsg: <q><b><<playerActionMessages.cannotAskSelfMsg>></b></q>\n
            cannotAskSelfForMsg: <q><b><<playerActionMessages.cannotAskSelfForMsg>></b></q>\n
            cannotTellSelfMsg: <q><b><<playerActionMessages.cannotTellSelfMsg>></b></q>\n
            cannotGiveToSelfMsg: <q><b><<playerActionMessages.cannotGiveToSelfMsg>></b></q>\n
            cannotGiveToItselfMsg: <q><b><<playerActionMessages.cannotGiveToItselfMsg>></b></q>\n
            cannotShowToSelfMsg: <q><b><<playerActionMessages.cannotShowToSelfMsg>></b></q>\n
            cannotShowToItselfMsg: <q><b><<playerActionMessages.cannotShowToItselfMsg>></b></q>\n
            cannotGiveToMsg: <q><b><<playerActionMessages.cannotGiveToMsg>></b></q>\n
            cannotShowToMsg: <q><b><<playerActionMessages.cannotShowToMsg>></b></q>\n
            notInterestedMsg(actor): <q><b><<playerActionMessages.notInterestedMsg(gDobj)>></b></q>\n 
            askVagueMsg: <q><b><<playerActionMessages.askVagueMsg>></b></q>\n
            tellVagueMsg: <q><b><<playerActionMessages.tellVagueMsg>></b></q>\n
            objCannotHearActorMsg(obj): <q><b><<playerActionMessages.objCannotHearActorMsg(gDobj)>></b></q>\n
            actorCannotSeeMsg(actor,obj): <q><b><<playerActionMessages.actorCannotSeeMsg(gDobj,gIobj)>></b></q>\n
            notFollowableMsg: <q><b><<playerActionMessages.notFollowableMsg>></b></q>\n
            cannotFollowSelfMsg: <q><b><<playerActionMessages.cannotFollowSelfMsg>></b></q>\n
            followAlreadyHereMsg: <q><b><<playerActionMessages.followAlreadyHereMsg>></b></q>\n
            followAlreadyHereInDarkMsg: <q><b><<playerActionMessages.followAlreadyHereInDarkMsg>></b></q>\n
            followUnknownMsg: <q><b><<playerActionMessages.followUnknownMsg>></b></q>\n
            cannotFollowFromHereMsg(srcLoc): <q><b><<playerActionMessages.cannotFollowFromHereMsg(gDobj)>></b></q>\n
            okayFollowInSightMsg(loc): <q><b><<playerActionMessages.okayFollowInSightMsg(gDobj)>></b></q>\n     
            notAWeaponMsg: <q><b><<playerActionMessages.notAWeaponMsg>></b></q>\n
            uselessToAttackMsg: <q><b><<playerActionMessages.uselessToAttackMsg>></b></q>\n
            pushNoEffectMsg: <q><b><<playerActionMessages.pushNoEffectMsg>></b></q>\n
            okayPushButtonMsg: <q><b><<playerActionMessages.okayPushButtonMsg>></b></q>\n
            alreadyPushedMsg: <q><b><<playerActionMessages.alreadyPushedMsg>></b></q>\n
            okayPushLeverMsg: <q><b><<playerActionMessages.okayPushLeverMsg>></b></q>\n
            pullNoEffectMsg: <q><b><<playerActionMessages.pullNoEffectMsg>></b></q>\n
            alreadyPulledMsg: <q><b><<playerActionMessages.alreadyPulledMsg>></b></q>\n
            okayPullLeverMsg: <q><b><<playerActionMessages.okayPullLeverMsg>></b></q>\n
            okayPullSpringLeverMsg: <q><b><<playerActionMessages.okayPullSpringLeverMsg>></b></q>\n
            moveNoEffectMsg: <q><b><<playerActionMessages.moveNoEffectMsg>></b></q>\n
            moveToNoEffectMsg: <q><b><<playerActionMessages.moveToNoEffectMsg>></b></q>\n
            cannotPushTravelMsg: <q><b><<playerActionMessages.cannotPushTravelMsg>></b></q>\n
            okayPushTravelMsg(obj): <q><b><<playerActionMessages.okayPushTravelMsg(gDobj)>></b></q>\n
            cannotMoveWithMsg: <q><b><<playerActionMessages.cannotMoveWithMsg>></b></q>\n
            cannotSetToMsg: <q><b><<playerActionMessages.cannotSetToMsg>></b></q>\n
            setToInvalidMsg: <q><b><<playerActionMessages.setToInvalidMsg>></b></q>\n
            okaySetToMsg(val): <q><b><<playerActionMessages.okaySetToMsg('Test')>></b></q>\n
            cannotTurnMsg: <q><b><<playerActionMessages.cannotTurnMsg>></b></q>\n
            mustSpecifyTurnToMsg: <q><b><<playerActionMessages.mustSpecifyTurnToMsg>></b></q>\n
            cannotTurnWithMsg: <q><b><<playerActionMessages.cannotTurnWithMsg>></b></q>\n
            turnToInvalidMsg: <q><b><<playerActionMessages.turnToInvalidMsg>></b></q>\n
            okayTurnToMsg(val): <q><b><<playerActionMessages.okayTurnToMsg('Test')>></b></q>\n
            alreadySwitchedOnMsg: <q><b><<playerActionMessages.alreadySwitchedOnMsg>></b></q>\n
            alreadySwitchedOffMsg: <q><b><<playerActionMessages.alreadySwitchedOffMsg>></b></q>\n
            okayTurnOnMsg: <q><b><<playerActionMessages.okayTurnOnMsg>></b></q>\n
            okayTurnOffMsg: <q><b><<playerActionMessages.okayTurnOffMsg>></b></q>\n
            flashlightOnButDarkMsg: <q><b><<playerActionMessages.flashlightOnButDarkMsg>></b></q>\n
            okayEatMsg: <q><b><<playerActionMessages.okayEatMsg>></b></q>\n
            mustBeBurningMsg(obj): <q><b><<playerActionMessages.mustBeBurningMsg(gDobj)>></b></q>\n
            matchNotLitMsg: <q><b><<playerActionMessages.matchNotLitMsg>></b></q>\n
            okayBurnMatchMsg: <q><b><<playerActionMessages.okayBurnMatchMsg>></b></q>\n
            okayExtinguishMatchMsg: <q><b><<playerActionMessages.okayExtinguishMatchMsg>></b></q>\n
            candleOutOfFuelMsg: <q><b><<playerActionMessages.candleOutOfFuelMsg>></b></q>\n
            okayBurnCandleMsg: <q><b><<playerActionMessages.okayBurnCandleMsg>></b></q>\n
            candleNotLitMsg: <q><b><<playerActionMessages.candleNotLitMsg>></b></q>\n
            okayExtinguishCandleMsg: <q><b><<playerActionMessages.okayExtinguishCandleMsg>></b></q>\n
            cannotConsultMsg: <q><b><<playerActionMessages.cannotConsultMsg>></b></q>\n
            cannotTypeOnMsg: <q><b><<playerActionMessages.cannotTypeOnMsg>></b></q>\n
            cannotEnterOnMsg: <q><b><<playerActionMessages.cannotEnterOnMsg>></b></q>\n
            cannotSwitchMsg: <q><b><<playerActionMessages.cannotSwitchMsg>></b></q>\n
            cannotFlipMsg: <q><b><<playerActionMessages.cannotFlipMsg>></b></q>\n
            cannotTurnOnMsg: <q><b><<playerActionMessages.cannotTurnOnMsg>></b></q>\n
            cannotTurnOffMsg: <q><b><<playerActionMessages.cannotTurnOffMsg>></b></q>\n
            cannotLightMsg: <q><b><<playerActionMessages.cannotLightMsg>></b></q>\n
            cannotBurnMsg: <q><b><<playerActionMessages.cannotBurnMsg>></b></q>\n
            cannotBurnWithMsg: <q><b><<playerActionMessages.cannotBurnWithMsg>></b></q>\n
            cannotBurnDobjWithMsg: <q><b><<playerActionMessages.cannotBurnDobjWithMsg>></b></q>\n
            alreadyBurningMsg: <q><b><<playerActionMessages.alreadyBurningMsg>></b></q>\n
            cannotExtinguishMsg: <q><b><<playerActionMessages.cannotExtinguishMsg>></b></q>\n
            cannotPourMsg: <q><b><<playerActionMessages.cannotPourMsg>></b></q>\n
            cannotPourIntoMsg: <q><b><<playerActionMessages.cannotPourIntoMsg>></b></q>\n
            cannotPourOntoMsg: <q><b><<playerActionMessages.cannotPourOntoMsg>></b></q>\n
            cannotAttachMsg: <q><b><<playerActionMessages.cannotAttachMsg>></b></q>\n
            cannotAttachToMsg: <q><b><<playerActionMessages.cannotAttachToMsg>></b></q>\n
            cannotAttachToSelfMsg: <q><b><<playerActionMessages.cannotAttachToSelfMsg>></b></q>\n
            alreadyAttachedMsg: <q><b><<playerActionMessages.alreadyAttachedMsg>></b></q>\n
            wrongAttachmentMsg: <q><b><<playerActionMessages.wrongAttachmentMsg>></b></q>\n
            wrongDetachmentMsg: <q><b><<playerActionMessages.wrongDetachmentMsg>></b></q>\n
            mustDetachMsg(obj): <q><b><<playerActionMessages.mustDetachMsg(gDobj)>></b></q>\n
            okayAttachToMsg: <q><b><<playerActionMessages.okayAttachToMsg>></b></q>\n
            okayDetachFromMsg: <q><b><<playerActionMessages.okayDetachFromMsg>></b></q>\n
            cannotDetachMsg: <q><b><<playerActionMessages.cannotDetachMsg>></b></q>\n
            cannotDetachFromMsg: <q><b><<playerActionMessages.cannotDetachFromMsg>></b></q>\n
            cannotDetachPermanentMsg: <q><b><<playerActionMessages.cannotDetachPermanentMsg>></b></q>\n
            notAttachedToMsg: <q><b><<playerActionMessages.notAttachedToMsg>></b></q>\n
            shouldNotBreakMsg: <q><b><<playerActionMessages.shouldNotBreakMsg>></b></q>\n
            cutNoEffectMsg: <q><b><<playerActionMessages.cutNoEffectMsg>></b></q>\n
            cannotCutWithMsg: <q><b><<playerActionMessages.cannotCutWithMsg>></b></q>\n
            cannotClimbMsg: <q><b><<playerActionMessages.cannotClimbMsg>></b></q>\n
            cannotOpenMsg: <q><b><<playerActionMessages.cannotOpenMsg>></b></q>\n
            cannotCloseMsg: <q><b><<playerActionMessages.cannotCloseMsg>></b></q>\n
            alreadyOpenMsg: <q><b><<playerActionMessages.alreadyOpenMsg>></b></q>\n
            alreadyClosedMsg: <q><b><<playerActionMessages.alreadyClosedMsg>></b></q>\n
            alreadyLockedMsg: <q><b><<playerActionMessages.alreadyLockedMsg>></b></q>\n
            alreadyUnlockedMsg: <q><b><<playerActionMessages.alreadyUnlockedMsg>></b></q>\n
            cannotLookInClosedMsg: <q><b><<playerActionMessages.cannotLookInClosedMsg>></b></q>\n
            cannotLockMsg: <q><b><<playerActionMessages.cannotLockMsg>></b></q>\n
            cannotUnlockMsg: <q><b><<playerActionMessages.cannotUnlockMsg>></b></q>\n
            cannotOpenLockedMsg: <q><b><<playerActionMessages.cannotOpenLockedMsg>></b></q>\n
            unlockRequiresKeyMsg: <q><b><<playerActionMessages.unlockRequiresKeyMsg>></b></q>\n
            cannotLockWithMsg: <q><b><<playerActionMessages.cannotLockWithMsg>></b></q>\n
            cannotUnlockWithMsg: <q><b><<playerActionMessages.cannotUnlockWithMsg>></b></q>\n
            unknownHowToLockMsg: <q><b><<playerActionMessages.unknownHowToLockMsg>></b></q>\n
            unknownHowToUnlockMsg: <q><b><<playerActionMessages.unknownHowToUnlockMsg>></b></q>\n
            keyDoesNotFitLockMsg: <q><b><<playerActionMessages.keyDoesNotFitLockMsg>></b></q>\n
            foundKeyOnKeyringMsg(ring,key): <q><b><<playerActionMessages.foundKeyOnKeyringMsg(gDobj,gIobj)>></b></q>\n
            foundNoKeyOnKeyringMsg(ring): <q><b><<playerActionMessages.foundNoKeyOnKeyringMsg(gDobj)>></b></q>\n
            cannotEatMsg: <q><b><<playerActionMessages.cannotEatMsg>></b></q>\n
            cannotDrinkMsg: <q><b><<playerActionMessages.cannotDrinkMsg>></b></q>\n
            cannotCleanMsg: <q><b><<playerActionMessages.cannotCleanMsg>></b></q>\n
            cannotCleanWithMsg: <q><b><<playerActionMessages.cannotCleanWithMsg>></b></q>\n
            cannotAttachKeyToMsg: <q><b><<playerActionMessages.cannotAttachKeyToMsg>></b></q>\n
            cannotSleepMsg: <q><b><<playerActionMessages.cannotSleepMsg>></b></q>\n
            cannotSitOnMsg: <q><b><<playerActionMessages.cannotSitOnMsg>></b></q>\n
            cannotLieOnMsg: <q><b><<playerActionMessages.cannotLieOnMsg>></b></q>\n
            cannotStandOnMsg: <q><b><<playerActionMessages.cannotStandOnMsg>></b></q>\n
            cannotBoardMsg: <q><b><<playerActionMessages.cannotBoardMsg>></b></q>\n
            cannotUnboardMsg: <q><b><<playerActionMessages.cannotUnboardMsg>></b></q>\n
            cannotGetOffOfMsg: <q><b><<playerActionMessages.cannotGetOffOfMsg>></b></q>\n
            cannotStandOnPathMsg: <q><b><<playerActionMessages.cannotStandOnPathMsg>></b></q>\n
            cannotEnterHeldMsg: <q><b><<playerActionMessages.cannotEnterHeldMsg>></b></q>\n
            cannotGetOutMsg: <q><b><<playerActionMessages.cannotGetOutMsg>></b></q>\n
            alreadyInLocMsg: <q><b><<playerActionMessages.alreadyInLocMsg>></b></q>\n
            alreadyStandingMsg: <q><b><<playerActionMessages.alreadyStandingMsg>></b></q>\n
            alreadyStandingOnMsg: <q><b><<playerActionMessages.alreadyStandingOnMsg>></b></q>\n
            alreadySittingMsg: <q><b><<playerActionMessages.alreadySittingMsg>></b></q>\n
            alreadySittingOnMsg: <q><b><<playerActionMessages.alreadySittingOnMsg>></b></q>\n
            alreadyLyingMsg: <q><b><<playerActionMessages.alreadyLyingMsg>></b></q>\n
            alreadyLyingOnMsg: <q><b><<playerActionMessages.alreadyLyingOnMsg>></b></q>\n
            notOnPlatformMsg: <q><b><<playerActionMessages.notOnPlatformMsg>></b></q>\n
            noRoomToStandMsg: <q><b><<playerActionMessages.noRoomToStandMsg>></b></q>\n
            noRoomToSitMsg: <q><b><<playerActionMessages.noRoomToSitMsg>></b></q>\n
            noRoomToLieMsg: <q><b><<playerActionMessages.noRoomToLieMsg>></b></q>\n
            okayPostureChangeMsg(posture): <q><b><<playerActionMessages.okayPostureChangeMsg(sitting)>></b></q>\n
            roomOkayPostureChangeMsg(posture,obj): <q><b><<playerActionMessages.roomOkayPostureChangeMsg(sitting,gDobj)>></b></q>\n
            okayNotStandingOnMsg: <q><b><<playerActionMessages.okayNotStandingOnMsg>></b></q>\n
            cannotPlugInMsg: <q><b><<playerActionMessages.cannotPlugInMsg>></b></q>\n
            cannotPlugInToMsg: <q><b><<playerActionMessages.cannotPlugInToMsg>></b></q>\n
            cannotUnplugMsg: <q><b><<playerActionMessages.cannotUnplugMsg>></b></q>\n
            cannotUnplugFromMsg: <q><b><<playerActionMessages.cannotUnplugFromMsg>></b></q>\n
            cannotScrewMsg: <q><b><<playerActionMessages.cannotScrewMsg>></b></q>\n
            cannotScrewWithMsg: <q><b><<playerActionMessages.cannotScrewWithMsg>></b></q>\n
            cannotUnscrewMsg: <q><b><<playerActionMessages.cannotUnscrewMsg>></b></q>\n
            cannotUnscrewWithMsg: <q><b><<playerActionMessages.cannotUnscrewWithMsg>></b></q>\n
            cannotEnterMsg: <q><b><<playerActionMessages.cannotEnterMsg>></b></q>\n
            cannotGoThroughMsg: <q><b><<playerActionMessages.cannotGoThroughMsg>></b></q>\n
            cannotThrowAtSelfMsg: <q><b><<playerActionMessages.cannotThrowAtSelfMsg>></b></q>\n
            cannotThrowAtContentsMsg: <q><b><<playerActionMessages.cannotThrowAtContentsMsg>></b></q>\n
            shouldNotThrowAtFloorMsg: <q><b><<playerActionMessages.shouldNotThrowAtFloorMsg>></b></q>\n
            dontThrowDirMsg: <q><b><<playerActionMessages.dontThrowDirMsg>></b></q>\n
            throwHitMsg(projectile,target): <q><b><<playerActionMessages.throwHitMsg(gDobj,gIobj)>></b></q>\n
            throwFallMsg(projectile,target): <q><b><<playerActionMessages.throwFallMsg(gDobj,gIobj)>></b></q>\n
            throwHitFallMsg(projectile,target,dest): <q><b><<playerActionMessages.throwHitFallMsg(gDobj,gIobj,dummyRoom)>></b></q>\n
            throwShortMsg(projectile,target): <q><b><<playerActionMessages.throwShortMsg(gDobj,gIobj)>></b></q>\n
            throwFallShortMsg(projectile,target,dest): <q><b><<playerActionMessages.throwFallShortMsg(gDobj,gIobj,dummyRoom)>></b></q>\n
            throwCatchMsg(obj,target): <q><b><<playerActionMessages.throwCatchMsg(gDobj,gIobj)>></b></q>\n
            cannotThrowToMsg: <q><b><<playerActionMessages.cannotThrowToMsg>></b></q>\n
            willNotCatchMsg(catcher): <q><b><<playerActionMessages.willNotCatchMsg(gDobj)>></b></q>\n
            cannotKissMsg: <q><b><<playerActionMessages.cannotKissMsg>></b></q>\n
            cannotKissActorMsg: <q><b><<playerActionMessages.cannotKissActorMsg>></b></q>\n
            cannotKissSelfMsg: <q><b><<playerActionMessages.cannotKissSelfMsg>></b></q>\n
            newlyDarkMsg: <q><b><<playerActionMessages.newlyDarkMsg>></b></q>\n
            ";
        }
    }
    dobjFor(NPCMessage) {
        verify() {}
        action() {
            askForIobj(NPCMessageWith);
        }
    }
    dobjFor(NPCMessageWith) {
        verify() {}
    }
    iobjFor(NPCMessageWith) {
        verify() {}
        action() {
            gActor = dummyNPC;
            "
            timePassesMsg: <q><b><<npcActionMessages.timePassesMsg>></b></q>\n
            cannotMoveFixtureMsg: <q><b><<npcActionMessages.cannotMoveFixtureMsg>></b></q>\n
            cannotMoveImmovableMsg: <q><b><<npcActionMessages.cannotMoveImmovableMsg>></b></q>\n
            cannotTakeHeavyMsg: <q><b><<npcActionMessages.cannotTakeHeavyMsg>></b></q>\n
            cannotMoveHeavyMsg: <q><b><<npcActionMessages.cannotMoveHeavyMsg>></b></q>\n
            cannotPutHeavyMsg: <q><b><<npcActionMessages.cannotPutHeavyMsg>></b></q>\n
            cannotMoveComponentMsg(loc): <q><b><<npcActionMessages.cannotMoveComponentMsg(gDobj)>></b></q>\n
            okayTakeMsg: <q><b><<npcActionMessages.okayTakeMsg>></b></q>\n
            okayDropMsg: <q><b><<npcActionMessages.okayDropMsg>></b></q>\n
            okayPutInMsg: <q><b><<npcActionMessages.okayPutInMsg>></b></q>\n
            okayPutOnMsg: <q><b><<npcActionMessages.okayPutOnMsg>></b></q>\n
            okayPutUnderMsg: <q><b><<npcActionMessages.okayPutUnderMsg>></b></q>\n
            okayPutBehindMsg: <q><b><<npcActionMessages.okayPutBehindMsg>></b></q>\n
            okayWearMsg: <q><b><<npcActionMessages.okayWearMsg>></b></q>\n
            okayDoffMsg: <q><b><<npcActionMessages.okayDoffMsg>></b></q>\n     
            okayOpenMsg: <q><b><<npcActionMessages.okayOpenMsg>></b></q>\n
            okayCloseMsg: <q><b><<npcActionMessages.okayCloseMsg>></b></q>\n
            okayLockMsg: <q><b><<npcActionMessages.okayLockMsg>></b></q>\n
            okayUnlockMsg: <q><b><<npcActionMessages.okayUnlockMsg>></b></q>\n
            pushNoEffectMsg: <q><b><<npcActionMessages.pushNoEffectMsg>></b></q>\n
            pullNoEffectMsg: <q><b><<npcActionMessages.pullNoEffectMsg>></b></q>\n
            moveNoEffectMsg: <q><b><<npcActionMessages.moveNoEffectMsg>></b></q>\n
            moveToNoEffectMsg: <q><b><<npcActionMessages.moveToNoEffectMsg>></b></q>\n
            whereToGoMsg: <q><b><<npcActionMessages.whereToGoMsg>></b></q>\n
            tooLargeForContainerMsg(obj,cont): <q><b><<npcActionMessages.tooLargeForContainerMsg(gDobj,gIobj)>></b></q>\n
            tooLargeForUndersideMsg(obj,cont): <q><b><<npcActionMessages.tooLargeForUndersideMsg(gDobj,gIobj)>></b></q>\n
            tooLargeForRearMsg(obj,cont): <q><b><<npcActionMessages.tooLargeForRearMsg(gDobj,gIobj)>></b></q>\n
            containerTooFullMsg(obj,cont): <q><b><<npcActionMessages.containerTooFullMsg(gDobj,gIobj)>></b></q>\n
            surfaceTooFullMsg(obj,cont): <q><b><<npcActionMessages.surfaceTooFullMsg(gDobj,gIobj)>></b></q>\n
            objNotForKeyringMsg: <q><b><<npcActionMessages.objNotForKeyringMsg>></b></q>\n
            takeFromNotInMsg: <q><b><<npcActionMessages.takeFromNotInMsg>></b></q>\n
            takeFromNotOnMsg: <q><b><<npcActionMessages.takeFromNotOnMsg>></b></q>\n
            takeFromNotUnderMsg: <q><b><<npcActionMessages.takeFromNotUnderMsg>></b></q>\n
            takeFromNotBehindMsg: <q><b><<npcActionMessages.takeFromNotBehindMsg>></b></q>\n
            cannotJumpOffHereMsg: <q><b><<npcActionMessages.cannotJumpOffHereMsg>></b></q>\n
            shouldNotBreakMsg: <q><b><<npcActionMessages.shouldNotBreakMsg>></b></q>\n
            okayPostureChangeMsg(posture): <q><b><<npcActionMessages.okayPostureChangeMsg(sitting)>></b></q>\n
            roomOkayPostureChangeMsg(posture,obj): <q><b><<npcActionMessages.roomOkayPostureChangeMsg(sitting,gDobj)>></b></q>\n
            okayNotStandingOnMsg: <q><b><<npcActionMessages.okayNotStandingOnMsg>></b></q>\n
            okayTurnToMsg(val): <q><b><<npcActionMessages.okayTurnToMsg('Test')>></b></q>\n
            okayPushButtonMsg: <q><b><<npcActionMessages.okayPushButtonMsg>></b></q>\n
            okayTurnOnMsg: <q><b><<npcActionMessages.okayTurnOnMsg>></b></q>\n
            okayTurnOffMsg: <q><b><<npcActionMessages.okayTurnOffMsg>></b></q>\n
            keyDoesNotFitLockMsg: <q><b><<npcActionMessages.keyDoesNotFitLockMsg>></b></q>\n
            okayFollowModeMsg: <q><b><<npcActionMessages.okayFollowModeMsg>></b></q>\n
            alreadyFollowModeMsg: <q><b><<npcActionMessages.alreadyFollowModeMsg>></b></q>\n
            okayExtinguishCandleMsg: <q><b><<npcActionMessages.okayExtinguishCandleMsg>></b></q>\n
            okayAttachToMsg: <q><b><<npcActionMessages.okayAttachToMsg>></b></q>\n
            okayDetachFromMsg: <q><b><<npcActionMessages.okayDetachFromMsg>></b></q>\n
            cannotTalkToSelfMsg: <q><b><<npcActionMessages.cannotTalkToSelfMsg>></b></q>\n
            cannotAskSelfMsg: <q><b><<npcActionMessages.cannotAskSelfMsg>></b></q>\n
            cannotAskSelfForMsg: <q><b><<npcActionMessages.cannotAskSelfForMsg>></b></q>\n
            cannotTellSelfMsg: <q><b><<npcActionMessages.cannotTellSelfMsg>></b></q>\n
            cannotGiveToSelfMsg: <q><b><<npcActionMessages.cannotGiveToSelfMsg>></b></q>\n
            cannotShowToSelfMsg: <q><b><<npcActionMessages.cannotShowToSelfMsg>></b></q>\n
            ";         
        }
    }
; 

modify Decoration 
  dobjFor(Gonear)  
  { 
    verify() {} 
    check() {} 
    action() {inherited;} 
  }   
; 
  
modify Distant 
  dobjFor(Gonear)  
  { 
    verify() {} 
    check() {} 
    action() {inherited;} 
  }   
; 

modify MultiLoc 
  dobjFor(Gonear) 
  { 
        verify() { illogical('{Du/er} {kann} das nicht tun, weil
            {der dobj/er} an mehreren Orten existiert. '); }  
  } 
  dobjFor(Purloin) 
  { 
        verify() { illogical('{Du/er} {kann} das nicht tun, weil
            {der dobj/er} an mehreren Orten existiert. '); }  
  } 
; 

// ###############################
// -- German: debug verbs -- VOCAB
// ###############################

DefineIAction(Vocab)
    execAction()
    {
        
        local objList = [];
        local stringList = [];
        local propList = [];
        
        local femaleList = [];
        local maleList = [];
        local neuterList = [];
        local pluralList = [];
        
        cmdDict.forEachWord({ x,y,z: objList += x});
        cmdDict.forEachWord({ x,y,z: stringList += y});
        cmdDict.forEachWord({ x,y,z: propList += z});
        
        local len = objList.length();
        local i;
        
        for (i = 1; i < len; i++) {
            if (propList[i] == &maleSyn) {
                maleList += stringList[i];
            }  
            else if (propList[i] == &femaleSyn) {
                femaleList += stringList[i];
            }  
            else if (propList[i] == &neuterSyn) {
                neuterList += stringList[i];
            }  
            else if (propList[i] == &pluralSyn) {
                pluralList += stringList[i];
            }  
        }
        
        "<.p>[FEMININ]<.p>";
        foreach (local cur in femaleList) {
            "\^";
            say(cur);
            " ";
        } 
        
        "<.p>[MASKULIN]<.p>";
        foreach (local cur in maleList) {
            "\^";
            say(cur);
            " ";
        } 
        
        "<.p>[NEUTRUM]<.p>";
        foreach (local cur in neuterList) {
            "\^";
            say(cur);
            " ";
        } 
        
        "<.p>[PLURAL]<.p>";
        foreach (local cur in pluralList) {
            "\^";
            say(cur);
            " ";
        } 
    }
;

VerbRule(Vokabular)
    'vocab' | 'vokabular' | 'vocabulary'
    :VocabAction 
    verbPhrase = 'das Vokabular anzuzeigen/anzeigen' 
; 

DefineIAction(Token)
    execAction()
    {       
        local error = nil;
        if (cmdDict.isWordDefined('durchs')) {
            "<b>DURCHS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('ans')) {
            "<b>ANS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('am')) {
            "<b>AM</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('aufs')) {
            "<b>AUFS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('vom')) {
            "<b>VOM</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('übers')) {
            "<b>ÜBERS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('ums')) {
            "<b>UMS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('ins')) {
            "<b>INS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('im')) {
            "<b>IM</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('unterm')) {
            "<b>UNTERM</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('unters')) {
            "<b>UNTERS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('hinterm')) {
            "<b>HINTERM</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('hinters')) {
            "<b>HINTERS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('runter')) {
            "<b>RUNTER</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('hinab')) {
            "<b>HINAB</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('herab')) {
            "<b>HERAB</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('herunter')) {
            "<b>HERUNTER</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('herauf')) {
            "<b>HERAUF</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('rauf')) {
            "<b>RAUF</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('raus')) {
            "<b>RAUS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('heraus')) {
            "<b>HERAUS</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('rein')) {
            "<b>REIN</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('herein')) {
            "<b>HEREIN</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('rüber')) {
            "<b>RÜBER</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('drüber')) {
            "<b>DRÜBER</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        if (cmdDict.isWordDefined('herüber')) {
            "<b>HERÜBER</b> gefunden, bitte aus Vokabular entfernen!\n";
            error = true;
        }
        
        if (!error)
            "*Keine Unstimmigkeiten gefunden* ";
    }
;

VerbRule(Token)
    'token' | 'tokens' 
    :TokenAction 
    verbPhrase = 'die Token anzuzeigen/anzeigen' 
; 

// ###############################
// -- German: debug verbs -- FINAL
// ###############################

DefineIAction(Final)
    execAction()
    {       
        
        "Der FINAL Befehl listet der Reihe nach alle Spielobjekte auf; willst du wirklich fortfahren? \n(Zustimmung mit J) &gt; ";

        /* stop if they don't want to proceed */
        if (!yesOrNo())
        {
            "Abgebrochen. ";
            exit;
        }
        
        local x = ' ';
        
        /* no history limit - scan every special topic in the game */
        for (local o = firstObj(Thing) ; (o != nil && x == ' ') ;
             o = nextObj(o, Thing))
        {
            if (o.name != '' && o.name != nil) {
                /* check this entry */
                "<.p>";
                "<b>*** <<o.pureName>> ***</b><.p>";
                
                if (o.isIt)
                    "Geschlecht: Neutrum<.p>";
                if (o.isHim)
                    "Geschlecht: Maskulin<.p>";
                if (o.isHer)
                    "Geschlecht: Feminin<.p>";
                if (o.isPlural)
                    "Geschlecht: Pluralwort<.p>";

                "Deklination:<.p>
                Wer? <<o.derName>>
                \nWessen? <<o.desName>>
                \nWem? <<o.demName>>
                \nWen? <<o.denName>><.p>";
                
                if (o.location != nil) {
                    if (o.location.name != '') {
                        "*\^<<o.derName>> <<o.verbZuBefinden>> sich <<o.location.actorInName>>*<.p> ";
                    }
                }
                else {
                    "*Location = nil oder Objekt gehört zu RoomPart oder MultiLoc*<.p> ";
                }
                
                "[Leertaste] schaltet weiter. Jede andere Taste bricht ab.<.p> ";
                x = inputManager.getKey(nil, nil);
            }
        }
    }
;

VerbRule(Final)
    'final'
    :FinalAction 
    verbPhrase = 'den Finalcheck anzuzeigen/anzeigen' 
; 

// ##################################
// -- German: debug verbs -- MESSAGES
// ##################################

DefineTAction(Message)
;

VerbRule(Nachrichten)
    'zeig' 'pcnachricht' 'mit' singleDobj
    | 'pcnachricht' 'mit' singleDobj
    : MessageAction
    verbPhrase = 'auszugeben/Nachrichten ausgeben (mit dativ was)'
;

DefineTIAction(MessageWith)
;

VerbRule(NachrichtenMit)
    'zeig' 'pcnachricht' 'mit' singleDobj 'und' singleIobj
    | 'pcnachricht' 'mit' singleDobj 'und' singleIobj
    : MessageWithAction
    verbPhrase = 'auszugeben/Nachrichten ausgeben (mit dativ was) (mit noch dativ was)'
;

DefineTAction(NPCMessage)
;

VerbRule(NPCNachrichten)
    'zeig' 'npcnachricht' 'mit' singleDobj
    | 'npcnachricht' 'mit' singleDobj
    : NPCMessageAction
    verbPhrase = 'auszugeben/Nachrichten ausgeben (mit dativ was)'
;

DefineTIAction(NPCMessageWith)
;

VerbRule(NPCNachrichtenMit)
    'zeig' 'npcnachricht' 'mit' singleDobj 'und' singleIobj
    | 'npcnachricht' 'mit' singleDobj 'und' singleIobj
    : NPCMessageWithAction
    verbPhrase = 'auszugeben/Nachrichten ausgeben (mit dativ was) (mit noch dativ was)'
;

DefineIAction(NPCdeferred)
    execAction() {
        gActor = dummyNPC;
        "
        commandNotUnderstood(actor): <q><b><<npcDeferredMessagesDirect.commandNotUnderstood(gActor)>></b></q>\n
        noMatchCannotSee(actor,txt): <q><b><<npcDeferredMessagesDirect.noMatchCannotSee(gActor, 'mantel')>></b></q>\n
        noMatchNotAware(actor,txt): <q><b><<npcDeferredMessagesDirect.noMatchNotAware(gActor, 'mantel')>></b></q>\n
        noMatchForAll(actor): <q><b><<npcDeferredMessagesDirect.noMatchForAll(gActor)>></b></q>\n
        noMatchForAllBut(actor): <q><b><<npcDeferredMessagesDirect.noMatchForAllBut(gActor)>></b></q>\n
        emptyNounPhrase(actor): <q><b><<npcDeferredMessagesDirect.emptyNounPhrase(gActor)>></b></q>\n
        zeroQuantity(actor,txt): <q><b><<npcDeferredMessagesDirect.zeroQuantity(gActor, 'mantel')>></b></q>\n
        insufficientQuantity(actor,txt,matchList,requiredNum): <q><b><<npcDeferredMessagesDirect.insufficientQuantity(gActor, 'mantel', [dummyCoat], 5)>></b></q>\n
        uniqueObjectRequired(actor,txt,matchList): <q><b><<npcDeferredMessagesDirect.uniqueObjectRequired(gActor,'mantel',[dummyCoat])>></b></q>\n
        singleObjectRequired(actor,txt): <q><b><<npcDeferredMessagesDirect.singleObjectRequired(gActor, 'mantel')>></b></q>\n
        ambiguousNounPhrase(actor,originalText,matchList,fullMatchList): <q><b><<npcDeferredMessagesDirect.ambiguousNounPhrase(gActor, 'Ding', [], [])>></b></q>\n
        askMissingObject(actor,action,which): fehlt\n
        wordIsUnknown(actor,txt): <q><b><<npcDeferredMessagesDirect.wordIsUnknown(gActor, 'mantel')>></b></q>\n 
        ";
    }
;

VerbRule(NPCdefNachricht)
    'npcdeferred'
    : NPCdeferredAction
    verbPhrase = 'Nachrichten auszugeben/Nachrichten ausgeben'
;

DefineIAction(NPCdirect)
    execAction() {
        gActor = dummyNPC;
        "
        noMatchCannotSee(actor,txt): <q><b><<npcMessagesDirect.noMatchCannotSee(gActor,'mantel')>></b></q>\n
        noMatchNotAware(actor,txt): <q><b><<npcMessagesDirect.noMatchNotAware(gActor,'mantel')>></b></q>\n
        noMatchForAll(actor): <q><b><<npcMessagesDirect.noMatchForAll(gActor)>></b></q>\n
        noMatchForAllBut(actor): <q><b><<npcMessagesDirect.noMatchForAllBut(gActor)>></b></q>\n
        zeroQuantity(actor,txt): <q><b><<npcMessagesDirect.zeroQuantity(gActor,'Test')>></b></q>\n
        insufficientQuantity(actor,txt,matchList,requiredNum): <q><b><<npcMessagesDirect.insufficientQuantity(gActor, 'mantel', [dummyCoat], 5)>></b></q>\n
        uniqueObjectRequired(actor,txt,matchList): <q><b><<npcMessagesDirect.uniqueObjectRequired(gActor,'mantel',[dummyCoat])>></b></q>\n
        singleObjectRequired(actor,txt): <q><b><<npcMessagesDirect.singleObjectRequired(gActor,'mantel')>></b></q>\n
        noMatchDisambig(actor,origPhrase,disambigResponse): <q><b><<npcMessagesDirect.noMatchDisambig(gActor,'mantel',[dummyCoat])>></b></q>\n
        disambigOrdinalOutOfRange(actor,ordinalWord,originalText): <q><b><<npcMessagesDirect.disambigOrdinalOutOfRange(gActor,'zehn','mantel')>></b></q>\n
        askDisambig(actor,originalText,matchList,fullMatchList,requiredNum,askingAgain,dist): fehlt
        ambiguousNounPhrase(actor,originalText,matchList,fullMatchList): fehlt
        askMissingObject(actor,action,which): fehlt
        missingObject(actor,action,which): fehlt
        missingLiteral(actor,action,which): fehlt
        askUnknownWord(actor,txt): <q><b><<npcMessagesDirect.askUnknownWord(gActor,'mantel')>></b></q>\n
        wordIsUnknown(actor,txt): <q><b><<npcMessagesDirect.wordIsUnknown(gActor,'mantel')>></b></q>\n
        ";
    }
;

VerbRule(NPCdirNachricht)
    'npcdirekt'
    : NPCdirectAction
    verbPhrase = 'Nachrichten auszugeben/Nachrichten ausgeben'
;

dummyRoom : Room 'Testraum' 'Testraum[-s]'
    isHim = true
;

dummyNPC : Person '' 'Testperson'
    isHer = true
;

dummyCoat : Thing 'mantel*mäntel' 'Mantel[-s]'
    isHim = true
    pluralName = 'Mäntel'
;

dummyChest : Thing '' 'Truhe'
    isHer = true
;

#endif /* __DEBUG */

// ##############################################################
// ## reminder object keeps track of the last mentioned object ##
// ##############################################################

reminder : object
    myLastObj = nil
    setLastObj(obj) {
        myLastObj = obj;
    }
    getLastObj() {
        return myLastObj;
    }
;

modify TAction
    getCurrentObjects()
    {
        reminder.setLastObj(dobjCur_);
        return [dobjCur_];
    }
;

// ##########################################################
// ## verbHelper object stores pariciples of the last verb ##
// ##########################################################

verbHelper : object
    reversed = nil
    blank = true
    participle = ''
    longParticiple = ''
    lastVerb = 'undefined'
    setParticiple(txt) {
        participle = txt;
    }
;

// ###############################################################
// ## infHelper object builds verbphrases from verbrule objects ##
// ###############################################################

infHelper : object
    
    tab = [
        'öffn' -> 'öffnen',
        'nimm' -> 'nehmen', 
        'wirf' -> 'werfen', 
        'lies' -> 'lesen', 
        'gib' -> 'geben', 
        'iss' -> 'essen',
        'steige' -> 'steigen',
        'friss' -> 'fressen',
        'brich' -> 'brechen',
        'zerbrich' -> 'zerbrechen',
        'säuber' -> 'säubern',
        'entziffer' -> 'entziffern',
        'schnüffl' -> 'schnüffeln',
        'schnüffel' -> 'schnüffeln',
        'schnupper' -> 'schnuppern',
        * -> 'undefined'
    ]
    
    buildVerbPhraseFrom(obj) {
         
        local verb = obj.verb_;
        local prep = obj.prep_;
        local misc = (obj.misc_ ? obj.misc_ + ' ' : '');
        local verbPhrase = nil;    

        // if we end up with 'e', cut it off
        if (verb.endsWith('e'))
            verb = verb.substr(1, verb.length() - 1);
        
        // if our verb is in the table with irregular infinitives, replace it
        local irregular = tab[verb];
        if (irregular != 'undefined')
            verb = irregular;
        else
            verb = verb + 'en';
               
        // if we have no prep, the form is rather simple
        if (prep == nil)
            verbPhrase = misc + 'zu ' + verb + '/' + misc + verb + ' ';
        // if we have a prep, use it
        else if (prep)
            verbPhrase = prep + 'zu' + verb + '/' + prep + verb + ' ';
        
        return(verbPhrase);
    }
;

// #######################################################
// ## tokHelper object helds token List for replacement ##
// #######################################################

tokHelper : object
    
    token = [
        'durchs' -> 'durch',
        'ans' -> 'an', 
        'am' -> 'an',
        'aufs' -> 'auf',
        'vom' -> 'von',
        'übers' -> 'über',
        'überm' -> 'über',
        'ums' -> 'um',
        'ins' -> 'in',
        'im' -> 'in',
        'unters' -> 'unter',
        'unterm' -> 'unter',
        'hinters' -> 'hinter',
        'hinterm' -> 'hinter',
        'runter' -> 'hinunter',
        'hinab' -> 'hinunter',
        'herab' -> 'hinunter',
        'herunter' -> 'hinunter',
        'herauf' -> 'hinauf',
        'rauf' -> 'hinauf',
        'raus' -> 'hinaus',
        'heraus' -> 'hinaus',
        'rein' -> 'hinein',
        'herein' -> 'hinein',
        'rüber' -> 'hinüber',
        'drüber' -> 'hinüber',
        'herüber' -> 'hinüber',
        'zum' -> 'zu',
        'zur' -> 'zu',
        * -> 'undefined'
    ]
   
    checkForValidTokens(txt) { 
        
        // get keys from token lookuptable
        local keys = token.keysToList();
        
        // iterate through the keys in token lookuptable
        foreach(local val in keys) {

            // if we find a matching start value (rüberspringen), replace it
            // with the value (hinüberspringen)
            
            // We have special rules at the beginning of a sentence:
            // We don't want to replace "durchs", "ans" because we 
            // have trouble with verbs like "*durchs*uch" ...
            // have trouble with verbs like "*rein*ige" ...
            
            if (txt.startsWith(val)) {
                
                if (txt.length() > val.length()) {
                    if (!val.endsWith('s')) {
                        local test = txt.substr(val.length() + 1, txt.length());
                        if (checkForValidWord(test)) {
                            txt  = txt.substr(val.length() + 1, txt.length());
                            txt  = token[val] + txt;
                            break;
                        }
                    }
                }
                else {
                    txt  = txt.substr(val.length() + 1, txt.length());
                    txt  = token[val] + txt;
                    break;
                }
            }
        }

        //txt = token[txt];
        // return either new or old value
        return(txt);
    }

    checkForValidWord(txt) {

        // it could be that we are already defined "as we are"
        if (cmdDict.isWordDefined(txt))
            return true;
        // it could be that we defined "truncated"
        txt = strangeObj.testEndings(txt);
        if (cmdDict.isWordDefined(txt))
            return true;
        // it could be that we defined as "irregular infinitve"
        local irregular = infHelper.tab[txt];
        if (irregular != 'undefined')
            return true;
        // we are really unknown :-(
        return nil;
    }
;

// ################################################
// ## curcase object keeps track of current case ##
// ################################################

curcase: object
    isNom = true
    isGen = nil
    isDat = nil
    isAkk = nil
    r_flag = nil
    d_flag = nil
    
    setcaseNom()
    {
        isNom = true;
        isGen = nil;
        isDat = nil;
        isAkk = nil;
        // -- "(case=NOM)"; -> uncomment for testing
    }
    setcaseGen()
    {
        isNom = nil;
        isGen = true;
        isDat = nil;
        isAkk = nil;
        // -- "(case=GEN)"; -> uncomment for testing
    }
    setcaseDat()
    {
        isNom = nil;
        isGen = nil;
        isDat = true;
        isAkk = nil;
        // -- "(case=DAT)"; -> uncomment for testing
    }
    setcaseAkk()
    {
        isNom = nil;
        isGen = nil;
        isDat = nil;
        isAkk = true;
        // -- "(case=AKK)"; -> uncomment for testing
    }
;

// ###############################################################
// ## curlistcase object keeps track of current case for lists  ##
// ###############################################################

// ###############################################################
// ## e.g. usage: showListPrefixWide(itemCount, pov, parent)    ##
// ## { "{Du/er} {sieht} {hier|dort} <<withCaseAccusative>>"; } ##
// ###############################################################

curlistcase: object
    isNom = nil
    isGen = nil
    isDat = nil
    isAkk = true // -- standard
    
    setlistcaseNom()
    {
        isNom = true;
        isGen = nil;
        isDat = nil;
        isAkk = nil;
        // -- "(listcase=NOM)"; -> uncomment for testing
    }
    setlistcaseGen()
    {
        isNom = nil;
        isGen = true;
        isDat = nil;
        isAkk = nil;
        // -- "(listcase=GEN)"; -> uncomment for testing
    }
    setlistcaseDat()
    {
        isNom = nil;
        isGen = nil;
        isDat = true;
        isAkk = nil;
        // -- "(listcase=DAT)"; -> uncomment for testing
    }
    setlistcaseAkk()
    {
        isNom = nil;
        isGen = nil;
        isDat = nil;
        isAkk = true;
        // -- "(listcase=AKK)"; -> uncomment for testing
    }
;

// #####################################################################
// ## curlistart object keeps track of current article mode for lists ##
// #####################################################################

curlistart: object
    isDef = nil
    isIndef = true // -- standard(!)
    
    setlistartDef()
    {
        isDef = true;
        isIndef = nil;
    }

    setlistartIndef()
    {
        isDef = nil;
        isIndef = true;
    }
;

// ############################################
// ## adjectives - endings with adjEnding{}  ##
// ############################################

// ##################################################################
// ## These snippets are added to any name, that ends with [^],    ##
// ## e.g. name = 'klein[^] Buch'                                  ##
// ## We distinguish the direct case (which is default) and the    ##
// ## indirect case (which is set by r_flag in the curcase object) ##
// ##                                                              ##
// ## indirect article: "ein kleines Buch"                         ##
// ## direct article: "das kleine Buch"                            ##
// ##################################################################

modify Thing
    adjEnding { 
        local ending;
        if (self.isHim)
        {
            if (curcase.isNom)
            {
                if (curcase.r_flag)
                    ending = 'er';
                else
                    ending = 'e';
            }
            if (curcase.isGen)
                ending = 'en';
            if (curcase.isDat)
                ending = 'en';
            if (curcase.isAkk)
                ending = 'en';
        }
        if (self.isHer)
        {
            if (curcase.isNom)
                ending = 'e';
            if (curcase.isGen)
                ending = 'en';
            if (curcase.isDat)
                ending = 'en';
            if (curcase.isAkk)
                ending = 'e';
        }
        if (!self.isHim && !self.isHer && !self.isPlural)
        {
            if (curcase.isNom)
            {
                if (curcase.r_flag)
                    ending = 'es';
                else
                    ending = 'e';
            }
            if (curcase.isGen)
                ending = 'en';
            if (curcase.isDat)
                ending = 'en';
            if (curcase.isAkk)
            {
                if (curcase.r_flag)
                    ending = 'es';
                else
                    ending = 'e';
            }
        }
        if (self.isPlural)
            {
                if (curcase.r_flag)
                    ending = 'e';
                else
                    ending = 'en';
            }
        // ##### say(ending); #####
        return ending;
    }

    adjPluralEnding { // ##### function for all adjective endings #####
        local ending;

        if (curcase.r_flag)
            ending = 'e';
        else
            ending = 'en';
        
        return ending;
    }
    
    // ##### four "safe" ways to change the gender #####
    
    changeIt() {
        isHer = nil;
        isHim = nil;
        isPlural = nil;
    }
    
    changeHim() {
        isHer = nil;
        isHim = true;
        isPlural = nil;
    }
    
    changeHer() {
        isHer = true;
        isHim = nil;
        isPlural = nil;
    }
    
    changePlural() {
        isHer = nil;
        isHim = nil;
        isPlural = true;
    }   
;

// ##### We treat 'steig auf (Plattform)' as standing on it #####

modify Surface
	dobjFor(Board) asDobjFor(StandOn)
;

modify BasicChair
	dobjFor(Board) asDobjFor(StandOn)
;

modify Actor
    
    // ******
    // -- German: construct the name of the strangeObj ...
    // ******
    
    constructName(txt) {
        
        // -- If the words endswith '&rsquo;s' cut it off and replace it with 's'
        
        txt = txt.findReplace('&amp;rsquo;s', 's', ReplaceAll); //replace any genitive s if there is one
        txt = txt.findReplace('&amp;&rsquos', 's', ReplaceAll); //replace any genitive s if there is one
        
        // -- German: we scan the input for miscwords to provide a clearer parser
        // -- answer like "Ich verstehe das Wort 'auf' in diesem Zusammenhang nicht. "
        
        local textparts = [];
        local changetxt = txt;
        local i = 0;
        
        while (!changetxt.find(' ') == nil) {
            i += 1;
            rexMatch('(<AlphaNum>*)<Space>(.*)', changetxt);
            textparts += rexGroup(1)[3];
            changetxt = rexGroup(2)[3];
        }
        
        textparts += changetxt;
        local max = textparts.length();
        
        strangeObj.name = '';           // -- we begin with an empty string
        strangeObj.changeIt();          // -- we begin with an neuter gender
        
        local fillWord = nil;
        local nounWord = nil;
        local nonsense = nil;
        
        for (local i = 1; i <= max ; i += 1) {
            // -- "[<<textparts[i]>>]"; uncomment for testing

            if (!cmdDict.isWordDefined(textparts[i]))
                textparts[i] = strangeObj.testEndings(textparts[i]);
            
            if (cmdDict.findWord(textparts[i], &adjective) != [])
                strangeObj.name += textparts[i]+'[^]';
            
            else if (cmdDict.findWord(textparts[i], &femaleSyn) != []) { //vorher war hier else if
                strangeObj.name += '\^' +textparts[i];
                if (fillWord == nil && nounWord == nil) {
                    strangeObj.changeHer();
                    nounWord = true;
                }
                if (cmdDict.findWord(textparts[i], &irregularNWord) != []) {
                    // -- "<<textparts[i]>> ist ein -n Word!"; remove comment for testing
                    strangeObj.name += '[-n]';
                }
            }
            else if (cmdDict.findWord(textparts[i], &maleSyn) != []) {
                strangeObj.name += '\^' +textparts[i];
                if (fillWord == nil && nounWord == nil) {
                    strangeObj.changeHim();
                    nounWord = true;
                }
                if (cmdDict.findWord(textparts[i], &irregularNWord) != []) {
                    // -- "<<textparts[i]>> ist ein -n Word!"; remove comment for testing
                    strangeObj.name += '[-n]';
                }
            }
            else if (cmdDict.findWord(textparts[i], &neuterSyn) != []) {
                strangeObj.name += '\^' +textparts[i];
                if (fillWord == nil && nounWord == nil) {
                    strangeObj.changeIt();
                    nounWord = true;
                }
                if (cmdDict.findWord(textparts[i], &irregularNWord) != []) {
                    // -- "<<textparts[i]>> ist ein -n Word!"; remove comment for testing
                    strangeObj.name += '[-n]';
                }
            }
            else if (cmdDict.findWord(textparts[i], &pluralSyn) != []) {
                strangeObj.name += '\^' +textparts[i];
                if (fillWord == nil && nounWord == nil) {
                    strangeObj.changePlural();
                    nounWord = true;
                }
                if (cmdDict.findWord(textparts[i], &irregularNWord) != []) {
                    // -- "<<textparts[i]>> ist ein -n Word!"; remove comment for testing
                    strangeObj.name += '[-n]';
                }
            }
            
            else {
                // -- "<<textparts[i]>> ist ein fillWord!"; remove comment for testing
                fillWord = true;
                if (nounWord == nil)
                    nonsense = true;
                strangeObj.name += '\v' +textparts[i];
            }
            
            if (i != max)
                strangeObj.name += ' ';
        }
        
        // ##### if we have a word beginning with a miscWord it is likely to #####
        // ##### be absolute nonsense #####
         
        if (nonsense == true)
            strangeObj.name = '';
        
    }
    
    // ##### return function for childInNameGen( #####
    
    returnName(txt) {
        constructName(txt);
        return strangeObj.name;
    }
    
    // #################################################
    // ##### output - keinen <txt> case accusative #####
    // #################################################
    
    keinen(txt)
    {
        // ##### if we decide to have simple answers, set gameMain.useNoTxt to nil #####
        if (gameMain.useNoTxt == nil) {
            "so etwas nicht";
            return;
        }
        
        if (!cmdDict.isWordDefined(txt))
            txt = strangeObj.testEndings(txt);
        
        if (cmdDict.findWord(txt, &adjective) != [])
        {
            "nichts \^<<txt>>es";
            return;
        }
        
        local oldtxt = txt;
        txt = constructName(txt);
        
        if (strangeObj.name == '')
            "so etwas (<q><<oldtxt>></q>) nicht";
        else
            "<<strangeObj.keinenName>>";
        return;
    }
    
    keinenAsString(txt)
    {
        // ##### if we decide to have simple answers, set gameMain.useNoTxt to nil #####
        if (gameMain.useNoTxt == nil) {
            return 'so etwas nicht';
        }
        
        if (!cmdDict.isWordDefined(txt))
            txt = strangeObj.testEndings(txt);
        
        if (cmdDict.findWord(txt, &adjective) != [])
        {
            return 'nichts \^<<txt>>es';
        }
        
        local oldtxt = txt;
        txt = constructName(txt);
        
        if (strangeObj.name == '')
            return 'so etwas (<q><<oldtxt>></q>) nicht';
        else
            return '<<strangeObj.keinenName>>';
    }
    
    // ################################
    // ##### output - viele <txt> #####
    // ################################
    
    viele(txt)
    {
        // ##### if we decide to have simple answers, set gameMain.useNoTxt to nil #####
        if (gameMain.useNoTxt == nil) {
            "viele davon";
            return;
        }
        
        if (!cmdDict.isWordDefined(txt))
            txt = strangeObj.testEndings(txt);
        
        if (cmdDict.findWord(txt, &adjective) != [])
        {
            "viele <<txt>>e";
            return;
        }
        
        txt = constructName(txt);
        if (strangeObj.name == '')
            "viele davon";
        else
            "<<strangeObj.vieleName>>";
        return;
    }
    
    // ##################################
    // ##### output - welchen <txt> #####
    // ##################################
    
    welchen(txt)
    {
        // ##### if we decide to have simple answers, set gameMain.useNoTxt to nil #####
        if (gameMain.useNoTxt == nil) {
            "was genau";
            return;
        }

        if (!cmdDict.isWordDefined(txt))
            txt = strangeObj.testEndings(txt);
        
        if (cmdDict.findWord(txt, &adjective) != [])
        {
            "was genau";
            return;
        }
        
        txt = constructName(txt);
        if (strangeObj.name == '')
            "was genau";
        else
            "<<strangeObj.welchenName>>";
        return;
    }
;

// ###############################################
// ## object which generates the correct output ##
// ## for keinen(txt) viele(txt) welche(txt)    ##
// ###############################################

strangeObj : Thing '' ''
    
    isNo = true
        
    // ##### this is our keinenName implementation #####
    
    keinenName = (keinenNameFrom(name))
    keinenNameFrom(str) 
    {
        withCaseAccusative;
        curcase.r_flag = true;
        // -- "Original: <<str>> "; remove comment for testing
        str = replaceEndings(str);
        return (isPlural ? 'keine ' : 
        isHim ? 'keinen ' : isHer ? 'keine ' : 'kein ' ) + str; 
    }
    
    // ##### this is our vieleName implementation #####
    
    vieleName = (vieleNameFrom(name))
    vieleNameFrom(str) 
    {
        withCaseNominative;
        curcase.r_flag = true;
        // -- "Original: <<str>> "; remove comment for testing
        str = replaceEndings(str);
        return 'viele '+ str; 
    }
    
    // ##### this is our keinenName implementation #####
    
    welchenName = (welchenNameFrom(name))
    welchenNameFrom(str) 
    {
        withCaseAccusative;
        curcase.r_flag = true;
        // -- "Original: <<str>> "; remove comment for testing
        str = replaceEndings(str);
        return (isPlural ? 'welche ' : 
        isHim ? 'welchen ' : isHer ? 'welche ' : 'welches ' ) + str; 
    }
    
    // ##### we parse the endings #####
    
    testEndings(txt) {
    
        local s = '';
        local w = '';
        local cvtFlag = nil;            
        local temp = txt;
        
        // -- German: Genitiv-s as in 'Mariels Gesicht'
        if (temp.endsWith('s') == true)
        {
            // -- "Endung -s gefunden!" - we assume it's genitive!";
            s = temp.substr(1, temp.length() - 1);
            if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
            {
                w = s;
                // -- we add an apostrophe-S and want to interpret it as a possessive phrase
                cvtFlag = true;
            }
        }
        // -- German: ending -es
        if (temp.endsWith('es') == true)
        {
            //"Endung -es gefunden!";
            s = temp.substr(1, temp.length() - 2);
            if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
            {
                w = s;
                cvtFlag = true;
            }
        }
        // -- German: ending -er
        if (temp.endsWith('er') == true && cvtFlag == nil)
        {
            //"Endung -er gefunden!";
            s = temp.substr(1, temp.length() - 2);
            if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
            {
                w = s;
                cvtFlag = true;
            }
        }
        // -- German: ending -en
        if (txt.endsWith('en') == true && cvtFlag == nil)
        {
            //"Endung -en gefunden!";
            s = temp.substr(1, temp.length() - 2);
            if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
            {
                w = s;
                cvtFlag = true;
            }
        }
        // -- German: ending -em
        if (txt.endsWith('em') == true && cvtFlag == nil)
        {
            //"Endung -em gefunden!";
            s = temp.substr(1, temp.length() - 2);
            if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
            {
                w = s;
                cvtFlag = true;
            }
        }
        // -- German: ending -e (for verbs)e.g. nehme = nehm
        if (txt.endsWith('e') == true && cvtFlag == nil)
        {
            //"Endung -e gefunden!";
            s = temp.substr(1, temp.length() - 1);
            if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
            {
                w = s;
                cvtFlag = true;
            }
        }
        // -- German: ending -n
        if (txt.endsWith('n') == true && cvtFlag == nil)
        {
            //"Endung -n gefunden!";
            s = temp.substr(1, temp.length() - 1);
            if (cmdDict.isWordDefined(s) == true && cvtFlag == nil)
            {
                w = s;
                cvtFlag = true;
            }
        }
        
        if (cvtFlag == true)
            return w;
        else
            return txt;
    
    } 
;

// #################################################
// ## we need a new definiton of destInfo objects ##
// ## zurück zu DEM wohnzimmer ... (dative)       ##
// ## in DAS wohnzimmer ... (accusative)          ##
// #################################################

replace DestInfo: object
    construct(dir, dest, destName, destIsBack)
    {
        /* remember the direction, destination, and destination name */
        dir_ = dir;
        dest_ = dest;
        destName_ = destName;
        
        // ##### if we have a destination object, store both cases, accusative & dative #####
        if (dest != nil) {
            denDestName_ = dest.denName;
            demDestName_ = dest.demName;
            if (dest.isProperName)
                destIsProperName = true;
        }
        
        destIsBack_ = destIsBack;
    }

    /* the direction of travel */
    dir_ = nil

    /* the destination room object */
    dest_ = nil

    /* the name of the destination */
    destName_ = nil
    
    denDestName_ = nil
    
    demDestName_ = nil

    destIsProperName = nil
    
    /* flag: this is the "back to" destination */
    destIsBack_ = nil

    /* list of other directions that go to our same destination */
    others_ = []
;
// #######################################################################
// ## We provide a SpecialNounphraseProd predefined for special grammar ##
// ## with multiple nouns/prepositions like                             ##
// ## 'Neu' 'Delhi', 'Mann' 'mit' 'Hut', 'Kranky' 'der' 'Clown' ...     ##
// #######################################################################

class SpecialNounPhraseProd: NounPhraseWithVocab
    /* get the list of objects matching our special phrase */
    getMatchList = []

    /* resolve the objects */
    getVocabMatchList(resolver, results, flags)
    {
        /* return all of the in-scope matches */
        return getMatchList().subset({x: resolver.objInScope(x)})
            .mapAll({x: new ResolveInfo(x, flags)});
    }
;

// #############################################################
// ## We modify gameMainDef for a little flag called useNoTxt ##
// ## this flag does nothing exept when set to nil: then it   ##
// ## simplifies keinen(txt) / viele(txt) / welchen(txt) to a ##
// ## more generic output (Du siehst hier "so etwas" nicht)   ##
// #############################################################

modify GameMainDef
    useNoTxt = true
    useCapitalizedAdress = nil
    usePastPerfect = true
;

// ###################################################################
// ## a non-prepositional phrasing has no way to                    ##
// ## distinguish the dobj and iobj properly, so we replace the     ##
// ## doActionMain() method with a tiny modification, which allows  ##
// ## us to set a special preferredIobj property and let the parser ##
// ## change the dobj to iobj when fitting into our scheme.         ##
// ###################################################################

modify TIAction
    preferredIobj = nil
    replace doActionMain()
    {
        local lst;
        local preAnnouncedDobj;
        local preAnnouncedIobj;
        
        /* 
         *   Get the list of resolved objects for the multiple object.  If
         *   neither has multiple objects, it doesn't matter which is
         *   iterated, since we'll just do the command once anyway.  
         */
        lst = (iobjList_.length() > 1 ? iobjList_ : dobjList_);

        /* 
         *   Set the pronoun antecedents, using the game-specific pronoun
         *   setter.  Don't set an antecedent for a nested command.
         */
        if (parentAction == nil)
        {
           /* 
            *   Set both direct and indirect objects as potential
            *   antecedents.  Rather than trying to figure out right now
            *   which one we might want to refer to in the future, remember
            *   both - we'll decide which one is the logical antecedent
            *   when we find a pronoun to resolve in a future command.  
            */ 
           gActor.setPronounMulti(dobjList_, iobjList_); 

            /*
             *   If one or the other object phrase was specified in the
             *   input as a pronoun, keep the meaning of that pronoun the
             *   same, overriding whatever we just did.  Note that the
             *   order we use here doesn't matter: if a given pronoun
             *   appears in only one of the two lists, then the list where
             *   it's not set has no effect on the pronoun, hence it
             *   doesn't matter which comes first; if a pronoun appears in
             *   both lists, it will have the same value in both lists, so
             *   we'll just do the same thing twice, so, again, order
             *   doesn't matter.  
             */
            setPronounByInput(dobjList_);
            setPronounByInput(iobjList_);
        }

        /* 
         *   pre-announce the non-list object if appropriate - this will
         *   provide a common pre-announcement if we iterate through
         *   several announcements of the main list objects 
         */
        if (lst == dobjList_)
        {
            /* pre-announce the single indirect object if needed */
            preAnnouncedIobj = preAnnounceActionObject(
                iobjList_[1], dobjList_, IndirectObject);

            /* we haven't announced the direct object yet */
            preAnnouncedDobj = nil;

            /* pre-calculate the multi-object announcements */
            cacheMultiObjectAnnouncements(dobjList_, DirectObject);
        }
        else
        {
            /* pre-announce the single direct object if needed */
            preAnnouncedDobj = preAnnounceActionObject(
                dobjList_[1], iobjList_, DirectObject);

            /* we haven't announced the indirect object yet */
            preAnnouncedIobj = nil;

            /* pre-calculate the multi-object announcements */
            cacheMultiObjectAnnouncements(iobjList_, IndirectObject);
        }

        /* we haven't yet canceled the iteration */
        iterationCanceled = nil;

        /* iterate over the resolved list for the multiple object */
        for (local i = 1, local len = lst.length() ;
             i <= len && !iterationCanceled ; ++i)
        {
            local dobjInfo;
            local iobjInfo;

            /* 
             *   make the current list item the direct or indirect object,
             *   as appropriate 
             */
            if (lst == dobjList_)
            {
                /* the direct object is the multiple object */
                dobjInfo = dobjInfoCur_ = lst[i];
                iobjInfo = iobjInfoCur_ = iobjList_[1];
            }
            else
            {
                /* the indirect object is the multiple object */
                dobjInfo = dobjInfoCur_ = dobjList_[1];
                iobjInfo = iobjInfoCur_ = lst[i];
            }

            // ###############################################################
            // ## we have now resolved objects for indirect and direct slot ##
            // ###############################################################
            
            if (preferredIobj != nil && dobjInfo.obj_.ofKind(preferredIobj) &&
                !iobjInfo.obj_.ofKind(preferredIobj)) {
                /* change both objects */
                dobjCur_ = iobjInfo.obj_;
                iobjCur_ = dobjInfo.obj_;
            }
            else {
                /* get the current dobj and iobj from the resolve info */
                dobjCur_ = dobjInfo.obj_;
                iobjCur_ = iobjInfo.obj_;
            }    
            
            /* 
             *   if the action was remapped, and we need to announce
             *   anything, announce the entire action 
             */
            if (isRemapped())
            {
                /*
                 *   We were remapped.  The entire phrasing of the new
                 *   action might have changed from what the player typed,
                 *   so it might be nonsensical to show the objects as we
                 *   usually would, as sentence fragments that are meant
                 *   to combine with what the player actually typed.  So,
                 *   instead of showing the usual sentence fragments, show
                 *   the entire phrasing of the command.
                 *   
                 *   Only show the announcement if we have a reason to: we
                 *   have unclear disambiguation in one of the objects, or
                 *   one of the objects is defaulted.
                 *   
                 *   If we don't want to announce the remapped action,
                 *   still consider showing a multi-object announcement,
                 *   if we would normally need to do so.  
                 */
                if (needRemappedAnnouncement(dobjInfo)
                    || needRemappedAnnouncement(iobjInfo))
                {
                    /* show the remapped announcement */
                    gTranscript.announceRemappedAction();
                }
                else
                {
                    /* announce the multiple dobj if necessary */
                    if (!preAnnouncedDobj)
                        maybeAnnounceMultiObject(
                            dobjInfo, dobjList_.length(), DirectObject);

                    /* announce the multiple iobj if necessary */
                    if (!preAnnouncedIobj)
                        maybeAnnounceMultiObject(
                            iobjInfo, iobjList_.length(), IndirectObject);
                }
            }
            else
            {
                /* announce the direct object if appropriate */
                if (!preAnnouncedDobj)
                    announceActionObject(dobjInfo, dobjList_.length(),
                                         DirectObject);

                /* announce the indirect object if appropriate */
                if (!preAnnouncedIobj)
                    announceActionObject(iobjInfo, iobjList_.length(),
                                         IndirectObject);
            }

            /* run the execution sequence for the current direct object */
            doActionOnce();

            /* if we're top-level, count the iteration in the transcript */
            if (parentAction == nil)
                gTranscript.newIter();
        }
    }
    
    createForMissingIobj(orig, asker)
    {
        /* create the new action based on the original action */
        local action = createForRetry(orig);

        /* use an empty noun phrase for the new action's indirect object */
        action.iobjMatch = new EmptyNounPhraseProd();

        /* set our custom response production and ResolveAsker */
        action.iobjMatch.setPrompt(action.askIobjResponseProd, asker);

        /* copy what we've resolved so far */
        action.initForMissingIobj(orig);
        
        // If we have already a valid verb_ or prep_ or misc_ property
        // hand it over to our new action
        
        if (orig.verb_ != nil)
            action.verb_ = orig.verb_;

        if (orig.prep_ != nil)
            action.prep_ = orig.prep_;
        
        if (orig.misc_ != nil)
            action.misc_ = orig.misc_;
        
        /* return the action */
        return action;
    }
    
;

modify TIAction

    createForMissingDobj(orig, asker)
    {
        /* create the action for a retry */
        local action = createForRetry(orig);

        /* use an empty noun phrase for the new action's direct object */
        action.dobjMatch = new EmptyNounPhraseProd();

        /* set our custom response production and ResolveAsker */
        action.dobjMatch.setPrompt(action.askDobjResponseProd, asker);

        /* initialize the new action with any pre-resolved parts */
        action.initForMissingDobj(orig);

        // If we have already a valid verb_ or prep_ or misc_ property
        // hand it over to our new action
        
        if (orig.verb_ != nil)
            action.verb_ = orig.verb_;

        if (orig.prep_ != nil)
            action.prep_ = orig.prep_;
        
        if (orig.misc_ != nil)
            action.misc_ = orig.misc_;
        
        /* return the new action */
        return action;
    }
    
;

// #####################################################################
// ## Modification in Actor for keeping track of the narrative Tense  ##
// #####################################################################

modify Actor
    pcReferralTense = Present
;

// ################################################################
// ## we define one object for singular plural parameter strings ##
// ## in the thirdPerson                                         ##
// ################################################################

dummyHim : Thing
    isHim = true
    globalParamName = 'singular'
;

dummyThem : Thing
    isPlural = true
    globalParamName = 'plural'
;

// #####################################################
// ## We're done so far. This is the end of the file. ##
// #####################################################
