# project Euler #5

# 2520 is the smallest number that can be divided by each
# of the numbers from 1 to 10 without any remainder.

# What is the smallest positive number that is evenly divisible
# by all of the numbers from 1 to 20?

n = 20

for r in range(2520, 10, 25000000)
    da = falses(n)
    da[1] = true
    for i = 2:n
        if r % i == 0
            da[i] = true
        else
            break
        end
        if da == trues(n)
            println(r)
        end
    end
end
