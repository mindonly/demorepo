# project Euler #9

# A Pythagorean triplet is a set of three natural numbers, a < b < c,
# for which, a^2 + b^2 = c^2

# For example, 3^2 + 4^2 = 9 + 16 = 25 = 5^2.

# There exists exactly one Pythagorean triplet for which a + b + c = 1000.
# Find the product abc.

prims = [03, 04, 05], [05, 12, 13], [08, 15, 17], [07, 24, 25],
        [20, 21, 29], [12, 35, 37], [09, 40, 41], [28, 45, 53],
        [11, 60, 61], [16, 63, 65], [33, 56, 65], [48, 55, 73],
        [13, 84, 85], [36, 77, 85], [39, 80, 89], [65, 72, 97]

for prim in prims
    for m = 20:30
        trip = prim .* m
        tripSum = sum(trip)
        if tripSum == 1000
            println("primitive: ", prim)
            println("m: ", m, " triple: ", trip, " sum: ", tripSum)
            println("product: ", prod(trip))
            break
        end
    end
end
