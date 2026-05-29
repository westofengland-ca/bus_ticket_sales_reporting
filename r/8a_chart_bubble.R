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
            route_day_distance = max(route_day_distance)) %>% 
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
                      hcaes(x = route_day_distance/1000,
                            y = pax_day,
                            #size = bph,
                            group = is_supported)
                      ) %>%
  hc_title(text = "Relationship between bus service mileage and patronage",
           margin = 20, # space between title (or subtitle) and plot [default = 15]
           align = "left",
           stlyle = list(useHTML = TRUE))  %>%
  hc_subtitle(text = "Unsurprisingly, bus services that cover more distance in a day tend to have more passengers",
              align = "left") %>% 
  hc_tooltip(
    headerFormat = "<b>{point.x + ' ' + this.point.route_long_name}</b><br>",
    pointFormat = "Distance: {point.x} mm<br>Passengers: {point.y} mm"
    #formatter = fntltp
  )# 

