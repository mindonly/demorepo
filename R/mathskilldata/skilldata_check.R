setwd("C:/Users/sancrobe/Dropbox/SCB GA work/Levenburg")
# setwd("~/Dropbox/SCB GA work/Levenburg")
df <- read.csv("skilldata_latest5.csv")

checkTotalCorrect <- function() {
  qSum <- sum(record[5:20], na.rm = TRUE)
  if (qSum != totalCorrect) {
    outv = c(recordNum, qSum, totalCorrect, "FALSE")
    return(outv)
  } else return(NULL)
}

checkTotalComplete <- function() {
  NAs = 0
  for (i in 5:20) {
    if (is.na(record[i])) {
      NAs = NAs + 1
    }
  }
  tcCheck <- NAs
    # if actual NAs not equal to expected NAs
  if (tcCheck != (totalQ - totalComplete)) {
    outv = c(recordNum, tcCheck, totalQ - totalComplete, totalComplete, "FALSE")
    return(outv)
  } else return(NULL)
}

checkCorrectofComplete <- function() {
  ccCheck <- round(totalCorrect / totalComplete * 100, 4)
  if (ccCheck != correctPctComplete) {
    outv = c(recordNum, ccCheck, correctPctComplete, "FALSE")
    return(outv)
  } else return(NULL)
}

checkCorrectofTotal <- function() {
  ctCheck <- round(totalCorrect / totalQ * 100, 4)
  if (ctCheck != correctPctTotal) {
    outv = c(recordNum, correctPctTotal, ctCheck, "FALSE")
    return(outv)
  } else return(NULL)
}

brecs = 0
skips = 0
testName = NULL

for (i in 1:nrow(df)) {
  record <- as.numeric(df[i,])
  
  recordNum <- record[1]
  totalCorrect <- record[21]
  totalComplete <- record[22]
  correctPctComplete <- round(record[23], 4)
  correctPctTotal <- round(record[24], 4)
  totalQ <- 16

  #
  # change the test, 1-4. see switch() statements below
  test = 4
  
  item = switch(test, 
                checkTotalCorrect(),
                checkTotalComplete(),
                checkCorrectofComplete(), 
                checkCorrectofTotal())
  
  testName = switch(test,
                    "checkTotalCorrect()",
                    "checkTotalComplete()",
                    "checkCorrectofComplete()",
                    "checkCorrectofTotal()")
  
  
  if( !(is.null(item)) ) {
    #
    # add ranges of missing observations here
    # if ( (as.numeric(item[1]) ) <= 51 ) {
    #   skips = skips + 1
    #   next
    # }
    # if ( ( as.numeric(item[1]) ) >= 282 && ( as.numeric(item[1]) ) <= 328 ) {
    #   skips = skips + 1
    #   next
    # }
    # commenting the 2 ifs above will display the records
    #
    print(item)
    brecs = brecs + 1
  }
}
cat(c("\nTest Name: ", testName))
cat(c("\nBad Records: ", brecs, " --> ", round(brecs / nrow(df) * 100, 2), "%"))
cat(c("\nSkipped Records: ", skips))