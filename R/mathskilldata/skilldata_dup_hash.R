library(hashmap)

setwd("C:/Users/sancrobe/Dropbox/SCB GA work/Levenburg")
# setwd("~/Dropbox/SCB GA work/Levenburg")

ndf <- read.csv("skilldata_new.csv")
odf <- read.csv("skilldata.csv")

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

nkeys <- ndf[, 01]
okeys <- odf[, 01]
nvals <- NULL
ovals <- NULL

begin = Sys.time()
for (i in 1:nrow(ndf)) {
    rec <- ndf[i, c(05:20, 25:26, 35:36)]
    nvals[[i]] <- paste(rec, collapse = " ")
}
nhash <- hashmap(nkeys, nvals)

for (i in 1:nrow(odf)) {
    rec <- odf[i, c(05:20, 25:26, 35:36)]
    ovals[[i]] <- paste(rec, collapse = " ")
}
ohash <- hashmap(okeys, ovals)

dups = 0
for (i in nkeys) {
    for (j in okeys) {
        if (nhash[[i]] == ohash[[j]]) {
            dups = dups + 1
            cat(c("\n", dups, " old", "new\n", "  ", j, i, "\n"))
        }
    }
}
end = Sys.time()
cat(c("\ncomparisons:", length(nkeys) * length(okeys)))
cat(c("\n duplicates:", dups))
cat(c("\nruntime (s):", round(end - begin, 4)))