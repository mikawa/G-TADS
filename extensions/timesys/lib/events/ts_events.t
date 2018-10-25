#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_events.t
 *
 *  Definitions of TimeSys Event classes.
 */

/* include the TimeSys header file */
#include "timesys.h"

/*
 *  Computes an event turns for timesys fuses from the 
 *  current datetime to the datetime computed from the date
 *  and time arguments. If the 
 */
computeTimeSysEventTurns(year, month, day, hour, minute, second)
{
    local currDt, nxtDt, totDt, totMin, gctu;

    /* initialize game clock time units to 0 */
    gctu    = 0;

    /* compute the current datetime from the game wallclock */
    currDt  = gWallClock.getCurrDateTime();

    /* compute the next datetime from the game wallclock */
    nxtDt   = gWallClock.getDateTime(year, month, day, 
        hour, minute, second);

    /* 
     *  only queue the fuse if the date is >= the
     *  current date. If the date is less than the
     *  current date the fuse is simply left 
     *  unreferenced and can be garbage collected.
     */
    if (gWallClock.getClock().compareRatios(nxtDt, currDt) > 0)
    {
        totDt   = nxtDt - currDt;
        totMin  = gWallClock.getClock().toMinutes(totDt);
        gctu    = gWallClock.cvtMinToGctu(totMin);
        gctu    = toInteger(gctu);

        gctu--;
    }

    return gctu;
}

/*
 *  Computes an event interval for timesys fuses from the 
 *  current datetime to the datetime computed from the date
 *  and time arguments. If the 
 */
computeTimeSysEventInterval(year, month, day, hour, minute, second)
{
    local gctu;

    gctu = computeTimeSysEventTurns(year, month, day, hour, minute, 
        second) + 1;

    return gctu;
}

/*
 *  A mix-in class for TimeSysEvents. This 
 *  handles properties common to all TimeSys
 *  Events, and synchronizes timepieces to the
 *  "relativistic" viewpoint of the actor_ 
 *  property.
 */
class TimeSysEventMixIn: ContActEventMixIn
{
    lastStartGctu_  = nil
    lastEndGctu_    = nil
    muteEventMsgs_  = nil

    callMethod()
    {
        /*
         *  Synchronize all game timepieces to the
         *  "relative" time of the next run time of 
         *  the actor we are asking the continuous
         *  action interrupt for. This let's us accurately
         *  reflect the time of the actor's next command
         *  execution.
         */
        setAllTimePieces(actor_.nextRunTime);

        try
        {
            inherited();
        }
        finally
        {
            local action;

            /*
             *  Save the pertinent characteristics
             *  of the last pending continuous action
             *  (WaitTimeAction) so that we can compare
             *  subsequent continuous actions to it.
             */
            action = getActorContActPending();
            if (action)
                saveWaitActGctu(action);

            /* 
             *  reset the game timepices to the "absolute"
             *  time of the Schedulable game clock.
             */
            setAllTimePieces(Schedulable.gameClockTime);
        }
    }

    /*
     *  If actor_ is waiting this method returns a list
     *  consisting of the following elements:
     *
     *      lst[1] = game wallclock gctu
     *      lst[3] = actor's wait action start gctu
     *      lst[3] = actor's wait action end gctu
     *      lst[4] = event cycle's remaining for actor's wait period
     *      lst[5] = actor's wait period turns remaining after last 
     *               event cycle
     *      lst[6] = whether the action is a equiv wait action
     *      lst[7] = whether the action is an expired 
     *               (completed/terminated) wait action.
     *
     *  If the actor_ is not performing a waiting periodthe 
     *  method returns nil.
     */ 
    getActorWaitEventVals()
    {
         local action, startGctu, endGctu, diff, div, mod;
         local currDt, initDt, currGctu, gctuLst, exp;

        /* get the active pending continuous action */
        action = actor_.getPendContActionFor(WaitTimeAction)[3];
        
        /*
         *  if there's no pending continuous action
         *  we get the expired continuous action, if
         *  there is one.
         */
        if (action == nil)
        {
            action = actor_.getExpContActionFor(WaitTimeAction);
            exp = true;
        }

        if (action != nil)
        {
            startGctu   = action.startGameClockTime_;
            endGctu     = action.endGameClockTime_;

            currDt      = gWallClock.getCurrDateTime();
            initDt      = gWallClock.getInitDateTime();
            currGctu    = gWallClock.cvtDtToGctu(initDt, currDt);

            if (interval_)
            {
                diff        = endGctu - currGctu;
                div         = diff / interval_;
                mod         = diff % interval_;
            }

            gctuLst = [currGctu, startGctu, endGctu, div, mod, 
                isEquivWaitAction(action), exp];
        }

        return gctuLst;
    }

