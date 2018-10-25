#charset "latin1"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of TIMESYS, a TADS 3 Library Extension Package
 *
 *  ts_track_de_de.t
 *
 *  Modifications to adv3 de_de
 *
 *  The TS_TRACK_EN_US module isolates english representations of date and
 *  time, as well as names for months and days.
 */

#include <de_de.h>
#include "timesys.h"

/*
 *  Add a full datetime command
 *  to the library messages.
 */
modify libMessages
{   
    commandFullDateTime = 'Zeit'
}

class LangTimePiece: VocabObject
{
    calendarMask_   = CalendarMask
    clockMask_      = ClockMask
        
    dayMask_        = 'ddddddddd'

    dateMask_       = 'ddddddddd, dd. mmmmmmmmm yyyy'
    
        timeMask_       = 'h:mm:ss tttt'

    /*--------------------------------------------------------------
     *  Methods for setting and getting day/date/time masks
     */
    setDayMask(mask)
    {
        dayMask_ = mask;
    }
    setDateMask(mask)
    {
        dateMask_ = mask;
    }
    setTimeMask(mask)
    {
        timeMask_ = mask;
    }
    getDayMask()
    {
        return dayMask_;
    }
    getDateMask()
    {
        return dateMask_;
    }
    getTimeMask()
    {
        return timeMask_;
    }

    /*--------------------------------------------------------------
     *  Methods producing date/time strings
     */
    toDayString(jdn)
    {
        return calendarMask_.formatDate(getDayMask(), getCalendar(), 
            jdn);
    }
    toDateString(jdn)
    {
        return calendarMask_.formatDate(getDateMask(), getCalendar(),
            jdn);
    }
    toTimeString(clockRatio)
    {
        return clockMask_.formatTime(getTimeMask(), getClock(), 
            clockRatio);
    }
    toDateTimeString(jdn, clockRatio) 
    { 
        return toDateString(jdn) 
            + ' ' 
            + toTimeString(clockRatio);
    }

    construct()
    {
        inherited();
    }
}

class Mask: object
{
    buildMaskVector(v, mask)
    {
        local s = 1, f = 1;

        for (local i = 2; i <= mask.length(); ++i)
        {
            if (mask.substr(i, 1) == mask.substr(i-1, 1))
                f++;
            else
            {
                v += mask.substr(s, f);
                s = i; 
                f = 1;
            }
        }

        v += mask.substr(s, f);

        return v;
    }
}

class CalendarMask: Mask
{
    year_       = nil
    month_      = nil
    day_        = nil
        
    monthsOfYear    = ['Januar', 'Februar', 'März', 'April', 
        'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 
        'November', 'Dezember']
    
    daysOfWeek      = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 
        'Donnerstag', 'Freitag', 'Samstag']
           
    formatDate(dateMask, calendar, jdn)
    {
        local lst, ret, v, str = '';

        lst     = calendar.toDate(jdn);
        year_   = lst[1];
        month_  = lst[2];
        day_    = lst[3];
        dow_    = calendar.toDayOfWeek(jdn);
        
        v = new Vector(20);
        
        v = buildMaskVector(v, dateMask);

        for (local i = 1; i <= v.length(); ++i)
        {
            ret = formatYear(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }

            ret = formatMonth(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }
            
            ret = formatDay(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }

            str += v[i];
        }

        return str;
    }
    formatYear(val)
    {
        local year, ret;
        
        ret = rexSearch('y+', val);
        if (ret == nil)
            return nil;

        year = toInteger(year_);

        val = toString(year);
        if (ret[2] == 2)
            val = val.substr(3,2);
        
        return val;
    }
    formatMonth(val)
    {
        local month, ret, str = '';
        
        ret = rexSearch('m+', val);
        if (ret == nil)
            return nil;

        month = toInteger(month_);

        if (ret[2] > 2)
            val = monthsOfYear[month].substr(1, ret[2]);
        else
        {
            val = month;
            if (ret[2] == 2)
            {
                if (val < 10)
                    str += '0';
                str += toString(val);

                val = str;
            }
        }
        
        return val;
    }
    formatDay(val)
    {
        local dow, day, ret, str = '';
        
        ret = rexSearch('d+', val);
        if (ret == nil)
            return nil;

        dow = toInteger(dow_);
        day = toInteger(day_);

        if (ret[2] > 2)
            val = daysOfWeek[dow].substr(1, ret[2]);
        else
        {
            val = day;
            if (ret[2] == 2)
            {
                if (val < 10)
                    str += '0';
                str += toString(val);

                val = str;
            }
        }
        
        return val;
    }
}

