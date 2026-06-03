

basemap <- source("r/9_basemap.R")

pax_1 <- pax_ss %>% filter(Service == "1") %>%
  mutate(datetime_day = floor_date(datetime, unit = "day")) %>%
  mutate(weekday = wday(datetime_day, label = TRUE)) %>%
  mutate(hol_boolean = timeDate::as.timeDate(datetime_day) %>% 
           timeDate::isHoliday(holidays = timeDate::holidayLONDON(2024:2027), 
                               wday = 1:5)) #%>%

pax_1 <- pax_1 %>% filter(hol_boolean == FALSE)

pax_1 <- pax_1 %>% 
  group_by(Ticket_ID) %>%
  filter(!(n()>1 & stop_sequence > 1))

pax_1_boilerplate <- pax_1 %>%  # boilerplate example for filling NA gaps
# this can be used when some GTFS trip start times do not match the Ticketer
# trip start times.
  ungroup() %>% 
  drop_na() %>% 
  select(Bus_Stop_Atco, route_id, shape_id, direction_id, stop_sequence, 
          stop_name, geometry, route_long_name) %>%
  # select(direction_id, stop_id,
  #        ) %>%
  group_by(route_id, direction_id, Bus_Stop_Atco, stop_sequence, shape_id, route_long_name) %>% 
  count() %>%
  ungroup() %>% 
  group_by(Bus_Stop_Atco) %>% 
  slice_max(n) %>% 
  ungroup() %>% 
  left_join(gtfs_sf$stops, by = c("Bus_Stop_Atco" = "stop_code")) %>% 
  select(-wheelchair_boarding, -location_type, -parent_station,
        -platform_code, -zone_id, -n)


pax_1_full <- pax_1 %>% 
  drop_na()

pax_1_na <- pax_1 %>% filter(if_any(everything(), is.na))
pax_1_na <- pax_1_na %>% 
  select(-route_id, -shape_id, -direction_id, -stop_sequence, -stop_id,
         -stop_name, -geometry, -route_long_name) %>% 
  left_join(pax_1_boilerplate, by = c("Bus_Stop_Atco"))

pax_1_full <- rbind(pax_1_full, pax_1_na)

rm(pax_1_na, pax_1_boilerplate)
  
############

pax1_30_tp_bin <- time_place_binner(pax_1_full, bin_in_mins = 30) # use time_place_binner function from 7_aggregate_by_time
#pax1_15_bin <- time_binner(pax_1_full, bin_in_mins = 15)


selected_route <- pax1_30_tp_bin %>% pull(route_long_name) %>%  unique()
selected_serv_number <- pax1_30_tp_bin %>% pull(Service) %>%  unique()
selected_stop_seq <- stop_seq %>% filter(route_long_name %in% selected_route)
#time_bins <-  pax1_30_bin %>% pull(time_unit_of_day) %>% unique() 

days_in_sample <- pax1_30_tp_bin %>% 
  mutate(unique_dates = lubridate::date(datetime_bin)) %>% 
  select(unique_dates) %>% 
  group_by(unique_dates) %>% 
  count() %>% 
  filter(n > 10) %>% 
  pull(unique_dates) %>% 
  length()

  
## join with 
pax1_30_bin_stop_pax <- pax1_30_tp_bin %>% left_join(selected_stop_seq, by = c("Bus_Stop_Atco" = "stop_code", 
                                                                "shape_id",
                                                                "direction_id"))


in_stop_pax <- pax1_30_bin_stop_pax %>% filter(direction_id == 1) %>% 
  group_by(Bus_Stop_Atco, stop_name) %>% 
  summarise(mean_pax = sum(pax_in_bin, na.rm = TRUE)/days_in_sample,
            stop_seq = names(which.max(table(stop_sequence))) %>%  as.integer(),
            geometry = first(geometry)) %>% 
  sf::st_as_sf(crs = 27700) %>% 
  sf::st_transform(4326)

out_stop_pax <- pax1_30_bin_stop_pax %>% filter(direction_id == 0) %>% 
  group_by(Bus_Stop_Atco, stop_name) %>% 
  summarise(mean_pax = sum(pax_in_bin, na.rm = TRUE)/days_in_sample,
            stop_seq = names(which.max(table(stop_sequence))) %>%  as.integer(),
            geometry = first(geometry)) %>% 
  sf::st_as_sf(crs = 27700) %>% 
  sf::st_transform(4326)


summarise(a = names(which.max(table(a))),
          value = sum(value))

out_stop_pax <- pax1_30_bin_stop_pax %>% filter(direction_id == 0) %>% 
  group_by(Bus_Stop_Atco, stop_name) %>% 
  summarise(mean_pax = sum(pax_in_bin, na.rm = TRUE)/days_in_sample)


