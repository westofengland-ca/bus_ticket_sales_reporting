## use one of gtfs tools gtfs shift gtfsio etc
## to get bus network stats 

# possibly already done similar?
# look at bus stats project...
# ... or 

# bus gtfs stats


# weekly mieage


# service frequency - bph
frequencies_route = GTFShift::get_route_frequency_hourly(gtfs)
am_route_freq <- tidytransit::get_route_frequency(gtfs, 
                                                  #service_ids = service_ids, 
                                     start_time = 6*3600, end_time = 10*3600) 
head(am_route_freq) %>%
  knitr::kable()
# stop frequency
# Perform frequency analysis
frequencies_stop = GTFShift::get_stop_frequency_hourly(gtfs)


# operating hours

