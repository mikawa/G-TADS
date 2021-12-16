#charset "latin1"
#include <adv3.h>
#include <de_de.h>

/*=====================================================================

Tads-3 Spelling Corrector, 1.1
(c) 2005-2006 Steve Breslin (at gmail)
in collaboration with Andreas Sewe
German Translation (c) 2021 by Michael Baltes

=======================================================================

License:

You're free to use this however you like, but if you make
changes/improvements, please make them available to the IF community.

=======================================================================

To use this extension, simply include it in your project build.

=======================================================================

Version History:

Version 1.1 includes the following fixes (thanks very much to Eric Eve):

Entering an illegal character (e.g. '[') in the command line no longer
causes an unhandled exception.

Entering certain typos (e.g. 'uo' for 'up') no longer causes an error.

The previous version declined to correct the objects of Literal actions,
because frequently these words will be spelled as intended, and simply
do not appear in the game's dictionary. The new version declines to
correct Topic actions for the same reason.  
        
Previously, the token "'s" was erroneously preceded by a space, when a
command string was reassembled from a token list.

=======================================================================

Design philosophy:

We want to correct typos very passively. If we cannot make a good guess
what the player meant, we fall back on the standard library's handling
for typos.

=======================================================================

Explanation of the main algorithm:

The main challenge with the spelling corrector is how to quickly figure
out the viable dictionary-match(es) for any given arbitrary typo-word.
(After this, we can run some case specific rules, filters, and
context-sensitive tie breakers, and ultimately automatically correct the
typo.)

It's theoretically possible to take a string-comparison function and use
it to compare the typo-word to each word in the dictionary, but because
the dictionary can be theoretically quite large, and because the
computation time for any string-comparison function will be relatively
high, we need some strategy to resolve a complete list of reasonable
candidates quickly.

Towards this, we considered a wide range of possibilities, including
greedy and heuristic-directed graph searches (with or without simulated
annealing), clustering/component-subgraphs, modifications to
StringComparator, dynamic hashing, and ultrametric spaces, as well as
the more conventional string-comparison tree-oriented techniques of
Burkhard-Keller Trees, Vantage Point Trees, and Bi-Sector Trees. In each
case we found the solution either incomplete, intractible, or too slow.

One main idea, in abstract, was to produce a very fast admissible
heuristic for the string-comparison function. This turned out to be the
best approach by far.

We finally decided that the fastest heuristic is to convert the
typo-string to its "binary signature," and perform bitwise comparisons
between that signature and the signature of each element in the
dictionary (whose signatures we precalculate). Because bitwise
comparison is extremely fast, in practice the size of the dictionary
actually does not make a significant difference; we can iterate over
even a very large dictionary in milliseconds. (Preprocessing the
dictionary is, however, somewhat slow, and the table takes up some
memory.)

The binary signature involves a bit assigned per each character-type in
the word: 'a'=1 ; 'b'='10' ; 'c'=100; and so on. So for example the word
'ace' would have a binary signature of 10101.

The heuristic works like this: we count the on-bits in a bitwise-XOR
comparison between the typo's signature and the signature of a given
word in the dictionary. This value/2 is a lower bound of the
transformation distance between the typo-word and the dictionary-word:

Transposition of two characters - no change in the bitwise-XOR bits.
Insert one character - bitwise-XOR bits change by at most 1.
Delete one character - bitwise-XOR bits change by at most 1.
Change one character - bitwise-XOR bits change by at most 2.

In practice, this filter cuts the number of candidates to a very small
percentage of the number of words in the dictionary.

(We also use a bitwise-AND comparison to filter matches. See below, the
"to do" list, for other filters under consideration.)

After we're done with the filter(s), we have a small subset of
dictionary words which might be a resonable transformation-distance away
from the typo-word. At this point, we perform a much more
computationally complex but rigorously accurate comparison: we compare
each of the candidates to the typo by calculating their edit-distance,
which tells us how many transformations would be necessary to transform
the typo into the viable candidate. The candidate(s) with the lowest
edit-distance (also known as Levenshtein distance) win(s).

In any case, if there are multiple final candidates, we run another
routine which breaks such ties, by context sensitivity and sundry. Our
current breakTie() algorithm seems to work well enough, but probably
could be sophisticated further. In a future version, I would like to
modularize the tiebreaking processes, and use more of the parser's
ranking tools (at which we make only a pathetic cheat in the current
version). But this gets us into the to-do list....

=======================================================================

To do (not a complete list I'm sure):

To optimize the heuristics, we can add more filters:

 - Eliminate all words whose bitwise-AND value is zero: no letters in
   common means a bad match -- and this is even faster than counting
   the bitwise-OR bits. <DONE>

 - Consider only those words which are of the same length as the
   typo-word +/- the typo-word's length (or some smaller measure of
   acceptable transformations given the typo-word's length --
   typoWord.length/3 seems a reasonable bound for the acceptable
   transformation distance). <DONE>

 - Require that at least two of the four letters in the beginning and
   ending pairs of letters in the typo-string is shared by the
   dictionary string. <DONE>

 - Halt strCompare() early when it's gone over the acceptable distance.

 - Use two bits per letter, the second bit indicating whether there's
   two or more of the letter in the string. (Would require 64-bit
   structure, or linked 32-bit.)

 - Use variable-size bit fields, e.g., 'e' gets three bits, while 'q'
   gets one.)

Feature ideas:

 - user/language -defined "standard typos". E.g.:
     (template) commonTypo 'teh' 'the';
     (or) commonTypos [['teh', 'the'], ['tpyo', 'typo']];

 - optionally query the user for tiebreaking

 - disallow "dangerous" typo-corrected commands

 - add words which are dynamically added to the dictionary at runtime
   to our databases, so spelling correction can resolve to them also.

breaking ties:

keyboard proximity (alpha/language/keyboard dependent) can rank matches
consider soundex, perhaps as a last resort for tiebreaking
better context sensitivity, especially:
better preposition inference, if possible:
   "put .. KN table"="put .. ON table"; "put .. KN bag"="put .. IN bag"
   although this would require a call through the verification scheme,
   which may be difficult, since verification wasn't designed for this.

   One possibility to consider: You can call verification and decode the
   results pretty easily given a resolved action - verifyAction()
   returns a VerifyResultList, which has methods (allowAction, for
   example) that characterize the results at a high level.

prefer verbs to nouns if the token is first, or after a comma/period
disfavor deletions from 2-letter typos
breakTie() may optionally query the player, similar to oops.
deleting doubles should be favored over other transformations:
   'bbat'='bat', not 'beat'
maybe rank the four transformation types by frequency, and favor
   tranformations accordingly
learning: typists tend to make the same mistakes repeatedly. Is learning
   possible without querying the user?

=======================================================================

Thanks to Dustin Boswell for some optimization recommendations. Thanks
to Cedric Knight (author of mistype.h, the Inform spelling corrector),
for his useful work, and for his advice on this project in particular.
Thanks to the first serious user of the system, Eric Eve, for giving
this system a very thorough working over indeed, and for fixing the
problems that appeared along the way.

=======================================================================

You might also like to include reflect.t if you want to enable
debugging messages. You can also #define CLOCK if you want to measure
the speed of the whole spelling-correction process.

*/

