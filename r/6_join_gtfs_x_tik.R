
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


palette_fun <- khroma::color("batlow")
palette <- palette_fun(6)
palette[1:6]

#bright
[1] "#4477AA" "#EE6677" "#228833" "#CCBB44" "#66CCEE" "#AA3377"
# batlow
[1] "#011959" "#185562" "#577647" "#B38E2F" "#FBA689" "#FACCFA"
# bilbao
[1] "#4C0001" "#8E3F46" "#A46F5A" "#AE9663" "#C4C0AC" "#FFFFFF"

# hawaii
[1] "#8C0273" "#954147" "#9C7524" "#8EB63C" "#62DCA9" "#B3F2FD"

# vik
[1] "#001261" "#116496" "#A7C9DA" "#E0B79F" "#B75A26" "#590008"

# roma
[1] "#7E1700" "#AC7726" "#D2D484" "#88D9D7" "#2D88BE" "#033198"

#discreterainbow
[1] "#1965B0" "#7BAFDE" "#4EB265" "#CAE0AB" "#F7F056" "#DC050C"

#iridescent
[1] "#FEFBE9" "#D7EAC3" "#9DD3E0" "#80AFE2" "#9B75A5" "#46353A"
# nuuk
[1] "#05598C" "#436E82" "#859493" "#B2B293" "#CACA83" "#FEFEB2"

#lisbon
"#E6E5FF" "#6083AE" "#132A42" "#383522" "#9A9160" "#FFFF9D"
#managua
"#FFCF67" "#C17449" "#773339" "#4C3D73" "#5F89C3" "#81E7FF"
#muted
[1] "#CC6677" "#332288" "#DDCC77" "#117733" "#88CCEE" "#882255"
#sunset
[1] "#364B9A" "#6EA6CD" "#C2E4EF" "#FEDA8B" "#F67E4B" "#A50026"




# import month passenger csv
tik_path <- here()
tik_path <- glue("{tik_path}/csv/bronze_month/")

month_csv <- dir(tik_path, pattern = "all_ops_ticketer_", full.names = FALSE)
cat(" ","listing files in ",tik_path, " ............. \n")
for(i in 1:length(month_csv)){
  cat("   ",i," ",fs::path_file(month_csv[i]), "\n")
}


month_csv <- dir(tik_path, pattern = "all_ops_ticketer_", full.names = TRUE)
# month_csv <- dir(glue("{proj_path}/csv/gold/"), pattern = "gold_ticketer_", full.names = TRUE) # could use gold_production tables

month_csv <- month_csv[2] %>%   ## !!! need to make sure ticketer dates match gtfs quarter !!!
#month_csv <- month_csv[1] %>%  
  map(read.csv) %>%
  map(as_tibble)

rm(i, tik_path)
# aggregate passeneger boardings by route


month_csv <- map(month_csv, dplyr::filter, Service %in% routes_select)
                       #c(6,7,42,43,44,45))
month_csv <- map(month_csv, dplyr::select, c(-Shadow_Fare, -Latitude, -Longitude, -From_Stage, -From_Stage_ID,
                                             -To_Stage, -To_Stage_ID, -Price, -Journey_Code, -Passenger_Count,
                                             -Currency, -External_Service_Code, -ETM_ID, - Ticket_Type_ID))
month_csv <- map(month_csv, mutate, datetime = as_datetime(IssuedAt))
month_csv <- do.call("rbind", month_csv)

# after running "stop_seq_gtfs" join route_long_name onto
# month_csv_map using Service = route_short_name and
# Bus_Stop_Atco = stop_code

pax <- month_csv %>% 
  left_join(stop_seq %>% 
              ungroup() %>% 
              select(-shape_id, 
                     -direction_id, 
                     -stop_sequence ) %>% 
              distinct(),
            by = c("Service" = "route_short_name", "Bus_Stop_Atco" = "stop_code"))


# or using stop_seq_trip_lookup



pax_ss <- month_csv %>% 
  left_join(stop_seq_trip_lookup_all_stops %>% 
              ungroup() %>% 
              # select(-shape_id, 
              #        -direction_id, 
              #        -stop_sequence ) %>% 
              distinct(),
            by = c("Service" = "route_short_name", 
                   "Bus_Stop_Atco" = "stop_code",
                   "Scheduled_Start_Time" = "departure_time"))

# pax_ss <- month_csv %>% 
#   left_join(stop_seq_boilerplate %>% 
#               ungroup() %>% 
#               # select(-shape_id, 
#               #        -direction_id, 
#               #        -stop_sequence ) %>% 
#               distinct(),
#             by = c("Service" = "route_short_name", 
#                    "Bus_Stop_Atco" = "stop_code")) %>% 
#   select(-shape_id) %>% 
#   distinct()
# find a way to join bus stats and month_csv by route






