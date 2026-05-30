#library(highcharter)
#library(raster)
#library(tiff)
library(sf)
#library(geojsonio)
library(dplyr)
library(leaflet)
library(glue)

basemap_path <- here::here()

builtup <- dir(glue("{basemap_path}/geojson/basemap/"), pattern = "weca_builtup.geojson", full.names = TRUE)
water <- dir(glue("{basemap_path}/geojson/basemap/"), pattern = "weca_water.geojson", full.names = TRUE)
boundary <- dir(glue("{basemap_path}/geojson/basemap/"), pattern = "weca_boundary.geojson", full.names = TRUE)
bbox <- dir(glue("{basemap_path}/geojson/basemap/"), pattern = "weca_bbox.geojson", full.names = TRUE)
land <- dir(glue("{basemap_path}/geojson/basemap/"), pattern = "weca_land.geojson", full.names = TRUE)
inverse <- dir(glue("{basemap_path}/geojson/basemap/"), pattern = "weca_inverse.geojson", full.names = TRUE)

builtup <- st_read(builtup) %>% st_transform(crs = 4326)
water <- st_read(water) %>% st_transform(crs = 4326)
boundary <- st_read(boundary) %>% st_transform(crs = 4326)
bbox <- st_read(bbox) %>% st_transform(crs = 4326)
land <- st_read(land) %>% st_transform(crs = 4326)
inverse <- st_read(inverse) %>% st_transform(crs = 4326)



# builtup <- st_read(choose.files()) %>% st_transform(crs = 4326)
# water <- st_read(choose.files()) %>% st_transform(crs = 4326)
# boundary <- st_read(choose.files()) %>% st_transform(crs = 4326)
# bbox <- st_read(choose.files()) %>% st_transform(crs = 4326)
# land <- st_read(choose.files()) %>% st_transform(crs = 4326)
# inverse <- st_read(choose.files()) %>% st_transform(crs = 4326)

leaflet::leaflet() %>%
  #leaflet::addTiles(options = list(minZoom = 9, maxZoom = 16)) %>% 
  leaflet::addProviderTiles("Stadia.StamenTonerLite", 
                            providerTileOptions(minZoom = 10, maxZoom = 16),
                            group = "stamen toner lite") %>% 
  leaflet::setView(lng = -2.5, lat = 51.5, zoom = 10) %>% 
  leaflet::setMaxBounds(lat1 = 51, lat2 = 52, lng1 = -3.2, lng2 = -1.8) %>% 
  leaflet::addPolygons(data = bbox, stroke = FALSE,
                       fillOpacity = 1, fillColor = "#abc",
                       group = "background") %>%
  leaflet::addPolygons(data = land, stroke = FALSE,
                       fillOpacity = 1, fillColor = "#eee",
                       group = "background") %>%
  leaflet::addPolygons(data = builtup, stroke = FALSE,
                       fillOpacity = 0.6, fillColor = "#ccc",
                       group = "background") %>%
  leaflet::addPolygons(data = water, stroke = FALSE,
                       fillColor = "#abc", fillOpacity = 1,
                       group = "background") %>%
  leaflet::addPolygons(data = inverse, stroke = FALSE,
                       fillColor = "#ffffff", fillOpacity = 0.6) %>%
  leaflet::addPolygons(data = boundary, color = "#777",
                       weight = 1, smoothFactor = 0.5,
                       opacity = 1.0, fillOpacity = 0,
                       group = "background") %>%
  addLayersControl(baseGroups = c("background", "stamen toner lite"))
  


