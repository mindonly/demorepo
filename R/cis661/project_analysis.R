library(aod)
library(Rcpp)
library(MASS)
# library(ggplot2)
# library(scales)
# library(dplyr)

# setwd("C:/Users/sancrobe/Dropbox/Fall 2016/CIS 661/Project/Bilirubin/datasets")
setwd("~/Dropbox/Fall 2016/CIS 661/Project/Bilirubin/datasets")

# 1.  DATASET SUBSETTING AND CLEANUP
#
# subset the merged dataset into NHANES dataframe 'df_nh'
df_nh <- merged_99_04[ , c(001, 003, 005, 022, 026, 030, 064, 065, 069, 070, 
                           074, 209, 212, 216, 226, 228, 250, 300, 306, 310, 
                           464, 465, 466, 467, 468, 526, 528, 575, 601, 619, 
                           644, 671, 678, 727, 741, 777, 778, 779, 780, 781, 
                           794) ]
# at this point, (df_nh) n = 31126.

# we remove all respondents younger than 20
df_nh <- df_nh[which(df_nh$RIDAGEYR >= 20), ]
# (df_nh) n = 15332, per pg. 782

# we remove 2062 respondents missing serum total bilirubin (df_nh$LBDSTBSI == 17)
# which(colnames(df_nh)=="LBDSTBSI")
df_nh <- df_nh[complete.cases(df_nh[ , "LBDSTBSI"]), ]
# (df_nh) n = 13270, per pg. 782

# write the trimmed NHANES dataframe to a CSV file
write.csv(df_nh, file = "NHANES_bilirubin_99_04.csv", row.names = FALSE)

#
# dataset fields
#

# SEQN,     001,  Sequence (respondent) number
resp          <- df_nh$SEQN

#
# COVARIATES: age, race/ethnicity, gender, smoking status, hypertension, 
#   diabetes, and total cholesterol to HDL cholesterol ratio.
#

# Age: (age)
# continuous
#
# RIDAGEYR, 070,  Age
age1          <- ifelse(df_nh$RIDAGEYR >= 20 & df_nh$RIDAGEYR <= 39, 1, NA)
age2          <- ifelse(df_nh$RIDAGEYR >= 40 & df_nh$RIDAGEYR <= 59, 2, NA)
age3          <- ifelse(df_nh$RIDAGEYR >= 60, 3, NA)
agedf         <- data.frame(cbind(age1, age2))
agejoin1      <- with(agedf, ifelse(is.na(age1), age2, age1))
agedf         <- data.frame(cbind(agejoin1, age3))
agejoin2      <- with(agedf, ifelse(is.na(agejoin1), age3, agejoin1))
age_group     <- agejoin2
age           <- df_nh$RIDAGEYR    

# Race/ethnicity: (race_eth)
# categorical (4): non-Hispanic white; non-Hispanic black; Mexican-American; other
#
# RIDRETH2, 074,  Race/Ethnicity
# the paper apparently merges categories 4,5 together -> 4
re1           <- ifelse(df_nh$RIDRETH2 == 5, 4, df_nh$RIDRETH2)
# race_eth      <- df_nh$RIDRETH2
race_eth      <- re1

# Gender
# categorical (2): 1 = male; 2 = female
#
# RIAGENDR, 069,  Gender
gender        <- df_nh$RIAGENDR

# Smoking status: (smoke)
# categorical (3): 1 = active; 2 = former; 3 = never
#
# Subjects were characterized as 
# 1) active smokers if the subject answered yes to “do you now smoke cigarettes”, as 
# 2a) former smokers if they were not active smokers and 
# 2b) they answered yes to “have you smoked at least 100 cigarettes in your life”, or as 
# 3) never smokers if they denied smoking at least 100 cigarettes.
# SMQ020,   526,  Smoked at least 100 cigarettes in life
# SMQ040,   528,  "Do you now smoke cigarettes?"
smoke1         <- ifelse(df_nh$SMQ040 == 1 | df_nh$SMQ040 == 2, 1, NA)
smoke2         <- ifelse(df_nh$SMQ040 == 3 & df_nh$SMQ020 == 1, 2, NA)
smoke3         <- ifelse(df_nh$SMQ020 == 2, 3, NA)
smokedf        <- data.frame(cbind(smoke1, smoke2))
smokejoin1     <- with(smokedf, ifelse(is.na(smoke1), smoke2, smoke1))
smokedf        <- data.frame(cbind(smokejoin1, smoke3))
smokejoin2     <- with(smokedf, ifelse(is.na(smokejoin1), smoke3, smokejoin1))
smoke          <- smokejoin2
# we remove 18 NAs for smoking status
# cutidx         <- which(is.na(smoke))
# smoke          <- smoke[-c(cutidx)]
# smokedf        <- smokedf[-c(cutidx), ]
# df_nh          <- df_nh[-c(cutidx), ]
# # delete these intermediate vars because n= doesn't match
# rm(smoke1, smoke2, smoke3, smokejoin1, smokejoin2)

# Hypertension: (hypertension)
# categorical(binary): 1 = yes; 0 = no
#
# A diagnosis of hypertension was assigned  
# 1) if the subject reported a physician diagnosis of hypertension (BPQ020), 
# 2) if the subject reported taking prescription medications for hypertension(BPQ040A), or 
# 3) if the systolic blood pressure was ≥140 mm Hg (BPXSAR) or 
# 4) the diastolic blood pressure was ≥90 mm Hg (BPXDAR).
# BPQ020,   003,  "Ever told you had high blood pressure?"
# BPQ040A,  005,  Taking prescription for hypertension
# BPXSAR,   064,  Systolic BP avg. reported 
# BPXDAR,   065,  Diastolic BP avg. reported
hyp1          <- (df_nh$BPQ020 == 1 | df_nh$BPQ040A == 1 | df_nh$BPXSAR >= 140 |
                  df_nh$BPXDAR >= 90)
hypertension  <- ifelse(is.na(hyp1), 0, 1)

