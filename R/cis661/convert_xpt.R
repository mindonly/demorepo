library(readr)
library(SASxport)

# setwd("C:/Users/sancrobe/Dropbox/Fall 2016/CIS 661/Project/Bilirubin/datasets")
setwd("~/Dropbox/Fall 2016/CIS 661/Project/Bilirubin/datasets")

# df1 <- read.xport("1999-2000 LAB11.XPT")
# write.csv(df1, file = "1999-2000 LAB11.csv", row.names = FALSE)

xptfiles <- list.files(pattern = "*.XPT")
csvfiles <- NULL
for (i in 1:length(xptfiles)) {
    xptfile <- xptfiles[i]
    filenm <- substr(xptfile, 1, nchar(xptfile)-3)
    ext <- "csv"
    
    csvfile <- paste0(filenm, ext)
    csvfiles[i] <- paste0(filenm, ext)
    
    df <- read.xport(xptfile)
    write.csv(df, file = csvfile, row.names = FALSE)
    cat(c(paste0("[", i, "]"), csvfiles[i], '\n'))
}
