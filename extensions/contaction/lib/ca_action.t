#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 Continuous Actions Library Extension
 *
 *  ca_action.t
 *
 *  Defines a ContAction (continuous action) Mix-in class 
 *  and supporting Actions. 
 */

#include "contaction.h"

/* 
 *   MixIn class for Actions that handles continuous actions.
 *   
 *   Actions that inherit from this class should not override
 *   execAction(), but should instead define execActionFirstTime(), 
 *   execActionContinuous(), execActionLastTime() and 
 *   execActionInterrupted() methods. 
 *
 *   In addition, the Action should define a checkActionCompleted()
 *   method that determines when the continuous action has completed.
 */
class ContAction: object
{
    /*
     *  The following values are carried on the 
     *  pending command info object and synchronized 
     *  with each subsequent action.
     */
    isRequeuedAction_       = nil   // is this a requeued action?
    initContAction_         = nil   // the first action in the series
    lastContAction_         = nil   // action previous to this one in series
    requeuingActor_         = nil   // global actor at the time of requeue
    requeuingActorState_    = nil   // global actor's curState at time of requeue
    execActionCnt_          = 0     // the number of times the action is executed
    queryActionSeriesCnt_   = 0     // total interrupt query cnt for series
    
    /* 
     *  This is a list of properties that are on the ContAction
     *  and PendingCommandInfo classes that we want to keep 
     *  synchronized from one action in a continuous action
     *  series to the next.
     */
    updActPropList          = [
                                &isRequeuedAction_,
                                &initContAction_,
                                &lastContAction_,
                                &requeuingActor_,
                                &requeuingActorState_,
                                &execActionCnt_,
                                &queryActionSeriesCnt_
                               ]
    
    queryActionCurrCnt_     = 0     // total interrupt query cnt for this action
    isCompletedAction_      = nil   // continuous action series completed
    checkBeforeExec_        = nil   // checked for completion before execution
    pendingCommandRequeue_  = nil   // requeue command toks or requeue action

    /*
     *  The default actor state when performing
     *  the continuous action series.
     */
    actionState             = ContActorState

    /*
     *  Returns true if action is equivalent to self. An 
     *  equivalent action is any action in the series of 
     *  a continuous action.
     */
    isEquivContAction(action)
    {
        if (action == self 
            || action.initContAction_ == initContAction_)
            return true;
        else
            return nil;
    }
    
    /*
     *  Before we execute the action we need to synchronize
     *  it with the information carried on its associated
     *  pendingCommandInfo object. We also need to indicate
     *  whether this action is the original continuous action
     *  in the series.
     */
    doAction(issuingActor, targetActor, targetActorPhrase,
             countsAsIssuerTurn)
    {
        /*
         *  Set the values retained from the previous continuous
         *  action, if there were any.
         */
        if (gPendingCommandInfo)
            synchronizeActionProps(self, gPendingCommandInfo);

        /*
         *  initilize properties specific to this instance.
         */
        initializeActionProps();

        inherited(issuingActor, targetActor, targetActorPhrase,
             countsAsIssuerTurn);
    }

    /*
     *  Synchronize obj1 state with the state 
     *  values of ob2 as indicated by the base
     *  classes updActPropList.
     */
    synchronizeActionProps(obj1, obj2)
    {
        /* update obj1 with info from obj2 */
        foreach (local prop in updActPropList)
            obj1.(prop) = obj2.(prop);
    }

    /*
     *  Initializes properties specific to this instance
     *  in the continuous action series.
     */
    initializeActionProps()
    {
        /*
         *  If, after synchronizing with the global 
         *  player command info, the action doesn't 
         *  have an original continuous action, then
         *  we set that value to this object.
         */
        if (initContAction_ == nil)
            initContAction_ = self;
    }