# Diabetes mellitus: (diabetes)
# categorical(binary): 1 = yes; 0 = no
#
# A diagnosis of diabetes mellitus was assigned 
# 1) if the subject reported a physician diagnosis of diabetes, 
# 2) if the subject reported taking prescription medications (either insulin or oral agents) for diabetes, 
# 3) if nonfasting plasma glucose was ≥11.1 mmol/L (200 mg/dL), or 
# 4) if fasting plasma glucose was ≥7.0 mmol/L (126 mg/dL).
# DIQ010,   209,  Doctor told you have diabetes, 99-00 DIQ,    01-02 DIQ_B,  03-04 DIQ_C
# DIQ050,   212,  Taking insulin now
# DIQ070,   216,  Take diabetic pills to lower blood sugar
# LBXGLUSI, 678,  Plasma glucose: SI(mmol/L),     99-00 LAB10AM, 01-02 L10AM_B,
# LBDGLUSI, 794,  Plasma glucose: SI(mmol/L),     03-04 L10AM_C
glucose       <- with(df_nh, ifelse(is.na(LBXGLUSI), LBDGLUSI, LBXGLUSI))
diab1         <- (df_nh$DIQ010 == 1 | df_nh$DIQ050 == 1 | df_nh$DIQ070 == 1 | glucose >= 7)
diabetes      <- ifelse(is.na(diab1), 0, 1)

# Total cholesterol to HDL cholesterol ratio: (chol_ratio)
# continuous
#
# LBDTCSI,  226,  Total cholesterol (mmol/L),   99-00 LAB13, 01-02 L13_B, 03-04 L13_C
# LBDHDLSI, 228,  HDL-cholesterol (mmol/L),     99-00 LAB13, 01-02 L13_B
# LBDHDDSI, 741,  HDL-cholesterol (mmol/L),     03-04 L13_C
hdl_chol      <- with(df_nh, ifelse(is.na(LBDHDLSI), LBDHDDSI, LBDHDLSI))
chol_ratio    <- (df_nh$LBDTCSI / hdl_chol)

# Hypercholesterolemia: (hyper_chol)
# categorical(binary): 1 = yes; 0 = no
#
# A diagnosis of hypercholesterolemia was assigned 
# 1) if the subject reported a physician diagnosis of hypercholesterolemia (BPQ080), 
# 2) if the subject reported taking prescription medications for hypercholesterolemia(BPQ090D & BPQ100D), or 
# 3) if the total cholesterol level was ≥62.1 mmol/L (240 mg/dL) (LBDTCSI).
# BPQ080,   022,  "Doctor told you - high cholesterol level"
# BPQ090D,  026,  Told to take prescription for cholesterol
# BPQ100D,  030,  Now taking prescribed medicine
# LBDTCSI,  226,  Total cholesterol (mmol/L)
# LBDHDLSI, 228,  HDL-cholesterol (mmol/L)
chol1         <- (df_nh$BPQ080 == 1 | df_nh$BPQ090D == 1 | df_nh$BPQ100D == 1 | 
                  df_nh$LBDTCSI >= 62.1)
hyper_chol    <- ifelse(is.na(chol1), 0, 1)

#
# POSSIBLE CONFOUNDERS: BMI, CRP, hemoglobin, and homocysteine
#

# Body weight: (bmi)
# Body weight was considered normal, overweight, or obese if the body mass index (BMI) was less than
# 25 kg/m2, 25 to 29.9 kg/m2, or 30 kg/m2 or more, respectively.
# BMXBMI,   575,    Body Mass Index (kg/m**2),  BMX
bmi           <- df_nh$BMXBMI

# C-reactive protein (CRP) level: (crp)
# CRP level was categorized as low (<1 mg/L),
# intermediate (1-3 mg/L), or 
# high (>3 mg/L) as suggested by Centers for Disease Control and Prevention/American Heart Assoc. guidelines.
# LBXCRP,   601,    C-reactive protein(mg/dL),  LAB11
crp           <- df_nh$LBXCRP

# Hemoglobin: (hemoglobin)
# LBXHGB,   619,    Hemoglobin (g/dL),          LAB25
hemoglobin    <- df_nh$LBXHGB

# Homocysteine: (homocysteine)
# LBXHCY,   644,    Homocysteine(umol/L),       99-00 LAB06, 03-04 L06MH_C
# LBDHCY,   727,    Homocysteine(umol/L),       01-02 L06_B
homocysteine  <- with(df_nh, ifelse(is.na(LBXHCY), LBDHCY, LBXHCY))

# Active liver disease: (liverdisease)
# categorical(binary): 1 = yes; 0 = no
#
# The presence of active liver disease was determined by the subject’s answer to the questions 
# "Has a doctor or other health professional ever told you that you have liver disease?” and 
# “Do you still have a liver condition?”
# MCQ160L,  306,    Ever told you had any liver condition,  
# MCQ170L,  310,    Do you still have a liver condition,
liver1        <- (df_nh$MCQ160L == 1 | df_nh$MCQ170L == 1)
liverdisease  <- ifelse(is.na(liver1), 0, 1)

# Alcohol intake: (alcohol)
# Alcohol intake was categorized as <1 drink per day, 1 to 4 drinks per day, or ≥5 drinks per day.
# ALQ130,   671,    Avg # alcoholic drinks/day -past 12 mos
alcohol       <- df_nh$ALQ130

# Bilirubin level: (bilirubin)
# continuous
#
# LBDSTBSI, 250,  Bilirubin total (umol/L),   99-00 LAB18,  01-02 L40_B,  03-04 L40_C
bilirubin     <- df_nh$LBDSTBSI
bil_dLL       <- df_nh$LBDSTBSI * 0.058
# bil_low       <- ifelse(round(bil_dLL, 1) >= 0.1 & round(bil_dLL, 1) <= 0.5, "low", NA)
# bil_med       <- ifelse(round(bil_dLL, 1) >= 0.6 & round(bil_dLL, 1) <= 0.7, "med", NA)
# bil_hi        <- ifelse(round(bil_dLL, 1) >= 0.8 & round(bil_dLL, 1) <= 12.9, "hi", NA)

