#!/usr/local/bin/julia

using StatsBase, StatsFuns, DataFrames

include("ANNlib.jl")

    #=
    TODO
    -momentum
    -learning rate decay
    -PCA
    =#

    #=
    encode categories using one-hot scheme
    author: AlexanderFabisch, JuliaStats:StatsBase
    =#
function onehot{T<:Real}(y::AbstractVector{T})
    n = length(y)
    c = maximum(y) + 1
    Y = zeros(T, c, n)
    for i = 1:n
        Y[y[i] + 1, i] = one(T)
    end
    return Y
end

    #=
    prepare input data, one-hot encode class (last column)
    =#
function prepdata(fn::String; z::Bool = true)
    f = open(fn)
    lines = readlines(f)

        # process dataset input as an array
    temp = Int[]
    lnlen = 0
    for line in lines
        line = split(line, ",")
        for item in line
            item = parse(Int, item)
            push!(temp, item)
        end
        lnlen = length(line)
    end

        # reshape/transpose input array to matrix
    rtemp = transpose(reshape(temp, (lnlen, div(length(temp), lnlen))))

        # store and slice off last column (classes)
    classv = rtemp[:, end]
    rtemp = rtemp[:, 1:end-1]

        # z-score transformation
    if z == true
        rtemp = zscore(rtemp)
    end

        # one-hot encode class vector
    ohm = onehot(classv)

    data = Vector{Tuple{Vector{Real}, Vector{Int}}}()
    for i = 1:(size(rtemp)[1])  # dim 1, number of rows
        push!(data, tuple(rtemp[i, :], ohm[:, i]))
    end

    close(f)

    return data
end

    #=
    sigmoid activation
    =#
function sigmoid(x::Real)
    return 1 / (1 + e^(-x))
end

    #=
    sigmoid derivative
    =#
function dsigmoid(y::Real)
    return y * (1 - y)
end

    #=
    initialize edge weights
    =#
function initweights(nn::NeuralNet)

        # small initial weights
    initmin = -0.125
    initmax =  0.125

    for j = 1:size(nn.ihewm, 2)
        for i = 1:size(nn.ihewm, 1)
            nn.ihewm[i, j] = tinyrand(initmin, initmax)
        end
    end

    for j = 1:size(nn.hoewm, 2)
        for i = 1:size(nn.hoewm, 1)
            nn.hoewm[i, j] = tinyrand(initmin, initmax)
        end
    end

    return nn
end

    #=
    feed observation forward through the NeuralNet
    =#
function feedforward(nn::NeuralNet, ob::Vector{Real})
    if length(ob) != length(nn.ilv) - 1
        error("feedforward(): wrong number of inputs!")
    end

    # input activations
    # for i = 1:length(ob)
    #     nn.ilv[i] = ob[i]
    # end
    nn.ilv[1:end-1] .= ob   # vectorized

        # hidden activations
    for i = 1:(length(nn.hlv) - 1)
        nn.hlv[i] = sigmoid(dot(nn.ilv, nn.ihewm[:, i]))
    end

        # output activations
    for i = 1:(length(nn.olv))
        nn.olv[i] = sigmoid(dot(nn.hlv, nn.hoewm[:, i]))
    end

    return nn
end

    #=
    calculate and store error vectors
    =#
function backpropagate(nn::NeuralNet, targets::Vector{Int})
    if length(targets) != length(nn.olv)
        error("backpropagate(): wrong number of targets!")
    end

        # output error
    odeltav = zeros(Vector{Real}(length(nn.olv)))
    for i = 1:length(odeltav)
        err = -(targets[i] - nn.olv[i])
        odeltav[i] = dsigmoid(nn.olv[i]) * err
    end

        # hidden error
    hdeltav = zeros(Vector{Real}(length(nn.hlv) - 1))
    for j = 1:length(hdeltav)
        err = 0
        for k = 1:length(odeltav)
            err += odeltav[k] * nn.hoewm[j, k]
        end
        hdeltav[j] = dsigmoid(nn.hlv[j]) * err
    end

    return nn, odeltav, hdeltav
end

    #=
    update edge weights with backprop error vectors
    =#
