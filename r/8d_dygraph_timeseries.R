library(highcharter)
library(datasets)

# # Convert the nottem data to a time series object
# ts_data <- ts(nottem, start = c(1920, 1), frequency = 12)
# 
# # Convert the time series object to a data frame
# df_nott <- data.frame(date = time(ts_data),
#                  value = as.numeric(ts_data))
# 
# # Create a highcharter time series plot
# hchart(df, "line", hcaes(x = date,
#                          y = value)) %>% 
#   hc_title(text = "Monthly Average Temperatures at Nottingham Castle") %>% 
#   hc_yAxis(title = list(text = "Temperature (Fahrenheit)")) %>% 
#   hc_xAxis(type = "datetime",
#            labels = list(format = "%b %Y"))
# 

####
var_name = "m2"

month_csv_map <- month_csv %>% select("Ticket_ID", "IssuedAt", "Service", "Bus_Stop_Atco") # select cols
month_csv_map <- month_csv_map %>%  filter(Service %in% "m2")
month_csv_map <- month_csv_map %>% mutate(datetime = as_datetime(IssuedAt))
month_csv_map <- month_csv_map %>% mutate(datetime_rnd = round_date(datetime, unit = "15 mins"))
# month_csv_map <- map(month_csv_map, mutate, isoweek = isoweek(datetime))
month_csv_map <- month_csv_map %>% group_by(datetime_rnd)
month_csv_map <- month_csv_map %>% summarise(!!var_name := n())

month_csv_map <- month_csv_map %>% as.xts()

# function to convert month_csv into xts

tik_xts <- function(csv_list = month_csv, routes = routes_select){
  month_csv_map <- csv_list %>% select("Ticket_ID", "IssuedAt", "Service", "Bus_Stop_Atco") # select cols
  month_csv_map <- month_csv_map %>%  filter(Service %in% routes)
  month_csv_map <- month_csv_map %>% mutate(datetime = as_datetime(IssuedAt))
  month_csv_map <- month_csv_map %>% mutate(datetime_rnd = round_date(datetime, unit = "15 mins"))
  # month_csv_map <- map(month_csv_map, mutate, isoweek = isoweek(datetime))
  month_csv_map <- month_csv_map %>% group_by(datetime_rnd)
  month_csv_map <- month_csv_map %>% summarise(!!routes := n())
  #month_csv_map <- month_csv_map %>% select(datetime_rnd, !!routes_select := patronage)
  
  month_csv_map <- month_csv_map %>% as.xts()
  return(month_csv_map)
}

metrobus_pal <- c("#E51A7E","#F2921F","#96BD30","#009FE2" )

xts_x39 <- tik_xts(csv_list = month_csv, routes = "X39")

m1 <- tik_xts(csv_list = month_csv, routes = c("m1"))
m2 <- tik_xts(csv_list = month_csv, routes = c("m2"))
m3 <- tik_xts(csv_list = month_csv, routes = c("m3"))
m4 <- tik_xts(csv_list = month_csv, routes = c("m4"))

xts_metrobus <- cbind(m1,m2,m3,m4)


library(dygraphs)
# p <- dygraph(month_csv_map) %>% 
#   #dyOptions(fillGraph = TRUE, stepPlot = TRUE) %>% 
#   dyBarChart() %>% 
#   dyAxis("x", drawGrid = FALSE) %>% 
#   dyRangeSelector() %>% 
#   dyOptions(colors = palette[5])

p <- dygraph(xts_metrobus, main = "metrobus patronage Q1 2026") %>% 
  dyGroup(c("m1", "m2", "m3", "m4"), # "patronage.2", "patronage.3"),
          color = metrobus_pal[1:4]) %>% 
  dyAxis("y", label = "Passengers Boarding", valueRange = c(0, 500)) %>%
  dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>% 
  dyRangeSelector()
p


