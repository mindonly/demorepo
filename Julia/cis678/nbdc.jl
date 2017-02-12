#!/usr/bin/env julia

#=
# machine learning:
# Naive Bayesian document classifier
=#

using DataFrames, StatPlots

    #=
    # initialize training dataset, global vocabulary
    # input: fn - training dataset filename (String)
    # output: data - training dataset as string lines (Vector)
    #          voc - global vocabulary, sorted + unique (String Vector)
    =#
function initrain(fn::String)
    f = open(fn)
    v = readstring(f)
    f = open(fn)
    data = readlines(f)
    voc = sort(unique(split(v)))
    return data, voc
end

    #=
    # initialize test dataset
    # input: fn - test dataset filename (String)
    # output: data - test data set as string lines (Vector)
    =#
function initest(fn::String)
    f = open(fn)
    data = readlines(f)
    return data
end

    #=
    # class list
    # output: known text classes, as a vector (String)
    =#
function classlist()
    return [ "atheism", "graphics", "mswindows", "pc", "mac",
             "xwindows", "forsale", "autos", "motorcycles", "baseball",
             "hockey", "cryptology", "electronics", "medicine", "space",
             "christianity", "guns", "mideastpolitics", "politics", "religion" ]
end

    #=
    # class prior probability
    # input: cls - class name (String)
    # output: class prior probability (Real)
    =#
function prior(cls::String)
    keys = classlist()
    N = 11293
    vals = [ 480/N, 584/N, 572/N, 590/N, 578/N,
             593/N, 585/N, 594/N, 598/N, 597/N,
             600/N, 595/N, 591/N, 594/N, 593/N,
             598/N, 545/N, 564/N, 465/N, 377/N ]
    pdict = Dict{String, Real}(zip(keys, vals))
    return pdict["$cls"]
end

    #=
    # build line index dictionary
    # input: dst - dataset type, "train" or "test" (String)
    # output: line index (Dictionary)
    =#
