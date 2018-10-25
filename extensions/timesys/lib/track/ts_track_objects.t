#charset "us-ascii"

/* 
 *  Copyright (c) 2001-2004 by Kevin Forchione. All rights reserved.
 *   
 *  This file is part of the TADS3 TimeSys Library Extension
 *
 *  ts_track_objects.t
 */

/* include the TimeSys header file */
#include "timesys.h"

/* 
 *  The WallClock class serves as a converter between a zero-point and
 *  and the Schedulable.gameClockTime.
 */
class WallClock: TimePiece
{
    initDate_   = [GregorianCalendar, 1887, 6, 17]
    initTime_   = [Clock, 5, 0, 0]
    initRate_   = 1

    construct()
    {
        inherited TimePiece(initDate_, initTime_, initRate_);
    }
}

class TimePiece: LangTimePiece
{
    initDateTime_   = nil
    currDateTime_   = nil

    year_           = nil
    month_          = nil
    day_            = nil
    dow_            = nil
    hour_           = nil
    minute_         = nil
    second_         = nil    

    calendar_       = nil
    clock_          = nil

    minPerGctu_     = static new BigNumber(1)

    /*--------------------------------------------------------------
     *  Methods for setting  and getting initial datetime attributes
     */

    /*
     *  Sets the timepiece's initial datetime value using
     *  calendarParms [Calendar, year, month, day], clockParms
     *  [Clock, hour, minute, second], and optional rate.
     */
    setInitDateTime(calendarParms, clockParms, [rate])
    {
        local jdn, clockRatio;

        setCalendar(calendarParms.car());
        setClock(clockParms.car());

        initDateTime_   = getDateTime(calendarParms.cdr()..., 
            clockParms.cdr()...);

        jdn             = getInitJdn();
        clockRatio      = getInitClockRatio();

        setDateVals(jdn);
        setDayOfWeek(jdn);
        setTimeVals(clockRatio);

        if (rate.length())
            setTimeRate(rate...); 
    }

    /*
     *  Returns the timepiece's initial julian day number.
     */
    getInitJdn()
    {
        return initDateTime_.getWhole();
    }

    /*
     *  Returns the timepiece's initial clockratio. A clockration
     *  is a BigNumber representation of time in seconds divided by
     *  total seconds per day. 
     */
    getInitClockRatio()
    {
        return initDateTime_.getFraction();
    }

    /*
     *  Returns the timepiece's initial datetime value.
     */
    getInitDateTime()
    {
        return initDateTime_;
    }

    /*
     *  Returns the timepiece's initial datetime string 
     *  representation, suitable for display.
     */
    getInitDateTimeString()
    {
        return toDateTimeString(getInitJdn(), getInitClockRatio());
    }

    /*--------------------------------------------------------------
     *  Methods for setting  and getting current datetime attributes
     */

    /*
     *  Sets the timepiece's current datetime value for the 
     *  corresponding game clock time unit.
     */
    setCurrDateTime(gctu)
    {
        local incrAmt, incrDateTime;
        local jdn, clockRatio;

        incrAmt = cvtGctuToMin(gctu);

        incrAmt = toInteger(incrAmt.roundToDecimal(0));

        incrDateTime = getClock().toDateTime(0, incrAmt, 0);

        currDateTime_ = initDateTime_ + incrDateTime;

        jdn         = getCurrJdn();
        clockRatio  = getCurrClockRatio();

        setDateVals(jdn);
        setDayOfWeek(jdn);
        setTimeVals(clockRatio);
    }

    /*
     *  Returns the timepiece's current julian day number.
     */
    getCurrJdn()
    {
        return currDateTime_.getWhole();
    }

    /*
     *  Return the timepiece's current clockratio. A clockratio is 
     *  a BigNumber representation of the time as a ratio of seconds
     *  divided by seconds-per-day.
     */
    getCurrClockRatio()
    {
        return currDateTime_.getFraction();
    }

    /*
     *  Returns the timepiece's current datetime.
     */
    getCurrDateTime()
    {
        return currDateTime_;
    }

    /*
     *  Returns the timepiece's current datetime value string, 
     *  suitable for display.
     */
    getCurrDateTimeString()
    {
        return toDateTimeString(getCurrJdn(), getCurrClockRatio());
    }

    /*--------------------------------------------------------------
     *  Methods for setting general timepiece attributes
     */

    /*
     *  Sets the timepiece's calendar object. This object is used
     *  in all calendar date computations for the timepiece.
     */
    setCalendar(calendar)
    {
        calendar_ = calendar;
    }

    /*
     *  Sets the timepiece's clock object. This object is used
     *  in all time computations for the timepiece.
     */
    setClock(clock)
    {
        clock_ = clock;
    }

    /*
     *  Sets the timepiece's timerate. The timerate controls
     *  the rate at which the timepiece's time passes per game 
     *  clock time unit.
     */
    setTimeRate(rate)
    {
        if (dataType(rate) == TypeInt)
            rate = new BigNumber(rate);

        minPerGctu_ = rate;
    }

