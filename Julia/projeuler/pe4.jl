# project Euler #4

# A palindromic number reads the same both ways. The largest palindrome made
# from the product of two 2-digit numbers is 9009 = 91 × 99.
#
# Find the largest palindrome made from the product of two 3-digit numbers.

pal = 0

for i = 100:999
  for j = 100:999
    p = i * j
    pa = digits(p)
    if pa == reverse(pa) && p > pal
      pal = p
      println(pal, " palindrome! ", i, " ", j)
    end
  end
end