function learn(nn::NeuralNet, N::Real,
                odeltav::Vector{Real}, hdeltav::Vector{Real})

    # N: learning rate

        # update hidden-output weights
    for j = 1:length(nn.hlv)
        for k = 1:length(nn.olv)
            change = odeltav[k] * nn.hlv[j]
            nn.hoewm[j, k] -= N * change + nn.hocam[j, k]
            nn.hocam[j, k] = change
        end
    end

        # update input-hidden weights
    for i = 1:length(nn.ilv)
        for j = 1:length(hdeltav)
            change = hdeltav[j] * nn.ilv[i]
            nn.ihewm[i, j] -= N * change + nn.ihcam[i, j]
            nn.ihcam[i, j] = change
        end
    end

    return nn
end

    #=
    compute total error of the NeuralNet
    =#
function totalerror(nn::NeuralNet, targets::Vector{Int})
    terr = 0.0
    for k = 1:length(targets)
        terr += 0.5 * (targets[k] - nn.olv[k])^2
    end

    return terr
end

    #=
    train NeuralNet with various options
    =#
function train(nn::NeuralNet, dset::Vector{Tuple{Vector{Real},Vector{Int}}},
               mbsz::Int, N::Real, epochs::Int, smpszf::Real)

    # N: learning rate

    if mbsz > 1
        println("training minibatch ...")
    elseif mbsz == 1
        println("training online ...")
        # smpszf = 1.0
    end
    @show mbsz, N
    @show smpszf, epochs

    accumerr = 0.0
    for i = 1:epochs
        epochdset = sample(dset, Int(round(smpszf * length(dset))), replace = false)
        err = 0.0
        condct = 0
        for (j, obtup) in enumerate(epochdset)
            inputs = obtup[1]
            targets = obtup[2]
            nn = feedforward(nn, inputs)
            if j % mbsz == 0
                nn, odeltas, hdeltas = backpropagate(nn, targets)
                nn = learn(nn, N, odeltas, hdeltas)
            end
            err = totalerror(nn, targets)
            # println("total error $err")

            if err < 0.001
                condct += 1
            end
            if condct == 150
                println("$j good enough, breaking out!")
                break
            end
        end
        accumerr += err
        # println("epoch $i ", err)
    end
    accumerr = round(accumerr / epochs * 100, 2)
    println("\ncumulative training error: $accumerr %\n", )

    return nn, accumerr
end

    #=
    classify test dataset with NeuralNet
    =#
function classify(testdset,
                  targetv::Vector{String},
                  nn::NeuralNet)

    tallyv = zeros(Vector{Int}(length(targetv)))

    misses = 0
    for (i, row) in enumerate(testdset)
        if isa(row, Vector)     # fishing
            ob = convert(Vector{Real}, row)
            NN = feedforward(nn, ob)

            predidx = indmax(softmax(NN.olv))
            predclass = targetv[predidx]
            tallyv[predidx] += 1
            println("$i ", predclass)

        elseif isa(row, Tuple)  # digits
            ob = convert(Vector{Real}, row[1])
            trueclassv = row[2]
            trueclass = indmax(trueclassv) - 1  #off-by-one!

            NN = feedforward(nn, ob)
            predidx = indmax(softmax(NN.olv))
            predclass = targetv[predidx]
            tallyv[predidx] += 1

            if parse(Int, predclass) != trueclass
                misses += 1
            end
            # println("$i $predclass $trueclass")
        end
    end

    println()
    for (i, tgt) in enumerate(targetv)
        println("$tgt ", tallyv[i])
    end

    if misses > 0
        classerror = round(misses / length(testdset) * 100, 2)
        println("\nmisses: $misses")
        println("classification error: $classerror %\n")
    else
        classerror = 0
    end

    if isa(testdset[1], Vector)     # fishing

        return tallyv[1], tallyv[2]
    elseif isa(testdset[1], Tuple)  # digits

        return misses, classerror
    end
end

    #=
    NeuralNet controller
    wrapper front-end for neural net experiments
    =#
function NeuralNetCTL(dset::String, trntyp::String, mbsz::Int, hnct::Int,
                      lrt::Real, trnep::Int, smpszf::Real)

    if trntyp == "ol" || trntyp == "online"
        mbsz = 1
    end

    if dset == "digits"
        # if trntyp == "ol" || trntyp == "online"
        #     trnep = 1
        # end
        trainfile = "digits-training.data"
        traindset = prepdata(trainfile)

        testfile = "digits-test.data"
        testdset = prepdata(testfile)

        targets = [ "0", "1", "2", "3", "4",
                    "5", "6", "7", "8", "9" ]

        inodect = 64
        onodect = 10
    elseif dset == "fishing"
        trainfile = "fishing-training-dummy.csv"
        traindset = prepdata(trainfile)

        testfile = "all_fishing.csv"
        testdset = encfish(testfile)

        targets = ["NO", "YES"]

        inodect = 10
        onodect = 2
    end

    NN = NeuralNet(inodect, hnct, onodect)
    NN = initweights(NN)
    NN, trnerr = train(NN, traindset, mbsz, lrt, trnep, smpszf)

    if dset == "digits"
        misses, clserr = classify(testdset, targets, NN)

        return trnerr, misses, clserr
    elseif dset == "fishing"
        no, yes = classify(testdset, targets, NN)

        return trnerr, no, yes
    end
