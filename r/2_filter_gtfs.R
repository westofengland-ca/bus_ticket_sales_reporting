# filter gtfs

# select route_id from routes

routes_select <- c("1","3","7","16","17",
                   "24","25","43",
                   "700","716","734",
                   "U1","U5",
                   "m1","m2","m3","m4",
                   "T1","Y1","X1","X39")   #c(6,7,42,43,44,45)

routes_filtered <- gtfs_sf$routes %>% filter(route_short_name %in% routes_select)
                                               #c(1,2,3,4,5,6,7,8,9,10))

# service day filtered
# if feed-type = remix/citymapper
# if(gtfs$feed_info$feed_publisher_name == "Citymapper Ltd."){
#   
#     calendar_filtered <- gtfs$calendar %>% filter(  tuesday == 1 ) %>% 
#   pull(service_id)
#   
# }

# if(gtfs$feed_info$feed_publisher_name == "basemap"){
  
  calendar_filtered <- gtfs$calendar %>% filter(  tuesday == 1 &     # filter for mon-fri service pattern
                                                    wednesday == 1 &   # tue,wed,thu accounts for some
                                                    thursday == 1) %>% # unique fri service_ids
    pull(service_id)
  
# }

# else if feed_type = basemap

# filter trips - extract only weekday services and selected routes
trips_filtered <- gtfs_sf$trips %>% 
  filter(route_id %in% routes_filtered$route_id) %>% 
  filter(service_id %in% calendar_filtered)
rm(calendar_filtered)
