#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_status.t
 *
 *  Modifications to adv3 status.t
 */

/* include the TimeSys header file */
#include "timesys.h"

/* change the status line to display date / time */
modify statusLine
{
    replace showStatusHtml()
    {
        /* hyperlink the location name to a "look around" command */
        "<a plain href='<<libMessages.commandLookAround>>'>";
            
        /* show the left part of the status line */
        showStatusLeft();
            
        "</a>";

        /* show the date time in the center */
        "<tab align=center><a plain
            href='<<libMessages.commandFullDateTime>>'>";

        showStatusCenter();

        "</a>";

        /* set up for the score part on the right half */
        "<tab align=right><a plain
            href='<<libMessages.commandFullScore>>'>";
        
        /* show the right part of the status line */
        showStatusRight();
        
        /* end the score link */
        "</a>";
        
        /* add the status-line exit list, if desired */
        if (gPlayerChar.location != nil)
            gPlayerChar.location.showStatuslineExits();
    }

    showStatusCenter()
    {
        "<<gWallClock.getCurrDateTimeString()>>";
    }

    replace showStatusRight()
    {
        local s;

        /* show the time and score */
        if ((s = libGlobal.scoreObj) != nil)
        {
            "<.statusscore>Score:\t<<s.totalScore>><./statusscore>";
        }
    }
}