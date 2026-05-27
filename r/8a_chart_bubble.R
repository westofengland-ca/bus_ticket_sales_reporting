# bubble chart:
# y = mileage
# x = passengers
# bubble_size = bph

# join pax_day to route stats using 

bubl_chart <- route_stats %>%
  sf::st_drop_geometry() %>% 
  left_join(pax_day, by = c("route_short_name" = "Service", "route_long_name")) %>% 
  group_by(route_short_name, route_long_name) %>% 
  summarise(bph = max(bph),
            trips_24hr = sum(trips_24hr),
            pax_day = max(pax_weekday_mean),
            route_day_distance = max(route_day_distance)) %>% 
  drop_na()


bubl_chart %>% hchart('scatter',
                      hcaes(x = route_day_distance,
                            y = pax_day,
                            size = bph)
                      )# 

