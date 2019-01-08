#!/usr/local/bin/julia

f = open("digits-training.classes")

lines = readlines(f)

dclassv = Vector{Int}()
for line in lines
    push!(dclassv, parse(Int, line))
end

repeats = 0
prev = nothing
for (i, item) in enumerate(dclassv)
    if item == prev
        println(i-1, " $i $prev $item")
        println()
        repeats += 1
    end
    prev = item
end

println("repeats: $repeats")

close(f)
