# project Euler #1

# If we list all the natural numbers below 10
# that are multiples of 3 or 5, we get 3, 5, 6 and 9.
# The sum of these multiples is 23. Find the sum of
# all the multiples of 3 or 5 below 1000.

i = 1
tot = 0
limit = 1000

while i < limit
    if i % 3 == 0 || i % 5 == 0
        #println(i)
        tot += i
    end
    i += 1
end

println(tot)