# Stroke: (adv_stroke_oc)
# categorical(binary): 1 = yes; 0 = no
#
# MCQ160F,  300,  Ever told you had a stroke, "Prevalent Stroke"  MCQ
# Health problems causing difficulty, stroke = 25
# PFD067A,  464,   99-00 PFQ, 01-02 PFQ
# PFD067B,  465,   99-00 PFQ, 01-02 PFQ
# PFD067C,  466,   99-00 PFQ, 01-02 PFQ
# PFD067D,  467,   99-00 PFQ, 01-02 PFQ
# PFD067E,  468,   99-00 PFQ, 01-02 PFQ
# PFQ063A,  777,   03-04 PFQ 
# PFQ063B,  778,   03-04 PFQ
# PFQ063C,  779,   03-04 PFQ
# PFQ063D,  780,   03-04 PFQ
# PFQ063E,  781,   03-04 PFQ
p_stroke      <- df_nh$MCQ160F
pstroke1      <- ifelse(df_nh$MCQ160F == 1, 1, 0)
# pstroke2      <- ifelse(df_nh$MCQ160F == 2, 0, NA)
# pstroke3      <- ifelse(df_nh$MCQ160F == 7, NA, df_nh$MCQ160F)
# pstroke4      <- ifelse(df_nh$MCQ160F == 9, NA, df_nh$MCQ160F)

stroke1       <- (df_nh$PFD067A == 25 | df_nh$PFD067B == 25 | df_nh$PFD067C == 25 | 
                  df_nh$PFD067D == 25 | df_nh$PFD067E == 25 | df_nh$PFQ063A == 25 | 
                  df_nh$PFQ063B == 25 | df_nh$PFQ063C == 25 | df_nh$PFQ063D == 25 | 
                  df_nh$PFQ063E == 25) 
adv_stroke_oc <- ifelse(is.na(stroke1), 0, 1)

# build final project dataframe for writing/export
df_proj <- data.frame(resp, age, age_group, race_eth, gender, bilirubin, bil_dLL, 
                        smoke, hypertension, diabetes, chol_ratio, hyper_chol,
                        bmi, crp, hemoglobin, homocysteine, liverdisease, 
                        alcohol, pstroke1, adv_stroke_oc)
names(df_proj) <- c("respondent", "age", "age_group", "race_ethnicity", "gender", 
                      "bilirubin_level", "bil_dLL", "smoking_status", "hypertension", "diabetes",
                      "cholesterol_ratio", "hypercholesterolemia", "BMI", "CRP", 
                      "hemoglobin", "homocysteine", "liver_disease", "alcohol_intake",
                      "prevalent_stroke", "adverse_stroke_outcome")
# remove covariate NAs
# 21 for smoking_status
df_proj <- df_proj[complete.cases(df_proj[ , "smoking_status"]), ]
# 21 for cholesterol_ratio
df_proj <- df_proj[complete.cases(df_proj[ , "cholesterol_ratio"]), ]
# at this point (df_proj) n = 13228

# std. dev. of bilirubin level per pg. 783
bil_sd <- sd(bilirubin, na.rm = TRUE)

# remove confounder NAs
# 4 for CRP
#df_proj <- df_proj[complete.cases(df_proj[ , "CRP"]), ]
# 7 for hemoglobin (LBXHGB)
#df_proj <- df_proj[complete.cases(df_proj[ , "hemoglobin"]), ]

# tertiles of Bilirubin per pg. 785
bil_low       <- ifelse(round(df_proj$bil_dLL, 1) >= 0.1 & round(df_proj$bil_dLL, 1) <= 0.5, "low", NA)
bil_med       <- ifelse(round(df_proj$bil_dLL, 1) >= 0.6 & round(df_proj$bil_dLL, 1) <= 0.7, "med", NA)
bil_hi        <- ifelse(round(df_proj$bil_dLL, 1) >= 0.8 & round(df_proj$bil_dLL, 1) <= 12.9, "hi", NA)

bil_ter1 <- ifelse(is.na(bil_low), bil_med, bil_low)
bil_ter <- ifelse(is.na(bil_ter1), bil_hi, bil_ter1)
df_proj$bil_ter <- bil_ter


# dataset summary
summary(df_proj)

# std. deviation of all vars
sapply(df_proj, sd)


# 2.  PARTICIPANT CHARACTERISTICS TABLES
#

# df_proj$age_group
# 1: 20-39, 2: 40-59, 3: 60+
table(df_proj$age_group)
age20_39      <- sum(df_proj$age >= 20 & df_proj$age <= 39)
age40_59      <- sum(df_proj$age >= 40 & df_proj$age <= 59)
age60plus     <- sum(df_proj$age >= 60)
age.response  <- na.omit(df_proj$age)
n             <- length(age.response)

# FREQUENCY
round(prop.test(age20_39, n)$estimate * 100, 1)
round(prop.test(age20_39, n)$conf.int[1] * 100, 1)
round(prop.test(age20_39, n)$conf.int[2] * 100, 1)

round(prop.test(age40_59, n)$estimate * 100, 1)
round(prop.test(age40_59, n)$conf.int[1] * 100, 1)
round(prop.test(age40_59, n)$conf.int[2] * 100, 1)

round(prop.test(age60plus, n)$estimate * 100, 1)
round(prop.test(age60plus, n)$conf.int[1] * 100, 1)
round(prop.test(age60plus, n)$conf.int[2] * 100, 1)


# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_age20_39   <- df_proj[df_proj$age_group == 1, ]
t.test(df_age20_39$bilirubin_level)
round(t.test(df_age20_39$prevalent_stroke)$estimate*100, 1)
round(t.test(df_age20_39$prevalent_stroke)$conf.int*100, 1)

df_age40_59   <- df_proj[df_proj$age_group == 2, ]
t.test(df_age40_59$bilirubin_level)
round(t.test(df_age40_59$prevalent_stroke)$estimate*100, 1)
round(t.test(df_age40_59$prevalent_stroke)$conf.int*100, 1)

df_age60plus  <- df_proj[df_proj$age_group == 3, ]
t.test(df_age60plus$bilirubin_level)
round(t.test(df_age60plus$prevalent_stroke)$estimate*100, 1)
round(t.test(df_age60plus$prevalent_stroke)$conf.int*100, 1)

