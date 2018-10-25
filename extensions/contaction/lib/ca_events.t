#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 Continuous Actions Library Extension
 *
 *  ca_events.t
 *
 *  Defines fuses and daemons for notifying an actor
 *  of the triggering of the fuse or daemon and requesting 
 *  a continuous action interrupt.
 */

#include "contaction.h"

/*
 *  A mix-in class for Continuous Action Events. These
 *  events attempt to interrupt the character player when
 *  performing a continuous action when the daemon or fuse
 *  fires.
 */
class ContActEventMixIn: object
{
    actor_              = gPlayerChar
    action_             = nil
    queryActor_         = nil
    bypassInterrupt_    = nil

    /*
     *  Indicates whether we evaluate the first or last 
     *  element returning queryActor_ == true during our
     *  checkForDupActorQuery(). This controls whether the
     *  first event (in a set of "simultaneous" events) 
     *  or the last is to issue its continuous action 
     *  interrupt query.
     */
    lastDupCheck_   = true

    getQueryActor() { return queryActor_; }
    
    /*
     *  Returns the pending continuous action
     *  for the Event's action_ property or
     *  if a pending continuous action wasn't 
     *  found, then returns nil.
     */
    getActorContActPending()
    {
        return actor_.getPendContActionFor(action_)[3];
    }

    /*
     *  Returns the expired (compteted/terminated)
     *  continuous action for the Event's action_ 
     *  property or if an expired continuous action wasn't 
     *  found, then returns nil.
     */
    getActorContActExpired()
    {
        return actor_.getExpContActionFor(action_);
    }
    
    getBypassInterrupt()
    {
        return bypassInterrupt_;
    }

    callMethod()
    {
        inherited();

        /*
         *  We want to eliminate duplicate actor
         *  queries for termination of continuous
         *  actons.
         */
        if (checkForDupActorQuery() == nil)
        {
            /*
             *  If a pending continuous action 
             *  exists do our pending continuous
             *  action interrupt method.
             */
            if (getActorContActPending() && !getBypassInterrupt())
                callActorContActInterrupt();
        }
    }

    /* 
     *  Invoke the issueContActionInterrupt() method only if 
     *  we have a source and sense and our actor can sense 
     *  the source, or if no source or sense has been provided.
     */
    callActorContActInterrupt()
    {
        if (checkSensoryContext())
            actor_.issueContActionInterrupt(actor_,
                action_, queryActor_);
    }

    /*
     *  Checks for events that would trigger 
     *  duplicate actor interrupt queries during 
     *  the same game turn. Returns true if this 
     *  event is the last in the event list to 
     *  return (queryActor_ == true) then we return
     *  nil; otherwise we return true.
     */
    checkForDupActorQuery()
    {
        local vec, val, f;

        /*
         *  returns true if the event wants to query the actor
         *  and the actor can sense the object (or doesn't have
         *  a sensory context).
         */
        f = new function(e) { 
            return (e.getQueryActor() && e.checkSensoryContext());
        };

        vec = eventManager.events_.subset({x: x.getNextRunTime()
                == Schedulable.gameClockTime});

        /* 
         *  This event will evaluate the last element 
         *  for which function is true if lastDupCheck_ 
         *  is set to true; otherwise it will evaluate the
         *  first element for which function is true.
         */
        if (lastDupCheck_)
            val = vec.lastValWhich(f);
        else
            val = vec.valWhich(f);

        /*
         *  If val doesn't equal self then we have a duplicate
         *  actorQuery situation, something that we would 
         *  normally like to avoid.
         */
        return (val != self);
    }

    /*
     *  Returns true if the actor doesn't require
     *  a sensory context (nil source_ or sense_) 
     *  or the actor has a sensory context and can
     *  sense the object.
     */
    checkSensoryContext()
    {
        return (source_ == nil
            || sense_ == nil
            || actor_.senseObj(sense_, source_).trans != opaque);
    }
}

/*
 *  Defines a continuous action fuse base class.
 */
class ContActFuse: ContActEventMixIn, Fuse
{
    construct(obj, prop, turns, actor, action, queryActor)
    {
        inherited(obj, prop, turns);

        actor_          = actor;
        action_         = action;
        queryActor_     = queryActor;
    }
}

/*
 *  Defines a sense continuous action fuse base class.
 */
class SenseContActFuse: ContActFuse
{
    construct(obj, prop, turns, actor, action, queryActor, 
        source, sense)
    {
        inherited(obj, prop, turns, actor, action, queryActor);

        source_     = source;
        sense_      = sense;
    }
}

/*
 *  Defines a continuous action daemon base class.
 */
class ContActDaemon: ContActEventMixIn, Daemon
{
    construct(obj, prop, interval, actor, action, queryActor)
    {
        inherited(obj, prop, interval);

        actor_          = actor;
        action_         = action;
        queryActor_     = queryActor;
    }
}

/*
 *  Defines a sense continuous action daemon base class.
 */
class SenseContActDaemon: ContActDaemon
{
    construct(obj, prop, interval, actor, action, queryActor, 
        source, sense)
    {
        inherited(obj, prop, interval, actor, action, queryActor);

        source_     = source;
        sense_      = sense;
    }
}

/*
 *   A basic CaEventObject, for CaCycleEvent events.
 */
class BasicCaEventObject: ContActEventMixIn, BasicEvent
{
    msgDone_            = nil

    /*
     *  The CaCycleEvent handles this.
     */
    callMethod() {}

    doEvent() {}

    doEventDelayed() {}

    /*
     *  Concrete classes shoudl define this.
     */
    initEvent() {}
}