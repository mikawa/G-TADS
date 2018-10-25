#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  timesys.h
 *
 *  The TimeSys header file.
 */

 #ifndef    TIME_SYS_H
 #define    TIME_SYS_H

#include <adv3.h>
#include <bignum.h>

/* The game's gameClock / wallClock conversion object */
#define gWallClock (libGlobal.wallClock)

/* define a token for time */
enum token tokTime;

/* macros for simplifying BigNumber calculations */
#define INT(x) ((x).getFloor())

#define FIX(x) ((x).getWhole())

#define advPcBusyTime(days, hours, minutes, seconds) \
    gActor.advanceBusyTime(gAction, days, hours, minutes, seconds)

#endif  /* TIME_SYS_H */