// #define CLOCK

property valToSymbol;


/* The SpellingCorrector class defines the general interface and
 * low-level methods for use with any specific spelling corrector
 * object. It is not, however, meant to be functional as a spelling
 * corrector itself. See below, defaultSpellingCorrector for our
 * fully functional instance of this class.
 */
class SpellingCorrector: StringPreParser

    execute() {
        /* don't register the SpellingCorrector class itself as a
         * StringPreParser
         */
        if(self != SpellingCorrector)
            inherited();
    }

    // we want to run after other string preparsers
    runOrder = 250

    correctionEnabled = true

    doParsing(str, which) {

#ifdef CLOCK
#ifdef __DEBUG
local curTime = getTime(GetTimeTicks);
try {
#endif // __DEBUG
#endif // CLOCK

        /* We'll be performing our operations on a tokenization of the
         * string.
         */
        local toks, transformedToks;

        /* If spelling correction has been disabled, we do nothing with
         * the string.
         */
        if(!correctionEnabled)
            return str;

          


        /* tokenize the string; make sure we catch an error thrown
         * by the tokenizer in the event of an illegal character
         * (e.g. '[') entered on the command line.
         */
       try
       {
            toks = cmdTokenizer.tokenize(str);
       }
       catch (TokErrorNoMatch exc)
       {
            /* note the token error */
            libMessages.invalidCommandToken(exc.curChar_.htmlify());
 
            /* abort the command */                 
            throw new TerminateCommandException;                 
                
       }


        /* First we scan toks for typos. If there is no typo, we return
         * the string unchanged.
         */
        if (!firstMismatch(toks))
            return str;

        /* If we find a viable action which is a LiteralAction, we do
         * not want to perform typo-correction. Likewise with a
         * TopicAction
         */

            
         if(cmdIsTopicOrLiteral(toks))
            return str;          
            

        /* If we made it this far, there is at least one token which
         * does not occur in the dictionary. We assume that this means
         * there is a typo in the command.
         *
         * Our first step is to preprocess the token list. This is
         * primarily for interrelated multi-word typos, such as a
         * misplaced "space".
         *
         * Note that preprocessing is performed only once, before the
         * typo-tokens are transformed individually.
         */
        transformedToks = preprocessTokens(toks);

        /* preprocessTokens() may have fixed all typo problems. We scan
         * the tokens again, and return the new toks list if there are
         * no typos remaining and it passes the final check.
         */
        if (!firstMismatch(transformedToks) && finalCheck(transformedToks))
            return toksToString(transformedToks);

        /* preprocessing did not solve our problem, so we reset the
         * transformedToks variable.
         */
        else transformedToks = toks;

        /* We cycle through the tokens, transforming each typo in turn.
         */
        for(local i = 1 ; i <= transformedToks.length ; i++) {

            local transformation;
            local token = transformedToks[i];
            local tokVal = getTokVal(token);

            /* If we have a viable LiteralAction, or TopicAction
             * we do not want to proceed with further typo-correction.
             */
            if(cmdIsTopicOrLiteral(transformedToks))
                return toksToString(transformedToks);

            /* If the token is in the dictionary, or if the token is
             * not of type tokWord, we proceed to the next token by
             * continuing the outer for-loop.
             */
            if(dict.isWordDefined(tokVal)
               || getTokType(token) != tokWord)
                continue;

            /* If we made it this far, token is not in the dictionary
             * and needs to be transformed.
             *
             * Frequently, there will be more than one equally-good
             * resolution of the typo. So our first task is to find a
             * list of reasonable transformations.
             */
            transformation = getBestMatches(
                                      getTokOrig(token).htmlify());

            /* We may want to filter our list of viable
             * transformations, in order, for example, to eliminate
             * those words which resolve only to object which the PC
             * does not yet know about or has not yet seen.
             */
            transformation = filterTransformations(transformation);

            /* Now that we have a list of equally-good transformations,
             * we want to break the tie. We reduce the transformation
             * list using the breakTie() method.
             */
            if(transformation.length > 1)
                transformation = breakTie(transformation, toks, i);

            /* breakTie() should return either a single-element list or
             * an empty list. But if we have more than one
             * transformation remaining, we arbitrarily pick the first.
             * If transformation is an empty list, we simply continue.
             */
            if(transformation.length == 0)
                continue; /* we can do nothing with this typo */
            transformation = transformation[1];

            /* We now have the best transformation for the typo-token.
             * We apply it to the token list, and proceed with the
             * outer token-scanning loop.
             */
            transformedToks = getTransformedTokList(transformation,
                                                  transformedToks, i);
        }

        /* If our transformed tokens list passes the final check,
         * return our transformed tokens list.
         */
        if (finalCheck(transformedToks))
            return toksToString(transformedToks);

        /* It failed to pass the final check. Return the original
         * string unchanged.
         */
        return str;

#ifdef CLOCK
#ifdef __DEBUG
} // try
finally {
"\nDEBUG MESSAGE: Total spelling-correction time =
<<getTime(GetTimeTicks) - curTime>> milliseconds\n";
}
#endif // __DEBUG
#endif // CLOCK

    }

    /* firstMismatch() finds the first token in a token list which does
     * not match a word in the dictionary.
     */
    firstMismatch(toks) {
        foreach(local token in toks)
            if(getTokType(token) == tokWord
               && !dict.isWordDefined(getTokVal(token)))
                return token;
        return nil; // no bad tokens found
    }

    /* We check if any parser-interpretation of the command resolves to
     * a Literal command. We use this to halt spelling-correction: in
     * this case, the tokens should not be altered. For example, given
     * the LiteralTAction command 'type':
     *
     * >TYPE QWERTY ON KKEYBOARD
     *
     * clearly, at least the token 'querty' should not be
     * spelling-corrected. Erring on the conservative side, we probably
     * don't want to correct any other tokens in the command either.

//--!! on the other hand, consider "type .. on .." vs. "type .. un .. "
//--!!
//--!! >type asdf un typewrytor
//--!! (on the typewriter)
//--!! You type 'asdf un typewrytor' on the typewriter. 
//--!!
//--!! >type asdf on typewrytor
//--!! The word 'typewrytor' is not necessary in this story.
//--!!
//--!! So perhaps some matchVal searching would be best, to correct the
//--!! preposition?
//--!!
//--!! On the third hand, probably not. Spelling correction should be
//--!! conservatively passive.

     */
