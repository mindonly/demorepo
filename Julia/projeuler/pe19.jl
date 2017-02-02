#!/usr/bin/env julia

# project Euler # 19: Counting Sundays

# You are given the following information, but you may prefer to do
# some research for yourself.

# 1 Jan 1900 was a Monday.
# Thirty days has September,
# April, June and November.
# All the rest have thirty-one,
# Saving February alone,
# Which has twenty-eight, rain or shine.
# And on leap years, twenty-nine.
# A leap year occurs on any year evenly divisible by 4,
# but not on a century unless it is divisible by 400.

# How many Sundays fell on the first of the month during
# the twentieth century (1 Jan 1901 to 31 Dec 2000)?

function isLeap(yr::Int64)
    if yr % 400 == 0 || (yr % 4 == 0 && yr % 100 != 0)
        return true
    end
    return false
end

function moDays(yr::Int64, mo::Int64)
    mdAr = [ 31 28 31 30 31 30 31 31 30 31 30 31 ]
    if mo == 2 && isLeap(yr)
        return 29
    end
    return mdAr[mo]
end

function main()
    # 0=Sun 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri 6=Sat
    wkDay = 2
    byr = 1901
    eyr = 2000
    sunCt = 0
    for year = byr:eyr
        for month = 1:12
            for day = 1:moDays(year, month)
                if day == 1 && wkDay == 0
                    sunCt = sunCt + 1
                end
                wkDay = (wkDay + 1) % 7
            end
        end
    end
    return sunCt
end

@time println(main())