function lid(dst::String)
    cidx = classlist()
    if dst == "train"
        doccts = [ 480, 584, 572, 590, 578,
                   593, 585, 594, 598, 597,
                   600, 595, 591, 594, 593,
                   598, 545, 564, 465, 377 ]
    elseif dst == "test"
        doccts = [ 319, 389, 393, 392, 385,
                   392, 390, 395, 398, 397,
                   399, 396, 393, 396, 394,
                   398, 364, 376, 310, 251 ]
    end
    offs = Matrix{Int}(0, 2)
    i = 0
    j = i
    k = 1
    for cls in cidx
        i = i + doccts[k]
        k += 1
        offs = vcat(offs, [j+1 i])
        j = i
    end
    return Dict(cidx[k] => offs[k, :]' for k = 1:length(cidx))
end

    #=
    # avg. length of doc in a class (stemmed only)
    # (plotting ONLY; not part of learn() + validate() workflow)
    # input: none
    # output: displays a dataframe of avg. doc. length per class
    =#
function avglen()
    train = "forumTraining-stemmed.data"
    test = "forumTest-stemmed.data"
    cidx = classlist()
    train, voc = initrain(train)
    test = initest(test)
    trnlid = lid("train")
    tstlid = lid("test")
    avs = DataFrame(class = String[], trnav = Real[], tstav = Real[])
    for class in cidx
        fst = trnlid["$class"][1]
        lst = trnlid["$class"][2]
        trnav = round(mean(length.(train[fst:lst])))
        fst = tstlid["$class"][1]
        lst = tstlid["$class"][2]
        tstav = round(mean(length.(test[fst:lst])))
        push!(avs, [ class trnav tstav ])
    end
    # return sort(avs, cols = order(:tstav), rev = true)
    return avs
end

    #=
    # aggregate class text, using lid() output
    # input: ds - training dataset (Vector{String})
    #         f - class start line # (Int)
    #         l - class end line # (Int)
    # output: t - concatenanted class text (Array{String})
    =#
function classtext(ds::Vector{String},
                    f::Int, l::Int)
    t = Array{String}(1, 0)
    chunk = ds[f:l]
    for doc in chunk
        row = split(doc)
        s = row[2:end]
        t = hcat(t, reshape(s, 1, length(s)))
    end
    return t
end

    #=
    # build class/vocabulary probabilities dataarray
    # input: ctxt - a concatenated class text (Matrix{String})
    #         voc - global vocabulary (Vector{String})
    # output:  da - class/vocabulary dataarray (DataArray)
    =#
function cvda(ctxt::Matrix{String},
               voc::Vector{SubString{String}})
    da = DataArray(AbstractFloat[])
    n = length(ctxt)
    map = countmap(ctxt)
    for word in voc
        if haskey(map, word)
            nk = map[word]
        else
            nk = 0
        end
        ewo = (nk + 1) / (n + length(voc))
        push!(da, ewo)
    end
    return da
end

    #=
    # learn the training dataset
    # input: fn - training dataset filename (String)
    # output: df - class/vocabulary probabilities dataframe (DataFrame)
    =#
function learn(fn::String)
    println("\nlearning ...")
    traindset, vocab = initrain(fn)
    cidx = classlist()
    lidx = lid("train")
    df = DataFrame()
    df[:word] = DataArray(Array(vocab))
    for class in cidx
        first = lidx["$class"][1]
        last = lidx["$class"][2]
        clstxt = classtext(traindset, first, last)
        df[Symbol("$class")] = cvda(clstxt, vocab)
    end
    println("learning complete!")
    return df
end

    #=
    # classify a document, given a word probability dataframe
    # input: doc - document to classify (Vector{String})
    #        wdf - words dataframe (DataFrame)
    #        idf - internal processing (DataFrame)
    # output: predicted classname - index of the maximum probability class
    =#
function classify(doc::Vector{SubString{String}},
                  wdf::DataFrame,
                  idf::DataFrame)
    cidx = classlist()
    priorv = DataArray(Real[])
    for cls in cidx
        push!(priorv, prior("$cls"))
    end
    idf = similar(idf, 0)
    push!(idf, priorv')
    for word in doc
        if word in wdf[:word]
            push!(idf, DataArray(wdf[(wdf[:word] .== "$word"), :][2:end]))
        else
            continue
        end
    end
    cnb = similar(priorv, 0)
    for cls in cidx
        push!(cnb, sum(log10.(idf[Symbol("$cls")])))
    end
    return cidx[indmax(cnb)]
end

    #=
    # validate test dataset with classify()
    # input: fn - test dataset filename (String)
    #       wdf - words dataframe (DataFrame)
    #     class - class to validate (String)
    #      vlid - validation line index (Dictionary)
    # output: correct - number of correct predictions (Int)
    #          docnum - number of documents processed (Int)
    =#
function validate(fn::String,
                  wdf::DataFrame,
                  class::String,
                  vlid::Dict)
    idf = DataFrame(atheism = Real[], graphics = Real[], mswindows = Real[],
                    pc = Real[], mac = Real[], xwindows = Real[],
                    forsale = Real[], autos = Real[], motorcycles = Real[],
                    baseball = Real[], hockey = Real[], cryptology = Real[],
                    electronics = Real[], medicine = Real[], space = Real[],
                    christianity = Real[], guns = Real[],
                    mideastpolitics = Real[], politics = Real[],
                    religion = Real[])
    testdset = initest(fn)
    if haskey(vlid, class)
        fst = vlid["$class"][1]
        lst = vlid["$class"][2]
        ids = sample(fst:lst, 100, replace = false)
    else
        class = "ALL"
        # ids = sample(1:length(testdset), 10, replace = false)
        ids = collect(range(1, length(testdset)))
    end
    println("\n$class document ids:\n ", ids')
    tds = Vector{String}()
    for id in ids
        push!(tds, testdset[id])
    end
    docnum = length(tds)
    correct = 0
    i = 1
    println("\nclassifying ...")
    for doc in tds
        doc = split(doc)
        trueclass = doc[1]
        predclass = classify(doc, wdf, idf)
        if predclass == trueclass
            correct += 1
        end
        println("idx: ", ids[i], " pred: ", predclass, " true: ", trueclass)
        i += 1
    end
    println("classfication complete!")
    return correct, docnum
end

    #=
    # create and display plots
    # input: rundt - results data (DataFrame)
    # output: 3 plotly() plots
    =#
function doplots(rundt::DataFrame)
    plotly()
    co11pt = font(11, "Courier")
    co12pt = font(12, "Courier")
    #rundt = readtable("nb-results1.csv")
    cidx = classlist()
    avaccda = DataArray(Real[])
    avsperda = similar(avaccda, 0)
    avgacc = 0
    avgsper = 0
    for class in cidx
        for i in 1:nrow(rundt)
            if rundt[i, 1] == class
                avgacc += rundt[i, 5]
                avgsper += rundt[i, 7]
            end
        end
        avgacc = avgacc / 3
        avgsper = avgsper / 3
        push!(avaccda, avgacc)
        push!(avsperda, avgsper)
        avgacc = 0
        avgsper = 0
    end
    avlendf = avglen()
    xlabels = cidx
    bp = bar(xlabels, avlendf[:tstav], title = "avg. document length",
             legend = false, fillcolor = :blue, xrotation = 90,
             xaxis = ("classes", ), xguidefont = co11pt, xtickfont = co11pt,
             yaxis = ("word count"), yguidefont = co11pt, ytickfont = co11pt,
             yticks = 0:250:2000,
             titlefont = co12pt)
    sp1 = scatter(avlendf[:tstav], avaccda,
                 title = "avg. doc. length vs. avg. class accuracy",
                 legend = false, smooth = true, line = :red, linewidth = 2,
                 xaxis = ("average document length(words)"),
                 xguidefont = co11pt, xtickfont = co11pt,
                 yaxis = ("average accuracy"),
                 yguidefont = co11pt, ytickfont = co11pt,
                 titlefont = co12pt, bottom_margin = 5mm, top_margin = 5mm)
    sp2 = scatter(avsperda, avaccda,
                 title = "processing time vs. avg. class accuracy",
                 legend = false, smooth = true, line = :red, linewidth = 2,
                 xaxis = ("seconds per document"),
                 xguidefont = co11pt, xtickfont = co11pt, xticks = 0:0.5:3,
                 yaxis = ("average accuracy"),
                 yguidefont = co11pt, ytickfont = co11pt,
                 titlefont = co12pt, bottom_margin = 5mm, top_margin = 5mm)
    display(bp)
    display(sp1)
    display(sp2)
end

    #=
    # main function
    # input: runs - number of classification runs per class (Int)
    =#
function main(runs)
    # train = "forumTraining.data"
    # test = "forumTest.data"
    train = "forumTraining-stemmed.data"
    test = "forumTest-stemmed.data"
    println("  TRAIN dataset: ", train)
    println("   TEST dataset: ", test)
    @time wdf = learn(train)
    rundf = DataFrame(class = String[], run = Int[], ndocs = Int[],
                  correct = Int[], accuracy = Real[],
                  seconds = Real[], sperdoc = Real[])
    matches = 0
    docnum = 0
    accuracy = 0.0
    tstlid = lid("test")
    # class = "ALL"
    for class in classlist()
        for i = 1:runs
            tic()
            matches, docnum = validate(test, wdf, class, tstlid)
            secs = toc()
            sper = round(secs/docnum, 1)
            secs = round(secs, 1)
            accuracy = round(matches/docnum * 100, 2)
            push!(rundf, [ class i docnum matches accuracy secs sper ])
            println("\ndocuments: ", docnum, " matches: ", matches)
            println("accuracy: ", accuracy, " %")
        end
    end
    showall(rundf)
    writetable("nbdc.csv", rundf)
    println("\nAGGREGATE RUN ACCURACY: ",
            round(sum(rundf[:correct]) / sum(rundf[:ndocs]) * 100, 2), " %")
    doplots(rundf)
end

@time main(3)
