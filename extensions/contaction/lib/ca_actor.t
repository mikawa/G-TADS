#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 Continuous Actions Library Extension
 *
 *  ca_actor.t
 *
 *  Defines Continuous Actor Methods. 
 */

#include "contaction.h"

modify ContAction
{
    /*
     *  This method should return true if an Action has completed; 
     *  otherwise it should return nil, meaning the Action is to be
     *  repeated.
     *
     *  By default we farm this out to the actor.
     */
    checkActionCompleted()
    {
        gActor.checkActionCompleted(self);
    }

    /*
     *  Authors should use this method to process the action the
     *  first time it is executed.
     *
     *  By default we farm this out to the actor.
     */
    execActionInitial()
    {
        gActor.execActionInitial(self);
    }

    /*
     *  This method should contain code for the last time an action
     *  is executed, when the action has successfully completed due
     *  to meeting the conditions in checkActionCompleted().
     *
     *  By default we farm this out to the actor.
     */
    execActionCompleted()
    {
        gActor.execActionCompleted(self);
    }

    /*
     *  This method should contain code for when an action is 
     *  interrupted, when the action has not successfully completed. 
     *
     *  By default we farm this out to the actor.
     */
    execActionInterrupted(issuingActor, targetActor)
    {
        targetActor.execActionInterrupted(issuingActor, self);
    }
}

modify ContIAction
{
    /*
     *  This method should contain code for actions that are being
     *  repeated. The execActionCnt_ will indicate the number
     *  of times the action has been repeated, excluding the initial
     *  time.
     *
     *  By default we farm this out to the actor.
     */
    execAction() 
    {
        gActor.execAction(self);
    }
}

/*
 *  Modify PendingCommandInfo to carry extra
 *  continuous action info.
 */
modify PendingCommandInfo
{
    isRequeuedAction_       = nil
    initContAction_         = nil
    lastContAction_         = nil
    requeuingActor_         = nil
    requeuingActorState_    = nil
    execActionCnt_          = 0      // the number of times the action is executed
    queryActionSeriesCnt_   = 0
}

/*
 *  Modify PendingCommandToks to stack a copy of itself
 *  as a global when executed.
 */
modify PendingCommandToks
{
    executePending(targetActor)
    {
        /* cache the old pending command info object */
        local oldInfo;
        
        oldInfo = gPendingCommandInfo;

        gPendingCommandInfo = self;

        try
        {
            inherited(targetActor);
        }
        finally
        {
            gPendingCommandInfo = oldInfo;
        }
    }
}

/*
 *  Modify PendingCommandAction to stack a copy of itself
 *  as a global when executed.
 */
modify PendingCommandAction
{
    executePending(targetActor)
    {
        /* cache the old pending command info object */
        local oldInfo;
        
        oldInfo = gPendingCommandInfo;

        gPendingCommandInfo = self;

        try
        {
            inherited(targetActor);
        }
        finally
        {
            gPendingCommandInfo = oldInfo;
        }
    }
}

/*
 *  Override the Actor acceptCommandBusy() to 
 *  Alert Continuous Actions that they've been interrupted 
 *  by another actor command.
 */
