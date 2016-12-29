setwd("//OHFS07/Home/dbasak/My Documents/CapitalOne Data Challenge -Debasmita/CapitalOne")

library(jsonlite)
library(plyr)



hmda_init <- function() {
  loan <- read.csv('2012_to_2014_loans_data.CSV',header=TRUE)
  inst <- read.csv('2012_to_2014_institutions_data.csv',header=TRUE)
  dt_merged <- join(loan, inst,   type = "left")
  dt_merged$Loan_Amount_Bucket <- cut(dt_merged$Loan_Amount_000, br=c(0,20000,40000,60000,80000,100000), labels = c("upto 20k","20k to 40k", "40k to 60k","60k to 80k","80k to 100k") )
  dt_merged$Applicant_Income_000 <- as.numeric(as.character(dt_merged$Applicant_Income_000))
  dt_merged$FFIEC_Median_Family_Income <- as.numeric(as.character(dt_merged$FFIEC_Median_Family_Income))
  ##Create field income category
  dt_merged$IncomeCategory <- NA

  dt_merged$pct_medianIncome = dt_merged$Applicant_Income_000*1000/dt_merged$FFIEC_Median_Family_Income
  
  i <- !is.na(dt_merged$pct_medianIncome) & dt_merged$pct_medianIncome <= 0.80  
  dt_merged[i,"IncomeCategory"] ="LMI"
  
  i <- !is.na(dt_merged$pct_medianIncome) &  dt_merged$pct_medianIncome > 0.80 & dt_merged$pct_medianIncome <= 1.2
  dt_merged[i,"IncomeCategory"] ="MUM"
  
  i <- !is.na(dt_merged$pct_medianIncome) & dt_merged$pct_medianIncome > 1.20
  dt_merged[i,"IncomeCategory"] ="UI"
  
  return(dt_merged)
}


hmda_to_json <- function(data, state_prm="All", conv_conf_prm="All") {
  data_subset<-data
  if (state_prm != "All")
  {
    data_subset <- subset(data_subset,state=state_prm)
  }
  if(conv_conf_prm != "All")
  {
    data_subset <- subset(data_subset,Conventional_Conforming_Flag=conv_conf_prm)
  }
   
  hmda_json <- toJSON(data_subset)
  write(hmda_json, file="hmda_json.JSON")
}

