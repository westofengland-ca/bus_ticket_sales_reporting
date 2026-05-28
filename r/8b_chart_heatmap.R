# based on:
# https://jkunst.com/highcharter/articles/showcase.html#the-impact-of-vaccines


data(vaccines)

vaccines <- vaccines


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
    x = qtrhr_of_day,
    y = paste0(Service, " ", route_long_name), 
    value = pax_count
  )
) |>
  hc_colorAxis(
    stops = color_stops(10, viridisLite::inferno(10, direction = -1))
    
    #type = "logarithmic"
  ) |>
  hc_yAxis(
    title = list(text = ""),
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
  # hc_xAxis(
  #   plotLines = list(plotline)) |>
  hc_title(
    text = "Passengers boarding throughout the day"
  ) |>
  hc_subtitle(
    text = "average count of weekday passengers boardings in each 15 minute time segment"
  ) |> 
  hc_legend(
    layout = "horizontal",
    verticalAlign = "top",
    align = "left",
    valueDecimals = 0
  ) |>
  hc_size(height = 600)
