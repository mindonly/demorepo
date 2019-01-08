#!/usr/local/bin/julia

    #=
    new type NeuralNet
    =#
type NeuralNet
    ilv::Vector{Real}    # input layer vector
    hlv::Vector{Real}    # hidden layer vector
    olv::Vector{Real}    # output layer vector
    ihewm::Matrix{Real}  # input-hidden edge weight matrix
    hoewm::Matrix{Real}  # hidden-output edge weight matrix
    ihcam::Matrix{Real}  # input-hidden change accumulator matrix
    hocam::Matrix{Real}  # hidden-output change accumulator matrix

        #=
        NeuralNet constructor
        =#
    function NeuralNet(inodes::Int, hnodes::Int, onodes::Int)
        # layers
        il = ones(Real, inodes + 1)
        hl = ones(Real, hnodes + 1)
        ol = ones(Real, onodes)

        # edge-weight matrices
        iw = zeros(Matrix{Real}(length(il), length(hl) - 1))
        ow = zeros(Matrix{Real}(length(hl), length(ol)))

        # change accumulator matrices
        ic = zeros(Matrix{Real}(length(il), length(hl) - 1))
        oc = zeros(Matrix{Real}(length(hl), length(ol)))

        # instantiate the NeuralNet
        return new(il, hl, ol, iw, ow, ic, oc)
    end
end

    #=
    generate all feature value combinations
    for FISHING, and write them to a CSV file
    =#
function allfishing()
    wind = DataFrame(wind = ["Strong", "Weak"])
    water = DataFrame(water = ["Cold", "Moderate", "Warm"])
    air = DataFrame(air = ["Warm", "Cool"])
    forecast = DataFrame(forecast = ["Sunny", "Cloudy", "Rainy"])

    WW = join(wind, water, kind = :cross)
    WWA = join(WW, air, kind = :cross)
    WWAF = join(WWA, forecast, kind = :cross)

    writetable("all_fishing.csv", WWAF)
end

    #=
    encode 36 FISHING observations
    from "all_fishing.csv" to dummy/binary
    =#
function encfish(fn::String)
    f = open(fn)
    lines = readlines(f)

    temp = Int[]
    for line in lines
        line = split(line, ",")
        for (i, item) in enumerate(line)
            item = strip(item, '\n')
            if i == 1   # Wind
                if item == "Weak"
                    push!(temp, 1)
                    push!(temp, 0)
                elseif item == "Strong"
                    push!(temp, 0)
                    push!(temp, 1)
                end
            elseif i == 2 # Water
                if item == "Cold"
                    push!(temp, 1)
                    push!(temp, 0)
                    push!(temp, 0)
                elseif item == "Moderate"
                    push!(temp, 0)
                    push!(temp, 1)
                    push!(temp, 0)
                elseif item == "Warm"
                    push!(temp, 0)
                    push!(temp, 0)
                    push!(temp, 1)
                end
            elseif i == 3 # Air
                if item == "Cool"
                    push!(temp, 1)
                    push!(temp, 0)
                elseif item == "Warm"
                    push!(temp, 0)
                    push!(temp, 1)
                end
            elseif i == 4 # Forecast
                if item == "Rainy"
                    push!(temp, 1)
                    push!(temp, 0)
                    push!(temp, 0)
                elseif item == "Cloudy"
                    push!(temp, 0)
                    push!(temp, 1)
                    push!(temp, 0)
                elseif item == "Sunny"
                    push!(temp, 0)
                    push!(temp, 0)
                    push!(temp, 1)
                end
            end
        end
    end

    fishv = Vector{Vector{Int}}()
    refish = transpose(reshape(temp, (10, 36)))
    for i = 1:size(refish)[1]
        push!(fishv, refish[i, :])
    end

    close(f)

    return fishv
end

    #=
    set up CIS678 NeuralNet tutorial example
    =#
function tutorial()
    NN = NeuralNet(2, 2, 1)

    # input weights
    NN.ihewm[1, 1] = 1
    NN.ihewm[1, 2] = -1
    NN.ihewm[2, 1] = 0.5
    NN.ihewm[2, 2] = 2
    NN.ihewm[3, 1] = 1
    NN.ihewm[3, 2] = 1

    # output weights
    NN.hoewm[1, 1] = 1.5
    NN.hoewm[2, 1] = -1
    NN.hoewm[3, 1] = 1

    ob = [0, 1]
    ob = convert(Vector{Real}, ob)
    NN = feedforward(NN, ob)

    targets = Vector{Int}()
    push!(targets, 1)

    NN, odeltas, hdeltas = backpropagate(NN, targets)
    lrate = 0.5
    NN = learn(NN, lrate, odeltas, hdeltas)

    terr = totalerror(NN, targets)

    return NN, terr
end

    #=
    generate tiny random numbers
    =#
function tinyrand(min::Real, max::Real)
    range = max - min
    scaled = rand() * range
    shifted = scaled + min

    return shifted
end

    #=
    vectorized sigmoid
    =#
function v_sigmoid(z::Matrix{Float64})
    return 1 ./ (1 + e.^(-z))
end
v_sigmoid(z::Matrix{Int}) = 1 ./ (1 + e.^(-z))
v_sigmoid(z::Matrix{Float32}) = 1 ./ (1 + e.^(-z))