    saveWaitActGctu(action)
    {
        lastStartGctu_  = action.startGameClockTime_;
        lastEndGctu_    = action.endGameClockTime_;
    }

    /*
     *  Returns true if the current action is an equivalent 
     *  action of the same continuous waiting action. Otherwise
     *  returns nil.
     */
    isEquivWaitAction(action)
    {
        local currStartGctu, currEndGctu;

        if (action == nil)
            return nil;

        currStartGctu   = action.startGameClockTime_;
        currEndGctu     = action.endGameClockTime_;

        if (nil is in (currStartGctu, currEndGctu, lastStartGctu_, 
            lastEndGctu_))
            return nil;

        if (currStartGctu != lastStartGctu_
            || currEndGctu != lastEndGctu_)
            return nil;

        return true;
    }

    /*
     *  If we have redirected display messages to the event
     *  object then we can check to see if they are to be 
     *  muted. If so then we don't display anything; otherwise
     *  we'll display them using the say() funciton.
     */
    tsDispMethod(val)
    {
        if (!muteEventMsgs_)
            say(val);
    }
}

/*
 *  DateTimeFuse.  A fuse is an event that fires once at a 
 *  given date and time in the future.  Once a fuse is executed, 
 *  it is removed from further scheduling.  
 *
 *  DateTimeEventFuses are executed when the WallClock reaches the 
 *  corresponding date and time.
 */
class DateTimeFuse: TimeSysEventMixIn, ContActFuse
{        
    construct(obj, prop, year, month, day, hour, minute, second, 
        queryActor)
    {
        local turns;

        turns = computeTimeSysEventTurns(year, month, day, hour, 
            minute, second);

        if (turns)
            inherited(obj, prop, turns, gPlayerChar, WaitTimeAction, 
                queryActor);
    }
}

/*
 *  Sensory-context-sensitive date time event fuse - this is a fuse 
 *  with an explicit sensory context.  We'll run the fuse in its 
 *  sense context, so any messages generated will be visible only 
 *  if the given source object is reachable by the player character 
 *  in the given sense.
 *   
 *   Conceptually, the source object is considered the source of any
 *   messages that the fuse generates, and the messages pertain to the
 *   given sense; so if the player character cannot sense the source
 *   object in the given sense, the messages should not be displayed.  For
 *   example, if the fuse will describe the noise made by an alarm clock
 *   when the alarm goes off, the source object would be the alarm clock
 *   and the sense would be sound; this way, if the player character isn't
 *   in hearing range of the alarm clock when the alarm goes off, we won't
 *   display messages about the alarm noise.  
 */
class SenseDateTimeFuse: DateTimeFuse
{
    construct(obj, prop, year, month, day, hour, minute, second,
        queryActor, source, sense)
    {
        /* inherit the base constructor */
        inherited(obj, prop, year, month, day, hour, minute, 
            second, queryActor);
        
        /* remember our sensory context */
        source_     = source;
        sense_      = sense;    
    }
}

/*
 *  ClockTimeFuse.  A fuse is an event that fires once at a 
 *  given time in the future.  Once a fuse is executed, 
 *  it is removed from further scheduling.  
 *
 *  TimeFuses are executed when the WallClock reaches the 
 *  corresponding future time.
 */
