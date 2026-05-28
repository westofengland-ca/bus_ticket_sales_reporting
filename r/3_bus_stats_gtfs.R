
##### NOTES ###########################################
## use one of gtfs tools gtfs shift gtfsio etc
## to get bus network stats 

# possibly already done similar?
# look at bus stats project...
# ... or 
# bus gtfs stats

# update 15/5/2026: 
# GTFSshift, tidytransit, gtfstools are all problematic
# using 

###########################
# weekly mieage


# # service frequency - bph
# frequencies_route = GTFShift::get_route_frequency_hourly(gtfs)
# am_route_freq <- tidytransit::get_route_frequency(gtfs, 
#                                                   #service_ids = service_ids, 
#                                      start_time = 6*3600, end_time = 10*3600) 
# head(am_route_freq) %>%
#   knitr::kable()
# # stop frequency
# # Perform frequency analysis
# frequencies_stop = GTFShift::get_stop_frequency_hourly(gtfs)
# 
# 
# # operating hours

# need to filter gtfs_sf so that only services for a given date are in the stop_times sf
# i.e. we just want the stop_times for the specific date we are interested in (e.g. a weekday in 2024)

# source("r/2_filter_gtfs.R")

# stop times for trips in filtered routes
bus_stats <- gtfs_sf$stop_times %>% inner_join(trips_filtered, by = "trip_id") #%>% # req trips_filtered obj from filter_gtfs.R
rm(trips_filtered)

# bph in specified time period (8am to 6pm)
trips_in_t_period <- bus_stats %>% filter(stop_sequence == 1) %>% 
  filter(arrival_time_secs >= 8*60*60 & arrival_time_secs <= 18*60*60) %>% # trips start between 7am and 7pm
  pull(trip_id)
bus_bph <- bus_stats %>% filter(trip_id %in% trips_in_t_period)
rm(trips_in_t_period)
bus_bph <- bus_bph %>% 
  group_by(stop_id, route_id, shape_id, direction_id) %>% 
  count() %>% 
  rename(trips_10hr = n) %>% 
  mutate(bph = trips_10hr/10) %>% # 10 = hours between 8am and 6pm
  mutate(awt = 60 * (60/bph/2) ) %>%  # awt in seconds
  # mutate(route_id2 = route_id)
  ungroup()

# total number of bus trips per day
bus_trips <- bus_stats %>%
  filter(stop_sequence == 1) %>% 
  group_by(route_id, shape_id, direction_id) %>% 
  count() %>% 
  rename(trips_24hr = n)

# route stats
# this accounts for trips that fall outside the 10hr 8am-6pm period
route_stats <- bus_stats %>% 
  group_by(route_id, shape_id, direction_id) %>%
  summarise()
route_stats <- route_stats %>% 
  left_join(routes_filtered) %>% 
  left_join(bus_trips) %>% 
  left_join(bus_bph %>% 
              group_by(route_id, shape_id, direction_id) %>%
              summarise(bph = median(bph),      # results in NAs ...
                        awt = median(awt))) %>% # ... if 0 trips 8am-6pm
  ungroup() %>% 
  left_join(gtfs_sf$shapes)
  
route_stats <- route_stats %>% 
  #remove NA and replace with 0
  mutate(bph = ifelse(is.na(bph), 0, bph)) %>% 
  mutate(awt = ifelse(is.na(awt), 0, bph))

# add day distance 
route_stats <- route_stats %>% 
  sf::st_as_sf() %>% 
  mutate(route_len_m = sf::st_length(.)) %>% 
  mutate(shape_day_distance = trips_24hr * route_len_m)

route_stats <- route_stats %>% 
  group_by(route_id) %>% 
  mutate(route_day_distance = sum(shape_day_distance)) %>% 
  group_by(route_id, direction_id) %>% 
  mutate(direction_day_distance = sum(shape_day_distance))


bus_bph_route <- bus_bph %>%
  group_by(route_id, shape_id, direction_id) %>% 
  summarise(trips_10hr = median(trips_10hr), # values should all be the same...
            bph = median(bph),               # ...for each route_id,shape_id... 
            awt = median(awt))               # ...and direction_id combo

bus_bph_route <- bus_bph_route %>%
#   left_join(bus_trips) %>% 
#   left_join(routes_filtered) %>% 
   left_join(gtfs_sf$shapes)

bus_bph_stop <- bus_bph %>% 
  group_by(stop_id) %>% 
  summarise(bph = sum(bph), 
            awt = 60 * (60/bph/2))