    /*
     *  Run the before routine for the entire action 
     */
    beforeActionMain()
    {
        inherited();

        /* do any initialization */
        if (execActionCnt_ == 0)
            beforeContActionMain();

        /* 
         *  If this action requires checking for completion
         *  before execution and the action appears to be 
         *  completed then we execute our action completed
         *  method and exit.
         */
        if (checkBeforeExec_ && checkActionCompleted())
        {
            afterContActionMain();
            exit;
        }

        /* increment our action execution counter */
        ++execActionCnt_;
    }

    /*
     *   Perform processing after running the entire action.  This is
     *   called just once per action, even if the action was iterated for
     *   a list of objects. 
     */
    afterActionMain()
    {
        inherited();

        /* 
         *  if the action appears to be completed we execute our
         *  action completed method. Otherwise we requeue this 
         *  action as either a command or a clone of this action.
         */
        if (checkActionCompleted())
            afterContActionMain();
        else
        {
            if (pendingCommandRequeue_)
                requeuePendingCommand();
            else
                requeuePendingAction();
        }
    }

    /*
     *  Requeue this action as a pending command. We will be parsing
     *  the same token list from this action next time.
     */
    requeuePendingCommand()
    {
        local toks;

        /* get this action's original tokens */
        toks = getOrigTokenList();

        /* add the tokens to the actor's pending command queue */
        gActor.addFirstPendingCommand(1, gIssuingActor, toks);

        /* update the first pending command with cont action info */
        updatePendingCommandInfo();
    }

    /*
     *  Each concrete action must determine how to requeue the action.
     */
    requeuePendingAction() {}

    /* 
     *  We check to see if there is a first pending command
     *  for the global actor, and then synchronize that 
     *  pending command with information from this action
     *  and the requeue process.
     */
    updatePendingCommandInfo()
    {
        local pci;

        if (gActor.pendingCommand.length() == 0)
            return;

        pci = gActor.pendingCommand[1];

        /* update the pending command with this object's stat info */
        synchronizeActionProps(pci, self);

        /* values unique to the requeue */
        pci.isRequeuedAction_       = true;
        pci.lastContAction_         = self;
        pci.requeuingActor_         = gActor;
        pci.requeuingActorState_    = gActor.curState;
    }

    /*
     *  Sets the current actorState to the actionState
     *  specified by this action, then calls execActionInitial().
     */
    beforeContActionMain()
    {
        local nextState;

        nextState = gActor.curState;

        setCurrActorState(gActor, actionState, nextState);

        execActionInitial();
    }

    /*
     *  Calls execActionCompleted(), then sets the current 
     *  actorState to the nextState stored in the actorState.
     */
    afterContActionMain()
    {
        setActionCompleted(true);

        execActionCompleted();

        setNextActorState(gActor);
    }

    /*
     *  Calls execActionInterrupted(), then sets the current 
     *  actorState to the nextState stored in the actorState.
     */
    interruptedContActionMain(issuingActor, targetActor)
    {
        /* set this action as completed */
        setActionCompleted(true);

        /* perform any action interrupted activities */
        execActionInterrupted(issuingActor, targetActor);

        /* set the targetActor's next run time */
        setActorNextRunTime(targetActor);

        /* set the actor's next state */
        setNextActorState(targetActor);
    }

    incrQueryActionCnt()
    {
        incrQueryActionSeriesCnt();
        incrQueryActionCurrCnt();
    }

    incrQueryActionSeriesCnt()
    {
        queryActionSeriesCnt_++;
    }

    incrQueryActionCurrCnt()
    {
        queryActionCurrCnt_++;
    }

    /* set this action as completed */
    setActionCompleted(val) { isCompletedAction_ = val; }

    /*
     *  Set the actor's state to the newState, with transition
     *  into nextState. We create an instance of the newState
     *  then set the actor's state to this instance.
     */
    setCurrActorState(actor, newState, nextState)
    {
        local stateObj;

        stateObj = newState.createInstance(actor, nextState);

        actor.setCurState(stateObj);
    }

