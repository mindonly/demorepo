#!/usr/bin/env julia

# project Euler #18: Maximum path sum 1

# By starting at the top of the triangle below and moving to adjacent numbers
# on the row below, the maximum total from top to bottom is 23.

#=
raw =
 [ 3,
  7, 4,
 2, 4, 6,
8, 5, 9, 3]
=#

# That is, 3 + 7 + 4 + 9 = 23.

# Find the maximum total from top to bottom of the triangle below:

# NOTE: As there are only 16384 routes, it is possible to solve this problem
# by trying every route. However, Problem 67 is the same challenge with a
# triangle containing one-hundred rows; it cannot be solved by brute force,
# and requires a clever method! ;o)

# Example: http://stackoverflow.com/questions/8002252/euler-project-18-approach

function setup()
                         raw = [75, #1 (1)
                              95, 64, #2-3 (2)
                            17, 47, 82, #4-6 (3)
                          18, 35, 87, 10, #7-10 (4)
                        20, 04, 82, 47, 65, #11-15 (5)
                      19, 01, 23, 75, 03, 34, #16-21 (6)
                    88, 02, 77, 73, 07, 63, 67, #22-28 (7)
                  99, 65, 04, 28, 06, 16, 70, 92, #29-36 (8)
                41, 41, 26, 56, 83, 40, 80, 70, 33, #37-45 (9)
              41, 48, 72, 33, 47, 32, 37, 16, 94, 29, #46-55 (10)
            53, 71, 44, 65, 25, 43, 91, 52, 97, 51, 14, #56-66 (11)
          70, 11, 33, 28, 77, 73, 17, 78, 39, 68, 17, 57, #67-78 (12)
        91, 71, 52, 38, 17, 14, 91, 43, 58, 50, 27, 29, 48, #79-91 (13)
      63, 66, 04, 68, 89, 53, 67, 30, 73, 16, 69, 87, 40, 31, #92-105 (14)
    04, 62, 98, 27, 23, 09, 70, 98, 73, 93, 38, 53, 60, 04, 23] #106-120 (15)
    triAr = Array{Array{Int64}}(15)
    triAr[1] = [raw[1]]
    j = 1
    k = 1
    for i = 2:15
        j = j + i - 1
        k = k + i
        triAr[i] = raw[j:k]
    end
    return triAr
end

function main()
    triRows = setup()
    nr = length(triRows)
    while length(triRows) > 1
        tempAr = Int64[]
        for i = 1:endof(triRows[nr-1])
            tCalc = triRows[nr-1][i] + max(triRows[nr][i], triRows[nr][i+1])
            push!(tempAr, tCalc)
        end
        pop!(triRows)
        pop!(triRows)
        push!(triRows, tempAr)
        nr = length(triRows)
    end
    println(pop!(triRows))
end

@time main()
