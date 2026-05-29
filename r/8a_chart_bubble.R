# bubble chart:
# y = mileage
# x = passengers
# bubble_size = bph

# join pax_day to route stats using 

library(highcharter)

bubl_chart <- route_stats %>%
  sf::st_drop_geometry() %>% 
  left_join(pax_day, by = c("route_short_name" = "Service", "route_long_name")) %>% 
  group_by(route_short_name, route_long_name) %>% 
  summarise(bph = max(bph),
            trips_24hr = sum(trips_24hr),
            pax_day = max(pax_weekday_mean),
            route_day_distance = round(max(route_day_distance/1000),0)) %>% 
  drop_na()

# join is supported
sup_path <- here()
sup_path <- glue("{sup_path}/csv/auxiliary/")
sup_path <- dir(sup_path, pattern = "supported", full.names = TRUE)
sup <- read.csv(sup_path)

bubl_chart <- left_join(bubl_chart, sup, by = c("route_short_name" = "Service", "route_long_name" = "route_long_name"))


fntltp <- JS("function(){
  return this.point.route_short_name + ' ' + this.point.route_long_name + ' ' +
  this.point.y + ': ' +
  Highcharts.numberFormat(this.point.value, 2);
}")

bubl_chart %>% hchart('scatter',
                      hcaes(x = round(route_day_distance,0),
                            y = round(pax_day,0),
                            #size = bph,
                            group = is_supported)
                      ) %>%
  hc_title(text = "Bus Services in the West of England: Relationship between total daily distance and patronage",
           margin = 20, # space between title (or subtitle) and plot [default = 15]
           align = "left",
           stlyle = list(useHTML = TRUE))  %>%
  hc_subtitle(text = "There is a strong correlation between distance covered and the number of passengers who use the bus service.",
              align = "left") %>%
  # x axis label
  hc_xAxis(title = list(text = "total distance covered by all trips (km)")) %>% 
  # y axis label
  hc_yAxis(title = list(text = "average weekday patronage")) %>% 
  hc_tooltip(
    headerFormat = NULL,
    pointFormat = "<b>{point.route_short_name} {point.route_long_name}</b><br>
    Distance: {point.x} km<br>
    Passengers: {point.y}<br>
    Buses Per Hour: {point.bph}<br>
    Trips Per Day (both directions): {point.trips_24hr}"
    #formatter = fntltp
  ) %>% 
  hc_colors(c(palette[4], palette[2])) %>% 
  hc_exporting(
    enabled = TRUE,
    filename = "bus_patronage_x_distance") %>% 
  hc_add_theme(hc_theme(chart = list(backgroundColor = 'white')))


bubl_chart %>% hchart('scatter',
                      hcaes(x = round(bph,1),
                            y = round(pax_day,0),
                            #size = bph,
                            group = is_supported)
) %>%
  hc_title(text = "Bus Services in the West of England: Relationship between buses per hour and patronage",
           margin = 20, # space between title (or subtitle) and plot [default = 15]
           align = "left",
           stlyle = list(useHTML = TRUE))  %>%
  hc_subtitle(text = "There is also a correlation between buses per hour and the number of passengers who use the bus service, although the relationship is not as strong as with distance covered.",
              align = "left") %>%
  # x axis label
  hc_xAxis(title = list(text = "buses per hour (8am-6pm)")) %>% 
  # y axis label
  hc_yAxis(title = list(text = "average weekday patronage")) %>% 
  hc_tooltip(
    headerFormat = NULL,
    pointFormat = "<b>{point.route_short_name} {point.route_long_name}</b><br>
    Buses Per Hour: {point.x}<br>
    Passengers: {point.y}<br>
    Distance: {point.route_day_distance}km<br>
    Trips Per Day (both directions): {point.trips_24hr}"
    #formatter = fntltp
  ) %>% 
  hc_colors(c(palette[4], palette[2])) %>% 
  hc_exporting(
    enabled = TRUE,
    filename = "bus_patronage_x_bph") %>% 
  hc_add_theme(hc_theme(chart = list(backgroundColor = 'white')))