class ClockTimeFuse: DateTimeFuse
{
    construct(obj, prop, hour, minute, second, queryActor)
    {
        local lst, year, month, day;

        lst     = gWallClock.getCurrDateTimeVals();
        year    = toInteger(lst[1]);
        month   = toInteger(lst[2]);
        day     = toInteger(lst[3]);

        inherited(obj, prop, year, month, day, hour, 
            minute, second, queryActor);
    }
}

/*
 *  Sensory-context-sensitive time event fuse - this is a fuse 
 *  with an explicit sensory context.  We'll run the fuse in its 
 *  sense context, so any messages generated will be visible only 
 *  if the given source object is reachable by the player character 
 *  in the given sense.
 *   
 *   Conceptually, the source object is considered the source of any
 *   messages that the fuse generates, and the messages pertain to the
 *   given sense; so if the player character cannot sense the source
 *   object in the given sense, the messages should not be displayed.  For
 *   example, if the fuse will describe the noise made by an alarm clock
 *   when the alarm goes off, the source object would be the alarm clock
 *   and the sense would be sound; this way, if the player character isn't
 *   in hearing range of the alarm clock when the alarm goes off, we won't
 *   display messages about the alarm noise.  
 */
class SenseClockTimeFuse: ClockTimeFuse
{
    construct(obj, prop, hour, minute, second, queryActor, source, sense)
    {
        /* inherit the base constructor */
        inherited(obj, prop, hour, minute, second, queryActor);

        /* remember our sensory context */
        source_     = source;
        sense_      = sense;
    }
}

/*
 *  The DateTimeDaemon runs every intervalSeconds, but is only 
 *  triggered when the WallClock time is equal to the WallClock 
 *  time corresponding to the year, month, day, hour, minute, 
 *  second arguments.
 *
 *  hour should be 24-hour military time.
 */
class DateTimeDaemon: TimeSysEventMixIn, ContActDaemon
{
    construct(obj, prop, year, month, day, hour, minute, second, 
        intervalMins, queryActor)
    {
        local nrtInterval, gctu;

        /*
         *  nrtInterval gets used in computing the daemon's
         *  nextRunTime. The remaining code computes the 
         *  interval, which is the frequency after the the 
         *  initial run time that the daemon executes.
         */
        nrtInterval = computeTimeSysEventInterval(year, month, day, hour, 
            minute, second);

        if (nrtInterval)
        {
            inherited(obj, prop, nrtInterval, gPlayerChar, WaitTimeAction, 
                queryActor);

            /* 
             *  We've set the daemon's next run time, which will be the 
             *  first time the daemon will fire. We need to convert 
             *  minutes to game clock time units and reset the 
             *  interval_ property for subsequent cycling 
             */
            gctu = toInteger(gWallClock.cvtMinToGctu(intervalMins));

            /* 
             *  daemon intervals must be at least 1
             */
            if (gctu < 1)
                gctu = 1;

            interval_   = gctu;
        }
    }
}

/*
 *  Sensory-context-sensitive datetime event daemon - this is a daemon 
 *  with an explicit sensory context.  This is the daemon counterpart 
 *  of SenseDateTimeFuse.  
 */
class SenseDateTimeDaemon: DateTimeDaemon
{
    construct(obj, prop, year, month, day, hour, minute, second, 
        intervalMins, queryActor, source, sense)
    {
        /* inherit the base constructor */
        inherited(obj, prop, year, month, day, hour, minute, second, 
            intervalMins, queryActor);

        /* remember our sensory context */
        source_     = source;
        sense_      = sense;
    }
}

