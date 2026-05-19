# Interactive Flow Accumulation Comparison

Creates an interactive Shiny app to compare flow accumulation with its
log-transformed version. Allows toggling layers on/off and adjusting
opacity for better visual comparison. This function requires
pre-calculated geomorphology metrics from
[`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md).

## Usage

``` r
plot_flow_acc(dtm, metrics)
```

## Arguments

- dtm:

  A SpatRaster object (from terra package) representing the Digital
  Elevation Model

- metrics:

  A list object returned from
  [`calc_geomorph_metrics()`](https://lenaelu.github.io/Rkeyline/reference/calc_geomorph_metrics.md).
  This parameter is required.

## Value

Launches a Shiny app for interactive visualization. No return value.

## Examples

``` r
if (FALSE) { # \dontrun{
dtm <- rast("path/to/your/dtm.tif")

# Calculate metrics first
metrics <- calc_geomorph_metrics(dtm)

# Launch interactive comparison
plot_flow_acc(dtm, metrics = metrics)
} # }
```
