#!/usr/bin/env julia

# project Euler #15: Lattice paths

# Starting in the top left corner of a 2×2 grid, and only being able
# to move to the right and down, there are exactly
# 6 routes to the bottom right corner.

# How many such routes are there through a 20×20 grid?

# binomial coefficient:
# routes = C(n+k, n)
# e.g. on a 2x2 grid, routes = C(2+2, 2) -> C(4,2) = 6

# for a 20x20 grid, routes = C(20+20, 20) -> C(40, 20)

# this causes overflow!
# routes = factorial(40) / factorial(20) * factorial(20)

# so does this
#fact(n) = n == 0 ? 1 : big(n) * fact(n-1)
#println(fact(BigInt(40)))

# python 3.5.2
#>>> m.factorial(40) / (m.factorial(20) * m.factorial(20))
#137846528820.0

# this doesn't overflow at the Julia command line, but it does in Juno
number = factorial(BigInt(40)) / (factorial(BigInt(20)) * factorial(BigInt(20)))
println(Int64(number))