class ClockMask: Mask
{
    hour_       = nil
    minute_     = nil
    second_     = nil
    noonHours_  = nil

    formatTime(timeMask, clock, clockRatio)
    {
        local lst, ret, v, str = '';

        lst         = clock.toTime(clockRatio);
        hour_       = lst[1];
        minute_     = lst[2];
        second_     = lst[3];
        noonHours_  = clock.noonHours_;
        
        v = new Vector(20);
        
        v = buildMaskVector(v, timeMask);

        for (local i = 1; i <= v.length(); ++i)
        {
            ret = format24Hour(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }

            ret = format12Hour(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }

            ret = formatMinute(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }
            
            ret = formatSecond(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }

            ret = formatMarker(v[i]);
            if (ret)
            {
                str += ret;
                continue;
            }

            str += v[i];
        }

        return str;
    }

    format24Hour(val)
    {
        local ret, str = '';
        
        ret = rexSearch('H+', val);
        if (ret == nil)
            return nil;
 
        val = hour_;
        if (ret[2] > 1)
        {
            if (val < 10)
                str += '0';
            str += toString(val);

            val = str;
        }
        else
            val = toString(val);

        return val;
    }
        
    format12Hour(val)
    {
        local ret, str = '';
        
        ret = rexSearch('h+', val);
        if (ret == nil)
            return nil;

        val = hour_;
        if (val == 0)
            val = noonHours_;
        else if (val > noonHours_)
            val -= noonHours_;

        if (ret[2] > 1)
        {
            if (val < 10)
                str += '0';
            str += toString(val);

            val = str;
        }
        else
            val = toString(val);

        return val;
    }

    formatMinute(val)
    {
        local ret, str = '';
        
        ret = rexSearch('m+', val);
        if (ret == nil)
            return nil;

        val = minute_;
        if (ret[2] > 1)
        {
            if (val < 10)
                str += '0';
            str += toString(val);

            val = str;
        }
        else
            val = toString(val);

        return val;
    }

    formatSecond(val)
    {
        local ret, str = '';
        
        ret = rexSearch('s+', val);
        if (ret == nil)
            return nil;

        val = second_;
        if (val == nil)
            val = 0;

        if (ret[2] > 1)
        {
            if (val < 10)
                str += '0';
            str += toString(val);

            val = str;
        }
        else
            val = toString(val);

        return val;
    }

    formatMarker(val)
    {
        local ret, h;
        
        ret = rexSearch('[tT]+', val);
        if (ret == nil)
            return nil;

        h = hour_;
        if (h < noonHours_)
            if (val == val.toLower())
                val = 'a';
            else
                val = 'A';
        else
            if (val == val.toLower())
                val = 'p';
            else
                val = 'P';

        if (ret[2] > 2)
            val += '.';

        if (ret[2] > 1)
            if (val == val.toLower())
                val += 'm';
            else
                val += 'M';

        if (ret[2] > 2)
            val += '.';

        return val;
    }
}


VerbRule(Time)
    'zeit' | 'uhrzeit' | 'zeitangabe'
    : TimeAction
    verbPhrase = 'die Zeit anzuzeigen/die Zeit anzeigen (was)'
;