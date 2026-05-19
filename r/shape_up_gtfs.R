library(dplyr)

#gtfs <- GTFShift::load_feed(choose.files())
gtfs <- tidytransit::read_gtfs(choose.files())
gtfs <- gtfstools::filter_by_route_type(gtfs, route_type = 3)
gtfs <- GTFShift::build_shapes(gtfs) ## WARNING - overides any existing shapes

#gtfs <- st_as_sf(gtfs)
#gtfs_sf <- gtfs %>% gtfstools::convert_shapes_to_sf()
gtfs_sf <- gtfs %>% tidytransit::gtfs_as_sf(crs = 27700)

gtfs_sf <- gtfs_sf %>% gtfstools::convert_time_to_seconds()

pal <-  mapview::mapviewPalette("mapviewSpectralColors")
mapview::mapview(gtfs_sf$shapes, zcol = "shape_id", col.regions = pal(10), legend = FALSE)



####

# use use GTFShift::osm_shapes_to_routes
# this would enhance above script by tracking the bus routes
# along the actual line of the roads (instead of using the
# euclidean line between bus stops)

# 
# library(osmdata)
# library(tidyverse)
# library(leaflet)
# 
# coords <- c(-3.00, 51.25, -2.25, 51.60) # west of england
# #coords <- c(-2.62, 51.42, -2.51, 51.48) # bristol central
# #coords <- c(-2.59, 51.45, -2.57, 51.46) # bristol central -smaller
# 
# # create quick map which shows extent of bbox
# leaflet() %>% 
#   addProviderTiles(providers$CartoDB.Positron) %>% 
#   addPolygons(lng = c(coords[1], coords[1], coords[3], coords[3], coords[1]), 
#               lat = c(coords[2], coords[4], coords[4], coords[2], coords[2]))
# 
# coords <- matrix(coords, ncol = 2, nrow = 2, byrow = FALSE, dimnames = list(c("x", "y"), c("min", "max")))
# 
# net <- opq("Bristol")
# net <- opq(coords)
# net <- add_osm_feature(net, key = "route", value = "bus")
# 
# net <- osmdata_sf(net)
# 
# # view using mapview
# pal <-  mapview::mapviewPalette("mapviewSpectralColors")
# mapview::mapview(net$osm_lines, 
#                  #zcol = "service_id3", 
#                  col.regions = pal(10), 
#                  legend = TRUE)
# 
# #### use GTFShift::osm_shapes_to_routes  ####
# 
# gtfs_shaped <- GTFShift::osm_shapes_to_routes(gtfs_sf, net)



