# highcharter time series



pax_15min_ts <- pax_15min %>% 
  filter(Service == "X39") %>% 
  mutate(datetime_15min = lubridate::as_date(datetime_15min))
  #group_by(datetime_15min, Service) %>%
  # summarise(pax_15min = sum(pax_15min),
  #           pax_weekday_mean_15min = max(pax_weekday_mean_15min),
  #           hol_boolean = max(hol_boolean)) %>%

hchart(pax_15min_ts, 'line', hcaes(x = datetime_15min, y = pax_15min, group = hol_boolean)) %>% 
  hc_title(text = "X39 passengers boarding by 15 min time segment") %>% 
  hc_subtitle(text = "Data from 2024-01-01 to 2024-06-30") %>% 
  hc_xAxis(title = list(text = "Time of day (15 min segments)")) %>% 
  hc_yAxis(title = list(text = "Number of passengers boarding")) %>% 
  hc_legend(title = list(text = "Holiday or not?")) %>% 
  hc_tooltip(pointFormat = "{point.datetime_15min}: {point.pax_15min} passengers boarding")

highchart() %>% 
  hc_add_series(data = pax_15min_ts, type = "column", hcaes(x = datetime_15min, y = pax_15min, group = hol_boolean)) 

highchart() %>% 
  hc_add_series(data = pax_15min_ts, type = "candlestick")  # type = "candlestick" or "ohlc"

highchart() %>% 
  hc_add_series(data = pax_15min_ts, type = "ohlc")  # type = "candlestick" or "ohlc"
