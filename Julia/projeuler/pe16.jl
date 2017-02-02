#!/usr/bin/env julia

# 2^15 = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.

# What is the sum of the digits of the number 2^1000?

# use python to get the digits: >>> str(2**1000)

A = "10715086071862673209484250490600018105614048117055",
    "33607443750388370351051124936122493198378815695858",
    "12759467291755314682518714528569231404359845775746",
    "98574803934567774824230985421074605062371141877954",
    "18215304647498358194126739876755916554394607706291",
    "45711964776865421676604298316526243868372056680693",
    "76"

s = ""

for i = 1:length(A)
    s = string(s, A[i])
end

B = split(s, "")

total = 0
for i = 1:length(B)
    total += parse(Int64, B[i])
end

println(total)