# Table 2
df_strokeh <- df_strokeh[df_strokeh$prevalent_stroke == 1, ]
df_strokeh_wadv <- df_strokeh[df_strokeh$adverse_stroke_outcome == 1, ]
df_strokeh_noadv <- df_strokeh[df_strokeh$adverse_stroke_outcome == 0, ]

strokeh_noadv_20_39 <- sum(df_strokeh_noadv$age_group == 1)
strokeh_noadv_40_59 <- sum(df_strokeh_noadv$age_group == 2)
strokeh_noadv_60p <- sum(df_strokeh_noadv$age_group == 3)
n              <- nrow(df_strokeh_noadv)

round(prop.test(strokeh_noadv_20_39, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_20_39, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_40_59, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_40_59, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_60p, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_60p, n)$conf.int * 100, 1)

strokeh_wadv_20_39 <- sum(df_strokeh_wadv$age_group == 1)
strokeh_wadv_40_59 <- sum(df_strokeh_wadv$age_group == 2)
strokeh_wadv_60p <- sum(df_strokeh_wadv$age_group == 3)
n                 <- nrow(df_strokeh_wadv)

round(prop.test(strokeh_wadv_20_39, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_20_39, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_40_59, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_40_59, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_60p, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_60p, n)$conf.int * 100, 1)


# df_proj$gender
# 1: male, 2: female
table(df_proj$gender)
male          <- sum(df_proj$gender == 1)
female        <- sum(df_proj$gender == 2)
gender.response <- na.omit(df_proj$gender)
n             <- length(age.response)

# FREQUENCY
round(prop.test(male, n)$estimate * 100, 1)
round(prop.test(male, n)$conf.int[1] * 100, 1)
round(prop.test(male, n)$conf.int[2] * 100, 1)

round(prop.test(female, n)$estimate * 100, 1)
round(prop.test(female, n)$conf.int[1] * 100, 1)
round(prop.test(female, n)$conf.int[2] * 100, 1)

# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_male <- df_proj[df_proj$gender == 1, ]
t.test(df_male$bilirubin_level)
round(t.test(df_male$prevalent_stroke)$estimate*100, 1)
round(t.test(df_male$prevalent_stroke)$conf.int*100, 1)

df_female <- df_proj[df_proj$gender == 2, ]
t.test(df_female$bilirubin_level)
round(t.test(df_female$prevalent_stroke)$estimate*100, 1)
round(t.test(df_female$prevalent_stroke)$conf.int*100, 1)

# Table 2
strokeh_noadv_male <- sum(df_strokeh_noadv$gender == 1)
strokeh_noadv_female <- sum(df_strokeh_noadv$gender == 2)
n              <- nrow(df_strokeh_noadv)

round(prop.test(strokeh_noadv_male, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_male, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_female, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_female, n)$conf.int * 100, 1)

strokeh_wadv_male <- sum(df_strokeh_wadv$gender == 1)
strokeh_wadv_female <- sum(df_strokeh_wadv$gender == 2)
n              <- nrow(df_strokeh_wadv)

round(prop.test(strokeh_wadv_male, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_male, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_female, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_female, n)$conf.int * 100, 1)


# df_proj$race_ethnicity
# 1: non-Hispanic white, 2: non-Hispanic black,
# 3: Mexican-American, 4: other
# FREQUENCY
table(df_proj$race_ethnicity)
white         <- sum(df_proj$race_ethnicity == 1)
black         <- sum(df_proj$race_ethnicity == 2)
mexam         <- sum(df_proj$race_ethnicity == 3)
other_re      <- sum(df_proj$race_ethnicity == 4)
race.response <- na.omit(df_proj$race_ethnicity)
n             <- length(race.response)

round(prop.test(white, n)$estimate * 100, 1)
round(prop.test(white, n)$conf.int * 100, 1)

round(prop.test(black, n)$estimate * 100, 1)
round(prop.test(black, n)$conf.int * 100, 1)

round(prop.test(mexam, n)$estimate * 100, 1)
round(prop.test(mexam, n)$conf.int * 100, 1)

round(prop.test(other_re, n)$estimate * 100, 1)
round(prop.test(other_re, n)$conf.int * 100, 1)

# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_white <- df_proj[df_proj$race_ethnicity == 1, ]
t.test(df_white$bilirubin_level)
round(t.test(df_white$prevalent_stroke)$estimate*100, 1)
round(t.test(df_white$prevalent_stroke)$conf.int*100, 1)

df_black <- df_proj[df_proj$race_ethnicity == 2, ]
t.test(df_black$bilirubin_level)
round(t.test(df_black$prevalent_stroke)$estimate*100, 1)
round(t.test(df_black$prevalent_stroke)$conf.int*100, 1)

df_mexam <- df_proj[df_proj$race_ethnicity == 3, ]
t.test(df_mexam$bilirubin_level)
round(t.test(df_mexam$prevalent_stroke)$estimate*100, 1)
round(t.test(df_mexam$prevalent_stroke)$conf.int*100, 1)

df_other_re <- df_proj[df_proj$race_ethnicity == 4, ]
t.test(df_other_re$bilirubin_level)
round(t.test(df_other_re$prevalent_stroke)$estimate*100, 1)
round(t.test(df_other_re$prevalent_stroke)$conf.int*100, 1)

# Table 2
strokeh_noadv_white <- sum(df_strokeh_noadv$race_ethnicity == 1)
strokeh_noadv_black <- sum(df_strokeh_noadv$race_ethnicity == 2)
strokeh_noadv_mexam <- sum(df_strokeh_noadv$race_ethnicity == 3)
strokeh_noadv_other <- sum(df_strokeh_noadv$race_ethnicity == 4)
n              <- nrow(df_strokeh_noadv)

round(prop.test(strokeh_noadv_white, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_white, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_black, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_black, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_mexam, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_mexam, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_other, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_other, n)$conf.int * 100, 1)

strokeh_wadv_white <- sum(df_strokeh_wadv$race_ethnicity == 1)
strokeh_wadv_black <- sum(df_strokeh_wadv$race_ethnicity == 2)
strokeh_wadv_mexam <- sum(df_strokeh_wadv$race_ethnicity == 3)
strokeh_wadv_other <- sum(df_strokeh_wadv$race_ethnicity == 4)
n              <- nrow(df_strokeh_wadv)

