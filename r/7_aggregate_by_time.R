# aggregate by x interval

# need to join direction_id, possibly by using the stop_code


pax_day <- pax %>%
  mutate(datetime_day = round_date(datetime, unit = "day")) %>% 
  group_by(datetime_day, 
           Service, route_long_name) %>%
  summarise(pax_count = n()) %>% # pax_counts for each day
  




# ??? bin by 15 min interval # idea: use modulo

pax_15min <- pax %>% 
  mutate(datetime_15min = round_date(datetime, unit = "15 mins")) %>% 
  mutate(qtrhr_of_day = (4 * hour(datetime)) + minute(datetime_15min)/15)  # ??? bin by 15 min interval

pax_15min <- pax_15min %>% 
  group_by(qtrhr_of_day, Service, route_long_name) %>% 
  summarise(pax_count = n())
