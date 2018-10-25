#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 TimeSys Library Extension
 *
 *  ts_actions_actor.t
 *
 *  Modifications to adv3 actor.t
 *  and definitions of TimeSys actor states. 
 */

#include "timesys.h"

modify Actor
{
    stopWaiting(issuingActor, queryActor)
    {
        return issueContActionInterrupt(issuingActor, WaitTimeAction, 
            queryActor);
    }
}

class WaitingReadyActorState: ActorState
{
    obeyCommand(issuingActor, action) { return true; }
}

class WaitingActorState: ContActorState
{
    stateDesc = "<<location.derName>> {wartet}{*}. "
    specialDesc = "<<location.derName>> is here. He appears to be 
        waiting for something to happen. "

    obeyCommand(issuingActor, action)
    {
        /* show our standard "no response" message */
        noResponse();
        return nil;
    }
}