round(prop.test(strokeh_wadv_white, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_white, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_black, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_black, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_mexam, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_mexam, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_other, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_other, n)$conf.int * 100, 1)


# df_proj$hypertension
# 1: yes, 0: no
table(df_proj$hypertension)
hypert_yes    <- sum(df_proj$hypertension == 1)
hypert_no     <- sum(df_proj$hypertension == 0)
hypert.response <- na.omit(df_proj$hypertension)
n             <- length(hypert.response)
# FREQUENCY
round(prop.test(hypert_yes, n)$estimate * 100, 1)
round(prop.test(hypert_yes, n)$conf.int * 100, 1)

round(prop.test(hypert_no, n)$estimate * 100, 1)
round(prop.test(hypert_no, n)$conf.int * 100, 1)

# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_hypert_yes <- df_proj[df_proj$hypertension == 1, ]
t.test(df_hypert_yes$bilirubin_level)
round(t.test(df_hypert_yes$prevalent_stroke)$estimate*100, 1)
round(t.test(df_hypert_yes$prevalent_stroke)$conf.int*100, 1)

df_hypert_no <- df_proj[df_proj$hypertension == 0, ]
t.test(df_hypert_no$bilirubin_level)
round(t.test(df_hypert_no$prevalent_stroke)$estimate*100, 1)
round(t.test(df_hypert_no$prevalent_stroke)$conf.int*100, 1)

# Table 2
strokeh_noadv_hypert_yes <- sum(df_strokeh_noadv$hypertension == 1)
strokeh_noadv_hypert_no <- sum(df_strokeh_noadv$hypertension == 0)
n              <- nrow(df_strokeh_noadv)
round(prop.test(strokeh_noadv_hypert_yes, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_hypert_yes, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_hypert_no, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_hypert_no, n)$conf.int * 100, 1)

strokeh_wadv_hypert_yes <- sum(df_strokeh_wadv$hypertension == 1)
strokeh_wadv_hypert_no <- sum(df_strokeh_wadv$hypertension == 0)
n              <- nrow(df_strokeh_wadv)
round(prop.test(strokeh_wadv_hypert_yes, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_hypert_yes, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_hypert_no, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_hypert_no, n)$conf.int * 100, 1)

# df_proj$diabetes
# 1: yes, 0: no
table(df_proj$diabetes)
diab_yes    <- sum(df_proj$diabetes == 1)
diab_no     <- sum(df_proj$diabetes == 0)
diab.response <- na.omit(df_proj$diabetes)
n             <- length(diab.response)
# FREQUENCY
round(prop.test(diab_yes, n)$estimate * 100, 1)
round(prop.test(diab_yes, n)$conf.int * 100, 1)

round(prop.test(diab_no, n)$estimate * 100, 1)
round(prop.test(diab_no, n)$conf.int * 100, 1)

# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_diab_yes <- df_proj[df_proj$diabetes == 1, ]
t.test(df_diab_yes$bilirubin_level)
round(t.test(df_diab_yes$prevalent_stroke)$estimate*100, 1)
round(t.test(df_diab_yes$prevalent_stroke)$conf.int*100, 1)

df_diab_no <- df_proj[df_proj$diabetes == 0, ]
t.test(df_diab_no$bilirubin_level)
round(t.test(df_diab_no$prevalent_stroke)$estimate*100, 1)
round(t.test(df_diab_no$prevalent_stroke)$conf.int*100, 1)

# Table 2
strokeh_noadv_diab_yes <- sum(df_strokeh_noadv$diabetes == 1)
strokeh_noadv_diab_no <- sum(df_strokeh_noadv$diabetes == 0)
n              <- nrow(df_strokeh_noadv)
round(prop.test(strokeh_noadv_diab_yes, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_diab_yes, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_diab_no, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_diab_no, n)$conf.int * 100, 1)

strokeh_wadv_diab_yes <- sum(df_strokeh_wadv$diabetes == 1)
strokeh_wadv_diab_no <- sum(df_strokeh_wadv$diabetes == 0)
n              <- nrow(df_strokeh_wadv)
round(prop.test(strokeh_wadv_diab_yes, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_diab_yes, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_diab_no, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_diab_no, n)$conf.int * 100, 1)


# df_proj$hypercholesterolemia
# 1: yes, 0: no
table(df_proj$hypercholesterolemia)
hyperc_yes    <- sum(df_proj$hypercholesterolemia == 1)
hyperc_no     <- sum(df_proj$hypercholesterolemia == 0)
hyperc.response <- na.omit(df_proj$hypercholesterolemia)
n             <- length(hyperc.response)
# FREQUENCY
round(prop.test(hyperc_yes, n)$estimate * 100, 1)
round(prop.test(hyperc_yes, n)$conf.int * 100, 1)

round(prop.test(hyperc_no, n)$estimate * 100, 1)
round(prop.test(hyperc_no, n)$conf.int * 100, 1)

# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_hyperc_yes <- df_proj[df_proj$hypercholesterolemia == 1, ]
t.test(hyperc_yes$bilirubin_level)
round(t.test(hyperc_yes$prevalent_stroke)$estimate*100, 1)
round(t.test(hyperc_yes$prevalent_stroke)$conf.int*100, 1)

df_hyperc_no <- df_proj[df_proj$hypercholesterolemia == 0, ]
t.test(hyperc_no$bilirubin_level)
round(t.test(hyperc_no$prevalent_stroke)$estimate*100, 1)
round(t.test(hyperc_no$prevalent_stroke)$conf.int*100, 1)

# Table 2
strokeh_noadv_hyperc_yes <- sum(df_strokeh_noadv$hypercholesterolemia == 1)
strokeh_noadv_hyperc_no <- sum(df_strokeh_noadv$hypercholesterolemia == 0)
n              <- nrow(df_strokeh_noadv)
round(prop.test(strokeh_noadv_hyperc_yes, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_hyperc_yes, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_hyperc_no, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_hyperc_no, n)$conf.int * 100, 1)

