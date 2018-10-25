#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_events_objects.t
 */

/* include the TimeSys header file */
#include "timesys.h"

modify Actor
{
    /*
     *  This function advances the busy time for the actor the 
     *  given number of days, hours, minutes, and seconds, adjusting
     *  for the action's actionTime.
     */
    advanceBusyTime(action, days, hours, minutes, seconds)
    {
        local tp, gctu;

        tp      = gWallClock.addToTime(days, hours, minutes, seconds);
        gctu    = tp.cvtCurrDtToGctu() - action.actionTime;
        addBusyTime(action, gctu);
    }
}

/*
 *  Provides Auxiliary TimePiece methods for TimeSys Events.
 */
modify TimePiece
{
    /*
     *  Returns the timepiece's initial date / time value list.
     */
    getInitDateTimeVals()
    {
        return getDateTimeVals(getInitJdn(), getInitClockRatio());
    }

    /*
     *  Returns the timepiece's current date / time value list.
     */
    getCurrDateTimeVals()
    {
        return getDateTimeVals(getCurrJdn(), getCurrClockRatio());
    }

    /*
     *  Returns the timepiece's date / time value list
     *  for the given julian day number and clock ratio.
     */
    getDateTimeVals(jdn, clockRatio)
    {
        local lst;

        lst = getDateVals(jdn);
        lst += getTimeVals(clockRatio);

        return lst;
    }

    /*
     *  Returns the game clock time unit associated 
     *  with the difference between a begining and 
     *  ending datetime
     */
    cvtDtToGctu(beginDt, endDt)
    {
        local dt, totMin, gctu;

        dt          = endDt - beginDt;

        totMin      = getClock().toMinutes(dt);
        
        gctu        = cvtMinToGctu(totMin);

        return toInteger(gctu);                 
    }

    /*
     *  Returns the game clock time unit associated 
     *  with the difference between the initial datetime
     *  and current datetime.
     */
    cvtCurrDtToGctu()
    {
        return cvtDtToGctu(initDateTime_, currDateTime_);
    }
}

/*
 *  Provides auxiliary Clock methods for TimeSys Events.
 */
modify Clock
{
    toSeconds(dt)
    {
        local jdn, clockRatio, tList, hour, minute, second;

        jdn         = dt.getWhole();
        second      = jdn * secondsPerDay_;

        clockRatio  = dt.getFraction();
        tList       = toTime(clockRatio);
        hour        = tList[1];
        minute      = tList[2];
        second      += tList[3];

        minute += (hour * minutesPerHour);
        second += (minute * secondsPerMinute);

        return second;
    }
    toMinutes(dt)
    {
        local second;

        second = toSeconds(dt);
        return (second / secondsPerMinute).getWhole();
    }
    toHours(dt)
    {
        local minute;

        minute = toMinutes(dt);
        return (minute / minutesPerHour).getWhole();
    }
    secondsToNxtClockRatio(startClockRatio, endClockRatio)
    {
        local val, d, seconds;

        val = compareRatios(startClockRatio, endClockRatio);

        switch(val)
        {
            case 0: // start == end
                return new BigNumber(secondsPerDay_);

            case -1:    // start < end
                d = endClockRatio - startClockRatio;
                break;

            case 1: // start > end
                d = new BigNumber(1) - (endClockRatio - startClockRatio);
                break;              
        }
        seconds = toSeconds(d);

        return seconds;
    }
    minutesToNxtClockRatio(startClockRatio, endClockRatio)
    {
        local seconds;

        seconds = secondsToNxtClockRatio(startClockRatio, endClockRatio);

        return (seconds / secondsPerMinute).getWhole();
    }
    hoursToNxtClockRatio(startClockRatio, endClockRatio)
    {
        local minutes;

        minutes = minutesToNxtClockRatio(startClockRatio, endClockRatio);

        return (minutes / minutesPerHour).getWhole();
    }
}