//    cmdIsLiteral(toks) {
//        foreach(local cmd in commandPhrase.parseTokens(toks, dict))
//            if(cmd.cmd_.ofKind(LiteralTAction)
//               || cmd.cmd_.ofKind(LiteralAction))
//                return true;
//        return nil;
//    }
    
    /* By the sake token we need to be cautious about spell-checking
     * TopicActions
     */
    
    
    cmdIsTopicOrLiteral(toks) {
       return commandPhrase.parseTokens(toks, dict).indexWhich
        ({cmd: cmd.cmd_ != nil && (
             cmd.cmd_.ofKind(LiteralActionBase)
            || cmd.cmd_.ofKind(TopicActionBase)) }) != nil;
    }
    

    /* By default we do nothing for token preprocessing, but this
     * is probably where one want to add "misplaced" or "elided" space
     * correction.
     */
    preprocessTokens(toks) { return toks; }

    /* toksToString simply converts a token list to a command string */
    toksToString(toks) {
        local ret = '';
        foreach (local tok in toks){
            if(getTokType(tok)==tokApostropheS)
              ret = ret.substr(1, ret.length-1);
            ret = ret + tok[1] + ' ';
        }
        return ret.substr(1, ret.length-1);
    }

    /* getBestMatches(str) must be defined by instances of the
     * SpellingCorrector class.
     *
     * Here we simply return an empty list: no reasonable matches are
     * indicated.
     */
    getBestMatches(str) { return []; }

    /* filterTransformation() takes as a single argument the vector of
     * transformations under consideration, and eliminates certain
     * candidates from further consideration. It returns the same or a
     * modified vector.
     *
     * By default, we filter out candidates which are not known to the
     * player, but which are necessarily game objects (as opposed to
     * abstract actions for example).
     *
     * We put this in the abstract SpellingCorrector class because
     * this protection is frequently crucial in order to protect
     * puzzles or the narrative integrity and suspense of the piece.
     */
    filterTransformations(transformation) {
        transLoop:
        for(local i = 1 ; i <= transformation.length ; i++) {
            local str = transformation[i];
            local objList = dict.findWord(str);
            for(local j = 1 ; j < objList.length ; j=j+2) {

                /* If this word meets the criteria, continue the
                 * transLoop.
                 */
                if(!objList[j].ofKind(VocabObject)) 
                    continue transLoop;
                if(gPlayerChar.knowsAbout(objList[j])
                   || gPlayerChar.hasSeen(objList[j]))
                    continue transLoop;
            }
            /* This word didn't meet the criteria. Filter it out. */
            transformation.removeElementAt(i);
            --i;
        }
        return transformation;
    }

    /* breakTie() takes three arguments: a vector of transformations
     * being considered, the complete token-list, and the index of the
     * typo-string now being corrected. It returns a single element
     * from the transformation vector, or an empty list if it fails to
     * come up with a single "best" transformation.
     *
     * This could be used for ranking types of typos, or by favoring
     * one transformation over the others by some context-sensitivity
     * analysis.
     *
     * By default, we simply return the first element of the
     * transformation vector.
     */
    breakTie(transformation, toks, i) { return transformation[1]; }

    /* apply the string 'str' to the token list at index i, and return
     * the altered token list.
     */
    getTransformedTokList(str, toks, i) {
        return toks.sublist(1, i-1) + [[str, tokWord, str]]
               + toks.sublist(i+1);
    }

    /* We perform a "final check" of a list of transformed tokens.
     * Return true if the tokens pass the check, nil if not.
     * By default, we allow the tokens to pass the check.
     */
    finalCheck(toks) {

        /* Tell the player what we've done. */
        printToks(toks);

        /* accept the tokens list */
        return true;
    }

    printToks(toks) {
        /* We tell the player what the transformed tokens list looks
         * like.
         */
        "(<<toksToString(toks)>>)";

        /* We tell the player how to disable spelling-correction if we
         * have not already done so.
         */
        if(!disableMessagePrinted)
            " <<disableMessage>>";
        disableMessagePrinted = true;
        "\n";
    }

    disableMessagePrinted = nil

    /* The method strCompare() takes as arguments two strings, and
     * returns an integer. The return value reflects the number of
     * operations necessary to transform the first string into the
     * second string. Operations considered are insertion, deletion,
     * substitution, and transposition.
     *
     * This measure is based on the work of scientist Vladimir
     * Levenshtein, who first wrote of this in 1965. His work did
     * not require transposition to be one operation: transposition
     * would mean two substutions. But for our purposes, transposition
     * is one operation, so the following is a modified Levenshtein
     * string comparator.
     *
     * We include this method in the abstract SpellingCorrector class
     * because it should be generally useful for any spelling
     * corrector.
     *
     * We apologize that this code is somewhat difficult to read.
     * Because it's essential that this expensive yet core process is
     * as fast as possible, we have sacrificed readability for speed.
     */
    strCompare(str1, str2, [args]) {

        local cost;

        local width = str1.length +1;
        local height = str2.length +1;

        /* If either str1 or str2 are empty, return the length of the
         * other string (which may itself be empty also).
         */
        if(width == 1)
            return height-1;
        if(height == 1)
            return width-1;

        /* Set up a Vector to represent a 2d matrix, and populate the
         * edge values.
         */
        local d = new Vector(width*height);
        for(local i = 1 ; i <= width ; i++)
            d[i] = i-1;
        for(local j = 1 ; j < height ; j++)
            d[1 + (j)*width] = j;

// To halt this early, we may need to iterate i and j alternately.
// Or maybe we could just 'continue' where the (i,j) value in the
// 2D-array is too high. I need to think on this some more.

        for(local s1Minus = nil, local i = 2 ; i <= width ; i++) {
            local s1 = str1.substr(i-1,1);

            for(local s2Minus = nil, local j = 2 ; j <= height ; j++) {
                local s2 = str2.substr(j-1,1);
                local val;
                if(s1 == s2)
                    cost = 0;
                else
                    cost = 1;
                val = min(
                    d[(i-1) + (j-1) * width] + 1,    // insertion
                    d[(i  ) + (j-2) * width] + 1,    // deletion
                    d[(i-1) + (j-2) * width] + cost  // substitution
                    );

                /* The above is the canonical Levenshtein algorithm.
                 * Here we fix Levenshtein so that transposition is
                 * considered one operation (rather than two
                 * substitutions).
                 */
                if (i>2 && j>2) {                    // transposition
                    if(s1Minus == s2 && s2Minus == s1)
                        val = d[i-2 + (j-3)*width] + 1;
                }

                d[i + (j-1) * width] = val;

                s2Minus = s2; /* remember the former value of s2 */
            }
            s1Minus = s1; /* remember the former value of s1 */
        }

        /* the last element of the matrix-Vector now holds the edit
         * distance.
         */
        return d[width*height];
    }

    /* By default the dictionary we're matching the typo against is the
     * standard cmdDict.
     */
    dict = cmdDict
