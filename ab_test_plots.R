# Brand colors
cols <- c('#34E0A1', '#00AA6C', '#004F32', '#7446AF', '#FF6666', '#F2B203', '#FFCCCC', '#595959', '#9b9b9b')
tt_cols <- c('#004f32', '#00AA6C', '#7446AF', '#FF6666', '#F2B203', '#595959')
st_cols <- c('#3A405A', '#4E878C', '#9A031E', '#4F518C', '#D5A18E', '#E36414')

# Function to set color based on significance and mean difference
set_color <- function(mean, sig) {
  # Grey if not significant, green if significant and positive, red if significant and negative
  barcolor <- ifelse(!sig, cols[8], ifelse(mean > 0, cols[2], cols[5])) 
  return(barcolor)
}

# Function to plot the results as a column range chart
plot_results <- function(data, title) {
  
  y_label <- data$metric_name 
  color <- set_color(data$mean_diff, data$significant)
  
  data$mean_diff_percent <- round(data$mean_diff * 100, 2)
  data$ci_lower_percent <- round(data$ci_lower * 100, 2)
  data$ci_upper_percent <- round(data$ci_upper * 100, 2)
  
  print(data)
  
  hc <- highchart() %>%
    hc_chart(type = "columnrange", inverted = TRUE) %>%
    hc_title(text = title) %>%
    hc_xAxis(categories = y_label) %>%
    hc_yAxis(title = list(text = 'Mean Diff %'),
             plotLines = list(
               list(
                 color = 'black',
                 width = 2,
                 value = 0,
                 zIndex = 5
               )
             )) %>%
    hc_add_series(
      data = data.frame(
        mean_diff = data$mean_diff_percent,
        low = data$ci_lower_percent,
        high = data$ci_upper_percent,
        color = color,
        metric_name = data$metric_name
        ),
      hcaes(y = mean_diff, high = high, low = low, color = color),
      type = "columnrange",
      showInLegend = FALSE
    ) %>%
    hc_tooltip(formatter = JS("function(){
                      return ('<b>Metric</b>: ' + this.point.metric_name + ' <br> ' +
                              '<b>Mean Diff.</b>: ' + this.point.mean_diff + '% <br> ' +
                              '<b>CI Lower</b>: ' + this.point.low + '% <br> ' +
                              '<b>CI Upper</b>: ' + this.point.high + '%'
                      )
                    }")) %>%
    hc_exporting(enabled=TRUE,
               chartOptions=list(chart=list(backgroundColor="white")))
  
  
  return(hc)
}
