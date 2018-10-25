#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_actions.t
 *
 *  The ts_actions module contains the action classes required by 
 *  the system. 
 */

#include "timesys.h"

/*
 *  An Action class for Waiting a specified amount of time. This class
 *  is a Continuous Action. If waiting is not completed or terminated, 
 *  the action will be placed into the actor's command queue until 
 *  it is. 
 */
class WaitTimeAction: ContIAction
{
    endGameClockTime_       = nil
    startGameClockTime_     = nil
    actionState             = WaitingActorState

    getIncrMinutes()
    {
        return timeMatch.getIncrMinutes();
    }

    execActionInitial()
    {
            local incrAmt;

            // calculate the wait time increment
            incrAmt = getIncrMinutes();

            // set the end game clock time
            setWaitTimes(incrAmt);

            // Display "time passes" message
            defaultReport(&timePassesMsg);
    }

    setWaitTimes(incrAmt)
    {
        local incrGctuAmt;

        incrGctuAmt = gWallClock.cvtMinToGctu(incrAmt);
            
        startGameClockTime_    = Schedulable.gameClockTime;

        endGameClockTime_      = toInteger(incrGctuAmt 
                                    + startGameClockTime_);
    }

    // Everything is done during execActionInitial
    execAction() {}

    // Nothing special to do on completion
    execActionCompleted() {}
   
    // Nothing special to do on interruption
    execActionInterrupted(issuingActor, actor) {}

    /* 
     *   The Action is completed when our computed end game clock time 
     *   (minus 1 turn) is less than or equal to the game clock time.
     */
    checkActionCompleted()
    {
        // return (endGameClockTime_ - 1 <= Schedulable.gameClockTime);
        return (gActor.nextRunTime >= endGameClockTime_);
    }

    interruptedContActionMain(issuingActor, targetActor)
    {
        inherited(issuingActor, targetActor);

        /*
         *  Interrupted commands don't increment the 
         *  actor's next run time 
         */
        targetActor.nextRunTime = Schedulable.gameClockTime + actionTime;
    }
}