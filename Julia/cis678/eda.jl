#!/usr/bin/env julia

using DataFrames, StatPlots

    # read in text body
function getcorpus(filename::String)
    f = open(filename)
    corpus = readstring(f)
    close(f)
    return corpus
end

    # count sentences in text body
function countsent(text::String)
    sent = split(text, r"\w[.!?][\"\s]+\w", keep = false)
    return length(sent)
end

    # count syllables and other tidbits
function countsyl(words::Array{SubString{String}})
    shorts = 0
    syl2 = 0
    syl3 = 0
    syl4 = 0
    syl5 = 0
    longs = 0
    syllables = 0
    sylregex = Regex("[AaEeIiOoUuYy]{1,3}")
    for word in words
        word = rstrip(string(word), ['.', '!', '?', ':', ';'])
        word = rstrip(word, 'e')
        if length(word) <= 3
            syllables += 1
            shorts += 1
            continue
        end
        m = matchall(sylregex, word)
        if length(m) == 2
            syl2 += 1
        elseif length(m) == 3
            syl3 += 1
        elseif length(m) == 4
            syl4 += 1
        elseif length(m) == 5
            syl5 += 1
        elseif length(m) > 5
            longs += 1
        else
            shorts += 1
        end
        syllables += length(m)
    end
    return syllables, shorts, syl2, syl3, syl4, syl5, longs
end

    # search directory path for filenames given key
function searchdir(path::String, key::String)
    return filter(x->endswith(x, key), readdir(path))
end

    # compute Flesch-Kincaid
function flesch(nsents::Int, nwords::Int, nsyls::Int)
    fi = 206.835 - (84.6 * (nsyls/nwords)) - (1.015 * (nwords/nsents))
    return round(fi, 3)
end

    # build the dataframe
function builddf(dir::String)
    files = searchdir(dir, ".txt")
    df = DataFrame(filename = String[], Flesch = AbstractFloat[],
                   wsratio = AbstractFloat[], wlratio = AbstractFloat[],
                   sentences = Int[], words = Int[], shorts = Int[],
                   syl2 = Int[], syl3 = Int[], syl4 = Int[], syl5 = Int[],
                   longs = Int[], syllables = Int[])
    for file in files
        text = getcorpus(file)
        sents = countsent(text)
        words = split(text)
        nwords = length(words)
        syls, shorts, twos, threes, fours, fives, longs = countsyl(words)
        fidx = flesch(sents, nwords, syls)
        wsr = round(nwords/shorts, 3)
        wlr = round(nwords/(fours + fives + longs), 3)
        push!(df,
        [file fidx wsr wlr sents nwords shorts twos threes fours fives longs syls])
    end
    df = sort!(df, cols = :Flesch, rev = true)
    return df
end

    # generate graphs and plots
function doplots(dt::DataFrame)
    plotly()
    co11pt = font(11, "Courier")
    co12pt = font(12, "Courier")
    for i = 1:nrow(dt)
        file = dt[[i], :filename][1]
        da = DataArray(dt[i, [:syl2, :syl3, :syl4, :syl5, :longs]])
        dv = vec(Array(da))
        xlabels = ["2", "3", "4", "5", "≥6"]
        plot = bar(xlabels, dv, title=file, legend = false, fillcolor = :green,
                   xaxis=("# of syllables", (0, 5)),
                   xguidefont = co11pt, xtickfont = co11pt,
                   yaxis=("word count"),
                   yguidefont = co11pt, ytickfont = co11pt,
                   titlefont = co12pt,
                   bottom_margin = 40mm, right_margin = 30mm)
        display(plot)
    end
    wsratio = DataArray(dt[:wsratio])
    sp = scatter(wsratio, dt[:Flesch], title="W/S ratio vs. F-K score",
                 legend = false, smooth= true, line = :red, linewidth = 2,
                 xaxis=("words/shorts ratio"),
                 xguidefont = co11pt, xtickfont = co11pt,
                 yaxis=("Flesch-Kincaid score"),
                 yguidefont = co11pt, ytickfont = co11pt,
                 titlefont = co12pt,
                 bottom_margin = 40mm, right_margin = 30mm)
    display(sp)
    wlratio = DataArray(dt[:wlratio])
    lp = scatter(wlratio, dt[:Flesch], title="W/L ratio vs. F-K score",
                 legend = false, smooth= true, line = :red, linewidth = 2,
                 xaxis=("words/longs ratio"),
                 xguidefont = co11pt, xtickfont = co11pt,
                 yaxis=("Flesch-Kincaid score"),
                 yguidefont = co11pt, ytickfont = co11pt,
                 titlefont = co12pt,
                 bottom_margin = 40mm, right_margin = 30mm)
    display(lp)
end

    # compute k-syllable percentages
function calcpct(dt::DataFrame)
    dataf = DataFrame(filename = String[], shortpct = AbstractFloat[],
                      syl2pct = AbstractFloat[], syl3pct = AbstractFloat[],
                      syl4pct = AbstractFloat[], syl5pct = AbstractFloat[],
                      longpct = AbstractFloat[], lgrppct = AbstractFloat[])
    for i = 1:nrow(dt)
        file = dt[[i], :filename][1]
        shpct = round(dt[[i], :shorts][1] / dt[[i], :words][1] * 100, 1)
        pct2 = round(dt[[i], :syl2][1] / dt[[i], :words][1] * 100, 1)
        pct3 = round(dt[[i], :syl3][1] / dt[[i], :words][1] * 100, 1)
        pct4 = round(dt[[i], :syl4][1] / dt[[i], :words][1] * 100, 1)
        pct5 = round(dt[[i], :syl5][1] / dt[[i], :words][1] * 100, 1)
        lpct = round(dt[[i], :longs][1] / dt[[i], :words][1] * 100, 1)
        lgrp = round((dt[[i], :syl4][1] + dt[[i], :syl5][1] +
                     dt[[i], :longs][1]) / dt[[i], :words][1] * 100, 1 )
        push!(dataf, [file shpct pct2 pct3 pct4 pct5 lpct lgrp])
    end
    dataf = sort!(dataf, cols = :lgrppct, rev = true)
    return dataf
end

function main()
    data_dir = pwd()

    rawdf = builddf(data_dir)
    showall(rawdf)
    println()
    writetable("eda.csv", rawdf)

    #describe(rawdf)    // summary statistics
    doplots(rawdf)

    pctdf = calcpct(rawdf)
    showall(pctdf)
    println()
    writetable("eda_pct.csv", pctdf)
end

@time main()