    /*
     *  Sets the timepiece's date values for this julian day number.
     *
     *  This does not set the timepiece's corresponding datetime value,
     *  and is used to support setInitDateTime() and setCurrDateTime()
     *  methods.
     */
    setDateVals(jdn)
    {
        local lst;

        lst     = getCalendar().toDate(jdn);

        year_   = lst[1];
        month_  = lst[2];
        day_    = lst[3];
    }

    /*
     *  Sets the timepiece's day-of-week value for this julian
     *  day number. 
     *
     *  This does not set the timepiece's corresponding datetime value,
     *  and is used to support setInitDateTime() and setCurrDateTime()
     *  methods.
     */
    setDayOfWeek(jdn)
    {
        dow_    = getCalendar().toDayOfWeek(jdn);
    }

    /*
     *  Sets the timepiece's time value for this clockratio. 
     *
     *  This does not set the timepiece's corresponding datetime value,
     *  and is used to support setInitDateTime() and setCurrDateTime()
     *  methods.
     */
    setTimeVals(clockRatio)
    {
        local lst;

        lst     = getClock().toTime(clockRatio);

        hour_   = lst[1];
        minute_ = lst[2];
        second_ = lst[3];
    }

    /*--------------------------------------------------------------
     *  Methods returning general timepiece attributes
     */

    /*  
     *  Returns the timepiece's calendar object. This object is
     *  used in all of the timepiece's calendar date computations.
     */
    getCalendar()
    {
        return calendar_;
    }

    /*
     *  Returns the timepiece's clock object. This object is
     *  used in all of the timepiece's clock time computations.
     */
    getClock()
    {
        return clock_;
    }

    /*
     *  Returns the BigNumber object representing the
     *  minutes-per-gameclock-time-unit. ratio.
     */
    getTimeRate()
    {
        if (dataType(minPerGctu_) == TypeInt)
            return new BigNumber(minPerGctu_);
        else
            return minPerGctu_;
    }

    /*
     *  Returns the datetime value for the timepiece's calendar
     *  and clock values for the year, month, day, hour, minute,
     *  and second passed.
     */
    getDateTime(year, month, day, hour, minute, second)
    {
        local date, time;

        date = getCalendar().toDateTime(year, month, day);

        time = getClock().toDateTime(hour, minute, second);

        return date + time;
    }

    /*
     *  Returns the [year, month, day] values for the 
     *  timepiece's calendar for the julian day number
     *  passed.
     */
    getDateVals(jdn)
    {
        return getCalendar().toDate(jdn);
    }

    /*
     *  Returns the day-of-week value for the timepiece's calendar
     *  for the julian day number argument.
     */
    getDayOfWeek(jdn)
    {
        return getCalendar().toDayOfWeek(jdn);
    }

    /*
     *  Returns the timepiece's clock time values [hours, minutes, seconds]
     *  for the given clockRatio.
     */
    getTimeVals(clockRatio)
    {
        return getClock().toTime(clockRatio);
    }

    /*--------------------------------------------------------------
     *
     *  An abstract method for converting minutes to 
     *  game clock time units based on this timepiece's
     *  time conversion ratio.
     */
    cvtMinToGctu(minutes)
    {
        if (dataType(minutes) == TypeInt)
            minutes = new BigNumber(minutes);

        return minutes / getTimeRate();
    }

    /*
     *  Converts Game Clock Time Units 
     *  to minutes based on this timepiece's
     *  time conversion ratio.
     */
    cvtGctuToMin(gctu)
    {
        if (dataType(gctu) == TypeInt)
            gctu = new BigNumber(gctu);

        return gctu * getTimeRate();
    }

    /*--------------------------------------------------------------
     *  Set the initial date, time, and rate
     */
    construct(calendarParms, clockParms, [rate])
    {
        inherited();
        
        setInitDateTime(calendarParms, clockParms, rate...);

        setCurrDateTime(0);
    }
}

/*
 *  Calendar class
 */
class Calendar: object
{
    daysPerWeek = 7

    /*
     *  Returns the day of the week as an BigNumber
     *  value between 1 and 7.
     */
    toDayOfWeek(jdn)
    {
        if (dataType(jdn) == TypeInt)
            jdn = new BigNumber(jdn);

        return ((jdn + 2).divideBy(daysPerWeek))[2] + 1;
    }

    /*
     *  Returns a datetime value
     *  for this date.
     */
    toDateTime(year, month, day)
    {
        return toJulianDayNumber(year, month, day);
    }
}

/*
 *  Gregorian Calendar converts between julian day numbers
 *  and gregorian dates.
 */