end

    #=
    set up and run experiments for digits dataset
    =#
function digits_exp()
    resultsdf = DataFrame(dataset = String[], train = String[],
                          batchSz = Int[], hNodes = Int[],
                          lRate = Real[], epochs = Int[], sampleSz = Int[],
                          accTrnErr = Real[], misses = Int[],
                          classErr = Real[], runtime = Real[])

    dset = "digits"
    trndsetlen = 3823

    # traintypev = ["ol", "mb"]
    traintypev = ["ol"]     # for Table 3
    mbsizev = [10, 25]
    hnodev = [40, 50]
    lratev = [0.025, 0.050]
    sampleszv = [0.10, 0.15, 0.20]

    exp = 0
    for tt in traintypev
      if tt == "ol" || tt == "online"
        mbs = 1
        trainepochv = [5, 10, 25]
        println(trainepochv)
        for hnc in hnodev
          for lr in lratev
            for te in trainepochv
              for ssf in sampleszv
                println("$tt $mbs $hnc $lr $te $ssf")
                rt = @elapsed cterr, mis, mcerr = NeuralNetCTL(dset, tt, mbs, hnc,
                                                               lr, te, ssf)
                exp += 1
                ssz = Int(round(trndsetlen * ssf))
                rt = round(rt, 1)
                push!(resultsdf, [dset tt mbs hnc lr te ssz cterr mis mcerr rt])
              end
            end
          end
        end
      else
        trainepochv = [50, 100]
        println(trainepochv)
        for mbs in mbsizev
          for hnc in hnodev
            for lr in lratev
              for te in trainepochv
                for ssf in sampleszv
                  println("$tt $mbs $hnc $lr $te $ssf")
                  rt = @elapsed cterr, mis, mcerr = NeuralNetCTL(dset, tt, mbs, hnc,
                                                                 lr, te, ssf)
                  exp += 1
                  ssz = Int(round(trndsetlen * ssf))
                  rt = round(rt, 1)
                  push!(resultsdf, [dset tt mbs hnc lr te ssz cterr mis mcerr rt])
                end
              end
            end
          end
        end
      end
    end

    println("\n $exp experiments:\n")
    resultsdf = sort(resultsdf, cols = [:classErr, :runtime])
    showall(resultsdf)
    writetable("digits_results.csv", resultsdf)
end

    #=
    set up and run experiments for fishing dataset
    =#
function fishing_exp()
    resultsdf = DataFrame(dataset = String[], train = String[],
                          batchSz = Int[], hNodes = Int[],
                          lRate = Real[], epochs = Int[],
                          accTrnErr = Real[], NO = Int[], YES = [],
                          runtime = Real[])

    dset = "fishing"
    traintypev = ["ol"]

    mbsizev = [1]
    hnodev = [4, 6, 8]
    lratev = [0.025, 0.05]
    trainepochv = [10, 25, 50, 100, 250, 1000]
    sampleszv = [1]

    exp = 0
    for tt in traintypev
      for mbs in mbsizev
        for hnc in hnodev
          for lr in lratev
            for te in trainepochv
              for ssf in sampleszv
                println("$tt $mbs $hnc $lr $te $ssf")
                rt = @elapsed cterr, no, yes = NeuralNetCTL(dset, tt, mbs, hnc,
                                                            lr, te, ssf)
                exp += 1
                rt = round(rt, 1)
                push!(resultsdf, [dset tt mbs hnc lr te cterr no yes rt])
              end
            end
          end
        end
      end
    end

    println("\n $exp experiments:\n")
    resultsdf = sort(resultsdf, cols = [:epochs])
    showall(resultsdf)
    writetable("fishing_results.csv", resultsdf)
end

    #=
    main function, run fishing and digits experiments
    =#
function main()
    fishing_exp()
    digits_exp()
end

@time tutNN, tutNNerr = tutorial()
# @time main()
