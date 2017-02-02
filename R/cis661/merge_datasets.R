library(readr)

# setwd("C:/Users/sancrobe/Dropbox/Fall 2016/CIS 661/Project/Bilirubin/datasets")
setwd("~/Dropbox/Fall 2016/CIS 661/Project/Bilirubin/datasets")

fastmerge <- function(d1, d2) {
  d1.names <- names(d1)
  d2.names <- names(d2)
    # columns in d1 but not in d2
  d2.add <- setdiff(d1.names, d2.names)
    # columns in d2 but not in d1
  d1.add <- setdiff(d2.names, d1.names)
    # add blank columns to d2
  if(length(d2.add) > 0) {
    for(i in 1:length(d2.add)) {
      d2[d2.add[i]] <- NA
    }
  }
    # add blank columns to d1
  if(length(d1.add) > 0) {
    for(i in 1:length(d1.add)) {
      d1[d1.add[i]] <- NA
    }
  }
  return(rbind(d1, d2))
}

# 1999-2000 NHANES raw data
x99_00_BPQ <- read_csv("1999-2000 BPQ.csv")
x99_00_BPX <- read_csv("1999-2000 BPX.csv")
x99_00_DEMO <- read_csv("1999-2000 DEMO.csv")
x99_00_DIQ <- read_csv("1999-2000 DIQ.csv")
x99_00_LAB13 <- read_csv("1999-2000 LAB13.csv")
x99_00_LAB18 <- read_csv("1999-2000 LAB18.csv")
x99_00_MCQ <- read_csv("1999-2000 MCQ.csv")
x99_00_PFQ <- read_csv("1999-2000 PFQ.csv")
x99_00_SMQ <- read_csv("1999-2000 SMQ.csv")

x99_00_BMX <- read.csv("1999-2000 BMX.csv")
x99_00_LAB11 <- read.csv("1999-2000 LAB11.csv")
x99_00_LAB25 <- read.csv("1999-2000 LAB25.csv")
x99_00_LAB06 <- read.csv("1999-2000 LAB06.csv")
x99_00_ALQ <- read.csv("1999-2000 ALQ.csv")
x99_00_LAB10 <- read.csv("1999-2000 LAB10AM.csv")
# 1999-2000 merged data
x99_00_NH <- x99_00_BPQ
list_99_00 <- list(x99_00_BPX, x99_00_DEMO, x99_00_DIQ, x99_00_LAB13, 
                   x99_00_LAB18, x99_00_MCQ, x99_00_PFQ, x99_00_SMQ, 
                   x99_00_BMX, x99_00_LAB11, x99_00_LAB25, x99_00_LAB06,
                   x99_00_ALQ, x99_00_LAB10)
for ( .df in list_99_00) {
  x99_00_NH <- merge(x99_00_NH, .df, by = "SEQN", all = TRUE)
}

# 2001-2002 NHANES raw data
x01_02_BPQ_B <- read_csv("2001-2002 BPQ_B.csv")
x01_02_BPX_B <- read_csv("2001-2002 BPX_B.csv")
x01_02_DEMO_B <- read_csv("2001-2002 DEMO_B.csv")
x01_02_DIQ_B <- read_csv("2001-2002 DIQ_B.csv")
x01_02_L13_B <- read_csv("2001-2002 L13_B.csv")
x01_02_L40_B <- read_csv("2001-2002 L40_B.csv")
x01_02_MCQ_B <- read_csv("2001-2002 MCQ_B.csv")
x01_02_PFQ_B <- read_csv("2001-2002 PFQ_B.csv")
x01_02_SMQ_B <- read_csv("2001-2002 SMQ_B.csv")

x01_02_BMX_B <- read.csv("2001-2002 BMX_B.csv")
x01_02_L11_B <- read.csv("2001-2002 L11_B.csv")
x01_02_L25_B <- read.csv("2001-2002 L25_B.csv")
x01_02_L06_B <- read.csv("2001-2002 L06_B.csv")
x01_02_ALQ_B <- read.csv("2001-2002 ALQ_B.csv")
x01_02_L10AM_B <- read.csv("2001-2002 L10AM_B.csv")
# 2001-2002 merged data
x01_02_NH <- x01_02_BPQ_B
list_01_02 <- list(x01_02_BPX_B, x01_02_DEMO_B, x01_02_DIQ_B, x01_02_L13_B,
                   x01_02_L40_B, x01_02_MCQ_B, x01_02_PFQ_B, x01_02_SMQ_B, 
                   x01_02_BMX_B, x01_02_L11_B, x01_02_L25_B, x01_02_L06_B,
                   x01_02_ALQ_B, x01_02_L10AM_B)
for ( .df in list_01_02) {
  x01_02_NH <- merge(x01_02_NH, .df, by = "SEQN", all = TRUE)
}

# 2003-2004 NHANES raw data
x03_04_BPQ_C <- read_csv("2003-2004 BPQ_C.csv")
x03_04_BPX_C <- read_csv("2003-2004 BPX_C.csv")
x03_04_DEMO_C <- read_csv("2003-2004 DEMO_C.csv")
x03_04_DIQ_C <- read_csv("2003-2004 DIQ_C.csv")
x03_04_L13_C <- read_csv("2003-2004 L13_C.csv")
x03_04_L40_C <- read_csv("2003-2004 L40_C.csv")
x03_04_MCQ_C <- read_csv("2003-2004 MCQ_C.csv")
x03_04_PFQ_C <- read_csv("2003-2004 PFQ_C.csv")
x03_04_SMQ_C <- read_csv("2003-2004 SMQ_C.csv")

x03_04_BMX_C <- read.csv("2003-2004 BMX_C.csv")
x03_04_L11_C <- read.csv("2003-2004 L11_C.csv")
x03_04_L25_C <- read.csv("2003-2004 L25_C.csv")
x03_04_L06_C <- read.csv("2003-2004 L06MH_C.csv")
x03_04_ALQ_C <- read.csv("2003-2004 ALQ_C.csv")
x03_04_L10AM_C <- read.csv("2003-2004 L10AM_C.csv")
# 2003-2004 merged data
x03_04_NH <- x03_04_BPQ_C
list_03_04 <- list(x03_04_BPX_C, x03_04_DEMO_C, x03_04_DIQ_C, x03_04_L13_C, 
                   x03_04_L40_C, x03_04_MCQ_C, x03_04_PFQ_C, x03_04_SMQ_C, 
                   x03_04_BMX_C, x03_04_L11_C, x03_04_L25_C, x03_04_L06_C,
                   x03_04_ALQ_C, x03_04_L10AM_C)
for ( .df in list_03_04) {
  x03_04_NH <- merge(x03_04_NH, .df, by = "SEQN", all = TRUE)
}

# 1999-2004 merged data
merged_99_02 <- fastmerge(x99_00_NH, x01_02_NH)
merged_99_04 <- fastmerge(merged_99_02, x03_04_NH)