class GregorianCalendar: Calendar
{
    /*
     *  Convert Julian Day Number to a Gregorian Date.
     */
    toDate(jdn)
    {
        local z, r, a, b, c, f, year, month, day;

        if (dataType(jdn) == TypeInt)
            jdn = new BigNumber(jdn);

        z = INT(jdn - 1721118.5);
        r = (jdn - 1721118.5) - z;
        
        /* calculate the number of full centuries */
        a = INT((z - 0.25)/36524.25);
        
        /*
         *  Calculate the days within the whole centuries (in the Julian
         *  Calendar) by adding back days removed in the Gregorian
         *  Calendar. 
         */
        b = z - 0.25 + a - INT(a/4);

        /*
         *  Calculate the year in a calendar whose years start on March 1
         */
        year = INT(b/365.25);
         
        /*
         *  Calculate the day count in the current year.
         */
        c = (b - INT(FIX(year*365.25))) + 1;
        
        /* 
         *  Calculate the month in the current year.
         */
        month = FIX((c*5 + 456)/153);
        
        /* 
         *  Calculate the number of days in the preceding months in the
         *  current year.
         */
        f = FIX((month*979 - 2918)/32);
        
        /*
         *  The Gregorian date's day of the month.
         */
        day = FIX(c - f + r);
        
        /*
         *  Convert the month and year to a calendar starting January 1.
         */
        year += FIX(month/13);
        month -= FIX(month/13) * 12;

        return [year, month, day];
    }

    /*
     *  Return the julian day number
     *  for this gregorian date.
     */
    toJulianDayNumber(year, month, day)
    {
        local z, f, jdn;

        if (dataType(year) == TypeInt)
            year = new BigNumber(year);
        if (dataType(month) == TypeInt)
            month = new BigNumber(month);
        if (dataType(day) == TypeInt)
            day = new BigNumber(day);

        z = year + FIX((month - 14)/12);

        f = FIX(((month - FIX((month - 14)/12)*12)*979 - 2918)/32);

        jdn = day + f + z*365 + INT(z/4) - INT(z/100) + INT(z/400) 
            + 1721118.5;

        return FIX(jdn);
    }
}

/*
 *  Julian Calendar converts between julian day numbers
 *  and julian dates.
 */
class JulianCalendar: Calendar
{
    /*
     *  Convert Julian Day Number to a Julian Date.
     */
    toDate(jdn)
    {
        local z, r, c, f, year, month, day;

        if (dataType(jdn) == TypeInt)
            jdn = new BigNumber(jdn);

        z = INT(jdn - 1721116.5);
        r = (jdn - 1721116.5) - z;

        /*
         *  Calculate the year in a calendar whose years
         *  start on March 1.
         */
        year = INT((z - 0.25)/365.25);

        /*
         *  Calculate the value of the day count in the 
         *  current year.
         */
        c = z - INT(year*365.25);

        /*
         *  Calculate the value of the month in the 
         *  current year.
         */
        month = FIX((c*5 + 456)/153);

        /*
         * Calculate the number of days in the preceding
         * months in the current year.
        */
        f = FIX((month*153 - 457)/5);
        
        day = FIX(c - f + r);

        year += FIX(month/13);

        month -= FIX(month/13) * 12;  
        
        return [year, month, day];
    }

    /*
     *  Returns the julian day number 
     *  for this julian date.
     */
    toJulianDayNumber(year, month, day)
    {
        local z, f, jdn;

        if (dataType(year) == TypeInt)
            year = new BigNumber(year);
        if (dataType(month) == TypeInt)
            month = new BigNumber(month);
        if (dataType(day) == TypeInt)
            day = new BigNumber(day);

        z = year + FIX((month - 14)/12);

        f = FIX(((month - FIX((month - 14)/12)*12)*979 - 2918)/32);

        jdn = day + f + z*365 + INT(z/4) + 1721116.5;

        return FIX(jdn);
    }
}

/*
 *  Clock converts between clock ratios
 *  and hours, minutes, and seconds.
 */
class Clock: object
{
    hoursPerDay         = 24
    minutesPerHour      = 60
    secondsPerMinute    = 60

    secondsPerDay_      = (hoursPerDay 
                            * minutesPerHour * secondsPerMinute)

    minutesPerDay_      = (hoursPerDay * minutesPerHour)
    
    secondsPerHour_     = (minutesPerHour * secondsPerMinute)

    /*
     *  These values represent the number of hours or minutes or
     *  seconds from midnight until noon.
     */
    noonHours_          = (hoursPerDay / 2)
    noonMinutes_        = (noonHours_ * minutesPerHour)
    noonSeconds_        = (noonMinutes_ * secondsPerMinute)

    /*
     *  Returns the hour, minute, and second
     *  for this clock ratio.
     */
    toTime(clockRatio)
    {
        local time, hour, minute, second;

        time    = (clockRatio * secondsPerDay_).roundToDecimal(0);
        time    = toInteger(time);

        hour    = time / (minutesPerHour * secondsPerMinute);
        minute  = (time / secondsPerMinute) % minutesPerHour;
        second  = time % secondsPerMinute;

        return [hour, minute, second];
    }

    /*
     *  Returns the clock ratio
     *  for this hour, minute, and second.
     */
    toClockRatio(hour, minute, second)
    {
        return toDateTime(hour, minute, second).getFraction();
    }

    /*
     *  Returns the datetime value
     *  for this hour, minute, and second.
     */
    toDateTime(hour, minute, second)
    {
        local time, dt;

        time = (hour * minutesPerHour * secondsPerMinute)
            + (minute * secondsPerMinute)
            + second;
            
        dt = new BigNumber(time) / secondsPerDay_;

        return dt;
    }
}