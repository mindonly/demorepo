    # clear workspace
rm(list = ls())

setwd("C:/Users/sancrobe/Dropbox/SCB GA work/Levenburg")
# setwd("~/Dropbox/SCB GA work/Levenburg")
odf <- read.csv("skilldata.csv")
ndf <- read.csv("skilldata_new.csv")

# 37 fields
#
# 01:     Number      - record number
# 02-04:  (UNUSED)    - course, instructor, section
# 05-20:  Q1-Q8       - skills assessment answers
# 21-24:  (COMPUTED)  - total correct, total complete, correct of complete, correct of total
# 25:     Q9          - gender
# 26:     Q10         - race/ethnicity
# 27:     Q11         - major
# 28-33:  Q12a-f      - math courses
# 34-35:  Q13a-b      - SAT & ACT score
# 36:     GPA         - GPA
# 37:     Q14         - expected final grade

sub_odf <- odf[, c(01, 05:20, 25:26, 35)]
sub_ndf <- ndf[, c(01, 05:20, 25:26, 35)]

dupes = 0

begin = Sys.time()
for (i in 1:nrow(sub_ndf)) {
   newrec <- sub_ndf[i, ]
    
  for (j in 1:nrow(sub_odf)) {
    oldrec <- sub_odf[j, ]
    
      # separate the record number from the responses
    newnum <- as.numeric(newrec[1])
    oldnum <- as.numeric(oldrec[1])
    newresp <- newrec[-1] # "-1" excludes field 1
    oldresp <- oldrec[-1] # "-1" excludes field 1
    
      # convert responses to strings for comparison
    nrs <- paste(newresp, collapse = " ")
    ors <- paste(oldresp, collapse = " ")
    
      # build result vector for comparison
    result <- c("new record:", newnum, "\nold record:", oldnum, "\n", (nrs == ors), "\n\n")
    
    if (result[6] == TRUE) {
      cat(result)
      dupes = dupes + 1
    }
  }
}
end = Sys.time()

cat(c("new records:", nrow(ndf)))
cat(c("\nold records:", nrow(odf)))
cat(c("\ncomparisons:", nrow(ndf) * nrow(odf)))
cat(c("\n duplicates:", dupes))
cat(c("\nruntime (s):", round(end - begin, 4)))