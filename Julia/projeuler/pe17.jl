#!/usr/bin/env julia

# project Euler #17: Number letter counts

# If the numbers 1 to 5 are written out in words:
# one, two, three, four, five, then there are
# 3 + 3 + 5 + 4 + 4 = 19 letters used in total.

# If all the numbers from 1 to 1000 (one thousand) inclusive were
# written out in words, how many letters would be used?

# NOTE: Do not count spaces or hyphens. For example, 342
# (three hundred and forty-two) contains 23 letters and
# 115 (one hundred and fifteen) contains 20 letters.
# The use of "and" when writing out numbers is in compliance with British usage.

nd = Dict{Int64, String}()
nd[1000] = "one thousand"
nd[900] = "nine hundred"
nd[800] = "eight hundred"
nd[700] = "seven hundred"
nd[600] = "six hundred"
nd[500] = "five hundred"
nd[400] = "four hundred"
nd[300] = "three hundred"
nd[200] = "two hundred"
nd[100] = "one hundred"
nd[90] = "ninety"
nd[80] = "eighty"
nd[70] = "seventy"
nd[60] = "sixty"
nd[50] = "fifty"
nd[40] = "forty"
nd[30] = "thirty"
nd[20] = "twenty"
nd[19] = "nineteen"
nd[18] = "eighteen"
nd[17] = "seventeen"
nd[16] = "sixteen"
nd[15] = "fifteen"
nd[14] = "fourteen"
nd[13] = "thirteen"
nd[12] = "twelve"
nd[11] = "eleven"
nd[10] = "ten"
nd[9] = "nine"
nd[8] = "eight"
nd[7] = "seven"
nd[6] = "six"
nd[5] = "five"
nd[4] = "four"
nd[3] = "three"
nd[2] = "two"
nd[1] = "one"

function chunk(n::Int64)
    chunkAr = Any[]
    places = length(digits(n))
    if places == 4
        push!(chunkAr, 1000)
    elseif places == 3
        huns = digits(n)[3] * 100
        tens = digits(n)[2] * 10
        units = digits(n)[1] * 1
        if tens < 20
            if n % 100 == 0
                push!(chunkAr, huns)
            else
                tens = tens + units
                push!(chunkAr, huns, "and", tens)
            end
        else
            push!(chunkAr, huns, "and", tens, units)
        end
    elseif places == 2
        tens = digits(n)[2] * 10
        units = digits(n)[1] * 1
        if tens < 20
            tens = tens + units
            push!(chunkAr, tens)
        elseif units > 0
            push!(chunkAr, tens, units)
        else
            push!(chunkAr, tens)
        end
    elseif places == 1
        units = digits(n)[1] * 1
        push!(chunkAr, units)
    end
    return chunkAr
end

function main()
    lc = 0
    for n = 1:1000
        stringAr = String[]
        for ch in chunk(n)
            if isa(ch, Int64) && ch > 0
                push!(stringAr, nd[ch])
            elseif ch == "and"
                push!(stringAr, ch)
            end
        end
        wordNum = join(stringAr, " ")
        strippedWordNum = join(split(wordNum, " "))
        #println("$n: ", wordNum, " ", length(strippedWordNum))
        lc = lc + length(strippedWordNum)
    end
    println("letter count: $lc")
end

@time main()