;

/*===================================================================*/

/* defaultSpellingCorrector is a robust corrector optimized for
 * calculation speed at runtime.
 *
 * Note that we rely on SpellingCorrector for all the generic behavior,
 * which means we only need to customize three methods:
 *
 * 1. getBestMatches()
 * 2. breakTie()
 * 3. preprocessTokens()
 *
 * The first, getBestMatches(), is the core method for any spelling
 * corrector object, and most of the other processes below are simply
 * support for this core method. The other two, breakTie() and
 * preprocessTokens(), are strictly optional, although it's difficult
 * to imagine a robust spelling corrector which does not take advantage
 * of these processes.
 */
defaultSpellingCorrector: SpellingCorrector

    execBeforeMe = [adv3LibPreinit]

    /* allWords, binSigTable, charToBitVals, and letterPairTable are
     * the databases we use during getBestMatches().
     *
     * allWords is simply a Vector of all the words in the dictionary.
     *
     * binSigTable is a table keyed by vocab-word strings, with values
     * of the corresponding string's binary signature. (The binary
     * signature involves a bit assigned per each character-type in the
     * word: 'a'=1 ; 'b'='10' ; 'c'=100; and so on. So for example the
     * word 'ace' would have a binary signature of 10101.)
     *
     * charToBitVals is a a LookupTable keyed by the alphabet-characters
     * from alphabet, with values equal to the corresponding bit value
     * for each character.
     *
     * letterPairTable is a large database to speed up candidate
     * resolution, on the assumption that a viable candidate must share
     * at least any two of the first or last pair of letters in the
     * typo word. It is keyed by letter pairs, with values as vectors
     * of words in the dictionary.
     *
     * These databases are initialized at preinit, and do not change
     * during runtime.
     */
    allWords = nil
    binSigTable = nil
    charToBitVals = nil
    letterPairTable = nil

    /* During preinit, we initalize these databases. */
    execute() {

        /* We do the default StringPreParser behavior, which basically
         * registers this object as a StringPreParser, so it is called
         * during the preparsing stage of command resolution.
         */
        inherited();

        /* We produce a Vector of unique dictionary words. */
        local allWordsTable;
        local allWordsRedundant = new Vector(1000);
        dict.forEachWord({ x,y,z: allWordsRedundant.append(y) });
        allWordsTable = new LookupTable(allWordsRedundant.length,
                                        allWordsRedundant.length);
        foreach(local elem in allWordsRedundant)
            allWordsTable[elem] = true;
        allWords = allWordsTable.keysToList;

        /* We assign a bit-value for each character in the alphabet */
        charToBitVals = new LookupTable(alphabet.length,
                                        alphabet.length);
        for(local i = 1, local j = 1 ; i <= alphabet.length ; i++) {
            charToBitVals[alphabet.substr(i, 1)] = j;

            /* increment j by one bit if it's not going over our 32-bit
             * cap. If the alphabet is longer than 32 letters, all
             * characters after the 31st have the same bit signature.
             *
             * This is a minor performance issue in some non-English
             * alphabets, but I imagine that this is rare.
             */
            if(j < 0X40000000)
                j*=2;
        }

        /* Assign to each word its binary signature. */
        binSigTable = new LookupTable(allWords.length,
                                      allWords.length);
        foreach(local str in allWords)
            binSigTable[str] = binarySignature(str);

        /* Set up a table keyed by first and/or last letter-pairs */
        letterPairTable = new LookupTable(allWords.length*6,
                                          allWords.length*6);
        foreach(local str in allWords) {
            foreach(local pair in getLetterPairs(str)) {
                if(!letterPairTable[pair])
                    letterPairTable[pair] = new Vector(50);
                letterPairTable[pair].append(str);
            }
        }
    }

    /* getLetterPairs() returns a List of letter-pairs for a given
     * string. The return List includes all combinations of the first
     * two and last two letters in the string.
     */
    getLetterPairs(str) {
        local tab, first, second, last;
        local len = str.length;

        /* We add single-letter words combined with each other letter
         * in the alphabet.
         */
        if(len == 1) {
            tab = new LookupTable(alphabet.length*2, alphabet.length*2);
            for(local i = 1 ; i <= alphabet.length ; i++) {
                local char = alphabet.substr(i,1);
                tab[str+char] = true;
                tab[char+str] = true;
            }
            return tab.keysToList;
        }

        tab = new LookupTable(6, 100);

        first = str.substr(1,1);
        last = str.substr(str.length, 1);

        tab[first+last] = true;
        tab[last+first] = true;

        if(len > 2) {
            second = str.substr(2,1);
            tab[first+second] = true;
            tab[second+last] = true;
        }

        if(len > 3) {
            local secondLast = str.substr(str.length-1, 1);
            tab[first+secondLast] = true;
            tab[second+secondLast] = true;
            tab[secondLast+last] = true;
        }
        return tab.keysToList;
    }

    /* We define getBestMatches(), the core method for any instance of
     * the SpellingCorrector class.
     */
    getBestMatches(str) {

        /* set a limit on the number of transformations allowed. */
        local transLimit = getReasonableDist(str);

        /* We get a list of candidate words, a (hopefully small) subset
         * of all the words in the dictionary which have some chance of
         * being suitable matches for the typo-string.
         */
        local candidates = getCandidates(str);

        /* We set up a LookupTable keyed by transformation distance,
         * with values as Vectors of words that are that
         * corresponding transformation distance away from the
         * typo-string.
         */
        local ret = new LookupTable(transLimit, transLimit);

        for(local i = 0 ; i <= transLimit ; i++)
            ret[i] = new Vector(8);

        foreach(local cand in candidates) {
/*--!! could pass transLimit as an optional argument to strCompare */
            local compVal = strCompare(str, cand);

            /* If the comparison value is within the transLimit, it is
             * worth considering.
             */
            if(compVal <= transLimit) {
                ret[compVal].append(cand);
                transLimit = compVal;
            }
        }

        /* We return the LookupTable value (a Vector) that contains
         * elements and has the lowest key value.
         */
        for(local i = 0 ; i <= transLimit ; i++)
            if(ret[i].length)
                return ret[i];

        /* We return an empty list if the lookup table's vectors are
         * all empty.
         */
        return [];
    }

    /* getCandidates() returns a vector of all the words in the
     * dictionary that have a "similar" binary signature to the
     * typo-string.
     *
     * This works basically as a dual filter: we begin with all the
     * words in the dictionary, and eliminate those which do not share
     * any letters in common with the typo-string. Then we eliminate
     * all the words which differ by a number of letters larger than
     * two-times the acceptable transformation threshold, as determined
     * by the length of the typo-string.
     *
     * The important thing here is to ensure we're not eliminating
     * any words which could be matched by our string comparison
     * function: we're not "over-filtering."
     *
     * We also filter by string length. Any word that has fewer than
     * (str.length+d) or more than (str.length-d) characters will not
     * pass this filter.
     */
    getCandidates(str) {

        local d = getReasonableDist(str);
        local bS = binarySignature(str);
        local lPFilterWords = getLPFilterWords(str);
        local bSAnd = binSigAnd(bS, lPFilterWords);
        local ret = binSigOr(d, bS, bSAnd);
        local len = str.length;

        /* We filter ret by length. */
        local i = 1;
        while(i <= ret.length) {
            if(ret[i].length+d < len
               || ret[i].length-d > len)
                ret.removeElementAt(i);
            else
                i++;
        }
        return ret;
    }

    /* We limit the number of acceptable transformations by the length
     * of the typo-string divided by three.
     */
    getReasonableDist(str) {
        if(str.length<3)
            return 1;
        return str.length/3;
    }

    /* binarySignature(str) calculates the "binary signature" of a
     * string of alphabet-letters.
     * 
     * The substr() computation and the charToBitVals lookup take some
     * processing time, so this computation takes up some significant
     * processing time during preinit, but since this method is only
     * run once per typo, the computation time is harmless at runtime.
     */
    binarySignature(str) {

        local ret=0;
        local len = str.length;
        str = str.toLower();

        /* Add to the return value a bit corresponding to each
         * character in the string.
         */
        for(local i=1 ; i <= len ; i++) {
            local val = charToBitVals[str.substr(i,1)];
            if(val)
                ret |= val;
        }
        return ret;
    }

    /* getLPFilterWords returns a vector of dictionary words which
     * share a minimum of two letters of the combined first and last
     * two letters of the string.
     */
    getLPFilterWords(str) {
        local letterPairs = getLetterPairs(str);
        local tab = new LookupTable(100, 100);
        foreach(local pair in letterPairs)
            if(letterPairTable[pair])
                foreach(local elem in letterPairTable[pair])
                    tab[elem] = true;
        return tab.keysToList;
    }

    /* binSigAnd(sig) compares the binary signature sig to each entry
     * in the binSigTable database, and returns the subset of those
     * entries which have at least one letter (one bit) in common with
     * the sig. This is the bitwise-AND comparison.
     * getCandidates() uses this to pre-filter the dictionary before
     * passing this filtered list through binSigOr().
     */
    binSigAnd(sig, vec) {
        local ret = new Vector(500);
        foreach(local str in vec)
            if(binSigTable[str] & sig)
                ret.append(str);
        return ret;
    }

    /* binSigOr() filters a Vector of possible candidates by
     * calculating the binary difference between each candidate's
     * binary signature and the given sig. If that difference is
     * smaller than the given distance, the candidate passes the
     * filter.
     */
    binSigOr(dist, sig, candidates) {
        local ret = new Vector(50);
        foreach(local cand in candidates) {

//--?? The next step might be faster if, instead of doing a lookup, we
//--?? iterate over parallel vectors. It probably doesn't matter: this
//--?? part of the algorithm is already quite fast.

            local dif = binDiff(sig, binSigTable[cand]);
            if(dif/2 <= dist)
                ret.append(cand);
        }
        return ret;
    }

    /* binDiff() returns the number of bit-differences between two sets
     * of binary numbers.
     *
     * This the number of 1's in the two numbers' bitwise-XOR value.
     */
    binDiff(a,b) {
        return bitCount(a^b);
    }
    bitCount(n) {  
        local count=0;
        while(n) {
            count++;
            n &= (n - 1);
        }
        return count;
    }

    /* This is where we incorporate context-sensitivity. So for
     * instance, if the current token list does not resolve an action,
     * and one of the transformations does, we'll favor that one. Or
     * if one of the transformations resolves to an object in scope,
     * we favor that one.
     */
    breakTie(transformation, toks, i) {

        local allCommands = [];
        local ranking;
        /* We want keep track of what transformations are "good", but
         * we want to keep the initial transformation list intact.
         */
        local goodTransformations = new Vector(transformation.length);

        /* We never want to perform substitution on single-character
         * typos.
         */
        if(getTokOrig(toks[i]).length == 1)
            transformation = transformation.subset({x: x.length>1});

        /* Generate a list of all commands resulting from any of the
         * transformations.
         */
        foreach(local str in transformation)            
            allCommands += commandPhrase.parseTokens(
                            getTransformedTokList(str, toks, i), dict);
        

        /* Set up the list of possible commands as a command ranking.
         * sortByRanking ultimately compares nounSlotCount; if any
         * of the commands in the allCommandsList don't define this
         * property, the comparison will cause a run-time error, so
         * we need to skip this step in this case.
         * Instead we set provide a truncated version of the
         * library's CommandRanking.sortByRanking method which
         * simply populates the ranking Vector in the same way
         * without attempting to sort it.
         */
         
         
//        if(allCommands.indexWhich({x: dataType(x.nounSlotCount ) == TypeNil} ))
//        {
//           ranking = new Vector(allCommands.length());
//           
//           foreach(local cur in allCommands)           
//           {
//            local curRank;
//            
//            /* create a ranking item for the entry */
//            curRank = new CommandRanking(cur);            
//            
//            /* add this to our ranking list */
//            ranking.append(curRank);
//           }
//
//        }
//        else 
           
//           ranking = MissingObjectRanking.sortByRanking(allCommands,
//                                           gPlayerChar, gPlayerChar);
                                           
           ranking = CommandRanking.sortByRanking(allCommands,
                                           gPlayerChar, gPlayerChar);
                                           

        /* Remember those that have a combined missingCount and
         * nonMatchCount no greater than the combined missingCount
         * and nonMatchCount of the first ranking entry.
         */
         
        /*
         *  This step can only be carried out if every element in ranking
         *  has a non-nil match property
         */
          
//        local ran = ranking.indexWhich({x: x.match == nil});     
          
        if(ranking.length)
        {
            local max = ranking[1].missingCount
                        + ranking[1].nonMatchCount;
            for(local j = 1 ; j <= ranking.length ; j++)
                if(ranking[j].missingCount
                   + ranking[j].nonMatchCount <= max)
                    goodTransformations.append(                        
                                   ranking[j].match.tokenList[i][1]);
        }
        else
          goodTransformations.appendAll(transformation);

        /* Remove those elements which are not in scope, but which are
         * necessarily game objects. If no objects are in scope, leave
         * the goodTransformations vector alone.
         */
        local scopeStrings = new Vector(goodTransformations.length,
                                        goodTransformations);
        strLoop:
        foreach(local str in scopeStrings) {
            local objList = dict.findWord(str);
            for(local j = 1 ; j < objList.length ; j=j+2) {
                if(!objList[j].ofKind(VocabObject))
                    continue strLoop;
                if(gPlayerChar.scopeList.indexOf(objList[j]))
                    continue strLoop;
            }
            scopeStrings.removeElement(str);
        }
        if(scopeStrings.length)
            goodTransformations = scopeStrings;

        /* Finally, we favor transformations which have the same first
         * letter as the typo-word in question.
         */
        if(goodTransformations.length > 1) {
            local origFirstLetter = getTokOrig(toks[i]).substr(1,1);
            local firstLetterSameTransformations =
                              new Vector(goodTransformations.length);
            foreach(local str in goodTransformations)
                if(origFirstLetter == str.substr(1,1))
                    firstLetterSameTransformations.append(str);
            if(firstLetterSameTransformations.length)
                goodTransformations = firstLetterSameTransformations;
        }

        /* If there's no good transformations remaining, we return an
         * empty list.
         */
        if(!goodTransformations.length)
            return [];

        /* If there's more than one good transformation, we refuse to
         * correct the typo, because we don't want to be too
         * aggressive. Instead, we return an empty list.
         */
        if(goodTransformations.length > 1) {
#ifdef __DEBUG
"DEBUG MESSAGE: Refusing to correct '<<toks[i][1]>>' because breakTie()
failed to generate a unique correction.";
if(mainGlobal.reflectionObj)
  "\nRemaining possibilities were:
  <<mainGlobal.reflectionObj.valToSymbol(goodTransformations.toList)>>";
"\b";
#endif
            return [];
        }
        /* We sucessfully broke the tie.
         */
        return goodTransformations;
    }

    /* We preprocess the tokens to replace elided spaces, move
     * misplaced spaces, and remove spurious spaces.
     *
     * If we cannot fix the command entirely, we return it unchanged. 
     *
     * We scan from left to right, which can theoretically have some
     * bearing on the result. More significant perhaps is the order of
     * operations. It may be that an alternate order will produce more
     * desirable results on average.
     */
    preprocessTokens(toks) {

        local tokVector = new Vector(toks.length);

        tokLoop:

        for(local i = 1 ; i <= toks.length ; i++) {

            local token = toks[i];

            if(getTokType(token) != tokWord
               || dict.isWordDefined(getTokVal(token))) {

                /* We found a good token, so add it to the tokVector */
                tokVector.append(getTokVal(token));

                /* We continue the tokLoop iteration. */
                continue tokLoop;
            }
            /* We have found a bad token. First we set up the local
             * variables, which give us the current, previous, and next
             * token in the command string.
             */
            local lastToken, nextToken;
            local curToken = getTokOrig(token);
            if(i>1)
                lastToken = tokVector[tokVector.length];
            if(i<toks.length)
                nextToken = getTokOrig(toks[i+1]);

            /* We consider elided spaces. So 'thedoor'='the door' */
            for(local j = 1 ; j < curToken.length ; j++) {
                local str1 = curToken.substr(1, j);
                local str2 = curToken.substr(j+1, curToken.length);
                if(dict.isWordDefined(str1)
                   && dict.isWordDefined(str2)) {
                    tokVector.append(str1);
                    tokVector.append(str2);
                    continue tokLoop;
                }
            }

            /* We consider misplaced spaces. (Allowing only for one-off
             * misplacement.)
             * So 'a napple'='an apple', 'ana pple'='an apple', and
             * 'theb room'='the broom'
             */
            if(lastToken) {

                /* try giving a letter back to the last token */
                local str1 = lastToken + curToken.substr(1,1);
                local str2 = curToken.substr(2, curToken.length);
                if(dict.isWordDefined(str1)
                   && dict.isWordDefined(str2)) {
                    tokVector.removeElementAt(tokVector.length);
                    tokVector.append(str1);
                    tokVector.append(str2);
                    continue tokLoop;
                }

                /* try taking the last letter from the last token */
                str1 = lastToken.substr(1, lastToken.length-1);
                str2 = lastToken.substr(lastToken.length, 1) + curToken;
                if(dict.isWordDefined(str1)
                   && dict.isWordDefined(str2)) {
                    tokVector.removeElementAt(tokVector.length);
                    tokVector.append(str1);
                    tokVector.append(str2);
                    continue tokLoop;
                }
            }

            if(nextToken) {

                /* try giving a letter to the next token */
                local str1 = curToken.substr(1,curToken.length-1);
                local str2 = curToken.substr(curToken.length,1) + nextToken;
                if(dict.isWordDefined(str1)
                   && dict.isWordDefined(str2)) {
                    tokVector.append(str1);
                    tokVector.append(str2);
                    ++i;
                    continue tokLoop;
                }

                /* try taking a letter back from the next token */
                str1 = curToken + nextToken.substr(1,1);
                str2 = nextToken.substr(2,nextToken.length);
                if(dict.isWordDefined(str1)
                   && dict.isWordDefined(str2)) {
                    tokVector.append(str1);
                    tokVector.append(str2);
                    ++i;
                    continue tokLoop;
                }
            }

            /* We consider spurious spaces. So 'cucu mber'='cucumber'
             */
            if(lastToken) {
                /* Try joining with the last token */
                if(dict.isWordDefined(lastToken+curToken)) {
                    tokVector.removeElementAt(tokVector.length);
                    tokVector.append(lastToken+curToken);
                    continue tokLoop;
                }
            }
            if(nextToken) {
                /* Try joining with the next token */
                if(dict.isWordDefined(curToken+nextToken)) {
                    tokVector.append(curToken+nextToken);
                    ++i;
                    continue tokLoop;
                }
            }
 
            /* If we haven't continued the tokLoop, we weren't able
             * to fix the typo. We do not allow partial fixes in
             * the preprocessing step, so we return the token list
             * unchanged.
             */
            return toks;
        }
        /* We changed all the tokens to viable words. We convert this
         * back to a token list.
         */
        local tokString = '';
        foreach(local elem in tokVector)
            tokString += (elem + ' ');
        tokVector = cmdTokenizer.tokenize(tokString);

        return tokVector;
    }

    finalCheck(toks) {
        local ranking;
        if(toks.ofKind(Vector))
            toks = toks.toList;
        ranking = CommandRanking.sortByRanking(
                          firstCommandPhrase.parseTokens(toks, dict),
                          gPlayerChar, gPlayerChar); 
        if(ranking.length == 0
           || ranking[1].missingCount
           || ranking[1].nonMatchCount)
            return nil;
        return inherited(toks);
    }
