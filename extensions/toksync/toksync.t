#charset "us-ascii"
/* 
 *  Copyright (c) 2003 by Kevin Forchione. All rights reserved.
 *   
 *  TokSync.t
 *
 *  TokSync is for library extensions and author games that need
 *  to add a new token to the command tokenizer. Simple create a
 *  TokenRuleObject, assign it an identifying name, the token rule 
 *  you want to add to the command tokenizer, and a list of single-
 *  quoted token strings that the token rule should match. 
 * 
 *  The tokSynPreinit will search for all TokenRuleObjects and add
 *  them to the command tokenizer rules and checks to see that the
 *  new token rules are then valid when compared to their token string
 *  lists.
 *
 *  For example. If you wanted to add a time token to the library:
 *  
 *      timeSysTokenRuleObject: TokenRuleObject
 *      {
 *          tokRule_    = ['token-name', new RexPattern('(<Digit>?<Digit>):(<Digit><Digit>)(<NoCase><space>*(am|pm|a.m.|p.m.|a|p))?'),
 *              tokTime, nil, nil]
 *          tokStrList_ = ['5:00', '17:00', '3:00 pm', '3:00 p.m', 
 *              '12:00 a.m.']
 *      }
 *
 *  If any of the token strings are not matched by the token rule then
 *  tokSyncPreinit throws a RuntimeError.
 */

#include "t3.h"
#include "tads.h"

// Dummy testing token  
 enum token tokSyncTest;

/* ------------------------------------------------------------------------ */
/*
 *   The TADS 3 TokSync library Extension ID.
 */
ModuleID
{
    name = 'TADS 3 TokSync Library Extension'
    byline = 'by Kevin L.\ Forchione'
    htmlByline = 'by <a href="mailto:kevin@lysseus.com">Kevin L.\ Forchione</a>'
    version = '1.1'

    /*
     *   We use a listing order of 60 so that, if all of the other credits
     *   use the defaults, we appear after the TADS 3 Library's own credits
     *   (conventionally at listing order 50) and before any other extension
     *   credits (which inherit the default order 100), but so that
     *   there's room for extensions that want to appear before us, or
     *   after us but before any default-ordered extensions.  
     */
    listingOrder = 60
} 

/*
 *  A base class for associating token rules
 *  with token string lists used to test the 
 *  token rule.
 */
class TokenRuleObject: object
{
    tokRule_        = nil
    tokStrList_     = []

    getTokenRule()
    {
        return tokRule_;
    }
    getTokenStringList()
    {
        return tokStrList_;
    }
    getTokenRuleName()
    {
        return tokRule_[1];
    }
    getTokenRulePattern()
    {
        return tokRule_[2];
    }
    getTokenType()
    {
        return tokRule_[3];
    }
}

/*
 *  The TokenRuleSynchronizer class is meant to aid
 *  authors in coordinating the addition of new token
 *  rules to the command tokenizer.
 */
