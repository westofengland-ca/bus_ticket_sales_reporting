library(calendR)


dates_table <- data.table(
  
  dates = seq(
    as.Date("1/01/2026", "%d/%m/%Y"),
    as.Date("31/12/2026", "%d/%m/%Y"),
  "days"
  )
  
)

dates_table <- dates_table %>% mutate(yday = yday(dates))


may_odd_down <- month_csv %>% filter(Service == "m2") %>% mutate(yday = yday(datetime))

may_odd_down <- may_odd_down %>% group_by(yday) %>% 
  summarise(tik_sales = n()) %>% 
  right_join(dates_table, by = "yday") %>% 
  mutate(tik_sales = ifelse(is.na(tik_sales), 0, tik_sales)) %>% 
  mutate(month = lubridate::month(dates)) %>% 
  arrange(yday) %>% 
  filter(month %in% c(4,5,6))

calendR(#year = 2026,
        #month = c(4,5,6),
        from = "2026-04-01",
        to = "2026-06-30",
        special.days = may_odd_down$tik_sales,
        gradient = TRUE,
        special.col = "#dc12dc",
        low.col = "white")
