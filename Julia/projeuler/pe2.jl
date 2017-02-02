# project Euler #2

# Each new term in the Fibonacci sequence is generated
# by adding the previous two terms. By starting with 1 and 2,
# the first 10 terms will be: 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...
# By considering the terms in the Fibonacci sequence whose values
# do not exceed four million, find the sum of the even-valued terms.

tot = 0
limit = 20
fibArray = Int64[]

for n = 1:limit
    #println(n, " ", length(fibArray))
    if n <= 2
        fib = n
        push!(fibArray, fib)
    else
        #fib = fibArray[n] + fibArray[n-1]
        fib = fibArray[n-1] + fibArray[n-2]
        push!(fibArray, fib)
    end
    if fib <= 4000000 && fib % 2 == 0
        tot += fib
    end
    #println(n, " ", fibArray[n+1])
    println(n, " ", fibArray[n])
end

println(tot)
