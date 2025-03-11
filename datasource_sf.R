# Get experiment list
experiment_list <- function() {
  list <- dbGetQuery(conn,  paste0("select distinct experiment_key
                                   from <db>.<schema>.<experiments_table>
                                   "))
  
  names(list) <- tolower(names(list))
  return(list)
}

# Get experiment info
experiment_metadata <- function(experiment_key) {
  metadata <- dbGetQuery(conn,  paste0("select coalesce(to_date(analysis_start_date), to_date(first_turned_on_ts)) as analysis_start_date
                                             , coalesce(to_date(analysis_end_date), to_date(last_turned_off_ts))   as analysis_end_date
                                             , to_date(first_turned_on_ts) as prod_start_date
                                             , to_date(last_turned_off_ts) as prod_end_date
                                             , experiment_display_name
                                             , experimenter_name
                                             , experiment_description
                                             , experiment_status
                                             , experiment_key
                                        from  <db>.<schema>.<experiment_metadata_table>
                                        where experiment_key ='", experiment_key, "'
                                       "))
  
  names(metadata) <- tolower(names(metadata))
  return(metadata)
}

# Format metadata
metadata_output <- function(metadata) {
  metadata_df <- data.frame(attr = c("Experiment Name", 
                                     "Experiment Description",
                                     "Experimenter",
                                     "Experiment Status",
                                     "Analysis Dates", 
                                     "Production Dates"
                                     ),
                            val = c(metadata$experiment_display_name, 
                                    metadata$experiment_description,
                                    metadata$experimenter_name,
                                    metadata$experiment_status,
                                    paste(format(metadata$analysis_start_date, "%Y-%m-%d"), 
                                          format(metadata$analysis_end_date, "%Y-%m-%d"), 
                                          sep = " to "),
                                    paste(format(metadata$prod_start_date, "%Y-%m-%d"), 
                                          format(metadata$prod_end_date, "%Y-%m-%d"), 
                                          sep = " to ") 
                                    ))
  
  return(metadata_df)
}

# Check if this experiment exists in the cumulative table & how many variants it has
check_cumulative <- function(experiment_key) {
  check_df <- dbGetQuery(conn, paste0("select distinct bucket_key, ds
                                      from <db>.<schema>.<cumulative_table>
                                      where experiment_key = '", experiment_key, "'
                                      "))
  
  return(list(bucket_key = check_df[['BUCKET_KEY']], max_ds = max(check_df[['DS']]))) # Get unique bucket keys and latest date
}

# Get metric repo - config of each selected metric
get_metric_repo <- function(experiment_key) {
  metric_repo <- dbGetQuery(conn, paste0("select  m.metric_id
                                                , m.metric_name
                                                , m.data_type
                                                , m.metric_sig
                                                , m.test_type
                                                , m.test_tails
                                                , e.metric_priority
                                          from <db>.<schema>.<metric_repo_table> m
                                                join <db>.<schema>.<experiment_metric_assignment_table> e 
                                                  on lower(m.metric_name) = lower(e.metric_key) and e.experiment_key = '", experiment_key, "'
                                        ")) %>%
    mutate(TEST_TAILS = as.numeric(TEST_TAILS),
           METRIC_PRIORITY = as.numeric(METRIC_PRIORITY)) %>%
    arrange(METRIC_PRIORITY)
  
  names(metric_repo) <- tolower(names(metric_repo))
  
  return(metric_repo)
}

# Create dataframe with segmented cumulative results
datasource_sf <- function(experiment_key, analysis_start_date, analysis_end_date, segment) {
  df_sf <- dbGetQuery(conn, paste0("select r.experiment_key
                                         , r.bucket_key
                                         , r.metric_id
                                         , r.metric_name
                                         , case when ", segment, " is null then 'Other' 
                                                else ", segment, " end           as ", segment, "
                                         , count(r.metric_value)                 as metric_count
                                         , sum(r.metric_value)                   as metric_sum
                                         , var_samp(r.metric_value)              as metric_var
                                    from <db>.<schema>.<cumulative_table> r
                                        join (select ds, unique_id
                                               from <db>.<schema>.<user_bucketing_assignment_table>
                                               where experiment_key = '", experiment_key, "'
                                                and ds between '", analysis_start_date, "' and '", analysis_end_date, "') h on r.unique_id = h.unique_id
                                        left join (select ds
                                                        , unique_id
                                                        , case when locale in ('en_US', 'en_CA', 'en_UK', 'en_AU', 'de', 'it', 'fr', 'es', 'fr_CH', 'it_CH', 'de_CH')
                                                                    then locale
                                                                    else 'Other' end                                                                    as locale
                                                        , case when user_id is not null then true else false end                                        as member_logged_in
                                                        , case when os_type in ('windows', 'osx', 'linux', 'ipad_browser', 'android_tablet_browser')
                                                                   then 'Desktop & Tablet Web'
                                                               when os_type in ('iphone_browser', 'android_browser', 'other_phone')
                                                                   then 'Mobile Web'
                                                               when os_type in ('iphone_native_app', 'ipad_native_app', 'android_native_app', 'android_tablet_native_app')
                                                                   then 'Native App'
                                                                   else 'Other' end                                                                      as device
                                                        , case when mcid_channel in
                                                                    ('Other Campaigns', 'InDirect', 'Partnerships', 'Syndication', 'Social', 'Email',
                                                                     'Other', 'Push') or mcid_channel is null
                                                                   then 'Other'
                                                                   else mcid_channel end                                                                 as traffic_source
                                                        , first_page_name                                                  
                                                    from <db>.<schema>.<unique_users_table> auu
                                                      left join <db>.<schema>.<marketing_channel_table> c
                                                          on auu.marketing_campaign_id = c.mcid
                                                    where ds between '", analysis_start_date, "' and '", analysis_end_date, "') u on h.unique_id = u.unique_id and h.ds = u.ds
                                    where r.experiment_key = '", experiment_key, "'
                                      and r.ds = '", analysis_end_date, "'
                                    group by 1, 2, 3, 4, 5
                                   "))

  names(df_sf) <- tolower(names(df_sf))
  df_sf$metric_count <- as.numeric(df_sf$metric_count)
  df_sf$metric_id <- as.numeric(df_sf$metric_id)
  return(df_sf) 
}
                                    
