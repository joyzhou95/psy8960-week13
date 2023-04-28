# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
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

## From the datascience_8960_table, select the manager_hire column, count its row number and save it as manager_count, 
## which represents the number of managers in the dataset 
dbGetQuery(conn, "SELECT 
           COUNT(manager_hire) AS manager_count
           FROM datascience_8960_table;")

## From the datascience_8960_table, select the employee_id column, count only the unique ids and save it as manager_unique_count, 
## which represents the number of unique managers in the dataset  
dbGetQuery(conn, "SELECT 
           COUNT(DISTINCT employee_id) AS manager_unique_count
           FROM datascience_8960_table;")

## From the datascience_8960_table, filter for the employees that were not hired as managers upon entering the company, 
## then group the table by city, lastly select the city column, count its row numbers and save it as manager_city_count, 
dbGetQuery(conn, "SELECT 
           city, 
           COUNT(city) AS manager_city_count 
           FROM datascience_8960_table
           WHERE manager_hire = 'N'
           GROUP BY city;")

## From the datascience_8960_table, first group by performance levels, then select the columns of performance levels,
## and calculate the mean and sd of years employed as mean_employ and sd_employ so that the final display includes the mean,
## sd and also their corresponding performance levels 
dbGetQuery(conn, "SELECT 
           performance_group, 
           AVG(yrs_employed) AS mean_employ, 
           STDDEV(yrs_employed) AS sd_employ
           FROM datascience_8960_table
           GROUP BY performance_group;")

## From the datascience_8960_table, first partition the dataset by city and sort it by the descending order of test scores,
## then create a column called rank_num, which represents the ranking of managers by test scores within each city, and save the new table as psy8960_table_rank_num 
## From the new table, select the employee_id and location of those ranked within top 3 
dbGetQuery(conn, "WITH psy8960_table_rank_num AS (
           SELECT *,
           RANK() OVER(PARTITION BY city ORDER BY test_score DESC) AS rank_num
           FROM datascience_8960_table
           )
           SELECT employee_id, city
           FROM psy8960_table_rank_num
           WHERE rank_num IN (1,2,3);")

