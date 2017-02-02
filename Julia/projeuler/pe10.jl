# project Euler #10

# The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

# Find the sum of all the primes below two million.

pmask = primesmask(2000000)
parray = find(pmask)
println(sum(parray))

# sum(primes(2000000))
