#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_misc.t
 *
 *  Modifications to adv3 misc.t
 *  and TimeSys library preinit objects.
 */

/* include the TimeSys header file */
#include "timesys.h"

/* add a reference to the game's wallclock */
modify libGlobal
{
    wallClock = nil
}

/* Creates an instance of WallClock to be used by the game */
PreinitObject
{
    execute()
    {
        gWallClock = new WallClock();
    }
}