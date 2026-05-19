
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


# get bus freq
bus_freq <- gtfs_sf$stop_times %>% left_join(gtfs_sf$trips, by = "trip_id") %>%
  #mutate(arrival_time = gtfstools::string_to_seconds(arrival_time) ) #%>% lubridate::seconds())
  filter(arrival_time_secs >= 8*60*60 & arrival_time_secs <= 18*60*60) %>%
  group_by(stop_id, route_id, shape_id, direction_id) %>% 
  count() %>% 
  rename(freq = n) %>% 
  mutate(bph = freq/10) %>% # 10 = hours between 8am and 6pm
  mutate(awt = 60 * (60/bph/2) ) %>%  # awt in seconds
  # mutate(route_id2 = route_id)
  ungroup() #%>% 

bus_freq_route <- bus_freq %>%
  group_by(route_id, shape_id, direction_id) %>% 
  summarise(bph = median(bph), 
            awt = median(awt))

bus_freq_stop <- bus_freq %>% 
  group_by(stop_id) %>% 
  summarise(bph = sum(bph), 
            awt = 60 * (60/bph/2))
