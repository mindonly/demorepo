library("data.table")
#setwd("C:/Users/sancrobe/Dropbox/W2017/cis635/Project1")
setwd("~/Dropbox/W2017/cis635/Project1")
  # read in raw data, remove 2 columns
dfraw <- read.delim("GSE17537-DEGdata.txt")
df <- dfraw[ , c(01:04, 06, 07) ]

nrow(df[which(df$P.Value < 0.05), ])
#df[which(df$P.Value < 0.05), ]

nrow(df[which(abs(df$logFC) > 0.7), ])
df[which(abs(df$logFC) > 0.7), ]

nrow(df[which(df$P.Value < 0.05 & abs(df$logFC) > 0.7), ])

summ <- df[which(df$Gene.symbol == "HES5" | df$Gene.symbol == "ZNF417" | df$Gene.symbol == "GLRA2" |
         df$Gene.symbol == "OR8D2" | df$Gene.symbol == "HOXA7" | df$Gene.symbol == "FABP6" |
         df$Gene.symbol == "MUSK" | df$Gene.symbol == "HTR6" | df$Gene.symbol == "GRIP2" |
         df$Gene.symbol == "KLRK1" | df$Gene.symbol == "VEGFA" | df$Gene.symbol == "AKAP12" |
         df$Gene.symbol == "RHEB" | df$Gene.symbol == "NCRNA00152" | df$Gene.symbol == "PMEPA1"), ]
setorder(summ, Gene.symbol, ID)
