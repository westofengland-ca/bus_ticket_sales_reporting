

basemap <- source("r/9_basemap.R")

pax_1 <- pax_ss %>% filter(Service == "1") %>%
  mutate(datetime_day = round_date(datetime, unit = "day")) %>%
  mutate(weekday = wday(datetime_day, label = TRUE)) %>%
  mutate(hol_boolean = timeDate::as.timeDate(datetime_day) %>% 
           timeDate::isHoliday(holidays = timeDate::holidayLONDON(2024:2027), 
                               wday = 1:5)) #%>%

pax_1 <- pax_1 %>% filter(hol_boolean == FALSE)

pax_1 <- pax_1 %>% 
  group_by(Ticket_ID) %>%
  filter(!(n()>1 & stop_sequence > 1))

#pax_1_dup <- pax_1 %>% group_by(Ticket_ID) %>% filter(n() > 1) %>% ungroup()

basemap