/*
 *  Cyclical Sensory-context-sensitive datetime event daemon - this 
 *  is a daemon with an explicit sensory context.  This is a specialized
 *  SenseDateTimeDaemon that processes "event objects". The daemon
 *  computes which event object to process, and then adopts the 
 *  characteristics of the "event object" and processes the methods
 *  of the event object. 
 *
 *  In addition, if the player is not able to sense the obj_ 
 *  at the time indicated for an event object, then a delayed
 *  method is executed for the event when the actor can sense
 *  the indicated obj_. 
 */
class CycleSenseDateTimeDaemon: SenseDateTimeDaemon
{
    time_               = []
    eventList_          = []
    muteInitEventMsgs_  = nil
    skipInitEvent_      = nil

    lastEvent_          = nil
    eventCnt_           = 0
    muteEventMsgs_      = nil
    skipEvent_          = nil
    bypassInterrupt_    = nil
    queryActor_         = nil
    actor_              = nil
    msgDone_            = nil

    clockRatio_         = nil
    
    getBypassInterrupt() { return bypassInterrupt_; }

    construct(year, month, day, hour, minute, second, eventList)
    {
        local vec;

        vec = new Vector(eventList.length());

        foreach (local e in eventList)
            vec += e.createClone();

        eventList_ = vec.toList();

        initEvents();

        /*
         *  Call this events callMethod passing it the 
         *  value of muteEventMsgs_ to indicate that we
         *  want the initial execution of this daemon, 
         *  which occurs during construction, to follow
         *  the requirements of the muteEventMsgs_ property.
         */
        callMethod(muteInitEventMsgs_);

        /*
         *  Set this daemon to run every turn from the 
         *  year, month, day, hour, and minute indicated.
         */
        inherited(nil, nil, year, month, day, hour, minute, second, 
            1, nil, nil, nil);
    }

    /*
     *  Initialize the event objects in our 
     *  event list and then sort the list in
     *  ascending order.
     */
    initEvents()
    {
        /*
         *  Initialize each event individually
         */
        foreach (local e in eventList_)
            e.initEvent();

        /*
         *  Sort the event list by its clock ratios
         */
        eventList_ = eventList_.sort(nil, {a, b: 
            toInteger(a.clockRatio_ * 100000) 
            - toInteger(b.clockRatio_ * 100000)});
    }

    /* 
     *   Call our underlying method.  This is an internal routine intended
     *   for use by the executeEvent() implementations.  
     */
    callMethod([args])
    {
        local e, mute, skip;

        /*
         *  mute indicates whether the event being executed
         *  is to be "silent". An event should use double-quoted
         *  strings for its display in order to be silent.
         */
        mute                = args.car();

        /*
         *  skip indicates that the event selected during
         *  the daemon's construction should be skipped and 
         *  marked as completed.
         */
        skip                = (skipInitEvent_ && eventCnt_ == 0);

        e                   = getCurrEvent();


        /* initialize prop_ */
        prop_               = nil;

        /* 
         *  If our last event isn't the current object
         *  selected then initialize the msgDone and prop.
         */
        if (lastEvent_ != e)
        {
            /* 
             *  Get the info governing this Event from 
             *  our selected TimeSys event object.
             */
            obj_                = e;
            bypassInterrupt_    = e.bypassInterrupt_;
            queryActor_         = e.queryActor_;
            actor_              = e.actor_;
            source_             = e.source_;
            sense_              = e.sense_;
            prop_               = &doEvent;
            skipEvent_          = skip;
            muteEventMsgs_      = mute;
            e.msgDone_          = nil;            
        }

        /*
         *  If our msg hasn't been done then
         *  we produce our secondary "while you
         *  were away" message.
         */
        else if (e.msgDone_ == nil)
        {
            prop_   = &doEventDelayed;
        }

        /*
         *  If we have set the property then we want 
         *  to invoke it within our sensory context,
         *  and in a simulated action environment.
         *
         *  We also check to see if the actor can
         *  detect the object. If so then we assume
         *  that the event has announced itself and 
         *  we can mark it's messaging as "done".
         */
        if (obj_ && prop_)
        {
            /*
             *  We set the event's muteEventMsgs_ property
             *  to indicate whether this event should be silent
             *  or be allowed to produce displays.
             */
            e.muteEventMsgs_ = mute;

            /*
             *  Set the tads display to our object
             *  property tsDispMethod. Any double-quoted
             *  strings will be caught by this method.
             */
            t3SetSay(&tsDispMethod);

            /*
             *  If we're supposed to skip the inital event,
             *  which occurs during daemon contruction, then
             *  we don't pass control to our superclass.
             */
            if (!skip)
                inherited();

            t3SetSay(say);

            e.muteEventMsgs_ = nil;

            /*
             *  If we're skipping this event or the sensory
             *  context shows that the actor would sense the
             *  event then we mark the event message as done
             *  and initialize this daemon's properties for
             *  the next turn.
             */
            if (skip || checkSensoryContext())
            {
                e.msgDone_       = true;

                /*
                 *  We're done with this event, so reinitialize
                 *  the daemon's fields.
                 */
                obj_                = nil;
                bypassInterrupt_    = nil;
                queryActor_         = nil;
                actor_              = nil;
                source_             = nil;
                sense_              = nil;
                prop_               = nil;
            }
        }

        /*
         *  Set the last event executed to the event
         *  we were set to execute this turn (whether it
         *  was executed or not) and increment the event
         *  counter.
         */
        lastEvent_                  = e;
        eventCnt_++;
    }

