#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 Continuous Actions Library Extension
 *
 *  ca_modid.t
 *
 *  Continuous Actions Module Id. 
 */

#include "contaction.h"

/* ------------------------------------------------------------------------ */
/*
 *   The TADS 3 ContAction library Extension ID.
 */
ModuleID
{
    name = 'TADS 3 Continuous Action Library Extension'
    byline = 'by Kevin L.\ Forchione'
    htmlByline = 'by <a href="mailto:kevin@lysseus.com">Kevin L.\ Forchione</a>'
    version = '2.6'

    /*
     *   We use a listing order of 60 so that, if all of the other credits
     *   use the defaults, we appear after the TADS 3 Library's own credits
     *   (conventionally at listing order 50) and before any other extension
     *   credits (which inherit the default order 100), but so that
     *   there's room for extensions that want to appear before us, or
     *   after us but before any default-ordered extensions.  
     */
    listingOrder = 65
}