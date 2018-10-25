#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_track_actions.t
 *
 *  The ts_actions module contains the action classes required by 
 *  the system. 
 */

#include "timesys.h"

/*
 *  An Action class for displaying the date and time as issued as 
 *  a player command. This facilitates cases where no status line
 *  is used.
 */
class TimeAction: SystemAction
{
    execSystemAction()
    {
        say(gWallClock.getCurrDateTimeString());
    }
    includeInUndo = nil
}