#!/usr/bin/env julia

# project Euler #24: Lexicographic permutations

# A permutation is an ordered arrangement of objects. For example, 3124 is one
# possible permutation of the digits 1, 2, 3 and 4. If all of the permutations
# are listed numerically or alphabetically, we call it lexicographic order. The
# lexicographic permutations of 0, 1 and 2 are:

# 012   021   102   120   201   210

# What is the millionth lexicographic permutation of the digits
# 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9?

# http://theory.cs.uvic.ca/inf/perm/PermInfo.html
# https://mathlesstraveled.com/2013/01/03/the-steinhaus-johnson-trotter-algorithm/

function perm(n, p, pi, dir)
    if n >= (length(p) - 1)
        for i = 0:(length(p) - 1)
            print(p[i+1])
        end
    end

    println(n, p, pi, dir)
    perm(n+1, p, pi, dir)
    #=for i = 1:n-1
        @printf("     (%d %d)\n", pi[n], pi[n] + dir[n])
        z = p[pi[n] + dir[n]]
        p[pi[n]] = z
        p[pi[n] + dir[n]] = n
        pi[z] = pi[n]
        pi[n] = pi[n] + dir[n]

        perm(n+1, p, pi, dir);
    end
    dir[n] = -dir[n];=#
end

function perm(n)
    p = Array{Int64, 1}(n)
    pi = Array{Int64, 1}(n)
    dir = Array{Int64, 1}(n)
    for i = 0:n-1
        dir[i+1] = -1
        p[i+1] = i
        pi[i+1] = i
    end
    perm(0, p, pi, dir)
    println("     (0 1)\n")

    println(dir)
    println(p)
    println(pi)
end

perm(4)