    getCurrEvent()
    {
        local clockRatio, currEvent;

        clockRatio = gWallClock.getCurrClockRatio();
        
        currEvent = eventList_[eventList_.length()];

        foreach (local event in eventList_)
        {
            if (gWallClock.getClock().compareRatios(clockRatio, 
                event.clockRatio_) != -1)
                currEvent = event;
        }

        return currEvent;
    }
}

/*
 *  The ClockTimeDaemon runs every intervalSeconds, but is only 
 *  triggered when the WallClock time is equal to the WallClock 
 *  time corresponding to the hour, minute, second arguments.
 *
 *  hour should be 24-hour military time.
 */
class ClockTimeDaemon: DateTimeDaemon
{
    firstHour_      = nil
    firstMinute_    = nil
    firstSecond_    = nil

    construct(obj, prop, hour, minute, second, intervalMins, queryActor)
    {
        local lst, year, month, day;

        lst     = gWallClock.getCurrDateTimeVals();
        year    = toInteger(lst[1]);
        month   = toInteger(lst[2]);
        day     = toInteger(lst[3]);

        inherited(obj, prop, year, month, day, hour, minute, second, 
            intervalMins, queryActor);
    }
}

/*
 *  Sensory-context-sensitive time event daemon - this is a daemon 
 *  with an explicit sensory context.  This is the daemon counterpart 
 *  of SenseTimeEventFuse.  
 */
class SenseClockTimeDaemon: ClockTimeDaemon
{
    construct(obj, prop, hour, minute, second, intervalMins, 
        queryActor, source, sense)
    {
        /* inherit the base constructor */
        inherited(obj, prop, hour, minute, second, intervalMins,
            queryActor);

        /* remember our sensory context */
        source_     = source;
        sense_      = sense;
    }
}

/*
 *  The DailyTimeEventDaemon runs every turn, but is only triggered 
 *  when the WallClock time is equal to the WallClock time 
 *  corresponding to the hour, minute, second arguments and at 
 *  daily intervals thereafter.
 *
 *  hour should be 24-hour military time.
 */
class DailyDaemon: ClockTimeDaemon
{
    construct(obj, prop, hour, minute, second, queryActor)
    {
        local intervalMins;

        intervalMins = gWallClock.getClock().minutesPerDay_;

        inherited(obj, prop, hour, minute, second, intervalMins,
            queryActor);
    }
}

/*
 *  Sensory-context-sensitive daily time event daemon - this is a 
 *  daemon with an explicit sensory context.  This is the daemon 
 *  counterpart of SenseTimeEventFuse.  
 */
