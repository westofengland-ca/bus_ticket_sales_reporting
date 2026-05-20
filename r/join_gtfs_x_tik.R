
library(dplyr)
library(tidyr)
library(purrr)
library(data.table)
library(lubridate)
library(scales)
library(hms)
library(DT)
library(ggplot2)
library(treemapify)
library(RColorBrewer)
library(glue)
library(here)
library(xts)



[1] "#A6CEE3" "#1F78B4" "#B2DF8A" "#33A02C" "#FB9A99" "#E31A1C"
[7] "#FDBF6F" "#FF7F00" "#CAB2D6" "#6A3D9A" "#FFFF99"

[1] "#A6CEE3" "#1F78B4" "#B2DF8A" "#33A02C" "#FB9A99" "#E31A1C"
[7] "#FDBF6F" "#FF7F00" "#CAB2D6" "#6A3D9A" "#FFFF99" "#B15928"

# bubble chart:
 # y = mileage
 # x = passengers
 # bubble_size = bph

# import month passenger csv
proj_path <- here()

month_csv <- dir(glue("{proj_path}/csv/sales/"), pattern = "all_ops_ticketer_", full.names = TRUE)

month_csv <- month_csv[4:5] %>%
  map(read.csv) %>%
  map(as_tibble)

# aggregate passeneger boardings by route

month_csv_map <- map(month_csv, filter, Service %in% c(6,7,42,43,44,45))
month_csv_map <- map(month_csv_map, mutate, datetime = as_datetime(IssuedAt))
month_csv_map <- do.call("rbind", month_csv_map)

# after running "stop_seq_gtfs" join route_long_name onto
# month_csv_map using Service = route_short_name and
# Bus_Stop_Atco = stop_code

pax <- month_csv_map %>% left_join(stop_seq, 
                                   by = c("Service" = "route_short_name", "Bus_Stop_Atco" = "stop_code"))

# find a way to join bus stats and month_csv by route