;

/*===================================================================*/

/* We make a minor modification to VocabObject.addToDictionary(), to
 * expand our databases as necessary. This needs some work still, so
 * we've commented this out for this version.
 */
/*
modify VocabObject
    addToDictionary(prop) {
        defaultSpellingCorrector.allWords.appendUnique(self.(prop));
        defaultSpellingCorrector.binSigTable[self.(prop)] =
              defaultSpellingCorrector.binarySignature(self.(prop));
        inherited(prop);
    }
;
*/

modify OopsIAction
  resolveNouns(issuingActor, targetActor, results)
     {
         /* 
          *   We have no objects to resolve.  The only thing we have to do
          *   is note in the results our number of structural noun slots
          *   for the verb, which is zero, since we have no objects at all. 
          */
         results.noteNounSlots(0);
     }
;


/*===================================================================*/

/* German language/alphabet-specific code */

modify SpellingCorrector

    /* By default we assume an English alphabet. If you're using an
     * alternate alphabet/language, simply alter this list and the rest
     * will be taken care of automatically.
     *
     * The characters must be in lowercase only. If that limitation is
     * inappropriate for your language, please let me know. (The order
     * is irrelevant.)
     */
    alphabet = 'aäbcdefghijklmnoöpqrsßtuüvwxyz'

    disableMessage = '\n(Sage TYPO um die Rechtschreibkorrektur an- oder 
                      auszuschalten.)\b'
