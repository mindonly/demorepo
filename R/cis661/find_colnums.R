library(stringr)

vars <- c("SEQN", "RIAGENDR", "RIDAGEYR", "RIDRETH2", "BPQ020",
          "BPQ040A", "BPXSAR", "BPXDAR", "BPQ080", "BPQ090D",
          "BPQ100D", "LBDTCSI", "LBDHDLSI", "LBDHDDSI", "DIQ010",
          "SMQ020", "SMQ040", "BMXBMI", "LBXCRP", "LBDSTBSI", 
          "MCQ160F", "LBXHGB", "LBXHCY", "PFD067A", "PFD067B",
          "PFD067C", "PFD067D", "PFD067E", "LBDHCY", "MCQ160L", 
          "MCQ170L", "ALQ130", "DIQ050", "DIQ070", "LBXGLUSI",
          "LBDGLUSI", "PFQ063A", "PFQ063B", "PFQ063C", "PFQ063D", 
          "PFQ063E")

count = 0
varidx <- NULL
vars <- sort(vars)
for (i in 1:length(vars)) {
  var <- vars[i]
  varct <- c(var, str_pad(which(colnames(merged_99_04)==var), 3, pad = "0"), '\n')
  cat(varct)
  print(summary(df[[var]]))
  varidx[i] <- str_pad(which(colnames(merged_99_04)==var), 3, pad = "0")
  count = count + 1
}
cat('\n', count, '\n\n')
varidx <- sort(varidx)
cat(paste(varidx, collapse = ", "))
cat('\n\n')
for (i in 1:length(vars)) {
  var <- vars[i]
  varct <- c(var, str_pad(which(colnames(df)==var), 3, pad = "0"), '\n')
  cat(varct)
}