basemap
basemap %>% leaflet::addCircleMarkers(data = in_stop_pax)

basemap <- leaflet::leaflet() %>%
  #leaflet::addTiles(options = list(minZoom = 9, maxZoom = 16)) %>% 
  leaflet::addProviderTiles("CartoDB.Positron", 
                            providerTileOptions(minZoom = 10, maxZoom = 16),
                            group = "carto") %>% 
  leaflet::setView(lng = -2.5, lat = 51.5, zoom = 10) %>% 
  leaflet::setMaxBounds(lat1 = 51, lat2 = 52, lng1 = -3.2, lng2 = -1.8) #%>%
  #addMapPane("pane_background")
  # leaflet::addPolygons(data = bbox, stroke = FALSE,
  #                      fillOpacity = 1, fillColor = "#abc",
  #                      group = "background") %>%
  # leaflet::addPolygons(data = land, stroke = FALSE,
  #                      fillOpacity = 1, fillColor = "#eee",
  #                      group = "background") %>%
  # leaflet::addPolygons(data = builtup, stroke = FALSE,
  #                      fillOpacity = 0.6, fillColor = "#ccc",
  #                      group = "background") %>%
  # leaflet::addPolygons(data = water, stroke = FALSE,
  #                      fillColor = "#abc", fillOpacity = 1,
  #                      group = "background") %>%
  # leaflet::addPolygons(data = inverse, stroke = FALSE,
  #                      fillColor = "#ffffff", fillOpacity = 0.6) %>%
  # leaflet::addPolygons(data = boundary, color = "#777",
  #                      weight = 1, smoothFactor = 0.5,
  #                      opacity = 1.0, fillOpacity = 0,
  #                      group = "background") %>% 
  # addLayersControl(baseGroups = c("background", "stamen toner lite"))

circle_colours <- colorNumeric(palette_fun(10)[10:1], 0:600)

basemap %>%  
  addCircles(data = in_stop_pax,
             radius = ~20+mean_pax/3,
             popup = ~as.character(paste0(stop_name,
                                          " <br>passengers per day (average): ",
                                          round(mean_pax,0))),
             label = ~paste0("average passengers boarding per day: ", round(mean_pax,0)),
             color = ~circle_colours(mean_pax),
             fillOpacity = 0.8,
             group = "northbound",
             fillColor = ~circle_colours(mean_pax),
             stroke = 0.2,
             opacity = 1
  ) %>% 
  addCircles(data = out_stop_pax,
             radius = ~20+mean_pax/3,
             popup = ~as.character(paste0(stop_name,
                                          " <br>passengers per day (average): ",
                                          round(mean_pax,0))),
             label = ~paste0("average passengers boarding per day: ", round(mean_pax,0)),
             color = ~circle_colours(mean_pax),
             fillOpacity = 0.8,
             group = "southbound",
             fillColor = ~circle_colours(mean_pax),
             stroke = 0.2,
             opacity = 1
  ) %>% 
  

addLayersControl(baseGroups = c("carto", "background" ),
                 overlayGroups = c("southbound", "northbound"))


##############

in_stop_pax_time <- pax1_30_bin_stop_pax %>% filter(direction_id == 1) %>% 
  group_by(Bus_Stop_Atco, stop_name, time_unit_of_day) %>% 
  summarise(mean_pax = sum(pax_in_bin, na.rm = TRUE)/days_in_sample,
            stop_seq = names(which.max(table(stop_sequence))) %>%  as.integer(),
            geometry = first(geometry)) %>% 
  sf::st_as_sf(crs = 27700) %>% 
  sf::st_transform(4326) %>% 
  mutate(time_unit_of_day = as.POSIXct( 1800 * time_unit_of_day ) )

circle_colours <- colorQuantile(palette_fun(10)[10:1], 0:30)

basemap %>% 
  leaflet.extras2::addTimeslider(data = in_stop_pax_time,
             radius = ~5+mean_pax,
             popup = ~as.character(paste0(stop_name,
                                          " <br>passengers per day (average): ",
                                          round(mean_pax,0))),
             label = ~paste0("average passengers boarding per day: ", round(mean_pax,0)),
             color = ~circle_colours(mean_pax),
             fillOpacity = 0.8,
             #group = "northbound",
             fillColor = ~circle_colours(mean_pax),
             stroke = 0.2,
             opacity = 1,
             #ordertime = TRUE,
             options = leaflet.extras2::timesliderOptions(
               position = "topright",
               timeAttribute = "time_unit_of_day",
               startTimeIdx = 60000,
               timeStrLength = 30,
               #showAllOnStart = TRUE,
              # isEpoch = TRUE,
               #minValue = 0,
               #maxValue = 10000,
               #range = FALSE,
               follow = FALSE,
               sameDate = FALSE)
  )


