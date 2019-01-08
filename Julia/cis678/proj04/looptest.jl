#!/usr/local/bin/julia

dset = "digits"
trndsetlen = 3823
traintypev = ["ol", "mb"]

mbsizev = [10, 15, 25]
hnodev = [40, 45, 50]
lratev = [0.025, 0.05, 0.075]
trainepochv = [50, 75, 100]
sampleszv = [0.10, 0.15, 0.25]

exp = 0
for tt in traintypev
  if tt == "ol" || tt == "online"
    mbs = 1
    trainepochv = [1, 5, 10]
    ssz = trndsetlen
    for hnc in hnodev
      for lr in lratev
        for te in trainepochv
          for ssf in sampleszv
            println("$dset $tt $mbs $hnc $lr $te $ssf")
            exp += 1
          end
          println("\n")
        end
      end
    end
  end
end
println("experiments: $exp")