;

DefineSystemAction(ToggleSpellingCorrection)
    execAction() {
        local enabled = SpellingCorrector.correctionEnabled;
        mainReport('Rechtschreibkorrektur ' +
        (enabled ? 'aus':'an') +'.');
        SpellingCorrector.correctionEnabled = !enabled;
    }
;

DefineSystemAction(DisableSpellingCorrection)
    execAction() {
        mainReport('Rechtschreibkorrektur aus.');
        SpellingCorrector.correctionEnabled = nil;
    }
;

DefineSystemAction(EnableSpellingCorrection)
    execAction() {
        mainReport('Rechtschreibkorrektur an.');
        SpellingCorrector.correctionEnabled = true;
    }
;

VerbRule(DisableSpellingCorrection)
    ('typo' | 'rechtschreibung' | 'rechtschreibkorrektur' | 'schreibkorrektur' | 'korrektur')
    'aus':
    DisableSpellingCorrectionAction
;

VerbRule(EnableSpellingCorrection)
    ('typo' | 'rechtschreibung' | 'rechtschreibkorrektur' | 'schreibkorrektur' | 'korrektur')
    ('ein' | 'an'):
    EnableSpellingCorrectionAction
;

VerbRule(ToggleSpellingCorrection) 
    ('typo' | 'rechtschreibung' | 'rechtschreibkorrektur' | 'schreibkorrektur' | 'korrektur'):
    ToggleSpellingCorrectionAction
;

/*===================================================================*/

moduleSpellingCorrector: ModuleID
    name = 'TADS 3 Spelling Corrector'
    byline = 'by Steve Breslin'
    htmlByline = byline
    version = '1.1'
;

/*=========================== End of File ===========================*/

