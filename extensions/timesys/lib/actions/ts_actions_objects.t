#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_actions_objects.t
 */

/* include the TimeSys header file */
#include "timesys.h"

modify WallClock
{
    addDateTimeToTime(dt)
    {
        gWallClock = inherited(dt);
        statusLine.showStatusLine();
    }
    subtractDateTimeFromTime(dt)
    {
        gWallClock = inherited(dt);
        statusLine.showStatusLine();
    }
}

modify TimePiece
{
    /*
     *  Returns the corresponding datetime value for the 
     *  days, hours, minutes, seconds passed. If passed an
     *  Action's actionTime value then this will be converted
     *  to seconds and added to the datetime computation.
     */
    cvtValsToDateTime(days, hours, minutes, seconds, [actionTime])
    {
        local dt;

        if (actionTime.length() > 0)
            seconds += toInteger(getTimeRate() * actionTime.car() 
            * getClock().secondsPerMinute);

        hours += getClock().hoursPerDay * days;

        dt = getClock().toDateTime(hours, minutes, seconds);

        return dt;
    }

    /*
     *  Creates a clone of this timepiece then
     *  adds the corresponding days, hours, minutes, and
     *  seconds to the clone's initial datetime value (zero-
     *  point). Automatically adjusts for an Action's actionTime.
     *  Returns the clone.
     */
    addToTime(days, hours, minutes, seconds)
    {
        local dt, actionTime = 0;

        if (gAction != nil)
            actionTime = (gAction.actionTime * -1);

        dt = cvtValsToDateTime(days, hours, minutes, seconds, actionTime);
        
        return addDateTimeToTime(dt);
    }

    /*
     *  Creates a clone of this timepiece then
     *  subtracts the corresponding days, hours, minutes, and
     *  seconds from the clone's initial datetime value (zero-
     *  point). Automatically adjusts for an Action's actionTime.
     *  Returns the clone.
     */
    subtractFromTime(days, hours, minutes, seconds)
    {
        local dt, actionTime = 0;

        if (gAction != nil)
            actionTime = gAction.actionTime;

        dt = cvtValsToDateTime(days, hours, minutes, seconds, actionTime);
        
        return subtractDateTimeFromTime(dt);
    }

    /*
     *  Creates a clone of this timepiece then
     *  adds the datetime argument to the clone's 
     *  initial datetime value (zero-point).
     *  Returns the clone.
     */
    addDateTimeToTime(dt)
    {
        local clone, tot, calendarParms = [], clockParms = [];

        clone = createClone();

        tot = clone.initDateTime_ + dt;

        calendarParms += clone.getCalendar();
        calendarParms += clone.getCalendar().toDate(tot.getWhole());

        clockParms += clone.getClock();
        clockParms += clone.getClock().toTime(tot.getFraction());

        clone.setInitDateTime(calendarParms, clockParms);
        clone.setCurrDateTime(Schedulable.gameClockTime);

        return clone;
    }

    /*
     *  Creates a clone of this timepiece then
     *  subtracts the datetime argument from the clone's 
     *  initial datetime value (zero-point). 
     *  Returns the clone.
     */
    subtractDateTimeFromTime(dt)
    {
        local clone, tot, calendarParms = [], clockParms = [];

        clone = createClone();

        tot = clone.initDateTime_ - dt;

        calendarParms += clone.getCalendar();
        calendarParms += clone.getCalendar().toDate(tot.getWhole());

        clockParms += clone.getClock();
        clockParms += clone.getClock().toTime(tot.getFraction());

        clone.setInitDateTime(calendarParms, clockParms);
        clone.setCurrDateTime(Schedulable.gameClockTime);

        return clone;
    }
}

modify Clock
{
    compareRatios(startClockRatio, endClockRatio)
    {
        if (dataType(startClockRatio) == TypeInt)
            startClockRatio = new BigNumber(startClockRatio);

        if (dataType(endClockRatio) == TypeInt)
            endClockRatio = new BigNumber(endClockRatio);

        if (startClockRatio.roundToDecimal(5) < endClockRatio.roundToDecimal(5))
            return -1;
        else if (startClockRatio.roundToDecimal(5) > endClockRatio.roundToDecimal(5))
            return 1;
        else 
            return 0;
    }
}