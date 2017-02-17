#!/usr/bin/env julia

import  StatsBase: countmap, sample
import  DataFrames: DataFrame, writetable

    #=
    # initialize training dataset, global vocabulary
    # input:    fn - training dataset filename (String)
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
    # input:    fn - test dataset filename (String)
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
    # aggregate class text, using lid() output
    # input: ds - training dataset (Vector{String})
    #         f - class start line # (Int)
    #         l - class end line # (Int)
    # output: t - concatenanted class text (Array{String})
    =#
function classtext(ds::Vector{String},
                    f::Int,
                    l::Int)
    t = Array{String}(1, 0)
    chunk = ds[f:l]
    for doc in chunk
        row = split(doc)
        # s = row[1:end]
        # t = hcat(t, reshape(s, 1, length(s)))
        t = hcat(t, reshape(row, 1, length(row)))
    end
    return t
end

    #=
    # build class/word dictionary
    # input: ctxt - a concatenated class text (Matrix{String})
    #         voc - global vocabulary (Vector{String})
    # output:  wd - word dictionary (Dict)
    =#
function cwd(ctxt::Matrix{String},
              voc::Vector{SubString{String}})
    wd = Dict{String, Real}()
    n = length(ctxt)
    map = countmap(ctxt)
    for word in voc
        if haskey(map, word)
            nk = map[word]
        else
            nk = 0
        end
        ewo = (nk + 1) / (n + length(voc))
        wd["$word"] = ewo
    end
    return wd
end

    #=
    # learn the training dataset
    # input:     fn - training dataset filename (String)
    # output: probs - class/vocabulary probabilities (Dict)
    =#
function learn(fn::String)
    println("\nlearning ...")
    trainset, vocab = initrain(fn)
    cidx = classlist()
    lidx = lid("train")
    probs = Dict("$word" => Dict{String, Real}() for word in vocab)
    for cls in cidx
        f = lidx["$cls"][1]
        l = lidx["$cls"][2]
        clstxt = classtext(trainset, f, l)
        wd = cwd(clstxt, vocab)
        for word in vocab
            probs["$word"]["$cls"] = wd["$word"]
        end
    end
    println("learning complete!")
    return probs
end

    #=
    # validate test dataset with classify()
    # input: fn - test dataset filename (String)
    #        wd - words dictionary (Dict)
    #     class - class to validate (String)
    #      vlid - validation line index (Dict)
    # output: correct - number of correct predictions (Int)
    #          docnum - number of documents processed (Int)
    =#
function validate(fn::String,
                  wd::Dict,
                 cls::String,
                vlid::Dict)
    testdset = initest(fn)
    if haskey(vlid, cls)
        f = vlid["$cls"][1]
        l = vlid["$cls"][2]
        ids = sample(f:l, 250, replace = false)
    else
        class = "ALL"
        # ids = sample(1:length(testdset), 10, replace = false)
        ids = collect(range(1, length(testdset)))
    end
    # println("\n$cls document ids:\n ", ids')
    tds = Vector{String}()
    for id in ids
        push!(tds, testdset[id])
    end
    docnum = length(tds)
    correct = 0
    i = 1
    println("\nclassifying $cls ...")
    for doc in tds
        doc = split(doc)
        trueclass = doc[1]
        predclass = classify(doc, wd)
        if predclass == trueclass
            correct += 1
        end
        # println("idx: ", ids[i], " pred: ", predclass, " true: ", trueclass)
        i += 1
    end
    println("classification complete!")
    return correct, docnum
end

    #=
    # classify a document, given a word probability dictionary
    # input: doc - document to classify (Vector{String})
    #         wd - words dictionary (Dict)
    # output: predicted classname - index of the maximum probability class
    =#
function classify(doc::Vector{SubString{String}},
                   wd::Dict)
    cidx = classlist()
    priorv = Array{Real, 1}()
    for cls in cidx
        append!(priorv, prior("$cls"))
    end
    priorv = transpose(priorv)
    for word in doc
        if haskey(wd, word)
            wrow = Array{Real, 1}()
            for cls in cidx
                append!(wrow, wd["$word"]["$cls"])
            end
                wrow = transpose(wrow)
                priorv = [ priorv; wrow ]
        else
            continue
        end
    end
    cnb = Array{Real, 1}()
    for i = 1:length(cidx)
        append!(cnb, sum(log.(priorv[:, i])))
    end
    return cidx[indmax(cnb)]
end

function main(runs)
    # train = "forumTraining.data"; test = "forumTest.data"
    train = "forumTraining-stemmed.data"; test = "forumTest-stemmed.data"
    # train = "forumMega-stemmed.data"; test = "forumMega-stemmed.data"
    println("  TRAIN dataset: ", train)
    println("   TEST dataset: ", test)
    @time ld = learn(train)
    rundf = DataFrame(class = String[], run = Int[], ndocs = Int[],
                  correct = Int[], accuracy = Real[],
                  seconds = Real[], sperdoc = Real[])
    cidx = classlist()
    matches = 0
    docnum = 0
    accuracy = 0.0
    tstlid = lid("test")
    for class in cidx
    # class = "ALL"
        for i = 1:runs
            tic()
            matches, docnum = validate(test, ld, class, tstlid)
            secs = toc()
            sper = round(secs/docnum, 4)
            secs = round(secs, 2)
            accuracy = round(matches/docnum * 100, 2)
            push!(rundf, [ class i docnum matches accuracy secs sper ])
            println("\ndocuments: ", docnum, " matches: ", matches)
            println("accuracy: ", accuracy, " %")
        end
    end
    showall(rundf)
    writetable("nbdc_nd.csv", rundf)
    println("\nAGGREGATE RUN ACCURACY: ",
            round(sum(rundf[:correct]) / sum(rundf[:ndocs]) * 100, 2), " %")
end

@time main(2)
