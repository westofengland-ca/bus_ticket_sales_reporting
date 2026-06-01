# based on:
# https://jkunst.com/highcharter/articles/showcase.html#the-impact-of-vaccines


# filter top x routes only
# title and axis
# save into html folder
# tooltip - route name/number etc

pax_15min <- pax1_30_bin


# sort order = order by total passengers
pax_15min <- pax_15min %>% 
  mutate(service_name = paste0(Service, " ", route_long_name)) %>% 
  filter(hol_boolean == FALSE)
  #factor(long_data$yaxis, levels = c("Y2", "Y1"))

# arrange service name by total number of passengers
service_name_sort <- pax_15min %>% 
  group_by(service_name) %>% 
  summarise(total_pax = sum(pax_in_bin)) %>% 
  arrange(total_pax) %>% 
  pull(service_name)

# use 'sorted' service_name_sort to factor service_name var
pax_15min <- pax_15min %>% 
  mutate(service_name = factor(service_name, levels = service_name_sort))


fntltp <- JS("function(){
  return this.point.x + ' ' +  this.series.yAxis.categories[this.point.y] + ': ' +
  Highcharts.numberFormat(this.point.value, 2);
}")

# plotline <- list(
#   color = "#fde725", value = 1963, width = 2, zIndex = 5,
#   label = list(
#     text = "Vaccine Intoduced", verticalAlign = "top",
#     style = list(color = "#606060"), textAlign = "left",
#     rotation = 0, y = -5
#   )
# )

hchart(
  pax_15min, 
  "heatmap", 
  hcaes(
    x = time_unit_of_day,
    y = service_name, 
    value = pax_in_bin
  )
) |>
  hc_colorAxis(
    stops = color_stops(10, palette_fun(10)[10:1])
                        #viridisLite::inferno(10, direction = -1))
    
    #type = "logarithmic"
  ) |>
  hc_yAxis(
    title = list(text = ""),
   # categories = sort(unique(pax_15min$pax_count)),
    reversed = TRUE, 
    offset = -20,
    tickLength = 0,
    gridLineWidth = 0, 
    minorGridLineWidth = 0,
    labels = list(style = list(fontSize = "9px"))
  ) |>
  hc_tooltip(
    formatter = fntltp
  ) |>
  hc_xAxis(
     text = "time of day") %>% 
  hc_title(
    text = "Passengers boarding throughout the day"
  ) |>
  hc_subtitle(
    text = "average count of weekday passengers boardings in each time segment"
  ) |> 
  hc_legend(
    layout = "horizontal",
    verticalAlign = "top",
    align = "left",
    valueDecimals = 0
  ) |>
  hc_size(height = 600)


#### function: heatmap passenger boarding by time unit and day of week

hc_pax_boarding_heatmap <- 
  function(pax_bin_df){
    pax_bin_df <- pax_bin_df %>% 
      mutate(service_name = paste0(Service, " ", route_long_name)) %>% 
      filter(hol_boolean == FALSE)
    
    # # arrange service name by total number of passengers
    # service_name_sort <- pax_bin_df %>% 
    #   group_by(service_name) %>% 
    #   summarise(total_pax = sum(pax_in_bin)) %>% 
    #   arrange(total_pax) %>% 
    #   pull(service_name)
    
    
    # use 'sorted' service_name_sort to factor service_name var
    # pax_bin_df <- pax_bin_df %>% 
    #   mutate(service_name = factor(service_name, levels = service_name_sort))
   
    pax_bin_df <- pax_bin_df %>% 
      mutate(day_of_week = lubridate::wday(datetime_bin))
    
    hchart(
      pax_bin_df, 
      "heatmap", 
      hcaes(
        x = time_unit_of_day,
        y = day_of_week, 
        value = pax_in_bin
      )
    ) |>
      hc_colorAxis(
        stops = color_stops(10, palette_fun(10)[10:1])
        
        #type = "logarithmic"
      ) |>
      hc_yAxis(
        title = list(text = ""),
        # categories = sort(unique(pax_15min$pax_count)),
        reversed = TRUE, 
        offset = -20,
        tickLength = 0,
        gridLineWidth = 0, 
        minorGridLineWidth = 0,
        labels = list(style = list(fontSize = "9px"))
      ) |>
      hc_tooltip(
        formatter = fntltp
      ) |>
      hc_xAxis(
        text = "time of day") %>% 
      hc_title(
        text = "Passengers boarding throughout the day"
      ) |>
      hc_subtitle(
        text = "average count of weekday passengers boardings in each time segment"
      ) |> 
      hc_legend(
        layout = "horizontal",
        verticalAlign = "top",
        align = "left",
        valueDecimals = 0
      ) |>
      hc_size(height = 600)
    
    
  }


hc_pax_boarding_heatmap(pax1_30_bin)
pax_bin_df <- pax1_30_bin %>% 
  mutate(day_of_week = lubridate::wday(datetime_bin, label = TRUE))
