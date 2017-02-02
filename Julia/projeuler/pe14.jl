#!/usr/bin/env/julia

# project Euler #14: Longest Collatz sequence

# The following iterative sequence is defined for the set of positive integers:
# n → n/2 (n is even)
# n → 3n + 1 (n is odd)
# Using the rule above and starting with 13, we generate the following sequence:

# 13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1
# It can be seen that this sequence
# (starting at 13 and finishing at 1) contains 10 terms.
# Although it has not been proved yet (Collatz Problem),
# it is thought that all starting numbers finish at 1.

# Which starting number, under one million, produces the longest chain?

# NOTE: Once the chain starts the terms are allowed to go above one million.

function collatz(n::Int64)
    if n == 1
        return -1
    elseif n % 2 == 0
        result = Int64(n/2)
    else
        result = Int64(3n + 1)
    end
    return result
end

function main()
    chainAr = Int64[]
    for n = 1:999999
        chainlen = 0
        while n != -1
            n = collatz(n)
            chainlen = chainlen + 1
        end
        push!(chainAr, chainlen)
    end
    println(indmax(chainAr), " ", maximum(chainAr), "\n")
end

@time main()
