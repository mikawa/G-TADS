#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_bigben.t
 */

/* include the TimeSys header file */
#include "timesys.h"

/*
 *  Simulates announcement and behaviors *similar* to that
 *  of "Big Ben" in Infocom's "Sherlock: The Riddle of the 
 *  Crown Jewels"
 */
class TimeSysBigBenDaemon: TimeSysIdxEventMixIn, DateTimeDaemon
{
    eventMsg = 
        [
        'In the distance, you hear Big Ben strike the hour. ',
        'While you wait, you hear Big Ben strike the hour. ',
        'While you wait, you hear Big Ben strike each hour. '
        ]

    construct(queryActor)
    {
        local minPerHour, interval, year, month, day, hour, minute, second;
        local diff, savWc, jdn, clockRatio, timeVals, dateVals;

        /*
         *  Compute the number of minutes past the hour for
         *  the current time.
         */
        minPerHour  = toInteger(gWallClock.getClock().minutesPerHour);
        jdn         = gWallClock.getCurrJdn();
        clockRatio  = gWallClock.getCurrClockRatio();
        timeVals    = gWallClock.getTimeVals(clockRatio);
        minute      = timeVals[2];
        diff        = minPerHour - minute;

        /*
         *  Save a clone of the current wall clock
         */
        savWc       = gWallClock.createClone();
        gWallClock.addToTime(0, 0, diff, 0);
        jdn         = gWallClock.getCurrJdn();
        clockRatio  = gWallClock.getCurrClockRatio();
        dateVals    = gWallClock.getDateVals(jdn);
        timeVals    = gWallClock.getTimeVals(clockRatio);
        year        = toInteger(dateVals[1]);
        month       = toInteger(dateVals[2]);
        day         = toInteger(dateVals[3]);
        hour        = timeVals[1];
        minute      = timeVals[2];
        second      = timeVals[3];
        interval    = 1;

        /*
         *  Restore the wall clock value
         */
        gWallClock  = savWc;

        inherited(self, &doEvents, year, month, day, hour, minute, 
            second, interval, queryActor);

        /*
         *  set the interval for the daemon to the the 
         *  minutes per hour value
         */
        interval_   = minPerHour;
    }

    doEvent1()
    {
        say(eventMsg[1]);
    }
    doEvent3()
    {
        say(eventMsg[2]);
    }
    doEvent4()
    {
        say(eventMsg[3]);
    }
}