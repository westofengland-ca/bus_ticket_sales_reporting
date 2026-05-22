# identify ticketer service =  gtfs route_long_name
# using stop_id and stop_code

# for each route and shape_id get one example of stop sequence

stop_seq <- bus_stats %>% 
  group_by(#shape_id, 
           route_id, 
           #stop_sequence,
           #direction_id,
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
