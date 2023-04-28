# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(keyring)
library(RMariaDB)

# Data Import and Cleaning
## Log into UMN LATIS server using my UMN credentials and the certificate downloaded from their website,
## already set up the password using the keyring package
conn <- dbConnect(MariaDB(),
                  user = "zhou1559",
                  password = key_get("latis_sql","zhou1559"),
                  host = "mysql-prod5.oit.umn.edu",
                  port = 3306,
                  ssl.ca = '../mysql_hotel_umn_20220728_interm.cer')

## Send a comment to access the cla_tntlab folder 
dbExecute(conn, "USE cla_tntlab;")

## Select everything in the datascience_8960_table and save it as week13_tbl
week13_tbl <- dbGetQuery(conn, "SELECT *
                         FROM datascience_8960_table;")

## Save week13_tbl as a csv file in the data folder
write_csv(week13_tbl, "../data/week13.csv") 

# Analysis

## Calculate the number of managers by counting the number of rows in the table
nrow(week13_tbl)

## Count the number of unique managers by counting the number of unique employee ids in the table 
n_distinct(week13_tbl$employee_id)

## Count the number of managers in each city by first filtering the ones that were not hired as managers initally,
## then counting the frequency of each city appearing in the table 
week13_tbl %>%
  filter(manager_hire == "N") %>%
  count(city)

##First group the dataset by the performance levels, then create now columns that contain the mean and sd
## of years employed in each group 
week13_tbl %>%
  group_by(performance_group) %>%
  summarize(mean_employ = mean(yrs_employed),
            sd_employ = sd(yrs_employed))

## First sort the table by city and then by test scores (descending order), then group by city and select 
## the top three managers based on their test scores using slice_max, and finally only display these managers'
## employee_id and their location
week13_tbl %>%
  arrange(city, desc(test_score)) %>%
  group_by(city) %>%
  slice_max(test_score, n = 3) %>%
  select(employee_id, city)
  
  
  
  