TokenRuleSynchronizer: object
{
    /*
     *  Updates the command tokenizer if our 
     *  new token rule matches all of the token
     *  strings of the token rule object.
     */
    testTokRuleForUpdate(tokRuleObj)
    {
        local newTokRule;
        local idx;

        newTokRule = tokRuleObj.getTokenRule();

        /*
         *  Get the index position for the new rule.
         */
        idx = testTokRule(tokRuleObj);

        /*
         *  If the index is not nil update
         *  the tokenizer rules with our new rule.
         */
        if (idx != nil)
            cmdTokenizer.insertRuleAt(newTokRule, idx);

        /*
         *  Tell the caller we updated the tokenizer rules
         *  by returning the update index, or that we did
         *  not update the tokenizer by returning nil.
         */
        return idx;
    }

    /*
     *  Returns the latest position at which you can insert the 
     *  new rule and have it take effect. This is to ensure 
     *  that the new rule doesn't override any existing rule that 
     *  it doesn't have to override, to avoid interactions as much 
     *  as possible. If no position is found, the method returns nil.
     */
    testTokRule(tokRuleObj)
    {
        local newTokRule, tokStrList;
        local oldRules, idx, idxMin;

        newTokRule = tokRuleObj.getTokenRule();
        tokStrList = tokRuleObj.getTokenStringList();

        if (tokStrList.length() == 0)
        {
            throw new NoTokStrTokenRuleObjectError(tokRuleObj);
        }

        // save the original rules
        oldRules    = cmdTokenizer.rules_;

        idxMin      = oldRules.length();

        /*
         *  Change element #2 to our dummy testing token.
         */
        newTokRule[3] = tokSyncTest;

        foreach (local tokStr in tokStrList)
        {
            // get the new token rule's matching index
            idx = getTokRuleIndex(newTokRule, tokStr);

            // restore the original tokenizer rules
            cmdTokenizer.rules_ = oldRules;

            /* 
             *  If the index is nil then our new
             *  tokenRule doesn't match the tokStr
             */
            if (idx == nil)
                throw new NoStrMatchTokenRuleObjectError(tokRuleObj, tokStr);

            /*
             *  We want the minimum position in the
             *  rules for all of the token strings.
             */
            if (idx < idxMin)
                idxMin = idx;
        }

        /*
         *  Return the minimum token rules position index,
         *  or nil if no appropriate position was found.
         */
        return idxMin;
    }

    /*
     *  Returns the token rule index for the first location
     *  in which our new token rule has correctly tokenized
     *  the token string. If no location in the rules was
     *  found, then nil is returned.
     */
    getTokRuleIndex(newTokRule, tokStr)
    {
        local tokType, newTokType, rules;

        rules = cmdTokenizer.rules_;
        
        // assign to the new token type for the new token rule
        newTokType = newTokRule[3];

        /*
         *  We iterate backward through the rules until 
         *  the tokenizer returns our new token type, at
         *  which point we return the position in which 
         *  tokenizing was successful.
         */
        for (local idx = rules.length() + 1; idx > 0; --idx)
        {
            // insert the new token rule into the rules list
            rules = rules.insertAt(idx, newTokRule);

            // assign the rules to the tokenizer
            cmdTokenizer.rules_ = rules;

            // get the token type for the tokStr
            tokType = getTokenType(tokStr);

            /*
             *  If our tok type matches the new tok type
             *  we'll return the index for its location 
             *  in the rules list.
             */
            if (tokType == newTokType)
                return idx;
        }

        /*
         *  Our new token rule never matched the token 
         *  string, we return nil.
         */
        return nil;
    }

    /*
     *  Get the token type for this token string 
     *  from the command tokenizer.
     */
    getTokenType(tokStr)
    {
        local toks;

        try
        {
            toks = cmdTokenizer.tokenize(tokStr);
            /*
             *  Since we're interested in a single token string
             *  value, our token list returned from the tokenizer
             *  should have only 1 element. If so we return the 
             *  element's token value.
             *
             *  Otherwise we have successfully tokenized the string,
             *  but not to a single token type, so we consider this
             *  a failure.
             */
            if (toks.length() == 1)
                return toks[1][2];
            else
                return nil;
        }
        catch (TokErrorNoMatch tokExc)
        {
            /*
             *  We didn't even manage to tokenize the string, 
             *  so we return nil.
             */
            return nil;
        }
    }
}

/*
 *  Updates token rules for the command tokenizer for
 *  each TokenRuleObject instance.
 */
tokSyncPreinit: PreinitObject
{
    execute()
    {
        local idx, objList = [];

        /*
         *  Iterate over every TokenRuleObject testing 
         *  for update.
         */
        for (local o = firstObj(TokenRuleObject); o != nil; o = nextObj(o, TokenRuleObject))
        {
            idx = TokenRuleSynchronizer.testTokRuleForUpdate(o);
            if (idx == nil)
                throw new NoRuleMatchTokenRuleObjectError(o);

            objList += o;
        }
        /*
         *  Iterate over every TokenRuleObject testing
         *  to see if it's still valid after we've updated
         *  the tokenizer's rules.
         */
        for (local i = 1; i <= objList.length(); ++i)
        {
            local o;

            o = objList[i];

            idx = TokenRuleSynchronizer.testTokRule(o);

            if (idx == nil)
                throw new NoRuleMatchTokenRuleObjectError(o);
        }
    }
}

/* base class for token rul object errors */
class TokenRuleObjectError: RuntimeError
{
    construct(tro)
    {
        // pass zero as the errno.
        inherited(0);

        exceptionMessage += tro.getTokenRuleName();
        
    }
}

/*
 *  No match detected for this token rule object error.
 */
class NoRuleMatchTokenRuleObjectError: TokenRuleObjectError
{
    exceptionMessage = 'No matching token rule: '
}

/*
 *  No match detected for this string element of 
 *  this token rule object error.
 */
class NoStrMatchTokenRuleObjectError: TokenRuleObjectError
{
    exceptionMessage = 'No matching token rule: '

    construct(tro, tokStr)
    {
        inherited(tro);

        exceptionMessage += (' string: ' + tokStr);
    }
}

/*
 *  No token strings elements for this token rule object error.
 */
class NoTokStrTokenRuleObjectError: TokenRuleObjectError
{
    exceptionMessage = 'No token string elements for token rule: '
}