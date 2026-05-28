# aggregate by x interval

# need to join direction_id, possibly by using the stop_code


pax_day <- pax %>%
  mutate(datetime_day = round_date(datetime, unit = "day")) %>% 
  group_by(datetime_day, 
           Service, route_long_name) %>%
  summarise(pax_count = n()) %>% # pax_counts for each day
  mutate(weekday = wday(datetime_day, label = TRUE)) %>%
  mutate(hol_boolean = as.timeDate(datetime_day) %>% timeDate::isHoliday(holidays = holidayLONDON(2024:2027), wday = 1:5)) %>%
  filter(hol_boolean == FALSE) %>% 
  group_by(Service, route_long_name) %>% 
  summarise(pax_weekday_mean = mean(pax_count) %>% round(digits = 1)) # pax_weekday_mean = daily average for non-holiday weekdays




# ??? bin by 15 min interval # idea: use modulo

pax_15min <- pax %>% 
  mutate(datetime_15min = round_date(datetime, unit = "15 mins")) %>% 
  mutate(qtrhr_of_day = (4 * hour(datetime)) + minute(datetime_15min)/15)  # ??? bin by 15 min interval

pax_15min <- pax_15min %>% 
  group_by(datetime_15min, qtrhr_of_day, Service, route_long_name) %>% 
  summarise(pax_15min = n()) %>% 
  ungroup()
 # filter(hol_boolean == FALSE) %>%
  # group_by(qtrhr_of_day, Service, route_long_name) %>% 
  # 
  # mutate(pax_weekday_mean_15min = mean(pax_15min)) %>% 
pax_15min <- pax_15min %>% 
  mutate(hol_boolean = timeDate::as.timeDate(datetime_15min) %>% timeDate::isHoliday(holidays = holidayLONDON(2024:2027), wday = 1:5)) %>% 
  group_by(qtrhr_of_day, Service, route_long_name, hol_boolean) %>% 
  mutate(pax_weekday_mean_15min = mean(pax_15min)) %>%    # average number of passengers boarding on non-holiday weekdays per 15 min time segment
  ungroup()

## 
