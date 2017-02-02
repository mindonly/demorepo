library(hashmap)

# setwd("C:/Users/sancrobe/Dropbox/SCB GA work/Levenburg")
setwd("~/Dropbox/SCB GA work/Levenburg")
odf <- read.csv("skilldata.csv")
ndf <- read.csv("skilldata_new.csv")

# 37 fields
#
# 01:     Number      - record number
# 02-04:  (UNUSED)    - course, instructor, section
# 05-20:  Q1-Q8       - skills assessment answers
# 21-24:  (COMPUTED)  - total correct, total complete,
#                       correct of complete, correct of total
# 25:     Q9          - gender
# 26:     Q10         - race/ethnicity
# 27:     Q11         - major
# 28-33:  Q12a-f      - math courses
# 34-35:  Q13a-b      - SAT & ACT score
# 36:     GPA         - GPA
# 37:     Q14         - expected final grade

begin = Sys.time()
    # separate the keys from the responses
okeys <- odf[ , 01]
nkeys <- ndf[ , 01]
orecs <- odf[ , c(05:20, 25:26, 35:36)]
nrecs <- ndf[ , c(05:20, 25:26, 35:36)]

    # convert resp. dataframes to char. vectors
ovals <- apply(orecs, 1, paste, collapse = " ")
nvals <- apply(nrecs, 1, paste, collapse = " ")

    # create hashmaps
ohash <- hashmap(okeys, ovals)
nhash <- hashmap(nkeys, nvals)

dups = 0
for (i in okeys) {
    for (j in nkeys) {
        if (ohash[[i]] == nhash[[j]]) {
            dups = dups + 1
            cat(c("\n", dups, " old", "new\n", "  ", j, i, "\n"))
        }
    }
}
end = Sys.time()

cat(c("\ncomparisons:", length(nkeys) * length(okeys)))
cat(c("\n duplicates:", dups))
cat(c("\nruntime (s):", round(end - begin, 4)))