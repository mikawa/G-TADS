#charset "latin1"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of TIMESYS, a TADS 3 Library Extension Package
 *
 *  ts_actions_en_us.t
 *
 *  Modifications to adv3 en_us
 *
 *  The TS_ACTIONS_EN_US module isolates english representations of date and
 *  time, as well as names for months and days.
 */

#include "timesys.h"
#include "ts_actions_de_de.h"

timeSysTokenRuleObject: TokenRuleObject
{
    tokRexPat_  = new RexPattern('(<Digit>?<Digit>):(<Digit><Digit>)(<NoCase><space>*(am|pm|a.m|p.m|a|p))?')    
    tokRule_    = ['timeSysTokenRuleObject', tokRexPat_, tokTime, nil, nil]
    tokStrList_ = ['5:00', '17:00', '3:00 pm', '3:00 p.m', '12:00 a.m']
}

modify WallClock
{
    /* post meridiem search string */
    pmStr = '(pm|p.m.|p)'
}


/* ------------------------------------------------------------------------ */
/*
 *   Grammar Rules 
 */

grammar timePhrase(conjunctionTimePhrase): 
    timeHrPhrase->timePhrase1_ (',' | 'und') timeMinPhrase->timePhrase2_
    : object
    getIncrMinutes()
    {
        return timePhrase1_.getIncrMinutes() + timePhrase2_.getIncrMinutes();
    }
;

grammar timePhrase(timePhrase): timeHrPhrase->timePhrase_ 
    | timeMinPhrase->timePhrase_ 
    | time2400Phrase->timePhrase_
    | timeMidnightPhrase->timePhrase_
    | timeNoonPhrase->timePhrase_
    : object
    getIncrMinutes()
    {
        return timePhrase_.getIncrMinutes();
    }
;

grammar timeMidnightPhrase(midnight): 'mitternacht'
    : object
    getIncrMinutes()
    {
        local incrAmt, startTime, endTime;

        startTime   = gWallClock.getCurrClockRatio();
                
        endTime     = gWallClock.getClock().toClockRatio(0,0,0);
            
        incrAmt = new BigNumber(1) + (endTime - startTime); 

        incrAmt *= gWallClock.getClock().secondsPerDay_;

        incrAmt /= gWallClock.getClock().secondsPerMinute;

        return toInteger(incrAmt);
    }
;

grammar timeNoonPhrase(noon): 'mittag'
    : object
    getIncrMinutes()
    {
        local incrAmt, startTime, endTime, noonHours;

        startTime   = gWallClock.getCurrClockRatio();

        noonHours   = gWallClock.getClock().noonHours_;
                
        endTime     = gWallClock.getClock().toClockRatio(noonHours,0,0);
            
        incrAmt = endTime - startTime;

        if (incrAmt.roundToDecimal(5) <= 0)
            incrAmt = new BigNumber(1) + incrAmt;

        incrAmt *= gWallClock.getClock().secondsPerDay_;

        incrAmt /= gWallClock.getClock().secondsPerMinute;

        return toInteger(incrAmt);
    }
;


grammar time2400Phrase(time2400): tokTime->time_
    : object
    getIncrMinutes()
    {
        local match, hh, mm;
        local incrAmt, startTime, endTime, ampm;
        local noon, noonHours;

        startTime = gWallClock.getCurrClockRatio();
        
        match   = rexSearch(timeSysTokenRuleObject.tokRexPat_, time_);

        if (match == nil)
            return 0;

        hh          = toInteger(rexGroup(1)[3]);
        mm          = toInteger(rexGroup(2)[3]);

        endTime     = gWallClock.getClock().toClockRatio(hh,mm,0);

        noonHours   = gWallClock.getClock().noonHours_;

        noon        = gWallClock.getClock().toClockRatio(noonHours,0,0);
        
        if (rexGroup(4))
        {
            ampm = rexGroup(4)[3];

            if (rexSearch(gWallClock.pmStr, ampm))
            {
                /* adjust 12:00 p.m. - 12:59 p.m. */
                if (Clock.compareRatios(endTime, noon) < 0)
                //if (endTime.roundToDecimal(5) < noon.roundToDecimal(5))
                    endTime += noon;
            }
            else
            {
                /* adjust 12:00 a.m. - 12:59 a.m. */
                if (Clock.compareRatios(endTime, noon) >= 0)
                //if (endTime.roundToDecimal(5) >= noon.roundToDecimal(5))
                    endTime -= noon;
            }
        }

        if (ampm == nil)
        {
            if (Clock.compareRatios(startTime, noon) < 0)
            //if (startTime.roundToDecimal(5) < noon.roundToDecimal(5))
            {
                if (Clock.compareRatios(startTime, endTime) >= 0)
                //if (startTime.roundToDecimal(5) >= endTime.roundToDecimal(5))
                    endTime += noon;
            }
            else
            {
                if (Clock.compareRatios(startTime, (endTime + noon)) < 0)
                //if (startTime.roundToDecimal(5) < (endTime + noon).roundToDecimal(5))
                    endTime += noon;
            }
        }
        
        endTime = endTime.getFraction();
        
        incrAmt = endTime - startTime;

        if (Clock.compareRatios(incrAmt, 0) <= 0)
        //if (incrAmt.roundToDecimal(5) <= 0)
            incrAmt = new BigNumber(1) + incrAmt;

        incrAmt *= gWallClock.getClock().secondsPerDay_;

        incrAmt /= gWallClock.getClock().secondsPerMinute;

        return toInteger(incrAmt);
    }
;

grammar timeHrPhrase(hour): tokInt->hr_ ('stunde')
    : object
    getIncrMinutes()
    {
        return toInteger(hr_) * gWallClock.getClock().minutesPerHour;
    }
;

grammar timeMinPhrase(minute): tokInt->mm_ 
    | tokInt->mm_ ('minute')
    : object
    getIncrMinutes()
    {
        return toInteger(mm_);
    }
;

/* ------------------------------------------------------------------------ */
/*
 *   Verbs.
 *   
 *   The actual body of each of our verbs is defined in the main
 *   language-independent part of the library extension.  We only 
 *   define the language-specific grammar rules here.  
 */

VerbRule(WaitTime)
    (('z' | 'wart') | ('z' | 'wart') 'bis') singleTime
    : WaitTimeAction
    verbPhrase = 'zu warten/warten (wie lange)'
;