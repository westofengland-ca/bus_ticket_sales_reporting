
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
library(khroma)



[1] "#A6CEE3" "#1F78B4" "#B2DF8A" "#33A02C" "#FB9A99" "#E31A1C"
[7] "#FDBF6F" "#FF7F00" "#CAB2D6" "#6A3D9A" "#FFFF99"


palette_fun <- khroma::color("sunset")
palette <- palette_fun(6)
palette[1:6]

#bright
[1] "#4477AA" "#EE6677" "#228833" "#CCBB44" "#66CCEE" "#AA3377"
#lisbon
"#E6E5FF" "#6083AE" "#132A42" "#383522" "#9A9160" "#FFFF9D"
#managua
"#FFCF67" "#C17449" "#773339" "#4C3D73" "#5F89C3" "#81E7FF"
#muted
[1] "#CC6677" "#332288" "#DDCC77" "#117733" "#88CCEE" "#882255"
#sunset
[1] "#364B9A" "#6EA6CD" "#C2E4EF" "#FEDA8B" "#F67E4B" "#A50026"




# import month passenger csv
proj_path <- here()

month_csv <- dir(glue("{proj_path}/csv/sales/"), pattern = "all_ops_ticketer_", full.names = TRUE)

month_csv <- month_csv[4:5] %>%
  map(read.csv) %>%
  map(as_tibble)

# aggregate passeneger boardings by route

month_csv_map <- map(month_csv, dplyr::filter, Service %in% routes_select)
                       #c(6,7,42,43,44,45))
month_csv_map <- map(month_csv_map, mutate, datetime = as_datetime(IssuedAt))
month_csv_map <- do.call("rbind", month_csv_map)

# after running "stop_seq_gtfs" join route_long_name onto
# month_csv_map using Service = route_short_name and
# Bus_Stop_Atco = stop_code

pax <- month_csv_map %>% left_join(stop_seq, 
                                   by = c("Service" = "route_short_name", "Bus_Stop_Atco" = "stop_code"))

# find a way to join bus stats and month_csv by route






