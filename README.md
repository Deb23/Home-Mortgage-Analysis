# data-challenge-data
Capital One Data Analyst Data Challenge

#How to Navigate
This folder contains 2 .R files and 2 R Markdown files

1)HMDA_API.R - This file conatins the 2 functions a) to load and merge data b) create Loan Amount Bucket c) create Applicant Income Category d) filter data based on user input(State and/or Conventional_Conforming_Flag) and export to a json file.
2)QualityCheck.RMD - This R markdown file will perform quality checks on Loan_Amount_000 and Respondent_Name.
3)DescriptiveAnalysis.RMD - This markdown file will analyse the HMDA data from different aspects and provide a summary report.
4)Shiny.R - This is an interactive Home Mortgage Data Analysis application created using Shiny.

#Prerequisites
1) The two source files should be placed in the same folder as these R codes.
2) Set the working directory in each of these files
3) For error free working of the entire code, below packages should be installed:
library(jsonlite)
library(plyr)
library(dplyr)
library(data.table)
library(sqldf)
library(ggplot2)
library(scales)
library(ggthemes)
library(shiny)