    /* 
     *  Set the actor's state to the next state 
     *  indicated by the actor's current state. If
     *  there is no next state specified then we don't
     *  change the actor's state.
     */
    setNextActorState(actor)
    {
        local nextState;
        
        nextState = actor.curState.nextState;

        if (nextState)
            actor.setCurState(nextState);
    }

    setActorNextRunTime(actor)
    {
        /*
         *  By default we don't advance the actor's next
         *  run time for terminated actions by setting it
         *  equal to the Schedulable's game clock time.
         */
        actor.nextRunTime = Schedulable.gameClockTime;
    }

    /*
     *  This method should return true if an Action has completed; 
     *  otherwise it should return nil, meaning the Action is to be
     *  repeated.
     *
     *  By default we return true.
     */
    checkActionCompleted() { return true; }

    /*
     *  Authors should use this method to process the action the
     *  first time it is executed.
     *
     *  By default we do nothing.
     */
    execActionInitial() {}

    /*
     *  This method should contain code for the last time an action
     *  is executed, when the action has successfully completed due
     *  to meeting the conditions in checkActionCompleted().
     *
     *  By default we do nothing.
     */
    execActionCompleted() {}

    /*
     *  This method should contain code for when an action is 
     *  interrupted, when the action has not successfully completed. 
     *
     *  By default we do nothing.
     */
    execActionInterrupted(issuingActor, targetActor) {}
}

/*
 *  Continuous Intransitive Action class
 */
class ContIAction: ContAction, IAction
{
    requeuePendingAction()
    {
        gActor.addFirstPendingAction(1, gIssuingActor, self.createClone());

        /* update the first pending command with cont action info */
        updatePendingCommandInfo();
    }
}

/*
 *  Continuous Transitive Action class
 */
class ContTAction: ContAction, TAction
{
    /*
     *  Method breaks down any multiple object command into
     *  an atomic action consisting of one [dobj] and queues 
     *  any remaining objects for the next execution.
     */
    beforeActionMain()
    {
        if (!pendingCommandRequeue_)
        {
            /*
             *  First, we remove any potential pending commands 
             *  that match this newly issued player command.
             */
            if (gPendingCommandInfo.isRequeuedAction_ == nil)
                removeActorPendingCommand();

            if (dobjList_.length() > 1)
            {
                local dobj;

                /* queue the tail of the list for future execution */
                dobj        = dobjList_.sublist(1, 1);
                dobjList_   = dobjList_.cdr();

                requeuePendingAction();

                /* reset the list to contain only its "head" */
                dobjList_   = dobj;
            }
        }
        inherited();
    }

    /*
     *  Break down further continuous actions into [dobj, iobj] atomic
     *  pairs and queue these on the actor for future processing.
     */
    requeuePendingAction()
    {
        local dobj, dobjs;

        dobjs = gAction.getResolvedDobjList();

        for (local i = dobjs.length(); i > 0; --i)
        {
            dobj = dobjs[i];

            gActor.addFirstPendingAction(1, gIssuingActor, 
                gAction.createClone(), dobj);

            /* update the first pending command with cont action info */
            updatePendingCommandInfo();
        }
    }

    /*
     *  Method will remove any requeued pending continuous command
     *  that is identical to the one being executed if the current
     *  command hasn't been requeued (i.e. it's a newly issued player
     *  command).
     *
     *  This will prevent, if necessary, any nesting of pending
     *  continuous commands due to the same command being reissued
     *  by the player.
     */
    removeActorPendingCommand()
    {
        local sc; 

        sc = getSuperclassList();

        foreach (local cmd in gActor.pendingCommand)
        {
            local action, objs, val1, indx; 

            action = cmd.action_;
            objs = cmd.objs_;

            if (cmd.isRequeuedAction_ == nil || action == nil)
                continue;

            if (action.getSuperclassList() == sc)
            {
                val1 = dobjList_.indexOf(objs[1]);

                if (val1)
                {
                    indx = gActor.pendingCommand.indexOf(cmd);
                    gActor.pendingCommand.removeElementAt(indx);
                }
            }
        }
    }
}

