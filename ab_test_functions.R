# Function to format the table output
format_table <- function(data) {
  data %>%
    select(segment, denominator_a, denominator_b, metric_name, mean_diff, significant) %>%
    mutate(mean_diff = formattable::percent(mean_diff, digits = 1),
           mean_diff = cell_spec(mean_diff, 
                                 'html', 
                                 color = ifelse(significant == FALSE, 'grey', ifelse(mean_diff > 0, cols[2], cols[5])), 
                                 bold = TRUE),
           control_bucket = format(as.numeric(denominator_a), 
                                   big.mark = ",", 
                                   scientific = FALSE),
           test_bucket = format(as.numeric(denominator_b), 
                                big.mark = ",", 
                                scientific = FALSE),
           metric_name = gsub("_", " ", metric_name),  # Transformation of metric_name
           metric_name = tolower(metric_name),
           metric_name = tools::toTitleCase(metric_name)) %>%  # Capitalize each word
    select(segment, control_bucket, test_bucket, metric_name, mean_diff) %>%
    distinct() %>%
    pivot_wider(names_from = metric_name, values_from = mean_diff) %>%
    rename('Segment' = segment, 
           "Control Bucket" = control_bucket, 
           "Test Bucket" = test_bucket) %>%
    datatable(
      escape = FALSE,
      rownames = FALSE,
      extensions = 'Buttons',
      selection = 'none',
      options = list(
        dom = 'lBfrtip',
        buttons = c('copy', 'csv'),
        paging = FALSE,
        scrollX= TRUE, 
        searching = FALSE,
        ordering = TRUE,
        columnDefs = list(
          list(className = 'dt-left', targets = c(0,1)),  # Align the first two columns to the left
          list(className = 'dt-center', targets = '_all')  # Align remaining columns to the center
        )
      )
    )
}
