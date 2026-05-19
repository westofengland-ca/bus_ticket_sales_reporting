# filter gtfs

# select route_id from routes

gtfs_sf$routes %>% filter(route_short_name %in% c(1,2,3,4,5,6,7,8,9,10))