modify Actor
{
    /* actors must issue continuous actions synchronously */
    issueCommandsSynchronously = nil

    checkActionCompleted(action) 
    { 
        return curState.checkActionCompleted(action); 
    }

    execActionInitial(action) { curState.execActionInitial(action); }
    execAction(action) { curState.execActionInitial(action); }
    execActionCompleted(action) { curState.execActionCompleted(action); }
    execActionInterrupted(issuingActor, action)
    {
        curState.execActionInterrupted(issuingActor, action);
    }

    /*
     *  Returns true is the actor is doing a continuous action
     *  of class actionClass; otherwise the method returns nil.
     */
    contActionPendingFor(actionClass)
    {
        local ret;

        ret = getPendContActionFor(actionClass);
        
        return (ret[3] != nil);
    }

    /*
     *  Returns true is the actor's most recent action is an
     *  expired continuous action of class actionClass; otherwise 
     *  the method returns nil.
     */
    contActionExpiredFor(actionClass)
    {
        return (getExpContActionFor(actionClass) != nil);
    }

    /*
     *  Determines whether the actor allows the action to be 
     *  interrupted. Method returns true if the action can be 
     *  interrupted; otherwise returns nil to indicate that we 
     *  won't allow the action to be interrupted.
     */
    allowsContActionInterrupt(issuingActor, action) 
    { 
        /* 
         *  increment the query count for the series
         *  and for the specific action.
         */
        action.incrQueryActionCnt();

        /* 
         *  if the actor isn't the player character, allow
         *  the action to be interrupted.
         */
        if (gPlayerChar != self)
            return true; 
        
        /* 
         *  Ask the player if they wish to continue the action and
         *  return the negative of the player's response. 
         */
        return !contActionYesOrNo(action);
    }

    /*
     *  A method for interrupting a continuous action for this actor.
     */
    issueContActionInterrupt(issuingActor, actionClass, queryActor)
    {
        local lst, ra, pa, qa;

        /*
         *  Get the most recent action, pending command 
         *  and query action for this action class.
         */
        lst = getPendContActionFor(actionClass);
        ra  = lst[1]; 
        pa  = lst[2];
        qa  = lst[3];
        
        /*
         *  If we don't have a most recent action
         *  or pending action then we return to 
         *  the caller.
         */
        if (ra == nil && pa == nil)
            return CaPendNotFound;

        /*
         *  Query the actor to see if it will allow
         *  the action.
         */
        if (queryActor 
            && !allowsContActionInterrupt(issuingActor, qa))
            return CaPendInterruptFail;

        /*
         *  If we have a most recent action for this action class
         *  that hasn't been completed, mark it as completed.
         */
        if (ra)
            ra.isCompletedAction_ = true;
        
        /* 
         *  If we have a pending action, remove 
         *  the pending action from the queue 
         */
        if (pa)
            pendingCommand.removeElementAt(1);

        /*
         *  Execute the queried action's interrupted 
         *  continuous action main() routine.
         */
        qa.interruptedContActionMain(issuingActor, self);

        return CaPendInterruptSuccess;
    }

    /*
     *  Builds a list of actions for this actor for this 
     *  action class. The list consists of the most recent
     *  action, first pending action, and query action. If 
     */
    getPendContActionFor(actionClass)
    {
        local ra, pa, qa;

        ra  = mostRecentAction
            && mostRecentAction.ofKind(actionClass) 
            && mostRecentAction.isCompletedAction_ == nil 
            ? mostRecentAction : nil;

        pa  = pendingCommand.length() > 0
            && pendingCommand[1].action_.ofKind(actionClass)
            ? pendingCommand[1].action_ : nil;

        qa = pa != nil ? pa : ra;

        return [ra, pa, qa];
    }

    /*
     *  Returns the expired action for this actor for this 
     *  action class. If the most recent action isn't ofKind()
     *  actionClass or is not completed then the method 
     *  returns nil.
     */
    getExpContActionFor(actionClass)
    {
        local ra;

        ra  = mostRecentAction
            && mostRecentAction.ofKind(actionClass) 
            && mostRecentAction.isCompletedAction_ != nil 
            ? mostRecentAction : nil;

        return ra;
    }
}

class ContActorState: HermitActorState
{
    deactivateState(actor, newState)
    {
        getActor().mostRecentAction.isCompletedAction_ = true;
    }

    construct(actor, next)
    {
        /* do the normal initialization */
        inherited(actor);

        /* remember the lead actor and the next state */
        nextState = next;
    }

    /* 
     *   the next state - we'll switch our actor to this state after the
     *   travel has been completed 
     */
    nextState = nil

    execActionInitial(action) {}
    execAction(action) {}
    execActionCompleted(action) {}
    execActionInterrupted(issuingActor, action) {}

    checkActionCompleted(action) { return true; }
}