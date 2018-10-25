#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_track_events.t
 *
 *  Modificatins to adv3 events.t 
 *  and definitions of TimeSys Event classes.
 */

/* include the TimeSys header file */
#include "timesys.h"

/*
 *  Synchronize the global wall clock with
 *  the Schedulable game clock.
 */
replace runScheduler()
{
    /* keep going until we quit the game */
    for (;;)
    {
        /* catch the exceptions that terminate the game */
        try
        {
            local minTime;
            local vec;

            /* start with an empty list of schedulable items */
            vec = new Vector(10);

            /* find the lowest time at which something is ready to run */
            minTime = nil;
            foreach (local cur in Schedulable.allSchedulables)
            {
                local curTime;

                /* get this item's next eligible run time */
                curTime = cur.getNextRunTime();

                /* 
                 *   if it's not nil, and it's equal to or below the
                 *   lowest we've seen so far, note it 
                 */
                if (curTime != nil && (minTime == nil || curTime <= minTime))
                {
                    /* 
                     *   if this is different from the current minimum
                     *   schedulable time, clear out the list of
                     *   schedulables, because the list keeps track of the
                     *   items at the lowest time only 
                     */
                    if (minTime != nil && curTime < minTime)
                        vec.removeRange(1, vec.length());

                    /* add this item to the list */
                    vec.append(cur);

                    /* note the new lowest schedulable time */
                    minTime = curTime;
                }
            }

            /* 
             *   if nothing's ready to run, the game is over by default,
             *   since we cannot escape this state - we can't ourselves
             *   change anything's run time, so if nothing's ready to run
             *   now, we won't be able to change that, and so nothing will
             *   ever be ready to run 
             */
            if (minTime == nil)
            {
                "\b[Error: nothing is available for scheduling -
                terminating]\b";
                return;
            }

            /* 
             *   advance the global turn counter by the amount of game
             *   clock time we're consuming now 
             */
            libGlobal.totalTurns += minTime - Schedulable.gameClockTime;

            /* 
             *   advance the game clock to the minimum run time - nothing
             *   interesting happens in game time until then, so we can
             *   skip straight ahead to this time 
             */
            Schedulable.gameClockTime = minTime;

            /*
             *  Synchronize the game's timepieces
             *  with the schedulable game clock.
             */
            setAllTimePieces(minTime);

            /* calculate the schedule order for each item */
            vec.forEach({x: x.calcScheduleOrder()});

            /*
             *   We have a list of everything schedulable at the current
             *   game clock time.  Sort the list in ascending scheduling
             *   order, so that the higher priority items come first in
             *   the list.  
             */
            vec = vec.sort(
                SortAsc, {a, b: a.scheduleOrder - b.scheduleOrder});

            /*
             *   Run through the list and run each item.  Keep running
             *   each item as long as it's ready to run - that is, as long
             *   as its schedulable time equals the game clock time.  
             */
        vecLoop:
            foreach (local cur in vec)
            {
                /* run this item for as long as it's ready to run */
                while (cur.getNextRunTime() == minTime)
                {
                    /* 
                     *   execute this item - if it doesn't want to be
                     *   called again without considering other objects,
                     *   stop looping and refigure the scheduling order
                     *   from scratch 
                     */
                    if (!cur.executeTurn())
                        break vecLoop;
                }
            }
        }
        catch (EndOfFileException eofExc)
        {
            /* end of file reading command input - we're done */
            return;
        }
        catch (QuittingException quitExc)
        {
            /* explicitly quitting - we're done */
            return;
        }
        catch (RestartSignal rsSig)
        {
            /* 
             *   explicitly restarting - re-throw the signal for handling
             *   in the system startup code 
             */
            throw rsSig;
        }
        catch (RuntimeError rtErr)
        {
            /* if this is a debugger error of some kind, re-throw it */
            if (rtErr.isDebuggerSignal)
                throw rtErr;
            
            /* display the error, but keep going */
            "\b[<<rtErr.displayException()>>]\b";
        }
        catch (TerminateCommandException tce)
        {
            /* 
             *   Aborted command - ignore it.  This is most like to occur
             *   when a fuse, daemon, or the like tries to terminate itself
             *   with this exception, thinking it's operating in a normal
             *   command execution environment.  As a convenience, simply
             *   ignore these exceptions so that any code can use them to
             *   abort everything and return to the main scheduling loop. 
             */
        }
        catch (ExitSignal es)
        {
            /* ignore this, just as we ignore TerminateCommandException */
        }
        catch (ExitActionSignal eas)
        {
            /* ignore this, just as we ignore TerminateCommandException */
        }
        catch (Exception exc)
        {
            /* some other unhandled exception - display it and keep going */
            "\b[Unhandled exception: <<exc.displayException()>>]\b";
        }
    }
}

/*
 *  Synchronize all of the game's TimePiece objects
 */
setAllTimePieces(gctu)
{
    forEachInstance(TimePiece, 
        {x: x.setCurrDateTime(gctu)}
    );
}
