

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
pax_1_na__ <- pax_1_na %>% 
  select(-route_id, -shape_id, -direction_id, -stop_sequence, -stop_id,
         -stop_name, -geometry, -route_long_name) %>% 
  left_join(pax_1_boilerplate, by = c("Bus_Stop_Atco"))

pax_1_full <- rbind(pax_1_full, pax_1_na__)


  
## maybe just nead a stop_direction var 0 or 1 ???

## turn agrregate by time script into functions

#pax_1_dup <- pax_1 %>% group_by(Ticket_ID) %>% filter(n() > 1) %>% ungroup()

basemap
