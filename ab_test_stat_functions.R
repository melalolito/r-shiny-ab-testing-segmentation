# Calculate aggregated variance for continuous metrics
agg_var <- function(data) {
  
  x_sum <- as.numeric(data$metric_sum)
  x_count <- as.numeric(data$metric_count)
  x_var <- as.numeric(data$metric_var)
  sqn <- x_sum^2 / x_count
  ss <- x_var * (x_count - 1)
  agg_var <- (sum(ss) + sum(sqn) - (sum(x_sum)^2 / sum(x_count))) / (sum(x_count) - 1)
  
  return(agg_var)
}

# Two tailed t-test 
ttest <- function(a, b, metric_id, metric_config) {

  # Calculate the total sample size (denominator) and sum of metric (numerator) for both groups A and B
  a_n <- sum(a$metric_count)
  b_n <- sum(b$metric_count)
  a_x <- sum(a$metric_sum)
  b_x <- sum(b$metric_sum)

  # Calculate means for both groups and the relative difference
  a_mean <- a_x / a_n
  b_mean <- b_x / b_n
  mean_diff <- b_mean / a_mean - 1
  
  if (metric_config$data_type == 'cont') { # For continuous metrics, calculate variance using the agg_var function
    a_var <- agg_var(a)
    b_var <- agg_var(b)
  } else if (metric_config$data_type == 'prop') { # For proportional metrics, use the formula for variance of proportions
    a_var <- a_mean * (1 - a_mean)
    b_var <- b_mean * (1 - b_mean)
  }

  # Calculate normalized variances (variance per sample size)
  a_var_n <- a_var / a_n
  b_var_n <- b_var / b_n
  Z <- qnorm(1 - (1 - metric_config$metric_sig) / metric_config$test_tails)   # Z-score calculation for confidence interval (CI) using the significance level from the metric config

  # Calculate the confidence interval for the mean difference
  ci <- (Z * sqrt(a_var_n + b_var_n)) / a_mean
  ci_lower <- mean_diff - ci
  ci_upper <- mean_diff + ci
  significant <- ci_lower > 0 | ci_upper < 0

  t <- (a_mean - b_mean) / sqrt((((a_n - 1) * a_var + (b_n - 1) * b_var) / (a_n + b_n - 2)) * (1 / a_n + 1 / b_n))
  P <- 2 * (1 - pnorm(abs(t))) * metric_config$test_tails
  
  results <- data.frame(denominator_a = a_n,
                        numerator_a = a_x,
                        mean_a = a_mean,
                        var_mean_a = a_var_n,
                        denominator_b = b_n,
                        numerator_b = b_x,
                        mean_b = b_mean,
                        var_mean_b = b_var_n,
                        mean_diff = mean_diff,
                        ci = ci,
                        ci_lower = ci_lower,
                        ci_upper = ci_upper,
                        significant = as.logical(significant),
                        significance_level = metric_config$metric_sig,
                        tails = metric_config$test_tails,
                        p_value = P,
                        metric_id = metric_id,
                        metric_name = metric_config$metric_name
  )
  
  return(results)
}
