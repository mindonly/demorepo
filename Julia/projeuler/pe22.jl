#!/usr/bin/env julia

# project Euler #22: Names score

# Using names.txt (right click and 'Save Link/Target As...'),
# a 46K text file containing over five-thousand first names,
# begin by sorting it into alphabetical order.
# Then working out the alphabetical value for each name,
# multiply this value by its alphabetical position in the
# list to obtain a name score.

# For example, when the list is sorted into alphabetical order,
# COLIN, which is worth 3 + 15 + 12 + 9 + 14 = 53, is the 938th
# name in the list. So, COLIN would obtain a score of 938 × 53 = 49714.

# What is the total of all the name scores in the file?

function nameScore(s::String)
    score = 0
    for i = 1:endof(s)
        score += Int64(s[i] - 64)
    end
    return score
end

function main()
    namesAr = sort(readcsv("p022_names.txt", String), 2)
    totScore = 0
    for i = 1:endof(namesAr)
        totScore += (i * nameScore(namesAr[i]))
    end
    println(totScore)
end

@time main()
