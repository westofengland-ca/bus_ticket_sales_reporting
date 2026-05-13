from tdh_keys import http_path
from tdh_keys import server_hostname
from databricks import sql
import polars as pl

from tdh_keys import *


connection = sql.connect(
    server_hostname=server_hostname,
    http_path=http_path,
    auth_type=auth_type
)

cursor = connection.cursor()


abus_sql = "SELECT *, 'abus' AS Operator FROM bronze_production.transport_operations.ticketer_sales_abus"
bath_bus_sql = "SELECT *, 'bath_bus_co' AS Operator FROM bronze_production.transport_operations.ticketer_sales_bath_bus"
ct_coaches_sql = "SELECT *, 'ct_coaches' AS Operator FROM bronze_production.transport_operations.ticketer_sales_ct_coaches"
big_lemon_sql = "SELECT *, 'big_lemon' AS Operator FROM bronze_production.transport_operations.ticketer_sales_big_lemon"
eurocoaches_sql = "SELECT *, 'eurocoaches' AS Operator FROM bronze_production.transport_operations.ticketer_sales_eurocoaches"
faresaver_sql = "SELECT *, 'faresaver' AS Operator FROM bronze_production.transport_operations.ticketer_sales_faresaver"
first_sql = "SELECT *, 'first' AS Operator FROM bronze_production.transport_operations.ticketer_sales_first_woe"

date_range_sql = " WHERE Scheduled_Start_Date BETWEEN '2026-04-13' AND '2026-04-19'"

abus_sql = abus_sql + date_range_sql + " UNION "
ct_coaches_sql = ct_coaches_sql + date_range_sql + " UNION "
big_lemon_sql = big_lemon_sql + date_range_sql + " UNION "
eurocoaches_sql = eurocoaches_sql + date_range_sql + " UNION "
faresaver_sql = faresaver_sql + date_range_sql + " UNION "
first_sql = first_sql + date_range_sql + ";"

sql_string = abus_sql + ct_coaches_sql + big_lemon_sql + eurocoaches_sql + faresaver_sql  + first_sql

cursor.execute(sql_string)
#cursor.execute("SELECT *, 'abus' AS Operator FROM bronze_production.transport_operations.ticketer_sales_abus UNION SELECT *, 'bath_bus_co' AS Operator FROM bronze_production.transport_operations.ticketer_sales_bath_bus UNION SELECT *, 'big_lemon' AS Operator FROM bronze_production.transport_operations.ticketer_sales_big_lemon UNION SELECT *, 'ct_coaches' AS Operator FROM bronze_production.transport_operations.ticketer_sales_ct_coaches UNION SELECT *, 'eurocoaches' AS Operator FROM bronze_production.transport_operations.ticketer_sales_eurocoaches UNION SELECT *, 'faresaver' AS Operator FROM bronze_production.transport_operations.ticketer_sales_faresaver UNION SELECT *, 'first_woe' AS Operator FROM bronze_production.transport_operations.ticketer_sales_first_woe LIMIT 100;")
df = pl.DataFrame(cursor.fetchall_arrow())
df.write_csv("./csv/all_ops_ticketer_20260413-20260419.csv")

#### above only works in R Studio!?!? - need to update for other IDEs.
#sql_string.("./sql.txt")

#lines = ['Readme', 'How to write text files in Python']
#with open('readme.txt', 'w') as f:
#    f.writelines(lines)



