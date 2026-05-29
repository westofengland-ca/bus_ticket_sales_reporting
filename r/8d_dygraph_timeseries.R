library(highcharter)
library(datasets)

# Convert the nottem data to a time series object
ts_data <- ts(nottem, start = c(1920, 1), frequency = 12)

# Convert the time series object to a data frame
df_nott <- data.frame(date = time(ts_data),
                 value = as.numeric(ts_data))

# Create a highcharter time series plot
hchart(df, "line", hcaes(x = date,
                         y = value)) %>% 
  hc_title(text = "Monthly Average Temperatures at Nottingham Castle") %>% 
  hc_yAxis(title = list(text = "Temperature (Fahrenheit)")) %>% 
  hc_xAxis(type = "datetime",
           labels = list(format = "%b %Y"))


####

month_csv_map <- month_csv %>% select("Ticket_ID", "IssuedAt", "Service", "Bus_Stop_Atco") # select cols
month_csv_map <- month_csv_map %>%  filter(Service == "X39")
month_csv_map <- month_csv_map %>% mutate(datetime = as_datetime(IssuedAt))
month_csv_map <- month_csv_map %>% mutate(datetime_rnd = round_date(datetime, unit = "15 mins"))
# month_csv_map <- map(month_csv_map, mutate, isoweek = isoweek(datetime))
month_csv_map <- month_csv_map %>% group_by(datetime_rnd)
month_csv_map <- month_csv_map %>% summarise(n = n())

month_csv_map <- month_csv_map %>% as.xts()


library(dygraphs)
p <- dygraph(month_csv_map) %>% 
  #dyOptions(fillGraph = TRUE, stepPlot = TRUE) %>% 
  dyBarChart() %>% 
  dyRangeSelector() %>% 
  dyOptions(colors = palette[3])

p


## convert to one xts object
# month_csv_map <- do.call("rbind", month_csv_map)

df <- data.frame(date = time(month_csv_map),
                 value = as.numeric(month_csv_map))

# Create a highcharter time series plot
hchart(df, "line", hcaes(x = date,
                         y = value)) %>% 
  hc_title(text = "Monthly Average Temperatures at Nottingham Castle") %>% 
  hc_yAxis(title = list(text = "Temperature (Fahrenheit)")) %>% 
  hc_xAxis(type = "datetime",
           labels = list(format = "%b %Y"))

hchart(df, "column", hcaes(x = date,
                         y = value))


hc <- pax_15min_ts %>%
  hchart(
    "line", 
    hcaes(x = datetime_15min, y = pax_15min)
  )
hc
