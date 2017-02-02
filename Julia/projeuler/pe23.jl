#!/usr/bin/env julia

# project Euler #23: Non-abundant sums

# A perfect number is a number for which the sum of its proper divisors is
# exactly equal to the number. For example, the sum of the proper divisors
# of 28 would be 1 + 2 + 4 + 7 + 14 = 28, which means that 28 is a perfect
# number.

# A number n is called deficient if the sum of its proper divisors is less
# than n and it is called abundant if this sum exceeds n.

# As 12 is the smallest abundant number, 1 + 2 + 3 + 4 + 6 = 16,
# the smallest number that can be written as the sum of two abundant
# numbers is 24. By mathematical analysis, it can be shown that all
# integers greater than 28123 can be written as the sum of two abundant
# numbers. However, this upper limit cannot be reduced any further by
# analysis even though it is known that the greatest number that cannot
# be expressed as the sum of two abundant numbers is less than this limit.

# Find the sum of all the positive integers which cannot be written as the
# sum of two abundant numbers.

# BIG HELP: http://codereview.stackexchange.com/questions/39946/[...]
# [...]optimizing-solution-for-project-euler-problem-23-non-abundant-sums

using Primes

function propdiv{T<:Integer}(n::T)
    n > 0 || throw(ArgumentError("number to be factored must be > 0, got $n"))
    n > 1 || return T[]
    !isprime(n) || return T[one(T), n]
    f = factor(n)
    d = T[one(T)]
    for (k, v) in f
        c = T[k^i for i in 0:v]
        d = d*c'
        d = reshape(d, length(d))
    end
    sort!(d)
    return d[1:end-1]
end

function isab(n::Int64)
    if n < 12 || isprime(n)
        return false
    end
    return sum(propdiv(n)) > n
end

function isabsum(n::Int64, arr::Array{Int64, 1}, set::Set{Int64})
    for i in arr
        if i > n
            return false
        elseif (n - i) in set
            return true
        end
    end
    return false
end

function main()
    lim = 28123
    abundants = Array{Int64, 1}()
    [ push!(abundants, x) for x in 12:lim if isab(x) ]
    abundants_set = Set{Int64}(abundants)
    nabsum = sum(x for x in 1:lim if !isabsum(x, abundants, abundants_set))
    println(nabsum)
end

@time main()
