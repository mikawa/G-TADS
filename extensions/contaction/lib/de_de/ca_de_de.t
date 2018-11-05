#charset "latin1"
/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS 3 Continuous Actions Library Extension
 *
 *  ca_de_de.t
 *
 *  The CA_EN_US module isolates english representations of continuous
 *  action elements.
 */

#include "contaction.h"

/* 
 *  A yes-or-no query for indicating whether to terminate a continuous
 *  action or not. The function takes one argument, the action to be
 *  terminated, and returns either true or nil in response to the 
 *  query.
 */
contActionYesOrNo(action)
{
        local str, ans, ret, pattern = '.*/ *(<Alpha>+) *%(?';
        local queryStr = '\bMöchtest du weiter ';

        /*
         *  Since we're about to ask the player a question in the 
         *  midst of a continuous action, update the status line.
         */
        statusLine.showStatusLine();

        /* format query to include the verb's -ing form */
        str = action.verbPhrase;
        ret = rexSearch(pattern, str);
        if (ret != nil)
            queryStr += rexGroup(1)[3];
        queryStr += '? ';

        say(queryStr);
        ans = yesOrNo();

        "\n";

        /* return the player's response */
        return ans;
}