strokeh_wadv_hyperc_yes <- sum(df_strokeh_wadv$hypercholesterolemia == 1)
strokeh_wadv_hyperc_no <- sum(df_strokeh_wadv$hypercholesterolemia == 0)
n              <- nrow(df_strokeh_wadv)
round(prop.test(strokeh_wadv_hyperc_yes, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_hyperc_yes, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_hyperc_no, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_hyperc_no, n)$conf.int * 100, 1)


# df_proj$smoking_status
# 1 = active; 2 = former; 3 = never
table(df_proj$smoking_status)
sm_active <- sum(df_proj$smoking_status == 1)
sm_former <- sum(df_proj$smoking_status == 2)
sm_never <- sum(df_proj$smoking_status == 3)
# FREQUENCY
round(prop.test(sm_active, n)$estimate * 100, 1)
round(prop.test(sm_active, n)$conf.int * 100, 1)

round(prop.test(sm_former, n)$estimate * 100, 1)
round(prop.test(sm_former, n)$conf.int * 100, 1)

round(prop.test(sm_never, n)$estimate * 100, 1)
round(prop.test(sm_never, n)$conf.int * 100, 1)

# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_sm_active <- df_proj[df_proj$smoking_status == 1, ]
t.test(df_sm_active$bilirubin_level)
round(t.test(df_sm_active$prevalent_stroke)$estimate*100, 1)
round(t.test(df_sm_active$prevalent_stroke)$conf.int*100, 1)

df_sm_former <- df_proj[df_proj$smoking_status == 2, ]
t.test(df_sm_former$bilirubin_level)
round(t.test(df_sm_former$prevalent_stroke)$estimate*100, 1)
round(t.test(df_sm_former$prevalent_stroke)$conf.int*100, 1)

df_sm_never <- df_proj[df_proj$smoking_status == 3, ]
t.test(df_sm_never$bilirubin_level)
round(t.test(df_sm_never$prevalent_stroke)$estimate*100, 1)
round(t.test(df_sm_never$prevalent_stroke)$conf.int*100, 1)

# Table 2
strokeh_noadv_sm_active <- sum(df_strokeh_noadv$smoking_status == 1)
strokeh_noadv_sm_former <- sum(df_strokeh_noadv$smoking_status == 2)
strokeh_noadv_sm_never <- sum(df_strokeh_noadv$smoking_status == 3)
n              <- nrow(df_strokeh_noadv)
round(prop.test(strokeh_noadv_sm_active, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_sm_active, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_sm_former, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_sm_former, n)$conf.int * 100, 1)

round(prop.test(strokeh_noadv_sm_never, n)$estimate * 100, 1)
round(prop.test(strokeh_noadv_sm_never, n)$conf.int * 100, 1)

strokeh_wadv_sm_active <- sum(df_strokeh_wadv$smoking_status == 1)
strokeh_wadv_sm_former <- sum(df_strokeh_wadv$smoking_status == 2)
strokeh_wadv_sm_never <- sum(df_strokeh_wadv$smoking_status == 3)
n              <- nrow(df_strokeh_wadv)
round(prop.test(strokeh_wadv_sm_active, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_sm_active, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_sm_former, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_sm_former, n)$conf.int * 100, 1)

round(prop.test(strokeh_wadv_sm_never, n)$estimate * 100, 1)
round(prop.test(strokeh_wadv_sm_never, n)$conf.int * 100, 1)

# df_proj$prevalent_stroke
# 1: yes, 0: no
table(df_proj$prevalent_stroke)
stroke_yes    <- sum(df_proj$prevalent_stroke == 1)
stroke_no     <- sum(df_proj$prevalent_stroke == 0)
stroke.response <- na.omit(df_proj$prevalent_stroke)
n             <- length(stroke.response)
# FREQUENCY
round(prop.test(stroke_yes, n)$estimate * 100, 1)
round(prop.test(stroke_yes, n)$conf.int * 100, 1)

round(prop.test(stroke_no, n)$estimate * 100, 1)
round(prop.test(stroke_no, n)$conf.int * 100, 1)

# SERUM TOTAL BILIRUBIN LEVEL & STROKE PREVALENCE
df_stroke_yes <- df_proj[df_proj$prevalent_stroke == 1, ]
t.test(df_stroke_yes$bilirubin_level)

df_stroke_no <- df_proj[df_proj$prevalent_stroke == 0, ]
t.test(df_stroke_no$bilirubin_level)

round(prop.test(453, 13228)$estimate * 100, 1)
round(prop.test(453, 13228)$conf.int * 100, 1)




## two-way contingency table of categorical outcome and predictors
## we want to make sure there are not 0 cells
# covariates
xtabs(~ prevalent_stroke + race_ethnicity, data = df_proj)
xtabs(~ prevalent_stroke + gender, data = df_proj)
xtabs(~ prevalent_stroke + smoking_status, data = df_proj)
xtabs(~ prevalent_stroke + hypertension, data = df_proj)
xtabs(~ prevalent_stroke + diabetes, data = df_proj)
xtabs(~ prevalent_stroke + hypercholesterolemia, data = df_proj)
# possible confounders
xtabs(~ prevalent_stroke + liver_disease, data = df_proj)



# 3. LOGISTIC REGRESSION (Prevalent Stroke)
#
# use factor() to make sure we indicate that 
# these variables below should be treated as categorical:
df_proj$age_group <- factor(df_proj$age_group)
df_proj$race_ethnicity <- factor(df_proj$race_ethnicity)
df_proj$gender <- factor(df_proj$gender)
df_proj$smoking_status <- factor(df_proj$smoking_status)
df_proj$hypertension <- factor(df_proj$hypertension)
df_proj$diabetes <- factor(df_proj$diabetes)
df_proj$hypercholesterolemia <- factor(df_proj$hypercholesterolemia)



# Prevalent Stroke logistic regressionn (quadratic)
sq_psLogit <- glm(prevalent_stroke ~ (bil_dLL^2) + age + race_ethnicity + gender + 
                 smoking_status + hypertension + diabetes + cholesterol_ratio,
               data = df_proj, family = "binomial")
summary(sq_psLogit)
exp(cbind(OR = coef(sq_psLogit), confint(sq_psLogit)) / 10)

