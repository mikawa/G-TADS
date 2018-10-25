#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 Continuous Actions Library Extension
 *
 *  ca_misc.t
 *
 *  Modifications to adv3 misc.t 
 */

#include "contaction.h"

/* set up a global pending command info */
modify libGlobal
{
    pendingCommandInfo = nil
}