class SenseDailyDaemon: DailyDaemon
{
    construct(obj, prop, hour, minute, second,
        queryActor, source, sense)
    {
        /* inherit the base constructor */
        inherited(obj, prop, hour, minute, second, queryActor);

        /* remember our sensory context */
        source_     = source;
        sense_      = sense;
    }
}

/*
 *  Defines an Indexed Event mix-in class that
 *  performs multiple events based on where the 
 *  daemon is positioned in an actor's waiting 
 *  period. 
 */
class TimeSysIdxEventMixIn: TimeSysEventMixIn
{
    getBypassInterrupt()
    {
        if (getEventIdx() == 3)
            return nil;
        else
            return true;
    }

    doEvents()
    {
        local idx;

        idx = getEventIdx();

        switch(idx)
        {
            case 1:
                doEvent1();
                break;

            case 2:
                doEvent2();
                break;

             case 3:
                doEvent3();
                break;

            case 4:
                doEvent4();
                break;

            default:
                doEvent0();
        }
    }

    getEventIdx()
    {
        local idx, vals;

        vals = getActorWaitEventVals();

        // initialized to our default event process
        idx = 0;

        // daemon fires, but not during a wait period
        if (vals == nil)
        {
            idx = 1;
        }      
        // this action is not an equivalent action of the
        // last continuous action encountered by this event
        else if (vals[6] == nil)
        {
            // daemon will fire only ONCE for this wait period
            // AND daemon fires at END of this wait period
            if (vals[4] == 0 && vals[5] == 0)
                idx = 2;

            // daemon will fire only ONCE for this wait period
            // OR (daemon will fire TWICE 
            // AND last firing at END of this wait period)
            else if ((vals[4] == 1 && vals[5] == 0)
            || vals[4] < 1)
                idx = 3;

            // daemon will fire MORE THAN ONCE 
            // during this wait period
            else
                idx = 4;
        }

        return idx;
    }

    /* 
     *  Default event, meets none of the conditions
     *  of idx selection. Generally we do nothing.
     */
    doEvent0() {}

    /* 
     *  Daemon fires, but not during a wait period.
     *  Concrete class should override this.
     */
    doEvent1() {}

    /*
     *  Daemon will fire only ONCE for this wait period
     *  AND daemon fires at END of this wait period.
     *  Generally we treat this the same as doEvent1.
     */
    doEvent2() { doEvent1(); }

    /*
     *  Daemon will fire only ONCE for this wait period
     *  OR
     *  Daemon will fire TWICE AND last firing at END of 
     *  this wait period.
     *  Concrete class should override this.
     */
    doEvent3() {}

    /*
     *  Daemon will fire MORE THAN ONCE 
     *  during this wait period
     *  Concrete class should override this.
     */
    doEvent4() {}
}

class TimeSysEventObject: BasicCaEventObject
{
    time_               = []

    clockRatio_         = nil

    /*
     *  Compute a clockratio appropriate for a daemon. All
     *  daemon's fire a game clock time unit later than 
     *  a fuse would and we need to compensate for this 
     *  game clock time unit.
     */
    initEvent()
    {
        local mins, minClockRatio, currClockRatio;

        /* convert 1 game clock time unit to minutes */
        mins = toInteger(gWallClock.cvtGctuToMin(1));

        /* compute the clockratio for 1 minute */
        minClockRatio   = gWallClock.getClock().toClockRatio(
            0, mins, 0);

        /* compute the clockratio for this event object's time */
        currClockRatio  = gWallClock.getClock().toClockRatio(
            time_...);
        
        /* compare the clockratios */
        if (gWallClock.getClock().compareRatios(currClockRatio,
            minClockRatio) == -1)
            currClockRatio = currClockRatio + 1;

        /*
         *  Compute the clockratio for this event object 
         *  compensating for the extra minute of daemon fire.
         */
        clockRatio_ = currClockRatio - minClockRatio;
    }
}