# Prevalent Stroke logistic regressionn (log-transformed)
lg_psLogit <- glm(prevalent_stroke ~ log(bil_dLL) + age + race_ethnicity + gender + 
                    smoking_status + hypertension + diabetes + cholesterol_ratio,
                  data = df_proj, family = "binomial")
summary(lg_psLogit)
exp(cbind(OR = coef(lg_psLogit), confint(lg_psLogit)) / 10)

# Prevalent Stroke logistic regression (normal)
psLogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                    smoking_status + hypertension + diabetes + cholesterol_ratio,
                    data = df_proj, family = "binomial")
summary(psLogit)
# 0.1 mg/dL increase: odds ratios and 95% confidence intervals
# rationale: 1 / 0.1 = 10
exp(cbind(OR = coef(psLogit), confint(psLogit)) / 10)

# 1 std. dev increase: odds ratios and 95% confidence intervals
# rationale: 1 / bil_sd_mgdL = 3.232509
bil_sd_mgdL = bil_sd * 0.058
exp(cbind(OR = coef(psLogit), confint(psLogit)) / (1 / bil_sd_mgdL))


# possible confounders
# BMI
psBMILogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                  smoking_status + hypertension + diabetes + cholesterol_ratio + BMI,
                  data = df_proj, family = "binomial")
summary(psBMILogit)
exp(cbind(OR = coef(psBMILogit), confint(psBMILogit)) / 10)

# CRP
psCRPLogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                  smoking_status + hypertension + diabetes + cholesterol_ratio + CRP,
                  data = df_proj, family = "binomial")
summary(psCRPLogit)
exp(cbind(OR = coef(psCRPLogit), confint(psCRPLogit)) / 10)

# hemoglobin
ps_hemoLogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                    smoking_status + hypertension + diabetes + cholesterol_ratio + hemoglobin,
                    data = df_proj, family = "binomial")
summary(ps_hemoLogit)
exp(cbind(OR = coef(ps_hemoLogit), confint(ps_hemoLogit)) / 10)

# homocysteine
ps_homocysLogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                         smoking_status + hypertension + diabetes + cholesterol_ratio + homocysteine,
                       data = df_proj, family = "binomial")
summary(ps_homocysLogit)
exp(cbind(OR = coef(ps_homocysLogit), confint(ps_homocysLogit)) / 10)

# subset project data frame by bilirubin tertiles defined in original paper
lowter_df_proj = df_proj[df_proj$bil_ter == "low", ]
midter_df_proj = df_proj[df_proj$bil_ter == "med", ]
hiter_df_proj = df_proj[df_proj$bil_ter == "hi", ]

# stroke prevalence, percent (95% CI), by "tertiles"
table(lowter_df_proj$prevalent_stroke)
pstroke_yes    <- sum(lowter_df_proj$prevalent_stroke == 1)
pstroke_no     <- sum(lowter_df_proj$prevalent_stroke == 0)
n             <- nrow(lowter_df_proj)

round(prop.test(pstroke_yes, n)$estimate * 100, 1)
round(prop.test(pstroke_yes, n)$conf.int * 100, 1)

table(midter_df_proj$prevalent_stroke)
pstroke_yes    <- sum(midter_df_proj$prevalent_stroke == 1)
pstroke_no     <- sum(midter_df_proj$prevalent_stroke == 0)
n             <- nrow(midter_df_proj)

round(prop.test(pstroke_yes, n)$estimate * 100, 1)
round(prop.test(pstroke_yes, n)$conf.int * 100, 1)

table(hiter_df_proj$prevalent_stroke)
pstroke_yes    <- sum(hiter_df_proj$prevalent_stroke == 1)
pstroke_no     <- sum(hiter_df_proj$prevalent_stroke == 0)
n             <- nrow(hiter_df_proj)

round(prop.test(pstroke_yes, n)$estimate * 100, 1)
round(prop.test(pstroke_yes, n)$conf.int * 100, 1)

# Prevalent Stroke logit regression by "tertiles"
lowter_psLogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                      smoking_status + hypertension + diabetes + cholesterol_ratio,
                      data = lowter_df_proj, family = "binomial")
  
midter_psLogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                      smoking_status + hypertension + diabetes + cholesterol_ratio,
                      data = midter_df_proj, family = "binomial")

hiter_psLogit <- glm(prevalent_stroke ~ bil_dLL + age + race_ethnicity + gender + 
                     smoking_status + hypertension + diabetes + cholesterol_ratio,
                     data = hiter_df_proj, family = "binomial")

summary(lowter_psLogit)
exp(cbind(OR = coef(lowter_psLogit), confint(lowter_psLogit)) / 10)

summary(midter_psLogit)
exp(cbind(OR = coef(midter_psLogit), confint(midter_psLogit)) / 5)

summary(hiter_psLogit)
exp(cbind(OR = coef(hiter_psLogit), confint(hiter_psLogit)) / 3.333)

ps_low_OR_CI = c(0.9428392, 0.7841239, 1.1407936)
mult <- (1 / ps_low_OR_CI)

ps_mid_OR_CI = c(0.9054971, 0.6462659, 1.2604953)
ps_hi_OR_CI = c(0.9796864, 0.9249730, 1.0208884)


# Logistic Regression (Adverse Stroke Outcome)
#
# Adverse Stroke Outcome logit regression
asoLogit <- glm(adverse_stroke_outcome ~ bil_dLL + age + race_ethnicity + gender + 
                smoking_status + hypertension + diabetes + cholesterol_ratio,
                data = df_proj, family = "binomial")
summary(asoLogit)
exp(cbind(OR = coef(asoLogit), confint(asoLogit)) / 10)
# 1 std. dev increase: odds ratios and 95% confidence intervals
# rationale: 1 / bil_sd_mgdL = 3.232509
bil_sd_mgdL = bil_sd * 0.058
exp(cbind(OR = coef(asoLogit), confint(asoLogit)) / (1 / bil_sd_mgdL))

# Adverse Stroke Outcome logit regression
lg_asoLogit <- glm(adverse_stroke_outcome ~ log(bil_dLL) + age + race_ethnicity + gender + 
                   smoking_status + hypertension + diabetes + cholesterol_ratio,
                   data = df_proj, family = "binomial")
