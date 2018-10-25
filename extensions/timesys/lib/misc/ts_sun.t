#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_sun.t
 *
 *  Specialized Definitions of TimeSys Event classes.
 */

/* include the TimeSys header file */
#include "timesys.h"

/*
 *  Simulates announcement and behaviors *similar* to that
 *  of the "sun" in Infocom's "Sherlock: The Riddle of the 
 *  Crown Jewels"
 *
 *  Also controls the lighting in OutdoorRoom class
 *  objects. The sun will brighten up at dawn, reach
 *  its brightest as sunrise, begins to fade at dusk,
 *  then goes out (down) at sunset.
 */
class TimeSysSunDaemon: CycleSenseDateTimeDaemon
{
    muteInitEventMsgs_  = true
}

/*
 *  MixIn class for sunEvents
 */
TimeSysSunEventObjectMixIn: object
{
    msg0_           = ''    // "waiting" message
    msg1_           = ''    // exact time message
    msg2_           = ''    // delayed message

    source_         = tsSun
    sense_          = sight
    queryActor_     = true  // query the actor for waiting interrupt
    muteEventMsgs   = nil

    doEvent() 
    {
        /* 
         *  Change the lighting, producing messages that
         *  might be sensible to the character at the point
         *  when they are displayed. Messages will only be
         *  displayed if the actor can sense the sun to 
         *  make observations, but we structure it so that
         *  a transition to and from darkness will hopefully
         *  be announced!
         */
        if (tsSun.brightnessOn)
        {
            doEventMsgs();
            tsSun.brightnessOn = brightnessVal;
        }
        else
        {
            tsSun.brightnessOn = brightnessVal;
            doEventMsgs();
        }
    }

    doEventMsgs()
    {
        /*
         *  If the actor is waiting, display the waiting message
         */
        if (actor_.curState && actor_.curState.ofKind(WaitingActorState))
            "<<msg0_>>";

        /* display the normal message */
        "<<msg1_>>";
    }

    doEventDelayed() 
    { 
        /*
         *  Display the delayed message. This is the
         *  message displayed when the player enters 
         *  an OutdoorRoom location after the normal 
         *  message would have displayed.
         */
        "<<msg2_>>"; 
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

/* 6:30 a.m. */
tsDawnEvent: TimeSysSunEventObjectMixIn, TimeSysEventObject
{
    time_   = [6, 30, 0]
    msg0_   = 'While you were waiting, the sky started to lighten. 
        Soon it will be  surnrise. '
    msg1_   = 'Visibility increases in the gathering light of
        the new day. Tourists are beginning to crowd into the streets. '
    msg2_   = 'You notice that the sky is lighter, soon it will be 
        sunrise. '
    brightnessVal = 2

    doEvent() 
    { 
        tsSun.brightnessOn = brightnessVal;

        if (actor_.curState && actor_.curState.ofKind(WaitingActorState))
            tadsSay(msg0_);

        "<<msg1_>>";
    }
}

/* 7:00 a.m. */
tsSunriseEvent: TimeSysSunEventObjectMixIn, TimeSysEventObject
{
    time_   = [7, 0, 0]
    msg0_   = 'While you were waiting, the sun rose... as much 
        as it ever does here. '
    msg1_   = 'The sun comes up, as much as it ever comes up
        in England. '
    msg2_   = 'You notice that the sun has risen... as much  as it 
        ever does in England. '
    brightnessVal = 3
}

/* 7:30 p.m. */
tsDuskEvent: TimeSysSunEventObjectMixIn, TimeSysEventObject
{
    time_   = [19, 30, 0]
    msg0_   = 'While you were waiting, the sun set. Soon it 
        will be dark. '
    msg1_   = 'Daylight begins to fade. Soon it will be dark. '
    msg2_   = 'You notice that the setting sun marks the end 
        of another day. Soon it will be dark. '
    brightnessVal = 2
}

/* 8:00 p.m. */
tsSunsetEvent: TimeSysSunEventObjectMixIn, TimeSysEventObject
{
    time_   = [20, 0, 0]
    msg0_   = 'While you were waiting, the sun set and 
        the mists rolled in. '
    msg1_   = 'Darkness falls and the mists come in. '
    msg2_   = 'You notice that the sun has set and the 
        mists have rolled in. '
    brightnessVal = 0
}

/*
 *  The sun is in every OutdoorRoom and 
 *  is a lightsource. The events control 
 *  the lighting of the sun and the messages
 *  accompanying its change in lighting.
 */
tsSun: MultiLoc, Distant, LightSource
{
    brightnessOn    = 0
    vocabWords      = 'sun' 
    name            = 'sun'
    desc()
    {
        switch(brightnessOn)
        {
            case 0:
                "The sun isn't out now. ";
                break;
            
            case 1:
            case 2:
                "The sun is rather faint in the sky. ";
                break;
            
            case 3:
                "The sun is as bright as always. ";
        }
    }

   initialLocationClass = OutdoorRoom
}