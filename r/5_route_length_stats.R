##

bus_bph_route_sf <- bus_bph_route %>% ungroup() %>% sf::st_as_sf(crs = 27700)

bus_day_freq <- bus_stats %>% ##  !!! bus_stats is whole day timetable (not 8am to 6pm)
  group_by(stop_id, route_id, shape_id, direction_id) %>% 
  count() %>% 
  rename(freq = n) %>% 
 # mutate(bph = freq/10) %>% # 10 = hours between 8am and 6pm
 # mutate(awt = 60 * (60/bph/2) ) %>%  # awt in seconds
  # mutate(route_id2 = route_id)
  ungroup()

bus_bph_route_sf <- bus_bph_route_sf %>% 
  mutate(route_len_m = sf::st_length(.)) %>% 
  mutate(route_day_distance = freq * route_len_m)   ### freq = buses travelling
                                                    ### between 8am and 6pm (or otherwise)