summary(lg_asoLogit)
exp(cbind(OR = coef(lg_asoLogit), confint(lg_asoLogit)) / 10)

# confounders
# BMI
asoBMILogit <- glm(adverse_stroke_outcome ~ bil_dLL + age_group + race_ethnicity + gender + 
                   smoking_status + hypertension + diabetes + hypercholesterolemia + BMI,
                   data = df_proj, family = "binomial")
summary(asoBMILogit)
exp(cbind(OR = coef(asoBMILogit), confint(asoBMILogit)) / 10)

# CRP
asoCRPLogit <- glm(adverse_stroke_outcome ~ bil_dLL + age_group + race_ethnicity + gender + 
                   smoking_status + hypertension + diabetes + hypercholesterolemia + CRP,
                   data = df_proj, family = "binomial")
summary(asoCRPLogit)
exp(cbind(OR = coef(asoCRPLogit), confint(asoCRPLogit)) / 10)

# hemoglobin
aso_hemoLogit <- glm(adverse_stroke_outcome ~ bil_dLL + age_group + race_ethnicity + gender + 
                     smoking_status + hypertension + diabetes + hypercholesterolemia + hemoglobin,
                     data = df_proj, family = "binomial")
summary(aso_hemoLogit)
exp(cbind(OR = coef(aso_hemoLogit), confint(aso_hemoLogit)) / 10)

# homocysteine
aso_homocysLogit <- glm(adverse_stroke_outcome ~ bil_dLL + age_group + race_ethnicity + gender + 
                        smoking_status + hypertension + diabetes + hypercholesterolemia + homocysteine,
                        data = df_proj, family = "binomial")
summary(aso_homocysLogit)
exp(cbind(OR = coef(aso_homocysLogit), confint(aso_homocysLogit)) / 10)


# Adverse Stroke Outcome logit regression by age group (by "tertiles")
lowter_asoLogit <- glm(adverse_stroke_outcome ~ bil_dLL + age + race_ethnicity + gender + 
                       smoking_status + hypertension + diabetes + cholesterol_ratio,
                       data = lowter_df_proj, family = "binomial")

midter_asoLogit <- glm(adverse_stroke_outcome ~ bil_dLL + age + race_ethnicity + gender + 
                       smoking_status + hypertension + diabetes + cholesterol_ratio,
                       data = midter_df_proj, family = "binomial")

hiter_asoLogit <- glm(adverse_stroke_outcome ~ bil_dLL + age + race_ethnicity + gender + 
                      smoking_status + hypertension + diabetes + cholesterol_ratio,
                      data = hiter_df_proj, family = "binomial")
summary(lowter_asoLogit)
exp(cbind(OR = coef(lowter_asoLogit), confint(lowter_asoLogit)) / 10)

summary(midter_asoLogit)
exp(cbind(OR = coef(midter_asoLogit), confint(midter_asoLogit)) / 10)

summary(hiter_asoLogit)
exp(cbind(OR = coef(hiter_asoLogit), confint(hiter_asoLogit)) / 10)


# relative comparison of ORs
aso_low_OR_CI = c(0.7947517, 0.5892335, 1.0869925)
mult <- (1 / aso_low_OR_CI)

aso_mid_OR_CI = c(1.0910321, 0.6192689, 1.9016434)
aso_mid_OR_CI * mult
aso_hi_OR_CI = c(0.9697591, 8.626288e-01, 1.0366037)
aso_hi_OR_CI * mult

# adverse stroke outcome prevalence, percent (95%, CI)
table(lowter_df_proj$prevalent_stroke)
wadv_yes    <- sum(lowter_df_proj$adverse_stroke_outcome == 1)
n             <- sum(lowter_df_proj$prevalent_stroke == 1)

round(prop.test(wadv_yes, n)$estimate * 100, 1)
round(prop.test(wadv_yes, n)$conf.int * 100, 1)

table(midter_df_proj$prevalent_stroke)
wadv_yes    <- sum(midter_df_proj$adverse_stroke_outcome == 1)
n             <- sum(midter_df_proj$prevalent_stroke == 1)

round(prop.test(wadv_yes, n)$estimate * 100, 1)
round(prop.test(wadv_yes, n)$conf.int * 100, 1)

table(hiter_df_proj$prevalent_stroke)
wadv_yes    <- sum(hiter_df_proj$adverse_stroke_outcome == 1)
n             <- sum(hiter_df_proj$prevalent_stroke == 1)

round(prop.test(wadv_yes, n)$estimate * 100, 1)
round(prop.test(wadv_yes, n)$conf.int * 100, 1)






# http://stackoverflow.com/questions/4126326/how-to-quickly-form-groups-quartiles-deciles-etc-by-ordering-columns-in-a
# https://cran.r-project.org/web/packages/dplyr/vignettes/window-functions.html
# tertiles of Bilirubin
# df_proj$bilirubin_tertile <- ntile(df_proj$bilirubin_level, 3)
# bilirubin_tertile <- ntile(df_proj$bilirubin_level, 3)
# 
# by_age_group <- group_by(df_proj, age_group)
# summarise(by_age_group, BIL = mean(df_proj$bilirubin_level))


# Logit Regression
# http://www.ats.ucla.edu/stat/r/dae/logit.htm

# Multinomial Logistic Regression
# http://www.ats.ucla.edu/stat/r/dae/mlogit.htm
#
# Description of the data
# with(df_proj, table(df_proj$bilirubin_tertile, df_proj$age_group))
# with(df_proj, table(df_proj$age_group, df_proj$bilirubin_tertile))
# 
# with(df_proj, do.call(rbind, tapply(df_proj$bilirubin_tertile, df_proj$age_group,
#                                     function(x) c(M = mean(x), SD = sd(x)))))

# exploratory data analysis (EDA)

# summary statistics

# stem and leaf plots

# histograms
bil <- df_proj$bilirubin_level
barplot(table(bil),
        main="histogram of bilirubin proportions",
        xlab="bilirubin",
        ylab="proportion",
        border="red",
        col="blue",
        density=50
)




# bee swarm plots

# write the export dataframe to a CSV file
write.csv(df_proj, file = "CIS661_final_project_dataframe.csv", row.names = FALSE)




