# r-shiny-ab-testing-segmentation

This tool is built in R Shiny to provide a user-friendly interface for segmenting and analyzing A/B test results, to support data-driven decisions for product changes.

It provides an interactive interface to select various metrics, experiment keys, and segments for comparison. The app automatically performs t-tests between selected variants and segments and displays the results in both tables and plots.

## Key Features:
- **Experiment Key Selection**: Choose the A/B test experiment key.
- **Metric Selection**: Select multiple metrics for the segmentation analysis.
- **Segment Selection**: Choose a segment (e.g., device, locale) for breaking down the results.
- **Statistical Analysis**: Run t-tests to compare performance across selected variants and segments.
- **Result Visualization**: Display results in a table and plot them interactively using highcharts.
