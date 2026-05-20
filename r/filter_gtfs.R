# filter gtfs

# select route_id from routes

routes_filtered <- gtfs_sf$routes %>% filter(route_short_name %in% c(1,2,3,4,5,6,7,8,9,10))

# service day filtered
calendar_filtered <- gtfs$calendar %>% filter(  tuesday == 1 &     # filter for mon-fri service pattern
                                                      wednesday == 1 &   # tue,wed,thu accounts for some
                                                      thursday == 1) %>% # unique fri service_ids
  pull(service_id)

# filter trips - extract only weekday services and selected routes
trips_filtered <- gtfs_sf$trips %>% 
  filter(route_id %in% routes_filtered$route_id) %>% 
  filter(service_id %in% calendar_filtered)
