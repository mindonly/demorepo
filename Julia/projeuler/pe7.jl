# project Euler #7

# By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we can see
# that the 6th prime is 13.

# What is the 10 001st prime number?

using Primes

N = 10001
pmask = primesmask(125000)
parray = find(pmask)
println(parray[N])