/*
 *  Continuous Transitive-with-indirect Action class
 */
class ContTIAction: ContAction, TIAction
{
    /*
     *  Method breaks down any multiple object command into
     *  an atomic action consisting of one [dobj, iobj] pair 
     *  and queues any remaining objects for the next execution.
     */
    beforeActionMain()
    {
        /*
         *  If this action queues the Action (not the command
         *  tokens) then we want to process each [dobj, iobj] pair
         *  as a separately queued pending command info object. To
         *  do this we simply grab the first pair, then queue the 
         *  remaining pairs to be evaluated in the future.
         */
        if (!pendingCommandRequeue_)
        {
            /*
             *  First, we remove any potential pending commands 
             *  that match this newly issued player command.
             */
            if (gPendingCommandInfo.isRequeuedAction_ == nil)
                removeActorPendingCommand();

            if (dobjList_.length() > 1)
            {
                local dobj;

                /* queue the tail of the list for future execution */
                dobj        = dobjList_.sublist(1, 1);
                dobjList_   = dobjList_.cdr();

                requeuePendingAction();

                /* reset the list to contain only its "head" */
                dobjList_   = dobj;
            }
            else if (iobjList_.length() > 1)
            {
                local iobj;

                /* queue the tail of the list for future execution */
                iobj        = iobjList_.sublist(1, 1);
                iobjList_   = iobjList_.cdr();

                requeuePendingAction();

                /* reset the list to contain only its "head" */
                iobjList_   = iobj;
            }
        }
        inherited();
    }

    /*
     *  Break down further continuous actions into [dobj, iobj] atomic
     *  pairs and queue these on the actor for future processing.
     */
    requeuePendingAction()
    {
        local dobj, dobjs, iobj, iobjs;

        dobjs = gAction.getResolvedDobjList();
        iobjs = gAction.getResolvedIobjList();

        if (iobjs.length() == 1)
        {
            iobj = iobjs.car();
            for (local i = dobjs.length(); i > 0; --i)
            {
                dobj = dobjs[i];

                gActor.addFirstPendingAction(1, gIssuingActor, 
                    gAction.createClone(), dobj, iobj);

                /* update the first pending command with cont action info */
                updatePendingCommandInfo();
            }
        }
        else
        {
            dobj = dobjs.car();
            for (local i = iobjs.length(); i > 0; --i)
            {
                iobj = iobjs[i];

                gActor.addFirstPendingAction(1, gIssuingActor, 
                    gAction.createClone(), dobj, iobj);

                /* update the first pending command with cont action info */
                updatePendingCommandInfo();
            }
        }
    }

    /*
     *  Method will remove any requeued pending continuous command
     *  that is identical to the one being executed if the current
     *  command hasn't been requeued (i.e. it's a newly issued player
     *  command).
     *
     *  This will prevent, if necessary, any nesting of pending
     *  continuous commands due to the same command being reissued
     *  by the player.
     */
    removeActorPendingCommand()
    {
        local sc; 

        sc = getSuperclassList();

        foreach (local cmd in gActor.pendingCommand)
        {
            local action, objs, val1, val2, indx; 

            action = cmd.action_;
            objs = cmd.objs_;

            if (cmd.isRequeuedAction_ == nil || action == nil)
                continue;

            if (action.getSuperclassList() == sc)
            {
                val1 = dobjList_.indexOf(objs[1]);
                val2 = iobjList_.indexOf(objs[2]);

                if (val1 && val2)
                {
                    indx = gActor.pendingCommand.indexOf(cmd);
                    gActor.pendingCommand.removeElementAt(indx);
                }
            }
        }
    }
}