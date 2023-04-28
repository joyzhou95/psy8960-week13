# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(keyring)
library(RMariaDB)

# Data Import and Cleaning
conn <- dbConnect(MariaDB(),
                  user = "zhou1559",
                  password = key_get("latis_sql","zhou1559"),
                  host = "mysql-prod5.oit.umn.edu",
                  port = 3306,
                  ssl.ca = '../mysql_hotel_umn_20220728_interm.cer')

dbExecute(conn, "USE cla_tntlab;")

week13_tbl <- dbGetQuery(conn, "SELECT *
                         FROM datascience_8960_table;")

write_csv(week13_tbl, "../data/week13.csv") 

# Analysis
nrow(week13_tbl)

n_distinct(week13_tbl$employee_id)

week13_tbl %>%
  filter(manager_hire == "N") %>%
  count(city)
  
week13_tbl %>%
  group_by(performance_group) %>%
  summarize(mean_employ = mean(yrs_employed),
            sd_employ = sd(yrs_employed))

week13_tbl %>%
  arrange(city, desc(test_score)) %>%
  group_by(city) %>%
  slice_max(test_score, n = 3) %>%
  select(employee_id, city)
  
  
  
  

