#charset "us-ascii"
/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 Continuous Actions Library Extension
 *
 *  cont_action.h
 *
 *  Continuous Action Header File.
 */

#include <adv3.h>

/* enums for the results of command interruption */
enum CaPendNotFound, CaPendInterruptFail, CaPendInterruptSuccess;

/*
 *  Define a concrete ContTAction, given the root name for the action.
 *  We'll automatically generate a class with name XxxAction. 
 */
#define DefineContTAction(name) \
    DefineAction(name, ContTAction) \
    verDobjProp = &verifyDobj##name \
    remapDobjProp = &remapDobj##name \
    preCondDobjProp = &preCondDobj##name \
    checkDobjProp = &checkDobj##name \
    actionDobjProp  = &actionDobj##name \

/*
 *  Define a concrete ContIAction, given the root name for the action.
 *  We'll automatically generate a class with name XxxAction. 
 */
#define DefineContIAction(name) \
    DefineAction(name, ContIAction)

/*
 *   Define a concrete TIAction, given the root name for the action.  We'll
 *   automatically generate a class with name XxxAction, a verDobjProp with
 *   name verDobjXxx, a verIobjProp with name verIobjxxx, a checkDobjProp
 *   with name checkDobjXxx, a checkIobjProp with name checkIobjXxx, an
 *   actionDobjProp with name actionDobjXxx, and an actionIobjProp with name
 *   actionIobjXxx.  
 */
#define DefineContTIAction(name) \
    DefineTIActionSub(name, ContTIAction)

/* define a global pending command info macro */
#define gPendingCommandInfo (libGlobal.pendingCommandInfo)