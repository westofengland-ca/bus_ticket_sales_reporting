# identify ticketer service =  gtfs route_long_name
# using stop_id and stop_code

# for each route and shape_id get one example of stop sequence

stop_seq <- bus_stats %>% 
  group_by(shape_id, 
           route_id, 
           stop_sequence,
           direction_id,
           stop_id) %>% 
  summarise()
# get the stop code for each stop id
stop_seq <- stop_seq %>% left_join(gtfs_sf$stops %>% 
                                     select(-wheelchair_boarding, 
                                            -location_type,
                                            -parent_station,
                                            -platform_code,
                                            -zone_id))
stop_seq <- stop_seq %>% left_join(gtfs_sf$routes %>% 
                                     select(route_id, 
                                            route_short_name, 
                                            route_long_name))


stop_seq_trip_lookup <- # gtfs info trip_id, shape_id and departure time for each trip_id
  # gtfs_sf$stop_times %>% 
  bus_stats %>% 
  filter(stop_sequence == 1) %>%
  select(trip_id, departure_time) %>% 
  left_join(gtfs_sf$trips %>% select(trip_id, 
                                     route_id, 
                                     #service_id, 
                                     shape_id, 
                                     direction_id), 
            by = "trip_id") %>%
  select(-trip_id) %>% 
  mutate(departure_time = stringr::str_remove(departure_time, pattern = ":00$"))
  
stop_seq_trip_lookup_all_stops <- stop_seq_trip_lookup %>% 
  left_join(stop_seq, by = c("route_id", "shape_id", "direction_id"))  


stop_seq_boilerplate <- stop_seq_trip_lookup_all_stops %>% 
  select(route_id, shape_id, direction_id,  stop_code,  
         route_short_name, route_long_name) %>% 
  distinct() 