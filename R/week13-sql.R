setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(keyring)
library(RMariaDB)

# Data Import and Cleaning
conn <- dbConnect(MariaDB(),
                  user = "zhou1559",
                  password = key_get("latis_sql","zhou1559"),
                  host = "mysql-prod5.oit.umn.edu",
                  port = 3306,
                  ssl.ca = 'mysql_hotel_umn_20220728_interm.cer')

dbExecute(conn, "USE cla_tntlab;")

dbGetQuery(conn, "SELECT 
           COUNT(manager_hire) AS manager_count
           FROM datascience_8960_table;")

dbGetQuery(conn, "SELECT 
           COUNT(DISTINCT employee_id) AS manager_unique_count
           FROM datascience_8960_table;")

dbGetQuery(conn, "SELECT 
           city, 
           COUNT(city) AS manager_city_count 
           FROM datascience_8960_table
           WHERE manager_hire = 'N'
           GROUP BY city;")

dbGetQuery(conn, "SELECT 
           performance_group, 
           AVG(yrs_employed) AS mean_employ, 
           STDDEV(yrs_employed) AS sd_employ
           FROM datascience_8960_table
           GROUP BY performance_group;")

dbGetQuery(conn, "WITH psy8960_table_row_num AS (
           SELECT *,
           RANK() OVER(PARTITION BY city ORDER BY test_score DESC) AS row_num
           FROM datascience_8960_table
           )
           SELECT employee_id, city
           FROM psy8960_table_row_num
           WHERE row_num IN (1,2,3);")

